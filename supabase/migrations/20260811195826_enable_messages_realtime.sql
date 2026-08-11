-- Lets the chat screen receive new handler replies live via Supabase
-- Realtime instead of only on manual refresh. RLS on `messages` is enforced
-- by Realtime using the connected client's JWT, so this doesn't widen who
-- can see what — it only turns on delivery for changes users could already
-- read.
alter publication supabase_realtime add table public.messages;
