-- Run this once in Supabase > SQL Editor.
-- Then enable Anonymous Sign-Ins in Authentication > Sign In / Providers.
create extension if not exists pgcrypto;
create type public.user_role as enum ('user', 'moderator');
create type public.conversation_status as enum ('waiting', 'active', 'closed');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 50),
  role public.user_role not null default 'user',
  created_at timestamptz not null default now()
);
create table public.conversations (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
  moderator_id uuid references public.profiles(id) on delete set null, topic text not null check (char_length(topic) between 1 and 100),
  language text not null check (language in ('en','de','ar')), status public.conversation_status not null default 'waiting',
  created_at timestamptz not null default now(), accepted_at timestamptz, closed_at timestamptz
);
create table public.messages (
  id bigint generated always as identity primary key, conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade, body text not null check (char_length(body) between 1 and 3000), created_at timestamptz not null default now()
);
create index conversations_user_idx on public.conversations(user_id,created_at desc);
create index conversations_queue_idx on public.conversations(status,created_at);
create index conversations_moderator_idx on public.conversations(moderator_id,created_at desc);
create index messages_conversation_idx on public.messages(conversation_id,created_at);
create index messages_sender_idx on public.messages(sender_id);

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path='' as $$
begin insert into public.profiles(id,display_name) values(new.id,coalesce(nullif(new.raw_user_meta_data->>'display_name',''),'Guest')); return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
create or replace function private.is_moderator() returns boolean language sql stable security definer set search_path='' as $$
  select auth.uid() is not null and exists(select 1 from public.profiles where id=(select auth.uid()) and role::text in ('moderator','admin')); $$;
create or replace function private.can_access_conversation(conversation_uuid uuid) returns boolean language sql stable security definer set search_path='' as $$
  select auth.uid() is not null and exists(select 1 from public.conversations c where c.id=conversation_uuid and (c.user_id=(select auth.uid()) or c.moderator_id=(select auth.uid()) or private.is_moderator())); $$;
create or replace function public.accept_conversation(conversation_uuid uuid) returns public.conversations language plpgsql security definer set search_path='' as $$
declare selected public.conversations; begin if auth.uid() is null or not private.is_moderator() then raise exception 'Moderator access required'; end if;
update public.conversations set moderator_id=(select auth.uid()),status='active',accepted_at=now() where id=conversation_uuid and status='waiting' returning * into selected;
if selected.id is null then raise exception 'Conversation is no longer waiting'; end if; return selected; end; $$;
create or replace function public.close_conversation(conversation_uuid uuid) returns void language plpgsql security definer set search_path='' as $$
begin
  if auth.uid() is null or not exists(select 1 from public.conversations c where c.id=conversation_uuid and (c.user_id=(select auth.uid()) or c.moderator_id=(select auth.uid()))) then raise exception 'Conversation access required'; end if;
  update public.conversations set status='closed',closed_at=now() where id=conversation_uuid;
end; $$;

alter table public.profiles enable row level security; alter table public.conversations enable row level security; alter table public.messages enable row level security;
create policy "read profiles" on public.profiles for select to authenticated using(id=(select auth.uid()) or private.is_moderator());
create policy "update own name" on public.profiles for update to authenticated using(id=(select auth.uid())) with check(id=(select auth.uid()) and role='user');
create policy "read participant conversations" on public.conversations for select to authenticated using(user_id=(select auth.uid()) or moderator_id=(select auth.uid()) or private.is_moderator());
create policy "create own conversation" on public.conversations for insert to authenticated with check(user_id=(select auth.uid()) and moderator_id is null and status='waiting');
create policy "participants read messages" on public.messages for select to authenticated using(private.can_access_conversation(conversation_id));
create policy "participants send messages" on public.messages for insert to authenticated with check(sender_id=(select auth.uid()) and private.can_access_conversation(conversation_id) and exists(select 1 from public.conversations c where c.id=conversation_id and c.status<>'closed'));

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke all on function private.is_moderator() from public, anon;
revoke all on function private.can_access_conversation(uuid) from public, anon;
grant execute on function private.is_moderator() to authenticated;
grant execute on function private.can_access_conversation(uuid) to authenticated;
revoke all on function public.accept_conversation(uuid) from public, anon;
revoke all on function public.close_conversation(uuid) from public, anon;
grant execute on function public.accept_conversation(uuid) to authenticated;
grant execute on function public.close_conversation(uuid) to authenticated;
grant usage on schema public to authenticated;
grant select on public.profiles to authenticated;
grant select, insert on public.conversations to authenticated;
grant select, insert on public.messages to authenticated;
grant usage, select on sequence public.messages_id_seq to authenticated;
alter publication supabase_realtime add table public.conversations; alter publication supabase_realtime add table public.messages;
-- Promote a trusted account manually: update public.profiles set role='moderator' where id='USER_UUID';

