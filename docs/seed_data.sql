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
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/onboarding/hero.png'),
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
insert into public.shelters (id, name, location, logo_url, distance_km, maps_url, instagram_url) values
  ('11111111-1111-1111-1111-111111111111',
   'Zariya Dog Sanctuary',
   'Delhi, India',
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/shelters/zariya-logo.jpg',
   null,
   'https://www.google.com/maps/place/Zariya+Dog+Sanctuary/@28.5206438,77.3454185,17z/data=!3m1!4b1!4m6!3m5!1s0x390ce7d2143015b7:0x67a942b459600dfc!8m2!3d28.5206438!4d77.3479934!16s%2Fg%2F11lcj0xymc?entry=ttu&g_ep=EgoyMDI2MDgyMy4wIKXMDSoASAFQAw%3D%3D',
   'https://www.instagram.com/zariya_dog_sanctuary/')
on conflict (id) do update set
  name = excluded.name,
  location = excluded.location,
  logo_url = excluded.logo_url,
  distance_km = excluded.distance_km,
  maps_url = excluded.maps_url,
  instagram_url = excluded.instagram_url;

-- ============================================================
-- dogs
-- ============================================================
insert into public.dogs (
  id, name, breed, age_months, image_url, story, care_tag, personality_tags,
  status, sort_order, sex, shelter_id
) values
  ('a25708d0-41d2-4c42-bc93-f9a8fd6b7a95',
   'Barnaby', 'Golden Mix', 144,
   'https://images.unsplash.com/photo-1517849845537-4d257902861a',
   'Barnaby loves slow walks and endless cuddles. His arthritis means he needs a little extra help with joint supplements and a soft orthopedic bed.',
   'Senior Care', array['Gentle Giant', 'Loves Naps'],
   'long_term_resident', 0, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('88903098-0722-4ffe-b388-7d9ae116545d',
   'Pip', 'Terrier Mix', 48,
   'https://images.unsplash.com/photo-1552053831-71594a27632d',
   'Pip doesn''t let his back legs slow him down! He needs sponsors to help maintain his custom wheels and twice-weekly hydrotherapy sessions.',
   'Wheels Needed', array['Speedy', 'Determined'],
   'active_rehab', 1, 'female',
   '11111111-1111-1111-1111-111111111111'),
  ('71fb238d-ec55-4e39-8faf-a9f32527ac77',
   'Pugsy', 'Pug', 168,
   'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
   'Pugsy is enjoying his golden days in comfort. Sponsorship helps cover his specialized soft-food diet and daily comfort care.',
   'Hospice Care', array['Snuggle Bug', 'Quiet'],
   'long_term_resident', 2, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('73eda24d-87be-405a-9852-5d576119f1d5',
   'Titli', 'Indie Mix', 144,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/titli-2.png',
   'Titli spent most of her life fending for herself on the streets before she found safety with us. Now in her golden years, she''s calm, watchful, and endlessly gentle — she just needs a soft bed, joint support, and someone patient enough to let her set the pace on her evening walks.',
   'Senior Care', array[]::text[],
   'long_term_resident', 3, 'female',
   '11111111-1111-1111-1111-111111111111'),
  ('b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60',
   'Wobble', 'Indie Mix', 108,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/wobble.png',
   E'Wobble lost his hind leg to an injury that went untreated for too long before he found his way to us, but at nine years old he still greets every visitor with a full-body wag and leans into any hand that reaches for him. He''s learned to get around on three legs, but it takes a toll on his aging joints and spine. A custom set of wheels will take that strain off him and let him move the way he wants to — steady, and without pain.',
   'Wheels Needed', array['Affectionate', 'Resilient'],
   'active_rehab', 4, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81',
   'Jaydee', 'Indie Mix', 72,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jaydee-1.png',
   E'Jaydee spent years fending for himself on the street before he found his way to us, and it never dulled his spirit one bit. At six years old he''s all bounce and mischief — tail wagging, tongue out, always looking for a game of chase or a toy to steal. He''s in great health and doesn''t need any special care, just someone with the energy to keep up with him and the patience to let a former stray learn what it feels like to be truly safe.',
   null, array['Playful', 'Energetic'],
   'newly_arrived', 5, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('d9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93',
   'Mareez', 'Indie Mix', 144,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/mareez.png',
   E'Mareez earned his name on the street, where he was found weak and unwell with nobody to look out for him. Years of care later, he''s a calm, dignified old soul who watches the world go by from wherever the sun happens to be warmest. At twelve, his needs are simple but constant — joint support, softer food, and regular checkups to keep him comfortable through his golden years.',
   'Senior Care', array['Calm', 'Gentle Soul'],
   'long_term_resident', 6, 'male',
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
  sort_order = excluded.sort_order,
  sex = excluded.sex,
  shelter_id = excluded.shelter_id;
-- monthly_funding_goal defaults to 30 for every dog; set it explicitly here
-- (or with a follow-up update) if a dog needs a different monthly goal.

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
  '71fb238d-ec55-4e39-8faf-a9f32527ac77',
  'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81'
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
  ('71fb238d-ec55-4e39-8faf-a9f32527ac77', 'image', 'https://images.unsplash.com/photo-1552053831-71594a27632d', null, 2, null),
  ('c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jaydee-1.png', null, 0, null),
  ('c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jaydee-2.png', null, 1, null);

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
  '71fb238d-ec55-4e39-8faf-a9f32527ac77',
  '73eda24d-87be-405a-9852-5d576119f1d5',
  'b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60',
  'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81',
  'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93'
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
  ('a1000000-0000-0000-0000-000000000009', '71fb238d-ec55-4e39-8faf-a9f32527ac77', 'coffee', 'Funds his prescription weight-management diet.', 3),
  ('a1000000-0000-0000-0000-000000000010', '73eda24d-87be-405a-9852-5d576119f1d5', 'heart', 'Funds monthly grooming and flea/tick prevention.', 1),
  ('a1000000-0000-0000-0000-000000000011', '73eda24d-87be-405a-9852-5d576119f1d5', 'zap', 'Covers daily enrichment toys and playtime.', 2),
  ('a1000000-0000-0000-0000-000000000012', '73eda24d-87be-405a-9852-5d576119f1d5', 'shield', 'Provides vaccinations and routine vet checkups.', 3),
  ('a1000000-0000-0000-0000-000000000013', 'b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60', 'zap', 'Funds his custom set of wheels for mobility.', 1),
  ('a1000000-0000-0000-0000-000000000014', 'b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60', 'plusCircle', 'Provides joint supplements and regular checkups.', 2),
  ('a1000000-0000-0000-0000-000000000015', 'b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60', 'moon', 'Ensures he has a comfortable orthopedic bed.', 3),
  ('a1000000-0000-0000-0000-000000000016', 'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'shield', 'Covers vaccinations and a full vet checkup.', 1),
  ('a1000000-0000-0000-0000-000000000017', 'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'coffee', 'Funds his daily meals.', 2),
  ('a1000000-0000-0000-0000-000000000018', 'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'zap', 'Provides toys and playtime to match his energy.', 3),
  ('a1000000-0000-0000-0000-000000000019', 'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93', 'plusCircle', 'Provides monthly joint supplements and senior wellness checks.', 1),
  ('a1000000-0000-0000-0000-000000000020', 'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93', 'coffee', 'Covers his soft-food senior diet.', 2),
  ('a1000000-0000-0000-0000-000000000021', 'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93', 'moon', 'Ensures he always has a warm, comfortable bed.', 3);
