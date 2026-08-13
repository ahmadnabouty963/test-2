-- Haven v2: admin role, appointments and moderator presence.
-- Run after the v1 schema. The live project was migrated on 2026-08-13.

alter type public.user_role add value if not exists 'admin';

alter table public.profiles
  add column if not exists availability text not null default 'offline'
    check (availability in ('offline','online','busy')),
  add column if not exists last_seen timestamptz;

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  moderator_id uuid references public.profiles(id) on delete set null,
  scheduled_at timestamptz not null,
  duration_minutes integer not null default 45 check (duration_minutes in (30,45,60)),
  language text not null check (language in ('en','de','ar')),
  note text not null default '' check (char_length(note)<=800),
  status text not null default 'requested'
    check (status in ('requested','confirmed','completed','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (scheduled_at>created_at)
);
create index if not exists appointments_user_time_idx on public.appointments(user_id,scheduled_at desc);
create index if not exists appointments_moderator_time_idx on public.appointments(moderator_id,scheduled_at desc);
create index if not exists appointments_status_time_idx on public.appointments(status,scheduled_at);
alter table public.appointments enable row level security;

create or replace function private.is_staff() returns boolean
language sql stable security definer set search_path='' as $$
  select auth.uid() is not null and exists(
    select 1 from public.profiles
    where id=(select auth.uid()) and role::text in ('moderator','admin')
  );
$$;
create or replace function private.is_admin() returns boolean
language sql stable security definer set search_path='' as $$
  select auth.uid() is not null and exists(
    select 1 from public.profiles
    where id=(select auth.uid()) and role::text='admin'
  );
$$;
create or replace function private.is_permanent_user() returns boolean
language sql stable security definer set search_path='' as $$
  select auth.uid() is not null
    and coalesce((auth.jwt()->>'is_anonymous')::boolean,false) is false;
$$;
revoke all on function private.is_staff() from public,anon;
revoke all on function private.is_admin() from public,anon;
revoke all on function private.is_permanent_user() from public,anon;
grant execute on function private.is_staff() to authenticated;
grant execute on function private.is_admin() to authenticated;
grant execute on function private.is_permanent_user() to authenticated;

drop policy if exists "read profiles" on public.profiles;
create policy "read profiles" on public.profiles for select to authenticated
using(id=(select auth.uid()) or private.is_staff());
drop policy if exists "update own name" on public.profiles;
drop policy if exists "staff update own presence" on public.profiles;
revoke update on public.profiles from authenticated,anon;

create policy "read appointments" on public.appointments for select to authenticated
using(
  (user_id=(select auth.uid()) and (select private.is_permanent_user()))
  or (select private.is_staff())
);
create policy "registered users create appointments" on public.appointments for insert to authenticated
with check(
  user_id=(select auth.uid()) and moderator_id is null and status='requested'
  and (select private.is_permanent_user())
);
grant select,insert on public.appointments to authenticated;

create or replace function public.get_public_stats() returns jsonb
language sql stable security definer set search_path='' as $$
  select jsonb_build_object(
    'moderators_total',count(*) filter(where role::text in ('moderator','admin')),
    'moderators_online',count(*) filter(
      where role::text in ('moderator','admin')
      and availability in ('online','busy')
      and last_seen>now()-interval '5 minutes'
    )
  ) from public.profiles;
$$;

create or replace function public.set_staff_availability(new_status text) returns void
language plpgsql security definer set search_path='' as $$
begin
  if auth.uid() is null or not private.is_staff() then raise exception 'Staff access required'; end if;
  if new_status not in ('offline','online','busy') then raise exception 'Invalid availability'; end if;
  update public.profiles set availability=new_status,last_seen=now()
  where id=(select auth.uid());
end; $$;

create or replace function public.manage_appointment(
  appointment_uuid uuid,new_status text,assigned_moderator uuid default null
) returns public.appointments
language plpgsql security definer set search_path='' as $$
declare selected public.appointments;
begin
  if auth.uid() is null or not private.is_staff() then raise exception 'Staff access required'; end if;
  if new_status not in ('requested','confirmed','completed','cancelled') then raise exception 'Invalid appointment status'; end if;
  if assigned_moderator is not null and not exists(
    select 1 from public.profiles
    where id=assigned_moderator and role::text in ('moderator','admin')
  ) then raise exception 'Invalid moderator'; end if;
  update public.appointments
  set status=new_status,
      moderator_id=coalesce(assigned_moderator,moderator_id,(select auth.uid())),
      updated_at=now()
  where id=appointment_uuid returning * into selected;
  if selected.id is null then raise exception 'Appointment not found'; end if;
  return selected;
end; $$;

create or replace function public.cancel_own_appointment(appointment_uuid uuid) returns void
language plpgsql security definer set search_path='' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  update public.appointments set status='cancelled',updated_at=now()
  where id=appointment_uuid
    and user_id=(select auth.uid())
    and status in ('requested','confirmed');
  if not found then raise exception 'Appointment cannot be cancelled'; end if;
end; $$;

create or replace function public.admin_set_role(profile_uuid uuid,new_role text) returns void
language plpgsql security definer set search_path='' as $$
begin
  if auth.uid() is null or not private.is_admin() then raise exception 'Admin access required'; end if;
  if new_role not in ('user','moderator','admin') then raise exception 'Invalid role'; end if;
  if profile_uuid=(select auth.uid()) and new_role<>'admin'
    then raise exception 'Admins cannot remove their own admin role'; end if;
  update public.profiles
  set role=new_role::public.user_role,
      availability=case when new_role='user' then 'offline' else availability end
  where id=profile_uuid;
end; $$;

revoke all on function public.get_public_stats() from public;
grant execute on function public.get_public_stats() to anon,authenticated;
revoke all on function public.set_staff_availability(text) from public,anon;
revoke all on function public.manage_appointment(uuid,text,uuid) from public,anon;
revoke all on function public.cancel_own_appointment(uuid) from public,anon;
revoke all on function public.admin_set_role(uuid,text) from public,anon;
grant execute on function public.set_staff_availability(text) to authenticated;
grant execute on function public.manage_appointment(uuid,text,uuid) to authenticated;
grant execute on function public.cancel_own_appointment(uuid) to authenticated;
grant execute on function public.admin_set_role(uuid,text) to authenticated;

do $$
begin
  if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='appointments')
    then alter publication supabase_realtime add table public.appointments; end if;
  if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='profiles')
    then alter publication supabase_realtime add table public.profiles; end if;
end $$;

-- After the owner registers, promote the first admin with:
-- update public.profiles set role='admin' where id='USER_UUID';
