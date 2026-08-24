// Receives RevenueCat webhook events and is the *only* writer of
// `public.angel_subscribers` and (indirectly, via status flips)
// `public.sponsorships` rows — the Flutter client can never grant/revoke
// access itself; it can only lock already-paid-for credits onto a dog via
// the `pledge_credits` RPC (see the migration in the same batch as this
// function).
//
// Auth: RevenueCat is configured to echo back a static shared secret in the
// `Authorization` header on every request (set via the webhook integration's
// `authorization_header` field in the RevenueCat dashboard/API). We compare
// it against the REVENUECAT_WEBHOOK_SECRET env var, which must be set with
// `supabase secrets set REVENUECAT_WEBHOOK_SECRET=<value> --project-ref sfuclalozufdtiatcrwz`
// (no MCP tool exists to set edge function secrets, so this is a manual step).
//
// Product model: there is now exactly ONE subscription family ("Become an
// Angel"), with 3 fixed monthly tiers mapped to a flat credit grant below —
// no more per-dog products, so there's no dog to resolve here at all. Which
// dog(s) a user supports is decided entirely client-side afterward via
// `pledge_credits`.
//
// Event coverage:
// - INITIAL_PURCHASE / UNCANCELLATION: (re)activate the subscriber at the
//   purchased tier, granting that tier's credits as their starting balance.
// - RENEWAL: adds this cycle's credits on top of any rollover balance —
//   this is what makes unspent credits accumulate month to month.
// - PRODUCT_CHANGE: updates the tier for future renewals only. Deliberately
//   does NOT grant/adjust available_credits immediately — an upgrade or
//   downgrade takes effect at the next renewal, not the moment it's chosen.
//   (The product spec doesn't say what should happen mid-cycle; this is a
//   documented assumption, not a spec requirement.)
// - EXPIRATION / BILLING_ISSUE: pauses the subscriber AND all of their
//   dog pledges (stops counting toward funding meters / chat access) without
//   losing the pledged credit amounts, which resume automatically on the
//   next grant event for the same user.
// - Everything else (TEST, paywall analytics events, etc.) is acknowledged
//   with 200 and ignored.
//
// Idempotency: RevenueCat can redeliver the same event (e.g. on a timeout),
// and unlike the old per-dog upsert, RENEWAL's credit grant is additive, not
// idempotent on its own — so every event is deduped by `event.id` against
// `processed_webhook_events` before anything else happens.
import { createClient } from 'jsr:@supabase/supabase-js@2';

const WEBHOOK_SECRET = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const GRANT_EVENTS = new Set(['INITIAL_PURCHASE', 'RENEWAL', 'UNCANCELLATION', 'PRODUCT_CHANGE']);
const REVOKE_EVENTS = new Set(['EXPIRATION', 'BILLING_ISSUE']);

// product_id -> credits/month granted at that tier ($1 = 1 credit).
const TIER_CREDITS: Record<string, number> = {
  sponsor_angel_10_monthly: 10,
  sponsor_angel_20_monthly: 20,
  sponsor_angel_50_monthly: 50,
};

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const authHeader = req.headers.get('authorization');
  if (!WEBHOOK_SECRET || authHeader !== WEBHOOK_SECRET) {
    return new Response('Unauthorized', { status: 401 });
  }

  let payload: { event?: Record<string, unknown> };
  try {
    payload = await req.json();
  } catch {
    // Malformed body isn't something a retry will fix — ack so RevenueCat
    // stops resending it.
    return new Response('ok', { status: 200 });
  }

  const event = payload.event;
  const eventId = event?.id as string | undefined;
  const type = event?.type as string | undefined;
  const appUserId = event?.app_user_id as string | undefined;
  const productId = event?.product_id as string | undefined;

  if (!eventId || !type || !appUserId || !productId) {
    console.log('Ignoring event with missing fields', { eventId, type, appUserId, productId });
    return new Response('ok', { status: 200 });
  }

  if (!GRANT_EVENTS.has(type) && !REVOKE_EVENTS.has(type)) {
    return new Response('ok', { status: 200 });
  }

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // Dedup gate: if this event.id has already been processed, this is a
  // RevenueCat redelivery — ack without reapplying anything.
  const { error: dedupError } = await supabase
    .from('processed_webhook_events')
    .insert({ event_id: eventId });
  if (dedupError) {
    if (dedupError.code === '23505') {
      console.log('Duplicate event, skipping', eventId);
      return new Response('ok', { status: 200 });
    }
    console.error('Failed to record processed event', dedupError);
    return new Response('ok', { status: 200 });
  }

  const tierCredits = TIER_CREDITS[productId];
  if (tierCredits === undefined) {
    console.log('Unknown product_id, ignoring', productId);
    return new Response('ok', { status: 200 });
  }

  if (type === 'INITIAL_PURCHASE' || type === 'UNCANCELLATION') {
    const { error } = await supabase.from('angel_subscribers').upsert(
      {
        user_id: appUserId,
        monthly_credits: tierCredits,
        available_credits: tierCredits,
        status: 'active',
        revenuecat_product_id: productId,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' },
    );
    if (error) console.error(`Failed to upsert angel_subscribers for ${type}`, error);

    const { error: resumeError } = await supabase
      .from('sponsorships')
      .update({ status: 'active' })
      .eq('user_id', appUserId);
    if (resumeError) console.error('Failed to resume sponsorships', resumeError);
  } else if (type === 'RENEWAL') {
    const { data: existing, error: fetchError } = await supabase
      .from('angel_subscribers')
      .select('available_credits')
      .eq('user_id', appUserId)
      .maybeSingle();
    if (fetchError) {
      console.error('Failed to load angel_subscribers for renewal', fetchError);
    } else if (!existing) {
      // Defensive: a renewal for a subscriber we've never granted before
      // shouldn't happen, but don't drop their credits if it does.
      const { error } = await supabase.from('angel_subscribers').insert({
        user_id: appUserId,
        monthly_credits: tierCredits,
        available_credits: tierCredits,
        status: 'active',
        revenuecat_product_id: productId,
      });
      if (error) console.error('Failed to insert angel_subscribers on renewal fallback', error);
    } else {
      const { error } = await supabase
        .from('angel_subscribers')
        .update({
          available_credits: existing.available_credits + tierCredits,
          monthly_credits: tierCredits,
          status: 'active',
          revenuecat_product_id: productId,
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', appUserId);
      if (error) console.error('Failed to grant renewal credits', error);
    }

    const { error: resumeError } = await supabase
      .from('sponsorships')
      .update({ status: 'active' })
      .eq('user_id', appUserId);
    if (resumeError) console.error('Failed to resume sponsorships', resumeError);
  } else if (type === 'PRODUCT_CHANGE') {
    // Tier change takes effect at the next renewal — never touches
    // available_credits here (see file header comment).
    const { error } = await supabase
      .from('angel_subscribers')
      .update({
        monthly_credits: tierCredits,
        revenuecat_product_id: productId,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', appUserId);
    if (error) console.error('Failed to record product change', error);
  } else if (REVOKE_EVENTS.has(type)) {
    const { error } = await supabase
      .from('angel_subscribers')
      .update({ status: 'cancelled', updated_at: new Date().toISOString() })
      .eq('user_id', appUserId);
    if (error) console.error(`Failed to cancel angel_subscribers for ${type}`, error);

    const { error: pauseError } = await supabase
      .from('sponsorships')
      .update({ status: 'cancelled' })
      .eq('user_id', appUserId);
    if (pauseError) console.error('Failed to pause sponsorships', pauseError);
  }

  return new Response('ok', { status: 200 });
});
