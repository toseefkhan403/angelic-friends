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
  ('a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17',
   'Brownie', 'Indie Mix', 96,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/brownie-1.png',
   E'Brownie was hit by a car and left with his back legs crushed, but it hasn''t dimmed his spirit one bit — he still drags himself over for every belly rub and every game with his best friend Rocket. At eight years old, dragging himself around takes a real toll on his body. A custom set of wheels will finally let him move, play, and keep up with Rocket without the pain and strain he faces now.',
   'Wheels Needed', array['Playful', 'Resilient'],
   'active_rehab', 0, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60',
   'Wobble', 'Indie Mix', 108,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/wobble.png',
   E'Wobble lost his hind leg to an injury that went untreated for too long before he found his way to us, but at nine years old he still greets every visitor with a full-body wag and leans into any hand that reaches for him. He''s learned to get around on three legs, but it takes a toll on his aging joints and spine. A custom set of wheels will take that strain off him and let him move the way he wants to — steady, and without pain.',
   'Wheels Needed', array['Affectionate', 'Resilient'],
   'active_rehab', 1, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('73eda24d-87be-405a-9852-5d576119f1d5',
   'Titli', 'Indie Mix', 144,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/titli-2.png',
   'Titli spent most of her life fending for herself on the streets before she found safety with us. Now in her golden years, she''s calm, watchful, and endlessly gentle — she just needs a soft bed, joint support, and someone patient enough to let her set the pace on her evening walks.',
   'Senior Care', array[]::text[],
   'long_term_resident', 2, 'female',
   '11111111-1111-1111-1111-111111111111'),
  ('c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81',
   'Jaydee', 'Indie Mix', 72,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jaydee-1.png',
   E'Jaydee spent years fending for himself on the street before he found his way to us, and it never dulled his spirit one bit. At six years old he''s all bounce and mischief — tail wagging, tongue out, always looking for a game of chase or a toy to steal. He''s in great health and doesn''t need any special care, just someone with the energy to keep up with him and the patience to let a former stray learn what it feels like to be truly safe.',
   null, array['Playful', 'Energetic'],
   'newly_arrived', 3, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('d9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93',
   'Mareez', 'Indie Mix', 144,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/mareez.png',
   E'Mareez earned his name on the street, where he was found weak and unwell with nobody to look out for him. Years of care later, he''s a calm, dignified old soul who watches the world go by from wherever the sun happens to be warmest. At twelve, his needs are simple but constant — joint support, softer food, and regular checkups to keep him comfortable through his golden years.',
   'Senior Care', array['Calm', 'Gentle Soul'],
   'long_term_resident', 4, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14',
   'Chirkut', 'Indie Mix', 96,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/chirkut-1.png',
   E'Chirkut is deaf, but you would never know it from the sheer chaos he brings to the shelter — he is the undisputed naughtiest dog around, always tearing after something, stealing something, or starting a game nobody asked for. At eight years old he has lost none of his mischief, reading the world entirely through his eyes and nose and never missing a beat. He just needs someone patient enough to keep up with him and learn his language.',
   null, array['Mischievous', 'Energetic'],
   'newly_arrived', 5, 'male',
   '11111111-1111-1111-1111-111111111111'),
  ('f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32',
   'Jimmy', 'Indie Mix', 72,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jimmy-1.png',
   E'Jimmy spent years tied up in a household that never once let her off the rope, forgotten in a corner while life went on around her. Now free of the chain, she''s still learning that space and gentleness aren''t going to be taken away again — she watches quietly before she trusts, but when she does, she leans in for every bit of affection she missed out on. At six years old, all she needs is patience and a soft place to finally just be a dog.',
   null, array['Gentle', 'Watchful'],
   'newly_arrived', 6, 'female',
   '11111111-1111-1111-1111-111111111111'),
  ('1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72',
   'Sheela', 'Indie Mix', 144,
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/sheela-2.png',
   E'Sheela is one of our oldest residents, a quiet old soul who has earned every bit of the calm life she has now. At twelve, she moves slowly and rests often, but she still leans into a gentle scratch behind the ears whenever someone stops by. She needs joint support, soft food, and warm bedding to stay comfortable through her senior years.',
   'Senior Care', array[]::text[],
   'long_term_resident', 7, 'female',
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
-- Captions are sample copy, per the "dogs info is sample right now" call.
-- ============================================================
delete from public.dog_media
where dog_id in (
  'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81',
  'e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14',
  'f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32',
  'a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17',
  'b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60',
  '73eda24d-87be-405a-9852-5d576119f1d5',
  'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93',
  '1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72'
);

insert into public.dog_media (dog_id, media_type, url, thumbnail_url, sort_order, caption) values
  ('c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jaydee-1.png', null, 0,
   'Jaydee spent the whole afternoon stealing toys and starting games nobody asked for.'),
  ('c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jaydee-2.png', null, 1, null),
  ('e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/chirkut-1.png', null, 0,
   E'Chirkut, deaf as ever, still didn''t miss a single squirrel today.'),
  ('e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/chirkut-2.png', null, 1, null),
  ('f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jimmy-1.png', null, 0,
   'Jimmy watched quietly from her corner before finally leaning in for a head scratch today.'),
  ('f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/jimmy-2.png', null, 1, null),
  ('a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/brownie-1.png', null, 0, null),
  ('a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/brownie-2.png', null, 1, null),
  ('a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'video', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/brownie/rocket-1.mp4', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/brownie/rocket-1-thumb.jpg', 2,
   'Brownie and Rocket got into their usual mischief together today.'),
  ('a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'video', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/brownie/rocket-2.mp4', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/brownie/rocket-2-thumb.jpg', 3, null),
  ('a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'video', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/brownie/rocket-3.mp4', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/brownie/rocket-3-thumb.jpg', 4, null),
  ('b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/wobble.png', null, 0,
   'Wobble greeted every visitor today with a full-body wag, three legs and all.'),
  ('73eda24d-87be-405a-9852-5d576119f1d5', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/titli.png', null, 0, null),
  ('73eda24d-87be-405a-9852-5d576119f1d5', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/titli-2.png', null, 1,
   'Titli took her evening walk at exactly her own pace today, and not a step faster.'),
  ('d9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/mareez.png', null, 0,
   'Mareez spent the afternoon in his favorite sunny spot, watching the world go by.'),
  ('1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/sheela-1.png', null, 0,
   'Sheela soaked up a slow, sunny afternoon today, exactly the way she likes it.'),
  ('1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72', 'image', 'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/dogs/sheela-2.png', null, 1, null);

-- ============================================================
-- promo_tiles
-- ============================================================
insert into public.promo_tiles (id, title, subtitle, cta_label, image_url, insert_after_index, is_active) values
  ('1e8d68df-7379-46b6-9d10-ad9c2f65233c',
   'Daily Feedings',
   'Every day, we feed the strays who have no one else — help us keep the bowls full.',
   'Feed a Hungry Pup',
   'https://sfuclalozufdtiatcrwz.supabase.co/storage/v1/object/public/dog-media/promo/street-feeding.png',
   1, true)
on conflict (id) do update set
  title = excluded.title,
  subtitle = excluded.subtitle,
  cta_label = excluded.cta_label,
  image_url = excluded.image_url,
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
  '73eda24d-87be-405a-9852-5d576119f1d5',
  'b7e5a1f0-6c2d-4a89-9e3f-1d4c8a2b7f60',
  'c4f8b3e2-9a1d-4e6c-8b7f-2a5d9c3e6f81',
  'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93',
  'e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14',
  'f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32',
  'a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17',
  '1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72'
);

insert into public.sponsorship_impacts (id, dog_id, icon, description, sort_order) values
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
  ('a1000000-0000-0000-0000-000000000021', 'd9a2c6e1-3f8b-4d5a-9c1e-7b6f4a2d8e93', 'moon', 'Ensures he always has a warm, comfortable bed.', 3),
  ('a1000000-0000-0000-0000-000000000022', 'e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14', 'shield', 'Covers vaccinations and a full vet checkup.', 1),
  ('a1000000-0000-0000-0000-000000000023', 'e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14', 'coffee', 'Funds his daily meals.', 2),
  ('a1000000-0000-0000-0000-000000000024', 'e3c7a9f5-4b1d-4e8a-9c6f-8d2b5a7e0f14', 'zap', 'Provides toys and enrichment to match his energy.', 3),
  ('a1000000-0000-0000-0000-000000000025', 'f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32', 'shield', 'Covers vaccinations and a full vet checkup.', 1),
  ('a1000000-0000-0000-0000-000000000026', 'f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32', 'coffee', 'Funds her daily meals.', 2),
  ('a1000000-0000-0000-0000-000000000027', 'f6d4b8a1-2c9e-4a3f-8b5d-6e1c9f4a7b32', 'heart', 'Supports gentle training to help her rebuild trust.', 3),
  ('a1000000-0000-0000-0000-000000000028', 'a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'zap', 'Funds his custom set of wheels for mobility.', 1),
  ('a1000000-0000-0000-0000-000000000029', 'a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'plusCircle', 'Covers physiotherapy and ongoing wound care.', 2),
  ('a1000000-0000-0000-0000-000000000030', 'a7c3e9d5-1f6b-4a82-9d4c-3b8e5f2a6c17', 'moon', 'Ensures he has a comfortable orthopedic bed.', 3),
  ('a1000000-0000-0000-0000-000000000031', '1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72', 'plusCircle', 'Provides monthly joint supplements and senior wellness checks.', 1),
  ('a1000000-0000-0000-0000-000000000032', '1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72', 'coffee', 'Covers her soft-food senior diet.', 2),
  ('a1000000-0000-0000-0000-000000000033', '1f6a8c3d-7b2e-4f91-9a5c-3d6e8b1f4a72', 'moon', 'Ensures she always has a warm, comfortable bed.', 3);
