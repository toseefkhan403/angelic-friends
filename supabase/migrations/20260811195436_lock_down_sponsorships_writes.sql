-- Sponsorships are now created and updated exclusively by the
-- `revenuecat-webhook` Edge Function (using the service_role key, which
-- bypasses RLS entirely), after it verifies a real RevenueCat purchase
-- event. Previously any signed-in user (including anonymous auth users,
-- which is this app's only auth method) could insert a sponsorship row for
-- themselves directly, granting themselves paid chat access for free.
--
-- Users can still read their own sponsorships (unchanged SELECT policy).
drop policy if exists "Users can create their own sponsorships" on public.sponsorships;
