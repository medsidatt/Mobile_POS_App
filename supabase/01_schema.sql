-- ============================================================
--  MOBILE POS WITH INVENTORY  —  Supabase schema
--  Mirrors Randy's "POS With Inventory" Excel workbook.
--  All objects are prefixed  posinv_  so they will NOT collide
--  with any other tables in a shared Supabase project.
--  Run this FIRST in the Supabase SQL Editor.
-- ============================================================

-- ---------- clean slate (only touches posinv_* objects) ----------
drop view   if exists posinv_sales_report  cascade;
drop view   if exists posinv_inventory     cascade;
drop table  if exists posinv_order_items   cascade;
drop table  if exists posinv_orders        cascade;
drop table  if exists posinv_products      cascade;
drop table  if exists posinv_customers     cascade;
drop table  if exists posinv_vendors       cascade;
drop table  if exists posinv_app_users     cascade;

-- ---------- PRODUCTS ----------
create table posinv_products (
  sku            text primary key,
  name           text not null,
  category       text,
  subcategory    text,
  purchase_price numeric(10,2) default 0,
  sales_price    numeric(10,2) default 0,
  opening_stock  integer       default 100,   -- starting on-hand so the POS shows stock day 1
  active         boolean       default true,
  created_at     timestamptz   default now()
);
create index posinv_products_category_idx on posinv_products (category);

-- ---------- CUSTOMERS / VENDORS ----------
create table posinv_customers (
  id   bigint generated always as identity primary key,
  name text not null
);
create table posinv_vendors (
  id   bigint generated always as identity primary key,
  name text not null
);

-- ---------- APP USERS (profile linked to Supabase Auth) ----------
create table posinv_app_users (
  id         uuid primary key references auth.users on delete cascade,
  name       text,
  role       text default 'Staff' check (role in ('Manager','Staff','Trainee')),
  created_at timestamptz default now()
);

-- Auto-create a profile row when someone signs up.
create or replace function posinv_handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.posinv_app_users (id, name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), 'Staff')
  on conflict (id) do nothing;
  return new;
end; $$;

drop trigger if exists posinv_on_auth_user_created on auth.users;
create trigger posinv_on_auth_user_created
  after insert on auth.users
  for each row execute function posinv_handle_new_user();

-- ---------- ORDERS ----------
-- Order IDs start at 10000 to match the Excel workbook.
create sequence if not exists posinv_order_id_seq start 10000;

create table posinv_orders (
  id         bigint primary key default nextval('posinv_order_id_seq'),
  order_on   timestamptz not null default now(),
  type       text not null default 'SALE'  check (type in ('SALE','PURCHASE')),
  status     text not null default 'Paid'  check (status in ('Open','Paid','Refund','Void')),
  party      text,                 -- customer name (SALE) or vendor name (PURCHASE)
  user_name  text,                 -- cashier name, for the receipt / Excel report
  total_paid numeric(10,2) default 0,
  created_by uuid references auth.users
);
alter sequence posinv_order_id_seq owned by posinv_orders.id;

-- ---------- ORDER ITEMS ----------
create table posinv_order_items (
  id           bigint generated always as identity primary key,
  order_id     bigint not null references posinv_orders(id) on delete cascade,
  type         text,
  sku          text,
  product_name text,
  qty          numeric(10,2) default 1,
  amount       numeric(10,2) default 0,   -- unit price
  disc_pct     numeric(5,4)  default 0,   -- 0.10 = 10%
  line_total   numeric(10,2) default 0
);
create index posinv_order_items_order_idx on posinv_order_items (order_id);
create index posinv_order_items_sku_idx   on posinv_order_items (sku);

-- ============================================================
--  VIEWS
-- ============================================================

-- Live inventory: opening stock + purchases - sales (Void/Refund excluded).
create view posinv_inventory
with (security_invoker = on) as
select
  p.sku,
  p.name,
  p.category,
  p.subcategory,
  p.opening_stock
    + coalesce(sum(case when o.type='PURCHASE' and o.status not in ('Void','Refund')
                        then oi.qty else 0 end), 0)
    - coalesce(sum(case when o.type='SALE'     and o.status not in ('Void','Refund')
                        then oi.qty else 0 end), 0) as on_hand
from posinv_products p
left join posinv_order_items oi on oi.sku = p.sku
left join posinv_orders o        on o.id  = oi.order_id
group by p.sku, p.name, p.category, p.subcategory, p.opening_stock;

-- Flattened SALES lines — this is what Excel Power Query pulls in.
create view posinv_sales_report
with (security_invoker = on) as
select
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

-- ============================================================
--  ROW LEVEL SECURITY   (one-way sync: Excel reads, never writes)
-- ============================================================
alter table posinv_products    enable row level security;
alter table posinv_customers   enable row level security;
alter table posinv_vendors     enable row level security;
alter table posinv_orders      enable row level security;
alter table posinv_order_items enable row level security;
alter table posinv_app_users   enable row level security;

-- READ: everyone (anon = Excel + authenticated = app) can SELECT.
create policy read_products   on posinv_products    for select using (true);
create policy read_customers  on posinv_customers   for select using (true);
create policy read_vendors    on posinv_vendors     for select using (true);
create policy read_orders     on posinv_orders      for select using (true);
create policy read_items      on posinv_order_items for select using (true);
create policy read_app_users  on posinv_app_users   for select using (true);

-- WRITE: only logged-in app users can create sales. Excel's anon key cannot.
create policy write_orders    on posinv_orders
  for insert to authenticated with check (true);

-- Cashiers may update an order (e.g. mark it Refund / Void).
create policy update_orders   on posinv_orders
  for update to authenticated using (true) with check (true);

-- Cashiers may add the line items that belong to their orders.
create policy write_items     on posinv_order_items
  for insert to authenticated with check (true);
