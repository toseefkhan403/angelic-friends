-- Account deletion (Apple App Store Guideline 5.1.1(v) / Play Console
-- account-deletion requirement): a self-service in-app request that takes
-- effect immediately from the user's perspective — they're signed out and
-- can never sign back into this account — even though the actual data
-- (sponsorships, messages, profile) is purged manually afterward rather
-- than by an automated cascade. Apple's rule only requires that requesting
-- deletion actually revokes access; it doesn't mandate immediate erasure.

create table public.account_deletion_requests (
  user_id uuid primary key references auth.users(id) on delete cascade,
  requested_at timestamptz not null default now()
);

comment on table public.account_deletion_requests is
  'One row per user who has requested account deletion via '
  'request_account_deletion(). The account is banned/signed-out immediately '
  'by that function; the rows here are a worklist for manually deleting '
  'the user''s data (sponsorships, messages, profile) afterward. No RLS '
  'policies — only ever read by an admin directly in the SQL editor.';

alter table public.account_deletion_requests enable row level security;
-- Deliberately zero policies: this table is only ever read by an admin
-- directly (SQL editor / service_role), never by any client role.

-- ── request_account_deletion(): flags the request, then immediately
-- revokes access so the account can't be used again, without deleting any
-- data yet. security definer because banning a user and revoking sessions
-- requires write access to the auth schema, which authenticated clients
-- don't have.
create or replace function public.request_account_deletion()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.account_deletion_requests (user_id)
  values (auth.uid())
  on conflict (user_id) do nothing;

  -- Effectively permanent ban — far enough in the future it never expires
  -- in practice, short of manually lifting it.
  update auth.users
  set banned_until = '2999-12-31 00:00:00+00'
  where id = auth.uid();

  -- Kill every existing session/refresh token for this user, on every
  -- device, so a token that's still technically unexpired can't keep
  -- working after the ban takes effect on next refresh.
  delete from auth.refresh_tokens where user_id = auth.uid()::text;
  delete from auth.sessions where user_id = auth.uid();
end;
$$;

revoke all on function public.request_account_deletion() from public, anon;
grant execute on function public.request_account_deletion() to authenticated;
