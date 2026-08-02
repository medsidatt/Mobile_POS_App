-- ============================================================
--  07 — MULTI-STORE SaaS UPGRADE
--  Turns the single-store POS into a subscription platform:
--   • every user owns their own store; data isolated per store
--   • stores start DISABLED; the platform admin activates them
--   • admin panel lists stores + toggles subscriptions
--   • Excel sync becomes per-store via a secret report token
--  Run AFTER 01–06 in the Supabase SQL Editor. Safe to re-run.
--  Platform admin email: cheikh.ahmed@amc4consulting.com
-- ============================================================

-- ---------- 1) STORES ----------
create table if not exists posinv_stores (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  owner_id     uuid references auth.users on delete set null,
  owner_email  text,
  active       boolean default false,
  report_token uuid not null default gen_random_uuid(),
  created_at   timestamptz default now()
);
alter table posinv_stores enable row level security;

-- ---------- 2) PROFILE: store link + admin flag ----------
alter table posinv_app_users add column if not exists store_id uuid references posinv_stores on delete set null;
alter table posinv_app_users add column if not exists is_admin boolean not null default false;

-- ---------- 3) Demo Store for the existing catalog ----------
insert into posinv_stores (name, owner_email, active)
select 'Demo Store', 'cheikh.ahmed@amc4consulting.com', true
where not exists (select 1 from posinv_stores where name = 'Demo Store');

-- ---------- 4) store_id on every data table + backfill ----------
alter table posinv_products    add column if not exists store_id uuid references posinv_stores;
alter table posinv_customers   add column if not exists store_id uuid references posinv_stores;
alter table posinv_vendors     add column if not exists store_id uuid references posinv_stores;
alter table posinv_orders      add column if not exists store_id uuid references posinv_stores;
alter table posinv_order_items add column if not exists store_id uuid references posinv_stores;

update posinv_products  set store_id = (select id from posinv_stores where name='Demo Store') where store_id is null;
update posinv_customers set store_id = (select id from posinv_stores where name='Demo Store') where store_id is null;
update posinv_vendors   set store_id = (select id from posinv_stores where name='Demo Store') where store_id is null;
update posinv_orders    set store_id = (select id from posinv_stores where name='Demo Store') where store_id is null;
update posinv_order_items oi set store_id = o.store_id
  from posinv_orders o where oi.order_id = o.id and oi.store_id is null;

alter table posinv_products alter column store_id set not null;
alter table posinv_orders   alter column store_id set not null;

-- Products: SKU is now unique PER STORE, not globally (two stores can both sell Coke).
do $$
begin
  if (select count(*) from pg_attribute a
      join pg_index i on a.attrelid = i.indrelid and a.attnum = any(i.indkey)
      where i.indrelid = 'posinv_products'::regclass and i.indisprimary) = 1 then
    alter table posinv_products drop constraint posinv_products_pkey;
    alter table posinv_products add primary key (store_id, sku);
  end if;
end $$;

-- ---------- 5) Helper functions (used by the security rules) ----------
create or replace function posinv_my_store() returns uuid
language sql stable security definer set search_path = public as
$$ select store_id from posinv_app_users where id = auth.uid() $$;

create or replace function posinv_is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select coalesce((select is_admin from posinv_app_users where id = auth.uid()), false) $$;

create or replace function posinv_store_is_active(sid uuid) returns boolean
language sql stable security definer set search_path = public as
$$ select coalesce((select active from posinv_stores where id = sid), false) $$;

-- ---------- 6) Signup trigger: auto-profile + auto-admin ----------
create or replace function posinv_handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare demo uuid;
begin
  insert into public.posinv_app_users (id, name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), 'Staff')
  on conflict (id) do nothing;
  if lower(new.email) = 'cheikh.ahmed@amc4consulting.com' then
    select id into demo from posinv_stores where name = 'Demo Store' limit 1;
    update posinv_app_users set is_admin = true, store_id = coalesce(store_id, demo) where id = new.id;
    update posinv_stores set owner_id = new.id where id = demo and owner_id is null;
  end if;
  return new;
end; $$;

-- If the admin account already exists, promote it now.
do $$
declare uid uuid; demo uuid;
begin
  select id into demo from posinv_stores where name = 'Demo Store' limit 1;
  select id into uid from auth.users where lower(email) = 'cheikh.ahmed@amc4consulting.com' limit 1;
  if uid is not null then
    update posinv_app_users set is_admin = true, store_id = coalesce(store_id, demo) where id = uid;
    update posinv_stores set owner_id = coalesce(owner_id, uid) where id = demo;
  end if;
end $$;

-- ---------- 7) SECURITY: per-store isolation + subscription gate ----------
-- Old single-store policies (including the anon read used by Excel) go away.
drop policy if exists read_products   on posinv_products;
drop policy if exists read_customers  on posinv_customers;
drop policy if exists read_vendors    on posinv_vendors;
drop policy if exists read_orders     on posinv_orders;
drop policy if exists read_items      on posinv_order_items;
drop policy if exists read_app_users  on posinv_app_users;
drop policy if exists write_orders    on posinv_orders;
drop policy if exists update_orders   on posinv_orders;
drop policy if exists write_items     on posinv_order_items;
drop policy if exists write_products  on posinv_products;
drop policy if exists update_products on posinv_products;

-- profiles: you see yourself; admin sees everyone; nobody can self-promote to admin
drop policy if exists au_select       on posinv_app_users;
drop policy if exists au_update_self  on posinv_app_users;
drop policy if exists au_admin_update on posinv_app_users;
create policy au_select on posinv_app_users for select to authenticated
  using (id = auth.uid() or posinv_is_admin());
create policy au_update_self on posinv_app_users for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid() and (coalesce(is_admin, false) = false or posinv_is_admin()));
create policy au_admin_update on posinv_app_users for update to authenticated
  using (posinv_is_admin()) with check (posinv_is_admin());

-- stores: owners see their store; admin sees + updates all; new stores always start disabled
drop policy if exists st_select       on posinv_stores;
drop policy if exists st_insert_own   on posinv_stores;
drop policy if exists st_admin_update on posinv_stores;
create policy st_select on posinv_stores for select to authenticated
  using (owner_id = auth.uid() or id = posinv_my_store() or posinv_is_admin());
create policy st_insert_own on posinv_stores for insert to authenticated
  with check (owner_id = auth.uid() and active = false);
create policy st_admin_update on posinv_stores for update to authenticated
  using (posinv_is_admin()) with check (posinv_is_admin());

-- products: read your store; write only while the subscription is active
drop policy if exists pr_select on posinv_products;
drop policy if exists pr_insert on posinv_products;
drop policy if exists pr_update on posinv_products;
create policy pr_select on posinv_products for select to authenticated
  using (store_id = posinv_my_store() or posinv_is_admin());
create policy pr_insert on posinv_products for insert to authenticated
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id));
create policy pr_update on posinv_products for update to authenticated
  using (store_id = posinv_my_store() and posinv_store_is_active(store_id))
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id));

-- customers / vendors
drop policy if exists cu_select on posinv_customers;
drop policy if exists cu_insert on posinv_customers;
create policy cu_select on posinv_customers for select to authenticated
  using (store_id = posinv_my_store() or posinv_is_admin());
create policy cu_insert on posinv_customers for insert to authenticated
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id));
drop policy if exists ve_select on posinv_vendors;
drop policy if exists ve_insert on posinv_vendors;
create policy ve_select on posinv_vendors for select to authenticated
  using (store_id = posinv_my_store() or posinv_is_admin());
create policy ve_insert on posinv_vendors for insert to authenticated
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id));

-- orders + items: same rule — your store, and only while active
drop policy if exists o_select on posinv_orders;
drop policy if exists o_insert on posinv_orders;
drop policy if exists o_update on posinv_orders;
create policy o_select on posinv_orders for select to authenticated
  using (store_id = posinv_my_store() or posinv_is_admin());
create policy o_insert on posinv_orders for insert to authenticated
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id) and created_by = auth.uid());
create policy o_update on posinv_orders for update to authenticated
  using (store_id = posinv_my_store() and posinv_store_is_active(store_id))
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id));
drop policy if exists oi_select on posinv_order_items;
drop policy if exists oi_insert on posinv_order_items;
create policy oi_select on posinv_order_items for select to authenticated
  using (store_id = posinv_my_store() or posinv_is_admin());
create policy oi_insert on posinv_order_items for insert to authenticated
  with check (store_id = posinv_my_store() and posinv_store_is_active(store_id));

-- ---------- 8) Views rebuilt with store scoping ----------
drop view if exists posinv_sales_report;
drop view if exists posinv_inventory;

create view posinv_inventory
with (security_invoker = on) as
select
  p.store_id, p.sku, p.name, p.category, p.subcategory,
  p.opening_stock
    + coalesce(sum(case when o.type='PURCHASE' and o.status not in ('Void','Refund')
                        then oi.qty else 0 end), 0)
    - coalesce(sum(case when o.type='SALE'     and o.status not in ('Void','Refund')
                        then oi.qty else 0 end), 0) as on_hand
from posinv_products p
left join posinv_order_items oi on oi.sku = p.sku and oi.store_id = p.store_id
left join posinv_orders o        on o.id  = oi.order_id
group by p.store_id, p.sku, p.name, p.category, p.subcategory, p.opening_stock;

create view posinv_sales_report
with (security_invoker = on) as
select
  o.store_id,
  o.id            as order_id,
  o.order_on,
  o.status,
  o.party         as customer,
  o.user_name     as cashier,
  oi.sku,
  oi.product_name,
  oi.qty,
  oi.amount       as unit_price,
  oi.disc_pct,
  oi.line_total,
  o.total_paid    as order_total
from posinv_orders o
join posinv_order_items oi on oi.order_id = o.id
where o.type = 'SALE'
order by o.order_on desc;

-- ---------- 9) Excel sync: per-store, token-protected ----------
-- Excel calls this with the store's secret report_token (shown in the
-- Admin tab). Wrong/missing token = zero rows. Read-only by design.
create or replace function posinv_sales_report_x(token uuid)
returns table(
  order_id bigint, order_on timestamptz, status text, customer text,
  cashier text, sku text, product_name text, qty numeric, unit_price numeric,
  disc_pct numeric, line_total numeric, order_total numeric)
language sql stable security definer set search_path = public as $$
  select o.id, o.order_on, o.status, o.party, o.user_name,
         oi.sku, oi.product_name, oi.qty, oi.amount, oi.disc_pct,
         oi.line_total, o.total_paid
  from posinv_orders o
  join posinv_order_items oi on oi.order_id = o.id
  where o.type = 'SALE'
    and o.store_id = (select s.id from posinv_stores s where s.report_token = token)
  order by o.order_on desc
$$;
revoke all on function posinv_sales_report_x(uuid) from public;
grant execute on function posinv_sales_report_x(uuid) to anon, authenticated;
