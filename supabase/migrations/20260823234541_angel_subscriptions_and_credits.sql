-- Replaces per-dog Silver/Gold subscriptions with a single global "Angel"
-- subscription (3 fixed monthly tiers, purchased once) whose credits the
-- user then pledges (permanently) to any dogs they choose. See
-- docs/PRODUCT_SPEC.md for the product rationale.

-- ── dogs: drop per-dog pricing, add funding-goal + denormalized live total ──
alter table public.dogs
  drop column if exists silver_price,
  drop column if exists gold_price,
  drop column if exists silver_product_id,
  drop column if exists gold_product_id;

alter table public.dogs
  add column monthly_funding_goal integer not null default 30
    check (monthly_funding_goal >= 0),
  add column funded_credits integer not null default 0
    check (funded_credits >= 0);

comment on column public.dogs.monthly_funding_goal is
  'Monthly funding goal in credits ($1 = 1 credit). Defaults to 30 for every dog.';
comment on column public.dogs.funded_credits is
  'Denormalized sum of credits from all currently-active sponsorships '
  'pledged to this dog. Kept in sync by trg_sync_dog_funded_credits — '
  'never written directly by clients.';

-- No RLS change needed: both columns are covered by the existing public
-- SELECT policy "Dogs are publicly readable".

-- ── sponsorships: tier -> permanent credit pledge ──
alter table public.sponsorships
  drop constraint if exists sponsorships_tier_check;

alter table public.sponsorships
  drop column if exists tier,
  add column credits integer not null check (credits > 0);

comment on column public.sponsorships.credits is
  'Total credits this user has ever pledged to this dog. Permanent — only '
  'ever increases, via pledge_credits(). status controls whether it '
  'currently counts toward dogs.funded_credits / unlocks chat.';

-- ── keep dogs.funded_credits in sync with active sponsorship credits ──
create or replace function public.sync_dog_funded_credits()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  affected_dog_id uuid := coalesce(new.dog_id, old.dog_id);
begin
  update public.dogs
  set funded_credits = coalesce((
    select sum(credits) from public.sponsorships
    where dog_id = affected_dog_id and status = 'active'
  ), 0)
  where id = affected_dog_id;
  return null;
end;
$$;

drop trigger if exists trg_sync_dog_funded_credits on public.sponsorships;
create trigger trg_sync_dog_funded_credits
after insert or update of credits, status or delete on public.sponsorships
for each row
execute function public.sync_dog_funded_credits();

-- ── angel_subscribers: one row per user, tracks tier + rollover balance ──
create table public.angel_subscribers (
  user_id uuid primary key references auth.users(id) on delete cascade,
  monthly_credits integer not null check (monthly_credits > 0),
  available_credits integer not null default 0 check (available_credits >= 0),
  status text not null default 'active' check (status in ('active', 'cancelled')),
  revenuecat_product_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

comment on table public.angel_subscribers is
  'One row per Angel subscriber. Written exclusively by the '
  'revenuecat-webhook Edge Function (service_role, bypasses RLS) and by '
  'pledge_credits() (security definer). Never written by clients directly.';

alter table public.angel_subscribers enable row level security;

create policy "Users can view their own angel subscription"
on public.angel_subscribers
for select
to authenticated
using (auth.uid() = user_id);

-- No insert/update/delete policy for any client role — mirrors the
-- sponsorships lockdown in 20260811195436_lock_down_sponsorships_writes.sql.

-- ── webhook idempotency: dedup RevenueCat event redelivery ──
create table public.processed_webhook_events (
  event_id text primary key,
  created_at timestamptz not null default now()
);

comment on table public.processed_webhook_events is
  'RevenueCat event.id values already processed by revenuecat-webhook, so '
  'a retried/redelivered webhook cannot double-apply a RENEWAL credit '
  'grant. No RLS — only ever touched by the Edge Function via service_role.';

alter table public.processed_webhook_events enable row level security;
-- Deliberately zero policies: only service_role (which bypasses RLS) ever
-- touches this table.

-- ── pledge_credits: the only way credits move from balance to a dog ──
create or replace function public.pledge_credits(p_dog_id uuid, p_credits integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_available integer;
  v_status text;
begin
  -- v_user_id is read from auth.uid() — the caller's own JWT — and never
  -- accepted as a parameter. Do not "fix" this by adding a p_user_id
  -- parameter; that would let any authenticated user pledge on someone
  -- else's behalf.
  if v_user_id is null then
    raise exception 'You need to be signed in for that.' using errcode = '28000';
  end if;

  if p_credits is null or p_credits <= 0 then
    raise exception 'Pledge amount must be a positive number of credits.'
      using errcode = '22023';
  end if;

  if not exists (select 1 from public.dogs where id = p_dog_id) then
    raise exception 'That dog no longer exists.' using errcode = 'P0002';
  end if;

  -- Lock the caller's balance row first — this single lock is what makes
  -- the whole function atomic w.r.t. concurrent pledges by the same user.
  select available_credits, status into v_available, v_status
  from public.angel_subscribers
  where user_id = v_user_id
  for update;

  if not found then
    raise exception 'You need an active Angel subscription to pledge credits.'
      using errcode = 'P0001';
  end if;

  if v_status <> 'active' then
    raise exception 'Your Angel subscription is not active right now.'
      using errcode = 'P0001';
  end if;

  if p_credits > v_available then
    raise exception 'You only have % credits available.', v_available
      using errcode = 'P0001';
  end if;

  update public.angel_subscribers
  set available_credits = available_credits - p_credits,
      updated_at = now()
  where user_id = v_user_id;

  insert into public.sponsorships (user_id, dog_id, credits, status)
  values (v_user_id, p_dog_id, p_credits, 'active')
  on conflict (user_id, dog_id)
  do update set credits = public.sponsorships.credits + excluded.credits,
                status = 'active';
  -- The AFTER trigger on sponsorships (trg_sync_dog_funded_credits) recomputes
  -- dogs.funded_credits for p_dog_id as part of this same transaction.
end;
$$;

revoke all on function public.pledge_credits(uuid, integer) from public;
grant execute on function public.pledge_credits(uuid, integer) to authenticated;
