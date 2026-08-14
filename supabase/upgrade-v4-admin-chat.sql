-- Upgrade v4: admins can also perform moderator chat duties.
-- Applied to the hosted Supabase project on 2026-08-14.

create or replace function private.is_moderator()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid() is not null
    and exists (
      select 1
      from public.profiles
      where id = (select auth.uid())
        and role::text in ('moderator', 'admin')
    );
$$;
