-- Reference copy of the schema + seed applied live via the Supabase MCP
-- connection on 2026-08-09. Kept here for reproducing in another
-- environment (e.g. a staging project) — not something you need to run
-- against the current project, it's already been applied.
--
-- See docs/DATABASE_SCHEMA.md for column-by-column rationale.

create table if not exists public.dogs (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  breed text not null,
  age_months int not null,
  image_url text not null,
  story text not null,
  care_tag text,
  personality_tags text[] not null default '{}',
  status text not null default 'active_rehab'
    check (status in ('newly_arrived', 'active_rehab', 'long_term_resident')),
  silver_price numeric(10,2) not null,
  gold_price numeric(10,2) not null,
  silver_product_id text,
  gold_product_id text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.dogs enable row level security;

create policy "Dogs are publicly readable"
on public.dogs
for select
to anon, authenticated
using (true);

create table if not exists public.promo_tiles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text not null,
  cta_label text not null,
  insert_after_index int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.promo_tiles enable row level security;

create policy "Promo tiles are publicly readable"
on public.promo_tiles
for select
to anon, authenticated
using (true);

insert into public.dogs (name, breed, age_months, image_url, story, care_tag, personality_tags, status, silver_price, gold_price, sort_order) values
('Barnaby', 'Golden Mix', 144, 'https://images.unsplash.com/photo-1517849845537-4d257902861a',
 'Barnaby loves slow walks and endless cuddles. His arthritis means he needs a little extra help with joint supplements and a soft orthopedic bed.',
 'Senior Care', array['Gentle Giant','Loves Naps'], 'long_term_resident', 12, 20, 0),
('Pip', 'Terrier Mix', 48, 'https://images.unsplash.com/photo-1552053831-71594a27632d',
 E'Pip doesn''t let his back legs slow him down! He needs sponsors to help maintain his custom wheels and twice-weekly hydrotherapy sessions.',
 'Wheels Needed', array['Speedy','Determined'], 'active_rehab', 15, 25, 1),
('Pugsy', 'Pug', 168, 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
 'Pugsy is enjoying his golden days in comfort. Sponsorship helps cover his specialized soft-food diet and daily comfort care.',
 'Hospice Care', array['Snuggle Bug','Quiet'], 'long_term_resident', 10, 18, 2);

insert into public.promo_tiles (title, subtitle, cta_label, insert_after_index) values
('Large portions', 'Help us keep the pantry stocked for our big eaters and special diet pups.', 'I like to eat!', 1);
