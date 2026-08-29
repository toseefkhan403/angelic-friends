-- Photo background support for promo tiles (e.g. the "daily feedings" tile).
alter table public.promo_tiles add column image_url text;

-- Feeding-fund credit pledges: like sponsorships.credits, but not tied to a
-- specific dog — for causes such as daily street-feeding. Pledges are
-- permanent, mirroring the dog-pledge model, and only ever written by the
-- pledge_credits_to_feeding RPC below (never directly by a client).
create table public.feeding_fund_pledges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  credits integer not null check (credits > 0),
  created_at timestamptz not null default now()
);

alter table public.feeding_fund_pledges enable row level security;

create policy "Users can view their own feeding fund pledges"
  on public.feeding_fund_pledges
  for select
  to authenticated
  using (user_id = auth.uid());

-- Locks credits from the caller's Angel balance onto the feeding fund,
-- permanently. Mirrors pledge_credits (see that function's comments for the
-- atomicity/security rationale) minus the dog_id — there's no dog to check
-- or fund-meter trigger to fire.
create or replace function public.pledge_credits_to_feeding(p_credits integer)
returns void
language plpgsql
security definer
set search_path = 'public'
as $$
declare
  v_user_id uuid := auth.uid();
  v_available integer;
  v_status text;
begin
  if v_user_id is null then
    raise exception 'You need to be signed in for that.' using errcode = '28000';
  end if;

  if p_credits is null or p_credits <= 0 then
    raise exception 'Pledge amount must be a positive number of credits.'
      using errcode = '22023';
  end if;

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

  insert into public.feeding_fund_pledges (user_id, credits)
  values (v_user_id, p_credits);
end;
$$;

grant execute on function public.pledge_credits_to_feeding(integer) to authenticated;
