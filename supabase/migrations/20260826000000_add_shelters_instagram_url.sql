-- Lets the shelter tile on Dog Detail link out to the shelter's Instagram
-- profile instead of a hardcoded URL in the client.
alter table public.shelters add column instagram_url text;
