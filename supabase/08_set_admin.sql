-- ============================================================
--  08 — Set the platform admin to mohamedaloueimin@gmail.com
--  Run this once in the SQL Editor of an EXISTING project.
--  (Fresh projects don't need it — SETUP_NEW_PROJECT.sql already
--  uses this email.) Safe to re-run.
-- ============================================================

-- New signups with this email become admin automatically.
create or replace function posinv_handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare demo uuid;
begin
  insert into public.posinv_app_users (id, name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), 'Staff')
  on conflict (id) do nothing;
  if lower(new.email) = 'mohamedaloueimin@gmail.com' then
    select id into demo from posinv_stores where name = 'Demo Store' limit 1;
    update posinv_app_users set is_admin = true, store_id = coalesce(store_id, demo) where id = new.id;
    update posinv_stores set owner_id = new.id where id = demo and owner_id is null;
  end if;
  return new;
end; $$;

-- If that account already exists, promote it right now.
do $$
declare uid uuid; demo uuid;
begin
  select id into demo from posinv_stores where name = 'Demo Store' limit 1;
  select id into uid from auth.users where lower(email) = 'mohamedaloueimin@gmail.com' limit 1;
  if uid is not null then
    update posinv_app_users set is_admin = true, store_id = coalesce(store_id, demo) where id = uid;
    update posinv_stores set owner_id = coalesce(owner_id, uid), owner_email = 'mohamedaloueimin@gmail.com' where id = demo;
  end if;
end $$;

-- Remove admin rights from the old admin email, if it has an account.
update posinv_app_users set is_admin = false
where id in (select id from auth.users where lower(email) = 'cheikh.ahmed@amc4consulting.com');

-- Keep the Demo Store label consistent either way.
update posinv_stores set owner_email = 'mohamedaloueimin@gmail.com' where name = 'Demo Store';

-- The store-type column (in case it wasn't added yet). Safe to re-run.
alter table posinv_stores add column if not exists business_type text;
