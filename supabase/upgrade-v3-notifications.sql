-- Haven v3: moderator device notifications.
-- Applied to the live project on 2026-08-13.

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  token text not null unique check (char_length(token) between 20 and 500),
  platform text not null check (platform in ('ios','android')),
  device_name text not null default '' check (char_length(device_name) <= 100),
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists device_push_tokens_staff_idx
  on public.device_push_tokens(user_id) where enabled;

alter table public.device_push_tokens enable row level security;

drop policy if exists "staff manage own push tokens" on public.device_push_tokens;
create policy "staff manage own push tokens"
on public.device_push_tokens
for all
to authenticated
using (user_id = (select auth.uid()) and (select private.is_staff()))
with check (user_id = (select auth.uid()) and (select private.is_staff()));

grant select, insert, update, delete on public.device_push_tokens to authenticated;

create table if not exists public.notification_events (
  conversation_id uuid primary key references public.conversations(id) on delete cascade,
  requested_at timestamptz not null default now(),
  pushed_at timestamptz,
  emailed_at timestamptz,
  push_recipient_count integer not null default 0 check (push_recipient_count >= 0),
  email_recipient_count integer not null default 0 check (email_recipient_count >= 0),
  last_error text check (char_length(last_error) <= 1000)
);

alter table public.notification_events enable row level security;
revoke all on public.notification_events from anon, authenticated;

comment on table public.device_push_tokens is
  'Expo push tokens registered by approved moderators and admins.';
comment on table public.notification_events is
  'Server-only delivery and idempotency log for new waiting conversations.';
