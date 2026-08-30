-- Follow-up to 20260830000000: the Supabase linter flags
-- admin_sponsorship_overview/admin_dog_update_status as ERROR-level
-- "security_definer_view" + "auth_users_exposed" -- views execute with the
-- owner's privileges for *any* role with SELECT granted, silently bypassing
-- RLS on the underlying tables (sponsorships/messages/dogs) and exposing
-- auth.users, with only the view's own WHERE clause as a guard. This
-- project also has a default-privileges rule that auto-grants
-- anon/authenticated full CRUD on every new public table/view, which made
-- both views reachable by `anon` regardless of the explicit grants below.
--
-- Converting both to SECURITY DEFINER *functions* (returning a table) fixes
-- this cleanly: functions aren't covered by the "security_definer_view"
-- lint, they explicitly `raise exception` for a non-admin caller instead of
-- silently returning zero rows, and this matches the exact RPC convention
-- already used by pledge_credits/pledge_credits_to_feeding/send_weekly_update
-- in this codebase.

drop view if exists public.admin_sponsorship_overview;
drop view if exists public.admin_dog_update_status;

alter function public.is_admin() set search_path = 'public';

create or replace function public.admin_sponsorship_overview()
returns table (
  sponsorship_id uuid,
  dog_id uuid,
  dog_name text,
  user_id uuid,
  angel_name text,
  credits integer,
  status text,
  started_at timestamptz,
  last_message_at timestamptz,
  last_user_message_at timestamptz
)
language plpgsql
security definer
set search_path = 'public'
as $$
begin
  if not public.is_admin() then
    raise exception 'Only an admin can view this.' using errcode = '42501';
  end if;

  return query
  select
    s.id,
    s.dog_id,
    d.name,
    s.user_id,
    coalesce(
      u.raw_user_meta_data ->> 'display_name',
      u.raw_user_meta_data ->> 'full_name',
      u.email,
      'Angel'
    ),
    s.credits,
    s.status,
    s.started_at,
    (
      select max(m.created_at) from public.messages m
      where m.sponsorship_id = s.id
    ),
    (
      select max(m.created_at) from public.messages m
      where m.sponsorship_id = s.id and m.sender_type = 'user'
    )
  from public.sponsorships s
  join public.dogs d on d.id = s.dog_id
  join auth.users u on u.id = s.user_id;
end;
$$;

revoke all on function public.admin_sponsorship_overview() from public, anon;
grant execute on function public.admin_sponsorship_overview() to authenticated;

create or replace function public.admin_dog_update_status()
returns table (
  dog_id uuid,
  dog_name text,
  last_weekly_update_sent_at timestamptz,
  eligible_sponsor_count bigint
)
language plpgsql
security definer
set search_path = 'public'
as $$
begin
  if not public.is_admin() then
    raise exception 'Only an admin can view this.' using errcode = '42501';
  end if;

  return query
  select
    d.id,
    d.name,
    d.last_weekly_update_sent_at,
    (
      select count(*) from public.sponsorships s
      where s.dog_id = d.id and s.status = 'active' and s.credits > 10
    )
  from public.dogs d;
end;
$$;

revoke all on function public.admin_dog_update_status() from public, anon;
grant execute on function public.admin_dog_update_status() to authenticated;
