-- ============================================================
--  Enable ADD-PRODUCT from the app:
--   (1) let logged-in cashiers insert/update products
--   (2) a public image bucket so they can attach a photo
--  Run AFTER 01_schema.sql. Safe to re-run.
-- ============================================================

-- (1) Product writes for authenticated users -----------------
drop policy if exists write_products  on posinv_products;
drop policy if exists update_products on posinv_products;
create policy write_products  on posinv_products
  for insert to authenticated with check (true);
create policy update_products on posinv_products
  for update to authenticated using (true) with check (true);

-- (2) Public storage bucket for product photos ---------------
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

-- anyone can view photos (public bucket)
drop policy if exists "pos read product images" on storage.objects;
create policy "pos read product images" on storage.objects
  for select using (bucket_id = 'product-images');

-- logged-in cashiers can upload photos
drop policy if exists "pos upload product images" on storage.objects;
create policy "pos upload product images" on storage.objects
  for insert to authenticated with check (bucket_id = 'product-images');

-- and replace their own uploads (upsert)
drop policy if exists "pos update product images" on storage.objects;
create policy "pos update product images" on storage.objects
  for update to authenticated using (bucket_id = 'product-images') with check (bucket_id = 'product-images');
