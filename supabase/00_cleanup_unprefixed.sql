-- ============================================================
--  CLEANUP — removes the UN-PREFIXED objects created by the
--  first (old) schema run. They are empty (no seed data was
--  loaded), so nothing is lost.
--  Run this FIRST, then run 01_schema.sql (the posinv_ version).
--
--  ⚠ This drops tables named exactly products/orders/customers/
--    vendors/order_items/app_users. If you have your OWN tables
--    with these names that you want to keep, STOP and tell Randy's
--    assistant before running.
-- ============================================================

drop trigger  if exists on_auth_user_created on auth.users;
drop function if exists handle_new_user() cascade;

drop view     if exists sales_report  cascade;
drop view     if exists inventory     cascade;

drop table    if exists order_items   cascade;
drop table    if exists orders        cascade;
drop table    if exists products      cascade;
drop table    if exists customers     cascade;
drop table    if exists vendors       cascade;
drop table    if exists app_users     cascade;

drop sequence if exists order_id_seq  cascade;

-- Done. Now run 01_schema.sql, then the seed files.
