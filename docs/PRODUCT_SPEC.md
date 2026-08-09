# Sponsor a Dog ("Angelic Friends") — Product & Technical Spec

Status: v3, all decisions locked · Owner: Toseef · Last updated: 2026-08-08

This merges the original `PRODUCT_SPEC.md` with `angelic_friends_screen_flow.md` (now superseded and removed — this file is the single source of truth). All decisions in §12 are locked; the one item in §13 depends on a fact about the real shelter, not a design call.

## 0. Naming

- **Technical/project name:** `sponsor_a_dog` — the Flutter package already scaffolded (bundle ID `com.sponsoradog.*`). No need to touch this now.
- **Product/brand name:** **Angelic Friends** — decided. Used as the display name (`app.dart` title, store listing) while the technical package name stays `sponsor_a_dog`; renaming the package later is mechanical if you ever want full alignment.

## 1. Concept & positioning

Virtual sponsorship for real **paralyzed shelter dogs in ongoing rehab** — not a generic "sponsor any shelter dog" app. That specificity is the differentiator: real photos and video, real handlers, one real story per dog, not stock-photo warmth. Monetization is tiered purely by update frequency (§5) — chat is a shared feature, not a tier differentiator.

Built for RevenueCat's **Shipaton** hackathon (§2) — a 2-week build, which should drive scope aggressively. Everything tagged 🟢 in §4 is what actually needs to exist for the submission; 🟡/🔴 items are explicitly deferred.

**Content authenticity rule:** the black-ink illustration style (§8) is for chrome only — onboarding art, icons, empty states, backgrounds. Every dog's actual photo/video content stays real and unfiltered. That authenticity is the app's core credibility; don't let the design system bleed into it.

**Copy voice:** concrete over vague, first-person/personality voice. "Be my angel" beats "Subscribe." "Your sponsorship covers weekly physical therapy" beats "help this dog." Mirrors the reference image's own specificity ("customize delivery, weekends and holidays").

## 2. Shipaton context

- Timeline: ~2-week build.
- Category focus: **Peace Prize** (primary — real personal story, real shelter) and **#BuildInPublic** (if progress is posted publicly during the build).
- Don't spread into Design/HAMM/Grand Prize unless execution genuinely earns it. HAMM was tentatively on the table via Gift a Sponsorship's creative-monetization angle, but that feature is now deferred post-hackathon (§5) — treat HAMM as off the table for this submission unless something else earns it.
- Demo video: open on real footage of the shelter and the dogs, not the app UI — lead with the personal story, it's the strongest asset here.

## 3. User journey

```
Onboarding (3 slides, skippable) → Home / Dog List
                                          │
                                          ├─ Dog card tap → Dog Detail → "Be my angel" CTA
                                          │                                 │
                                          │                                 ▼
                                          │                    Paywall — Silver / Gold / one-time donation
                                          │                                 │
                                          ▼                                 ▼
                                    My Dogs (tab 2) ◄──────────── purchase completes → confirmation
                                          │
                                          └─ Sponsor row tap → Update feed (video/photo + ♥) + Chat with handler

Profile / Settings (tab 3): profile, photo, manage subscription, notification preferences, support
```

No login is required to browse dogs or complete onboarding. An account is only required at the point money changes hands (§7).

## 4. Screens

Priority key: 🟢 MVP · 🟡 Stretch · 🔴 Post-hackathon

### 4.1 🟢 Onboarding (3 slides)
- Slide 1 — the hook: illustrated hero dog, one line on the mission (real shelter, paralyzed dogs, second chances).
- Slide 2 — how it works: sponsor a dog → get real updates → chat with their handler.
- Slide 3 — the ask: emotional close + CTA into the dog list ("Meet the dogs").
- Skippable, dot progress indicator, no login required to browse.

### 4.2 🟢 Name capture
- Single screen, single text field ("What should we call you?"), Continue button.
- Not an account — a display name attached to the anonymous session (§7), used to personalize copy ("Hey Alex, meet Bruno"). Recommend not skippable given how much it buys in personalization for one field.

### 4.3 🟢 Home / Dog List
- Grid or list: real photo thumbnail, name, one-line personality tag, sponsorship status ("14 angels" or "Needs more support" — reinforces the many-sponsors-per-dog model, §6).
- Optional filter: newly arrived / in active rehab / long-term resident.

### 4.4 🟢 Dog Detail
- Real photo/video hero, name, personality tag, age, location.
- Bio: how they arrived, current rehab status/progress — specific, not generic.
- "Your sponsorship covers" — concrete line items (wheelchair cart upkeep, weekly physical therapy, video updates), not vague appeals.
- Primary CTA, personality-voiced, price visible ("Be my angel — $12/mo").
- Social proof line ("Join 14 others already sponsoring Bruno") — promoted from optional-v1.1 to MVP, since it directly reinforces the sponsorship model in §6.

### 4.5 🟢 Paywall (RevenueCat) — full tier reconciliation in §5.

### 4.6 🟢 My Dogs (tab 2, was "My Sponsors")
- List of the user's active/past sponsorships: dog photo, name, tier badge, tenure ("Sponsoring Bruno for 3 months").
- Empty state before first sponsorship: "You haven't sponsored a dog yet" + CTA back to Home. Static tab, always visible — no dynamic insert/remove.
- Tap a row → Sponsor Detail (§4.7, §4.8).

### 4.7 🟢 Update Feed (per dog)
- Vertical scroll of past video/photo updates, dated, short handler captions, newest first.
- Lightweight heart reaction — this isn't a social feed, it's a relationship; no comments, no vanity-metric treatment.
- **Decided: uploads are admin-only for v1** (§4.9) — no caretaker-facing app. Gold sponsors get a push on every new upload; Silver sponsors get one batched push a week. Don't hide the archive from Silver — gate notification cadence, not access.

### 4.8 🟢 Chat with Handler
- 1:1 thread, sponsor ↔ handler.
- Supports text **and short inline video clips** from the handler — a quick video reply, not just text. This is the single most differentiating feature vs. a passive content subscription; protect build time for it. Tier gating in §5.

### 4.9 🔴 Handler-side tooling (post-hackathon)
- Confirmed admin/manual-only for the hackathon build — and confirmed low-risk, not just assumed: you operate the actual shelter, so there's no dependency on a third-party handler's cooperation or tooling to get real video content. A bare internal upload form (or even hand-written Firestore docs) is enough to demo convincingly — don't spend build days here.

### 4.10 🟡 Notification Preferences
- Update cadence control, quiet hours. Distinct from the tier-driven cadence in §5 — this is user-controlled timing layered on top of whatever cadence the tier already grants.

### 4.11 🟢 Profile / Settings (tab 3)
- Profile photo + display name (edit).
- "Manage subscription" → deep link to RevenueCat Customer Center / native App Store / Play subscription management.
- Donation/gift history.
- Support/contact, legal (privacy policy, terms), sign out / delete account.
- Notification preferences (§4.10) lives here once built.

## 5. Paywall & monetization — decided

| Offer | Cadence | Chat access | Pricing |
|---|---|---|---|
| **Silver** | Weekly video update | Included | Fixed per dog |
| **Gold** | Daily video update | Included | Fixed per dog |
| **One-time donation** | Single charge, no subscription | — | Preset amounts, generic across dogs |

Three offers for this build, not four — **Gift a Sponsorship is deferred post-hackathon** (§5a has the mechanics worked out for whenever it's picked back up; no need to re-derive them). This also takes HAMM off the table for the Shipaton submission (§2), since gifting was the creative-monetization angle for that category.

**Decided: chat is included on both tiers.** Silver and Gold differ only in video update cadence (weekly vs. daily) — not in features.

### 5a. Gift a Sponsorship — deferred, mechanics kept for later

App Store / Play subscriptions are tied to whoever's payment method is on them — there's no native way to buy a subscription and hand the entitlement to someone else's account. Whenever this gets built, the mechanism decouples the purchase from the entitlement:

1. **The gift is a one-time product, not a subscription.** The gifter buys a non-renewing IAP product — "1 month of Silver/Gold for Bruno" — priced at that dog's normal monthly rate. Because pricing is fixed per dog, this adds *two more* per-dog products beyond the existing subscriptions: `sponsor_<dog_id>_silver_gift_1mo` and `..._gold_gift_1mo` — per-dog product count would become 4, not 2.
2. **Purchase generates a redemption code**, not an assignment to a specific person — a Cloud Function triggered by the RevenueCat webhook creates a row in a `gift_codes` table with a short human-typeable code. No need to know the recipient's identity at purchase time, same as a gift card.
3. **Sharing is just the code — no deep links needed.** Gifter gets a code + a share-sheet message ("You've been gifted a month with Bruno! Open Angelic Friends and enter code XYZ123"). Recipient installs the app if needed, opens an "I have a gift code" field, types it in. Deferred deep linking (auto-redeeming on install) is real infra work, skip it.
4. **Redemption grants access via RevenueCat's promotional entitlements**, not a real store transaction — the backend calls RevenueCat's server API to grant the recipient's `app_user_id` the relevant entitlement for a 1-month duration, and creates a `sponsorships` row (`started_at` = now, `ends_at` = now + 1 month, non-renewing). Keeps entitlement-checking logic in the app uniform regardless of whether access came from a real subscription or a gift grant.
5. **After the month, it just expires** — no auto-renewal. If the recipient wants to continue, they subscribe themselves through the normal paywall.

Considered and skipped even for the future build: native App Store/Play subscription offer-codes would make the gift feel like a "real" subscription, but that means building and maintaining two separate platform-specific code systems for one feature, versus the fully platform-agnostic approach above via RevenueCat.

**Not built now** — the `gift_codes` table and the `gifted_by_user_id`/`ends_at` fields on `sponsorships` (§9) are kept in the schema sketch as a reference for later, not something to implement in this pass.

Design implication (unchanged): Gold reads as the "hero" tier via the brand's gold accent (§8); Silver gets a distinct, cooler neutral so the two don't visually compete.

**Decided, unchanged from before:**
- Both offers route through RevenueCat/IAP — one payment flow, no separate Stripe/PayPal rail.
- Pricing is fixed per dog → every dog needs its own Silver and Gold store product in App Store Connect / Play Console (2 products per dog, minimum). Naming convention: `sponsor_<dog_id>_silver_monthly`. RevenueCat's Offerings present "the right two products for this dog" dynamically even though the underlying products are static per-dog.
- Donations are 2–4 preset amounts (e.g. $5 / $15 / $30), not free-text — IAP doesn't support user-entered custom prices. Donation products are **generic across all dogs**; the specific dog is recorded in your own `donations` row, not in the store product.

## 6. Sponsorship model — many sponsors per dog

**Decided: many sponsors per dog**, like symbolic wildlife adoption — not one exclusive sponsor per dog. Matches the existing schema as-is: `sponsorships` keys on `(user_id, dog_id)` with no exclusivity constraint, so no schema changes needed.

**Also worth confirming with the actual shelter, not assumed:** the "dog gets adopted → subscriber churns" retention risk flagged earlier in this project probably doesn't apply here, since these are long-term rehab/sanctuary dogs rather than fast-turnover adoptions — that's a fact about the real shelter's situation, not a design choice, so confirm it rather than build retention mechanics for a problem that may not exist.

## 7. Auth strategy — recommendation

**Don't require login up front.** Start every user on anonymous auth (Firebase Anonymous Auth or Supabase's anonymous sign-in), created silently right after name capture. This gets you a stable user ID for analytics and local state with zero onboarding friction.

**Require a real account only at first payment** — right before the paywall completes, or immediately after, upgrade the anonymous account to a permanent one by *linking* credentials (both Firebase and Supabase support this without losing the existing UID/data). This is the point where losing the account would actually hurt the user (they've paid; they need to restore purchases and see chat/video history on a new device), so it's the right moment to ask.

**Social providers: Sign in with Apple + Google Sign-In.** Skip Facebook — lower conversion and added privacy overhead for little gain in this audience. If you offer Google Sign-In on iOS, Apple's guidelines require you to also offer Sign in with Apple, so plan for both from day one. Add email/password or magic-link only if you find drop-off at the Apple/Google step.

## 8. Design system (extracted from reference image)

See the companion visual doc for swatches and type pairing in context. Values were sampled directly from the reference illustration's pixels, not eyeballed:

- **Ink** `#000000` — line art, headlines, primary text
- **Ground** `#FFFFFF` — background
- **Mustard** `#FEC81D` — single accent color: CTA buttons, illustration highlights (collar, food, bowls). Reads naturally as the **Gold tier** color.
- **Body gray** `≈ #8F8F8F` — secondary text (subtitles, captions)

Illustration style: loose hand-drawn black ink line art, single flat accent color, no gradients, generous negative space, dogs rendered with warmth/personality rather than realism — used for chrome only (§1), never over real dog photo/video content.

Type: a serif display face for headlines (the reference's "Large portions" is a soft serif, not a grotesque) paired with a plain sans for body copy and UI chrome — keep the serif for moments of warmth (onboarding, empty states, dog names) and the sans everywhere functional (lists, buttons, forms).

Buttons: full-width, rectangular with a slight corner radius, solid mustard fill, bold black label — personality-voiced ("Be my angel — $12/mo"), not generic ("Subscribe").

## 9. Data model (backend-agnostic sketch)

| Entity | Key fields |
|---|---|
| `users` | id, display_name, photo_url, auth_provider, created_at |
| `dogs` | id, name, breed, age_months, story, image_urls[], shelter_id, status, silver_product_id, gold_product_id, silver_price, gold_price |
| `shelters` | id, name, location |
| `caretakers` | id, shelter_id, name, photo_url |
| `sponsorships` | id, user_id, dog_id, tier (`silver`\|`gold`), status, revenuecat_product_id, gifted_by_user_id (nullable), started_at, ends_at (nullable, gifts only), cancelled_at |
| `gift_codes` | id, code, dog_id, tier, gifted_by_user_id, revenuecat_transaction_id, redeemed_by_user_id (nullable), redeemed_at (nullable), created_at |
| `donations` | id, user_id, dog_id, amount, revenuecat_product_id, created_at |
| `messages` | id, sponsorship_id, sender_id, sender_type (`user`\|`caretaker`), text, media_type (`text`\|`video`), media_url (nullable), created_at |
| `video_updates` | id, dog_id, video_url, thumbnail_url, caption, created_at |
| `update_reactions` | id, video_update_id, user_id, created_at |

Notes:
- `video_updates` is keyed to the **dog**, not the sponsorship — uploads happen once per dog, admin-only (§4.9); each sponsor's tier controls notification cadence, not which videos exist.
- `dogs.silver_price` / `gold_price` are denormalized copies of what's configured in App Store Connect / Play Console — Home and Dog Detail need to show "$12/mo" before ever touching RevenueCat's offering fetch.
- `gift_codes` exists separately from `sponsorships` because an unredeemed gift isn't a sponsorship yet — no active sponsor, no user_id to attach it to. On redemption, a normal `sponsorships` row is created (`gifted_by_user_id` set for provenance, `ends_at` set since gifts don't auto-renew) and `gift_codes.redeemed_by_user_id`/`redeemed_at` are filled in. See §5a.
- `messages.media_type`/`media_url` support the handler's inline video replies (§4.8) without a separate table.
- `update_reactions` is a join table rather than a counter column so "who reacted" is available if it matters later — cheap to add now, awkward to retrofit.
- If Notification Preferences (§4.10) gets built: add `notification_cadence`, `quiet_hours_start`, `quiet_hours_end` to `users`.

## 10. Backend — Supabase (Firebase kept for Analytics only)

**Decided: Supabase**, reversing the earlier Firebase recommendation — a billing-account requirement blocked provisioning Firestore/Storage/Auth on the Firebase project, so the backend moved to Supabase (Postgres, Auth, Storage, Realtime). Practical consequence worth flagging: Supabase Realtime over Postgres changes is the mechanism for chat (§4.8) and live sponsorship status instead of Firestore listeners — same job, different underlying model (row-change subscriptions vs. document listeners).

**Firebase is kept, scoped to Analytics only.** The `angelic-friends` Firebase project stays live purely for Firebase Analytics (event/screen tracking) — it's a separate, lightweight SDK that doesn't touch the billing-gated APIs (Firestore/Storage/Auth) that caused the original problem, and isn't available on Windows desktop anyway so it can't reintroduce the native build issues either. `core/analytics/` wraps it behind an `AnalyticsService` interface with a no-op fallback on unsupported platforms.

Push notifications (video-upload cadence, §4.7) lose their natural Firebase Cloud Messaging fit with this switch — Supabase doesn't ship an equivalent, so a separate push provider (e.g. OneSignal) will need to be picked when that feature gets built. Not yet decided.

RevenueCat sits in front of Supabase the same way it would have with Firebase, as the subscription/entitlement layer — this backend switch doesn't touch the monetization plan in §5.

## 11. Suggested Flutter feature modules

Matches the existing feature-first Clean Architecture scaffold (`lib/features/<feature>/{data,domain,presentation}`), resequenced by priority:

**🟢 MVP**
- `onboarding` — 3-slide PageView + name capture
- `dogs` — home list + dog detail (already scaffolded)
- `paywall` — RevenueCat offering display (Silver / Gold / donation)
- `sponsors` — My Dogs list + sponsor detail shell
- `video_updates` — feed per dog + heart reactions
- `chat` — handler messaging, text + inline video

**🟡 Stretch**
- `profile` — account, subscription management, notification preferences

**🔴 Post-hackathon, out of the consumer app's scope**
- Handler-side upload tooling (admin-only manual process for now)
- Gift a Sponsorship (§5a has the mechanics ready whenever this gets picked up)

`core/auth` — anonymous session + provider linking (cuts across features, belongs in `core`, not a feature).

`core/analytics` — already scaffolded: `AnalyticsService` interface, Firebase Analytics implementation, no-op fallback where Firebase Analytics isn't supported (Windows desktop dev).

**DI note:** no service locator (get_it was removed) — dependencies are hand-assembled once in `core/di/app_dependencies.dart` and handed down via `RepositoryProvider`/`context.read`, with use cases and blocs constructed at the point of use.

## 12. Decisions log

| # | Question | Decision |
|---|---|---|
| 1 | Silver/Gold pricing: per-dog or global? | **Per-dog.** |
| 2 | Does tier apply per-dog or account-wide? | **Per-dog.** |
| 3 | Donation payment rail? | **RevenueCat/IAP, same as Silver/Gold** — one payment flow, preset amounts. |
| 4 | Who uploads `video_updates`? | **Admin-only for v1** — confirmed low-risk, you run the shelter directly. |
| 5 | Is chat Silver+Gold, or Gold-only? | **Both tiers.** Tiers differ only by video cadence. |
| 6 | Keep Gift a Sponsorship in scope for this build? | **No — deferred post-hackathon.** Mechanics kept in §5a for later. |
| 7 | One sponsor per dog, or many? | **Many.** Matches existing schema, no changes needed. |
| 8 | Product display name? | **Angelic Friends.** `sponsor_a_dog` stays the technical package name (§0). |

All 8 decisions are locked — nothing blocking in §4/§11's 🟢 MVP scope.

## 13. Open questions remaining

None. **Confirmed: long-term rehab dogs**, not fast-turnover adoptions (§6) — no dedicated churn/retention mechanics needed for v1; the "dog gets adopted → subscriber churns" risk doesn't apply here.
