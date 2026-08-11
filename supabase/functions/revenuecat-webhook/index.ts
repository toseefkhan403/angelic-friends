// Receives RevenueCat webhook events and is the *only* writer of
// `public.sponsorships` rows — the Flutter client can no longer insert them
// directly (see the RLS migration in the same batch as this function).
//
// Auth: RevenueCat is configured to echo back a static shared secret in the
// `Authorization` header on every request (set via the webhook integration's
// `authorization_header` field in the RevenueCat dashboard/API). We compare
// it against the REVENUECAT_WEBHOOK_SECRET env var, which must be set with
// `supabase secrets set REVENUECAT_WEBHOOK_SECRET=<value> --project-ref sfuclalozufdtiatcrwz`
// (no MCP tool exists to set edge function secrets, so this is a manual step).
//
// Event coverage:
// - Grants/keeps a sponsorship active: INITIAL_PURCHASE, RENEWAL,
//   UNCANCELLATION, PRODUCT_CHANGE.
// - Revokes access: EXPIRATION, BILLING_ISSUE. CANCELLATION is deliberately
//   NOT treated as a revoke — it only means auto-renew was turned off, the
//   subscriber still has access until the period actually expires (which
//   RevenueCat then reports as EXPIRATION).
// - Everything else (TEST, paywall analytics events, etc.) is acknowledged
//   with 200 and ignored.
import { createClient } from 'jsr:@supabase/supabase-js@2';

const WEBHOOK_SECRET = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const GRANT_EVENTS = new Set(['INITIAL_PURCHASE', 'RENEWAL', 'UNCANCELLATION', 'PRODUCT_CHANGE']);
const REVOKE_EVENTS = new Set(['EXPIRATION', 'BILLING_ISSUE']);

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
  const type = event?.type as string | undefined;
  const appUserId = event?.app_user_id as string | undefined;
  const productId = event?.product_id as string | undefined;

  if (!type || !appUserId || !productId) {
    console.log('Ignoring event with missing fields', { type, appUserId, productId });
    return new Response('ok', { status: 200 });
  }

  if (!GRANT_EVENTS.has(type) && !REVOKE_EVENTS.has(type)) {
    return new Response('ok', { status: 200 });
  }

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: dogs, error: dogsError } = await supabase
    .from('dogs')
    .select('id, silver_product_id, gold_product_id');

  if (dogsError) {
    console.error('Failed to load dogs', dogsError);
    return new Response('ok', { status: 200 });
  }

  const dog = dogs?.find(
    (d) => d.silver_product_id === productId || d.gold_product_id === productId,
  );
  if (!dog) {
    console.log('No dog matches product_id', productId);
    return new Response('ok', { status: 200 });
  }

  const tier = dog.silver_product_id === productId ? 'silver' : 'gold';

  if (GRANT_EVENTS.has(type)) {
    const { error } = await supabase
      .from('sponsorships')
      .upsert(
        { user_id: appUserId, dog_id: dog.id, tier, status: 'active' },
        { onConflict: 'user_id,dog_id' },
      );
    if (error) console.error(`Failed to upsert sponsorship for ${type}`, error);
  } else {
    const { error } = await supabase
      .from('sponsorships')
      .update({ status: 'cancelled' })
      .eq('user_id', appUserId)
      .eq('dog_id', dog.id);
    if (error) console.error(`Failed to cancel sponsorship for ${type}`, error);
  }

  return new Response('ok', { status: 200 });
});
