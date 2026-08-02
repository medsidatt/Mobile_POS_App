-- ============================================================
--  VEHICLE KEYS & ACCESSORIES catalog seed (optional).
--  Loads a realistic starter catalog into ONE store.
--
--  >>> EDIT THE STORE NAME on the next line before running <<<
--  (must match the store's exact name as shown in the Admin tab)
--  Prices are example MRU values — adjust freely in the app or here.
--  Run AFTER setup.sql. Safe to re-run.
-- ============================================================
with target as (select id from posinv_stores where name = 'Demo Store')
insert into posinv_products (sku,name,category,subcategory,purchase_price,sales_price,opening_stock,store_id)
select v.*, target.id from (values
  -- Car Keys (complete remote keys, by brand)
  ('KEY-TOY-3B',   'Toyota 3-Button Remote Key',        'Car Keys','Toyota',   1200, 2500, 10),
  ('KEY-TOY-SMART','Toyota Smart Key (Keyless)',        'Car Keys','Toyota',   2500, 4500, 5),
  ('KEY-NIS-3B',   'Nissan 3-Button Remote Key',        'Car Keys','Nissan',   1100, 2300, 10),
  ('KEY-HYU-3B',   'Hyundai 3-Button Remote Key',       'Car Keys','Hyundai',  1000, 2200, 10),
  ('KEY-KIA-3B',   'Kia 3-Button Remote Key',           'Car Keys','Kia',      1000, 2200, 10),
  ('KEY-MB-SMART', 'Mercedes-Benz Smart Key',           'Car Keys','Mercedes', 3500, 6500, 3),
  ('KEY-REN-CARD', 'Renault Key Card',                  'Car Keys','Renault',  1800, 3500, 5),
  ('KEY-MIT-2B',   'Mitsubishi 2-Button Remote Key',    'Car Keys','Mitsubishi',1000, 2100, 8),
  -- Key Shells & Blades (replacement cases, uncut blades)
  ('SHL-TOY-3B',   'Toyota 3-Button Key Shell',         'Shells & Blades','Toyota',  150, 400, 30),
  ('SHL-NIS-3B',   'Nissan 3-Button Key Shell',         'Shells & Blades','Nissan',  150, 400, 30),
  ('SHL-HYU-FLIP', 'Hyundai Flip Key Shell',            'Shells & Blades','Hyundai', 180, 450, 25),
  ('BLD-TOY43',    'TOY43 Uncut Key Blade',             'Shells & Blades','Blades',   80, 250, 50),
  ('BLD-HYN14',    'HYN14 Uncut Key Blade',             'Shells & Blades','Blades',   80, 250, 50),
  ('BLD-NSN14',    'NSN14 Uncut Key Blade',             'Shells & Blades','Blades',   80, 250, 50),
  -- Transponder Chips
  ('CHP-4D67',     'Transponder Chip 4D67 (Toyota)',    'Transponder Chips','Toyota', 300, 800, 20),
  ('CHP-PCF7936',  'Transponder Chip PCF7936 (ID46)',   'Transponder Chips','Universal',280, 750, 20),
  ('CHP-8A',       'Transponder Chip 8A (Toyota H)',    'Transponder Chips','Toyota', 350, 900, 15),
  -- Batteries
  ('BAT-CR2032',   'Battery CR2032',                    'Batteries','Button Cells',  20,  80, 100),
  ('BAT-CR2025',   'Battery CR2025',                    'Batteries','Button Cells',  20,  80, 100),
  ('BAT-CR1620',   'Battery CR1620',                    'Batteries','Button Cells',  25, 100, 60),
  ('BAT-VL2330',   'Rechargeable Battery VL2330 (Renault)','Batteries','Button Cells',120, 350, 20),
  -- Accessories
  ('ACC-COVER-SIL','Silicone Key Cover',                'Accessories','Covers',      60, 200, 40),
  ('ACC-CHAIN-LTH','Leather Keychain',                  'Accessories','Keychains',   80, 250, 40),
  ('ACC-RING-SET', 'Key Rings Set (10 pcs)',            'Accessories','Keychains',   50, 150, 30),
  ('ACC-FINDER',   'Bluetooth Key Finder Tag',          'Accessories','Electronics', 250, 600, 15),
  -- Services (sold like products — no stock concern)
  ('SRV-CUT',      'Key Cutting Service',               'Services','Cutting',         0, 500, 999),
  ('SRV-PROG',     'Key Programming Service',           'Services','Programming',     0, 2000, 999),
  ('SRV-DUP',      'Key Duplication (Simple)',          'Services','Cutting',         0, 800, 999),
  ('SRV-UNLOCK',   'Car Unlock Service',                'Services','Emergency',       0, 1500, 999)
) as v(sku,name,category,subcategory,purchase_price,sales_price,opening_stock), target
on conflict (store_id,sku) do update
  set name = excluded.name, sales_price = excluded.sales_price;
