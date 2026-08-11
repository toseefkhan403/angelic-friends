-- Full seed script for the Angelic Friends / sponsor_a_dog Supabase project.
-- Safe to re-run: every insert upserts on its fixed id, so running this
-- against a fresh project bootstraps it, and running it again just resets
-- these rows back to this state without duplicating anything.
--
-- Run in the Supabase SQL Editor, or via the MCP/CLI execute_sql tooling.
-- Assumes the schema from docs/PRODUCT_SPEC.md + the onboarding_slides /
-- shelters / sponsorship_impacts migrations already exists (this script
-- only inserts rows, it doesn't create tables).

-- ============================================================
-- onboarding_slides
-- Four distinct slide_type templates (see OnboardingSlideView) rather than
-- one generic image/title/subtitle shape. Fully owned by this script, so
-- reset via delete + insert rather than upsert-by-id, since ids aren't
-- referenced anywhere else and the slide set is redesigned wholesale here.
-- ============================================================
delete from public.onboarding_slides;

insert into public.onboarding_slides (sort_order, slide_type, eyebrow, title, subtitle, image_url) values
  (0, 'hero', null,
   E'Give a shelter dog\nthe family they never had.',
   'Your support means real care, real comfort, and real joy — video updates straight from their handler.',
   'https://images.unsplash.com/photo-1517849845537-4d257902861a'),
  (1, 'who_these_dogs', 'Who these dogs are',
   E'The ones who couldn''t be adopted.\nThe ones who need you most.',
   'We only list dogs in long-term rehab — seniors, paralysis, amputees. The ones shelters struggle to place at all.',
   null),
  (2, 'letter', 'A letter of love',
   E'From kennel to your inbox\nin 4 easy steps.',
   'Here''s how it works, step by step.',
   null),
  (3, 'marquee_name_capture', 'Real dogs, real rehab',
   E'Ready to be someone''s\nangelic friend?',
   'What should we call you?',
   null);

-- ============================================================
-- shelters
-- ============================================================
insert into public.shelters (id, name, location, logo_url, distance_km, maps_url) values
  ('11111111-1111-1111-1111-111111111111',
   'Second Chance Animal Sanctuary',
   'Portland, OR',
   'https://images.unsplash.com/photo-1601758228041-f3b2795255f1',
   3.2,
   'https://www.google.com/maps/search/?api=1&query=Second+Chance+Animal+Sanctuary,+Portland,+OR')
on conflict (id) do update set
  name = excluded.name,
  location = excluded.location,
  logo_url = excluded.logo_url,
  distance_km = excluded.distance_km,
  maps_url = excluded.maps_url;

-- ============================================================
-- dogs
-- ============================================================
insert into public.dogs (
  id, name, breed, age_months, image_url, story, care_tag, personality_tags,
  status, silver_price, gold_price, silver_product_id, gold_product_id, sort_order, sex, shelter_id
) values
  ('a25708d0-41d2-4c42-bc93-f9a8fd6b7a95',
   'Barnaby', 'Golden Mix', 144,
   'https://images.unsplash.com/photo-1517849845537-4d257902861a',
   'Barnaby loves slow walks and endless cuddles. His arthritis means he needs a little extra help with joint supplements and a soft orthopedic bed.',
   'Senior Care', array['Gentle Giant', 'Loves Naps'],
   'long_term_resident', 12, 20, 'sponsor_barnaby_silver_monthly', 'sponsor_barnaby_gold_monthly', 0, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('88903098-0722-4ffe-b388-7d9ae116545d',
   'Pip', 'Terrier Mix', 48,
   'https://images.unsplash.com/photo-1552053831-71594a27632d',
   'Pip doesn''t let his back legs slow him down! He needs sponsors to help maintain his custom wheels and twice-weekly hydrotherapy sessions.',
   'Wheels Needed', array['Speedy', 'Determined'],
   'active_rehab', 15, 25, 'sponsor_pip_silver_monthly', 'sponsor_pip_gold_monthly', 1, 'female',
   '11111111-1111-1111-1111-111111111111'),
  ('71fb238d-ec55-4e39-8faf-a9f32527ac77',
   'Pugsy', 'Pug', 168,
   'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
   'Pugsy is enjoying his golden days in comfort. Sponsorship helps cover his specialized soft-food diet and daily comfort care.',
   'Hospice Care', array['Snuggle Bug', 'Quiet'],
   'long_term_resident', 10, 18, 'sponsor_pugsy_silver_monthly', 'sponsor_pugsy_gold_monthly', 2, 'male',
   '11111111-1111-1111-1111-111111111111')
on conflict (id) do update set
  name = excluded.name,
  breed = excluded.breed,
  age_months = excluded.age_months,
  image_url = excluded.image_url,
  story = excluded.story,
  care_tag = excluded.care_tag,
  personality_tags = excluded.personality_tags,
  status = excluded.status,
  silver_price = excluded.silver_price,
  gold_price = excluded.gold_price,
  silver_product_id = excluded.silver_product_id,
  gold_product_id = excluded.gold_product_id,
  sort_order = excluded.sort_order,
  sex = excluded.sex,
  shelter_id = excluded.shelter_id;

-- ============================================================
-- dog_media (photo/video gallery for Dog Detail + onboarding highlights)
-- Fully owned by this script, so reset via delete-then-insert like
-- sponsorship_impacts rather than upsert-by-id.
--
-- `caption` is set on exactly one row per dog — those are the rows that
-- feed onboarding's "letter" and update-marquee slides (see
-- DogRepository.getFeaturedDogUpdates, which selects `caption is not null`).
-- Barnaby's video is a placeholder test upload (unrelated footage) — swap
-- for a real handler video before shipping; captions are sample copy too,
-- per the "dogs info is sample right now" call.
-- ============================================================
delete from public.dog_media
where dog_id in (
  'a25708d0-41d2-4c42-bc93-f9a8fd6b7a95',
  '88903098-0722-4ffe-b388-7d9ae116545d',
  '71fb238d-ec55-4e39-8faf-a9f32527ac77'
);

insert into public.dog_media (dog_id, media_type, url, thumbnail_url, sort_order, caption) values
  ('a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'image', 'https://images.unsplash.com/photo-1517849845537-4d257902861a', null, 0, null),
  ('a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'image', 'https://images.unsplash.com/photo-1552053831-71594a27632d', null, 1, null),
  ('a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'image', 'https://images.unsplash.com/photo-1543466835-00a7907e9de1', null, 2, null),
  ('a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'video', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/barnaby/crazy.mp4', 'https://images.unsplash.com/photo-1517849845537-4d257902861a', 3,
   'Barnaby napped in the sun for two hours straight. He earned it.'),
  ('88903098-0722-4ffe-b388-7d9ae116545d', 'image', 'https://images.unsplash.com/photo-1552053831-71594a27632d', null, 0, null),
  ('88903098-0722-4ffe-b388-7d9ae116545d', 'image', 'https://images.unsplash.com/photo-1543466835-00a7907e9de1', null, 1, null),
  ('88903098-0722-4ffe-b388-7d9ae116545d', 'image', 'https://images.unsplash.com/photo-1517849845537-4d257902861a', null, 2, null),
  ('88903098-0722-4ffe-b388-7d9ae116545d', 'video', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 'https://images.unsplash.com/photo-1552053831-71594a27632d', 3,
   'Pip took ten extra minutes on his walk today. He didn''t want it to end.'),
  ('71fb238d-ec55-4e39-8faf-a9f32527ac77', 'image', 'https://images.unsplash.com/photo-1543466835-00a7907e9de1', null, 0,
   'Pugsy finished his whole dinner tonight. First time all week.'),
  ('71fb238d-ec55-4e39-8faf-a9f32527ac77', 'image', 'https://images.unsplash.com/photo-1517849845537-4d257902861a', null, 1, null),
  ('71fb238d-ec55-4e39-8faf-a9f32527ac77', 'image', 'https://images.unsplash.com/photo-1552053831-71594a27632d', null, 2, null);

-- ============================================================
-- promo_tiles
-- ============================================================
insert into public.promo_tiles (id, title, subtitle, cta_label, insert_after_index, is_active) values
  ('1e8d68df-7379-46b6-9d10-ad9c2f65233c',
   'Large portions',
   'Help us keep the pantry stocked for our big eaters and special diet pups.',
   'I like to eat!', 1, true)
on conflict (id) do update set
  title = excluded.title,
  subtitle = excluded.subtitle,
  cta_label = excluded.cta_label,
  insert_after_index = excluded.insert_after_index,
  is_active = excluded.is_active;

-- ============================================================
-- sponsorship_impacts
-- icon is a string key the Flutter app maps to an actual icon
-- (see the _iconFor switch in dog_detail_page.dart), not a Dart identifier —
-- safe to reuse across dogs and independent of whichever icon package/names
-- the app currently uses.
--
-- This table is fully owned by this script (no other real data lives here),
-- so — unlike the tables above — it's reset via delete-then-insert rather
-- than upsert-by-id: the ids below are fixed for readability, not because
-- they need to match whatever ids already exist in a given database.
-- ============================================================
delete from public.sponsorship_impacts
where dog_id in (
  'a25708d0-41d2-4c42-bc93-f9a8fd6b7a95',
  '88903098-0722-4ffe-b388-7d9ae116545d',
  '71fb238d-ec55-4e39-8faf-a9f32527ac77'
);

insert into public.sponsorship_impacts (id, dog_id, icon, description, sort_order) values
  ('a1000000-0000-0000-0000-000000000001', 'a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'plusCircle', 'Provides monthly joint supplements and senior wellness checks.', 1),
  ('a1000000-0000-0000-0000-000000000002', 'a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'coffee', 'Covers his special soft-food diet.', 2),
  ('a1000000-0000-0000-0000-000000000003', 'a25708d0-41d2-4c42-bc93-f9a8fd6b7a95', 'moon', 'Ensures he always has an orthopedic bed.', 3),
  ('a1000000-0000-0000-0000-000000000004', '88903098-0722-4ffe-b388-7d9ae116545d', 'heart', 'Funds monthly grooming and flea/tick prevention.', 1),
  ('a1000000-0000-0000-0000-000000000005', '88903098-0722-4ffe-b388-7d9ae116545d', 'zap', 'Covers daily enrichment toys and playtime.', 2),
  ('a1000000-0000-0000-0000-000000000006', '88903098-0722-4ffe-b388-7d9ae116545d', 'shield', 'Provides vaccinations and routine vet checkups.', 3),
  ('a1000000-0000-0000-0000-000000000007', '71fb238d-ec55-4e39-8faf-a9f32527ac77', 'plusCircle', 'Covers respiratory checkups common to the breed.', 1),
  ('a1000000-0000-0000-0000-000000000008', '71fb238d-ec55-4e39-8faf-a9f32527ac77', 'moon', 'Provides a cooling bed to ease joint and breathing comfort.', 2),
  ('a1000000-0000-0000-0000-000000000009', '71fb238d-ec55-4e39-8faf-a9f32527ac77', 'coffee', 'Funds his prescription weight-management diet.', 3);
