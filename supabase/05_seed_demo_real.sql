-- ============================================================
--  REAL DEMO PRODUCTS from Open Food Facts (open data, ODbL).
--  Real barcodes + real product photos. Great for filming:
--  scan a real item and its real photo appears.
--  Run AFTER 01_schema.sql AND 04_add_images.sql.
-- ============================================================
insert into posinv_products (sku,name,category,subcategory,purchase_price,sales_price,image_url) values
('5449000054227','Coca-Cola Original Taste','Drinks & Beverages','Soda',1.10,2.49,'https://images.openfoodfacts.org/images/products/544/900/005/4227/front_en.543.200.jpg'),
('6111035000430','Sidi Ali Mineral Water','Drinks & Beverages','Drinking Water',0.45,1.25,'https://images.openfoodfacts.org/images/products/611/103/500/0430/front_en.104.200.jpg'),
('6111035003035','Oulmes Sparkling Water','Drinks & Beverages','Drinking Water',0.60,1.60,'https://images.openfoodfacts.org/images/products/611/103/500/3035/front_en.61.200.jpg'),
('6111128000071','Ain Saiss Mineral Water','Drinks & Beverages','Drinking Water',0.45,1.25,'https://images.openfoodfacts.org/images/products/611/112/800/0071/front_fr.62.200.jpg'),
('6111035000058','Natural Mineral Water 1.5L','Drinks & Beverages','Drinking Water',0.50,1.40,'https://images.openfoodfacts.org/images/products/611/103/500/0058/front_en.134.200.jpg'),
('6111203006653','Cheddar Cheese Slices','Dairy & Eggs','Cheese',2.20,4.29,'https://images.openfoodfacts.org/images/products/611/120/300/6653/front_ar.14.200.jpg'),
('6111246721278','Cream Cheese','Dairy & Eggs','Cheese',1.80,3.49,'https://images.openfoodfacts.org/images/products/611/124/672/1278/front_en.4.200.jpg'),
('6111246721261','Fromage Blanc Nature','Dairy & Eggs','Cheese',1.30,2.79,'https://images.openfoodfacts.org/images/products/611/124/672/1261/front_fr.118.200.jpg'),
('3329770077003','Skyr Plain 0%','Dairy & Eggs','Yogurt',1.40,2.99,'https://images.openfoodfacts.org/images/products/332/977/007/7003/front_en.164.200.jpg'),
('6111242100206','Plain Yogurt','Dairy & Eggs','Yogurt',0.60,1.49,'https://images.openfoodfacts.org/images/products/611/124/210/0206/front_en.38.200.jpg'),
('6111266962187','Fresh Farm Milk 1L','Dairy & Eggs','Fresh Milk',0.80,1.79,'https://images.openfoodfacts.org/images/products/611/126/696/2187/front_fr.56.200.jpg'),
('6111242101180','UHT Whole Milk 1L','Dairy & Eggs','Fresh Milk',0.75,1.69,'https://images.openfoodfacts.org/images/products/611/124/210/1180/front_fr.79.200.jpg'),
('3760049790214','Organic Sliced Bread','Breads & Cereals','Bread',1.40,2.99,'https://images.openfoodfacts.org/images/products/376/004/979/0214/front_en.262.200.jpg'),
('3228857002344','American Sandwich Bread','Breads & Cereals','Bread',1.50,3.19,'https://images.openfoodfacts.org/images/products/322/885/700/2344/front_fr.117.200.jpg'),
('7311070032611','Krisprolls Wholegrain','Breads & Cereals','Bread',1.90,3.79,'https://images.openfoodfacts.org/images/products/731/107/003/2611/front_en.91.200.jpg'),
('3284230006408','Sliced Brioche','Breads & Cereals','Buns',1.70,3.49,'https://images.openfoodfacts.org/images/products/328/423/000/6408/front_en.160.200.jpg'),
('3168930010265','Crunchy Nut Muesli','Breads & Cereals','Healthy Cereal',2.40,4.59,'https://images.openfoodfacts.org/images/products/316/893/001/0265/front_en.297.200.jpg'),
('7622210449283','Prince Chocolate Biscuits','Breads & Cereals','Cookies',1.30,2.69,'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_en.605.200.jpg'),
('3229820100234','Dark Chocolate Filled Biscuits','Breads & Cereals','Cookies',1.40,2.89,'https://images.openfoodfacts.org/images/products/322/982/010/0234/front_fr.246.200.jpg'),
('3017620422003','Nutella Hazelnut Spread','Breads & Cereals','Spreads',2.80,4.99,'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.879.200.jpg'),
('3046920029759','Lindt Excellence 90% Dark','Breads & Cereals','Cookies',2.20,3.99,'https://images.openfoodfacts.org/images/products/304/692/002/9759/front_en.544.200.jpg'),
('3760020507350','Pure Peanut Butter','Breads & Cereals','Spreads',2.60,4.79,'https://images.openfoodfacts.org/images/products/376/002/050/7350/front_en.403.200.jpg')
on conflict (sku) do update set image_url = excluded.image_url;
