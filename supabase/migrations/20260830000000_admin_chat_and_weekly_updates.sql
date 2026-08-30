-- Admin tooling: lets the developer's own account (flagged via
-- auth.jwt() app_metadata.is_admin) reply to any sponsor's chat thread as
-- the "handler", and broadcast one weekly video update per dog into every
-- eligible active sponsor's thread.

-- ── is_admin(): the single authorization check every new policy/RPC uses ──
create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean,
    false
  );
$$;

comment on function public.is_admin() is
  'True iff the calling JWT carries app_metadata.is_admin = true. '
  'app_metadata (not user_metadata) is used because it is not client-writable. '
  'Used directly in RLS policies and admin-only RPCs/views -- no service-role '
  'admin API, no Edge Function, consistent with this app''s direct-RLS pattern.';

grant execute on function public.is_admin() to authenticated;

-- ── dogs: track when the last weekly video update was broadcast ──
alter table public.dogs
  add column last_weekly_update_sent_at timestamptz;

comment on column public.dogs.last_weekly_update_sent_at is
  'Set by send_weekly_update() each time an admin broadcasts a weekly video '
  'to this dog''s eligible sponsors. Null = never sent.';

-- ── sponsorships: admin can see every sponsorship, not just their own ──
create policy "Admins can view all sponsorships"
on public.sponsorships
for select
to authenticated
using (public.is_admin());

-- ── messages: admin can see every thread and reply as the handler ──
create policy "Admins can view all messages"
on public.messages
for select
to authenticated
using (public.is_admin());

create policy "Admins can send handler messages"
on public.messages
for insert
to authenticated
with check (sender_type = 'handler' and public.is_admin());

-- ── admin_sponsorship_overview: angel name + thread activity per sponsorship ──
-- A view (not a table) so it can read auth.users (definer-owned, no
-- security_invoker) without granting authenticated broad access to that
-- schema. Its own "where public.is_admin()" means a non-admin querying it
-- gets zero rows even though SELECT is granted broadly.
create or replace view public.admin_sponsorship_overview
with (security_invoker = false)
as
select
  s.id as sponsorship_id,
  s.dog_id,
  d.name as dog_name,
  s.user_id,
  coalesce(
    u.raw_user_meta_data ->> 'display_name',
    u.raw_user_meta_data ->> 'full_name',
    u.email,
    'Angel'
  ) as angel_name,
  s.credits,
  s.status,
  s.started_at,
  (
    select max(m.created_at) from public.messages m
    where m.sponsorship_id = s.id
  ) as last_message_at,
  (
    select max(m.created_at) from public.messages m
    where m.sponsorship_id = s.id and m.sender_type = 'user'
  ) as last_user_message_at
from public.sponsorships s
join public.dogs d on d.id = s.dog_id
join auth.users u on u.id = s.user_id
where public.is_admin();

grant select on public.admin_sponsorship_overview to authenticated;

-- ── admin_dog_update_status: which dogs are due for a weekly update ──
create or replace view public.admin_dog_update_status
with (security_invoker = false)
as
select
  d.id as dog_id,
  d.name as dog_name,
  d.last_weekly_update_sent_at,
  (
    select count(*) from public.sponsorships s
    where s.dog_id = d.id and s.status = 'active' and s.credits > 10
  ) as eligible_sponsor_count
from public.dogs d
where public.is_admin();

grant select on public.admin_dog_update_status to authenticated;

-- ── send_weekly_update: broadcast one video message per eligible sponsor ──
create or replace function public.send_weekly_update(
  p_dog_id uuid,
  p_media_url text,
  p_media_thumbnail_url text,
  p_caption text
)
returns integer
language plpgsql
security definer
set search_path = 'public'
as $$
declare
  v_sent_count integer;
begin
  if not public.is_admin() then
    raise exception 'Only an admin can send weekly updates.' using errcode = '42501';
  end if;

  if p_media_url is null or length(trim(p_media_url)) = 0 then
    raise exception 'A video is required for a weekly update.' using errcode = '22023';
  end if;

  if not exists (select 1 from public.dogs where id = p_dog_id) then
    raise exception 'That dog no longer exists.' using errcode = 'P0002';
  end if;

  insert into public.messages (
    sponsorship_id, sender_type, media_type, text, media_url, media_thumbnail_url
  )
  select s.id, 'handler', 'video', p_caption, p_media_url, p_media_thumbnail_url
  from public.sponsorships s
  where s.dog_id = p_dog_id
    and s.status = 'active'
    and s.credits > 10;

  get diagnostics v_sent_count = row_count;

  update public.dogs
  set last_weekly_update_sent_at = now()
  where id = p_dog_id;

  return v_sent_count;
end;
$$;

revoke all on function public.send_weekly_update(uuid, text, text, text) from public;
grant execute on function public.send_weekly_update(uuid, text, text, text) to authenticated;
