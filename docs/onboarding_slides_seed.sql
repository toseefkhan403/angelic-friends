-- Reference copy of the schema + seed applied live via the Supabase MCP
-- connection on 2026-08-08. Kept here for reproducing in another
-- environment (e.g. a staging project) — not something you need to run
-- against the current project, it's already been applied.

create table if not exists public.onboarding_slides (
  id uuid primary key default gen_random_uuid(),
  sort_order int not null,
  title text not null,
  subtitle text not null,
  image_url text not null,
  created_at timestamptz not null default now()
);

alter table public.onboarding_slides enable row level security;

create policy "Onboarding slides are publicly readable"
on public.onboarding_slides
for select
to anon, authenticated
using (true);

-- Note the E'' prefix: a plain '...' literal would insert a literal
-- backslash-n rather than a real newline.
insert into public.onboarding_slides (sort_order, title, subtitle, image_url) values
  (1,
   E'Real dogs.\nReal rehab.',
   'Meet shelter dogs recovering from paralysis, getting a second chance at a full life.',
   'https://images.unsplash.com/photo-1517849845537-4d257902861a'),
  (2,
   E'Sponsor.\nWatch them thrive.',
   'Your monthly support funds real care — and brings real updates straight from their handler.',
   'https://images.unsplash.com/photo-1552053831-71594a27632d'),
  (3,
   E'Ready to be\nsomeone''s angel?',
   'Meet the dogs waiting for you.',
   'https://images.unsplash.com/photo-1543466835-00a7907e9de1');
