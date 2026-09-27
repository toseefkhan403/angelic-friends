-- Supersedes 20260927000000_account_deletion.sql's ban-and-flag approach:
-- on reflection, an immediate real delete is simpler and gives a cleaner
-- guarantee than a ban (no "why can't I sign in with my Google account
-- anymore" support tickets, no worklist to remember to work through).
-- Signing in again afterward naturally creates a brand-new auth.users row
-- with a fresh id, since the old one no longer exists — i.e. a new profile.

drop function if exists public.request_account_deletion();
drop table if exists public.account_deletion_requests;

-- ── delete_my_account(): deletes the signed-in user's app data, then their
-- auth.users row itself. security definer because deleting from auth.users
-- requires access authenticated clients don't have. Reads auth.uid()
-- internally rather than taking a parameter — see pledge_credits() for the
-- same convention.
--
-- Note: deleting sponsorships here removes their credits from the
-- affected dogs' public funded_credits totals (via the existing
-- sync_dog_funded_credits trigger) — a deliberate trade-off of doing a
-- real delete instead of a ban; see EULA.md's pledge-permanence language,
-- which this changes the practical effect of on account deletion.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  delete from public.feeding_fund_pledges where user_id = v_user_id;
  delete from public.angel_subscribers where user_id = v_user_id;
  -- Cascades to public.messages via messages.sponsorship_id's existing
  -- ON DELETE CASCADE.
  delete from public.sponsorships where user_id = v_user_id;
  -- Removing the auth.users row cascades to Supabase's own internal auth
  -- tables (sessions, refresh_tokens, identities), which immediately
  -- revokes every session for this user on every device.
  delete from auth.users where id = v_user_id;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
