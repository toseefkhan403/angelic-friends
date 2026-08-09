# Database Schema — Supabase

Status: v1 · Last updated: 2026-08-09

Tracks what's actually migrated in the live Supabase project vs. what's sketched
in `PRODUCT_SPEC.md` §9 for later. Built the same way `onboarding_slides` was
(§10 of the spec) — applied live via the Supabase MCP connection, RLS on,
public `select` policy for `anon`/`authenticated`.

Priority key, same convention as the spec: 🟢 built · 🟡 needed next · 🔴 deferred

## 🟢 Built for the Explore tab

### `dogs`

Backs the Explore feed (`docs/PRODUCT_SPEC.md` §4.3) and, later, Dog Detail (§4.4).

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid pk` | |
| `name` | `text` | |
| `breed` | `text` | |
| `age_months` | `int` | rendered as "N years old" on the card |
| `image_url` | `text` | hero photo. **Deviation from spec §9's `image_urls[]`**: kept singular for the Explore card, which only ever shows one image. Revisit as an array when Dog Detail needs a gallery. |
| `story` | `text` | shown truncated (2 lines) on the card, full on Dog Detail |
| `care_tag` | `text`, nullable | the pill badge overlaid on the hero image — "Senior Care", "Wheels Needed", "Hospice Care". Free text, not an enum: these are editorial, shelter-written labels, not a fixed taxonomy. |
| `personality_tags` | `text[]` | the small chips under the name — "Gentle Giant", "Loves Naps". Array, not a join table: purely descriptive, no cross-dog querying needed (unlike `update_reactions`, which the spec explicitly join-tables because "who reacted" matters later). |
| `status` | `text`, default `'active_rehab'` | `newly_arrived` \| `active_rehab` \| `long_term_resident` — backs the optional Home filter in spec §4.3. Not wired to any UI yet. |
| `silver_price` / `gold_price` | `numeric(10,2)` | per spec §5/§9's locked per-dog pricing decision. Not rendered on the Explore card (the reference image doesn't show a price there) but modeled now so Dog Detail/Paywall don't need a schema change later. |
| `silver_product_id` / `gold_product_id` | `text`, nullable | RevenueCat product identifiers (§5, §9) — filled in once store products exist. |
| `sort_order` | `int` | manual ordering for the feed |
| `created_at` | `timestamptz` | |

**Not included yet:** `shelter_id` (spec §9 has it, but there's only one shelter
right now — the operator's own — so a FK to a not-yet-existing `shelters`
table would be pure overhead. Add it when a second shelter is a real
possibility.)

### `promo_tiles`

New table, **not in the original spec §9 sketch**. Backs the "Large portions"
donation-upsell card spliced into the Explore feed between dog cards. Added
because the task explicitly calls for every piece of that screen — including
the promo copy — to come from the database rather than be hardcoded, so the
copy/CTA can change without an app release.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid pk` | |
| `title` | `text` | e.g. "Large portions" |
| `subtitle` | `text` | |
| `cta_label` | `text` | e.g. "I like to eat!" |
| `insert_after_index` | `int` | 0-based position in the **dog list** after which the app splices this tile in (e.g. `1` → after the 2nd dog card, matching the reference image) |
| `is_active` | `boolean`, default `true` | lets an admin retire a tile without deleting it |
| `created_at` | `timestamptz` | |

Only one active tile is rendered per feed for now, but the table supports
more (e.g. rotating seasonal appeals) without a schema change.

## 🟡 Needed next (per spec §9, not yet migrated)

These back the other two bottom-nav tabs (My Sponsors, Profile) and Dog
Detail/Paywall — not built in this pass, no reference design yet:

| Table | Needed for |
|---|---|
| `users` | Profile tab, auth (spec §7) |
| `sponsorships` | My Sponsors tab, "Join 14 others sponsoring Bruno" social proof (§4.4) |
| `donations` | one-time donation flow (§5), including donations made via the `promo_tiles` CTA |
| `messages` | Chat with Handler (§4.8) |
| `video_updates` | Update Feed (§4.7) |
| `update_reactions` | heart reactions on updates (§4.7) |

## 🔴 Deferred (per spec, no immediate driver)

| Table | Why it's waiting |
|---|---|
| `shelters` | only one shelter exists right now; add when `dogs.shelter_id` becomes necessary |
| `caretakers` | no handler-facing tooling yet (spec §4.9 — admin/manual only) |
| `gift_codes` | Gift a Sponsorship is explicitly deferred post-hackathon (spec §5a) |

## Already live (unrelated to this screen)

| Table | Purpose |
|---|---|
| `onboarding_slides` | 3-slide onboarding intro (spec §4.1) |
