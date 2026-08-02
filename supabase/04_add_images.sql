-- ============================================================
--  Adds an image_url column to products so each item can show
--  a photo. Products without a photo fall back to a branded
--  category tile in the app. Safe to re-run.
--  Run AFTER 01_schema.sql.
-- ============================================================
alter table posinv_products add column if not exists image_url text;
