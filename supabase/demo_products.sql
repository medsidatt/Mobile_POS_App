-- ============================================================
--  DEMO PRODUCTS for the Demo Store only (optional).
--  Real barcodes + photos (Open Food Facts, ODbL) so live
--  scanning works in demos. Prices are example MRU values.
--  Run AFTER setup.sql. Safe to re-run. Real stores are
--  never affected — this touches only the Demo Store.
-- ============================================================
insert into posinv_products (sku,name,category,subcategory,purchase_price,sales_price,image_url,store_id) values
('5449000054227','Coca-Cola Original Taste','Drinks & Beverages','Soda',11,25,'https://images.openfoodfacts.org/images/products/544/900/005/4227/front_en.543.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111035000430','Sidi Ali Mineral Water','Drinks & Beverages','Drinking Water',4,12,'https://images.openfoodfacts.org/images/products/611/103/500/0430/front_en.104.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111035003035','Oulmes Sparkling Water','Drinks & Beverages','Drinking Water',6,16,'https://images.openfoodfacts.org/images/products/611/103/500/3035/front_en.61.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111128000071','Ain Saiss Mineral Water','Drinks & Beverages','Drinking Water',4,12,'https://images.openfoodfacts.org/images/products/611/112/800/0071/front_fr.62.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111035000058','Natural Mineral Water 1.5L','Drinks & Beverages','Drinking Water',5,14,'https://images.openfoodfacts.org/images/products/611/103/500/0058/front_en.134.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111203006653','Cheddar Cheese Slices','Dairy & Eggs','Cheese',22,43,'https://images.openfoodfacts.org/images/products/611/120/300/6653/front_ar.14.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111246721278','Cream Cheese','Dairy & Eggs','Cheese',18,35,'https://images.openfoodfacts.org/images/products/611/124/672/1278/front_en.4.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111246721261','Fromage Blanc Nature','Dairy & Eggs','Cheese',13,28,'https://images.openfoodfacts.org/images/products/611/124/672/1261/front_fr.118.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3329770077003','Skyr Plain 0%','Dairy & Eggs','Yogurt',14,30,'https://images.openfoodfacts.org/images/products/332/977/007/7003/front_en.164.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111242100206','Plain Yogurt','Dairy & Eggs','Yogurt',6,15,'https://images.openfoodfacts.org/images/products/611/124/210/0206/front_en.38.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111266962187','Fresh Farm Milk 1L','Dairy & Eggs','Fresh Milk',8,18,'https://images.openfoodfacts.org/images/products/611/126/696/2187/front_fr.56.200.jpg',(select id from posinv_stores where name='Demo Store')),
('6111242101180','UHT Whole Milk 1L','Dairy & Eggs','Fresh Milk',8,17,'https://images.openfoodfacts.org/images/products/611/124/210/1180/front_fr.79.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3760049790214','Organic Sliced Bread','Breads & Cereals','Bread',14,30,'https://images.openfoodfacts.org/images/products/376/004/979/0214/front_en.262.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3228857002344','American Sandwich Bread','Breads & Cereals','Bread',15,32,'https://images.openfoodfacts.org/images/products/322/885/700/2344/front_fr.117.200.jpg',(select id from posinv_stores where name='Demo Store')),
('7311070032611','Krisprolls Wholegrain','Breads & Cereals','Bread',19,38,'https://images.openfoodfacts.org/images/products/731/107/003/2611/front_en.91.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3284230006408','Sliced Brioche','Breads & Cereals','Buns',17,35,'https://images.openfoodfacts.org/images/products/328/423/000/6408/front_en.160.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3168930010265','Crunchy Nut Muesli','Breads & Cereals','Healthy Cereal',24,46,'https://images.openfoodfacts.org/images/products/316/893/001/0265/front_en.297.200.jpg',(select id from posinv_stores where name='Demo Store')),
('7622210449283','Prince Chocolate Biscuits','Breads & Cereals','Cookies',13,27,'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_en.605.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3229820100234','Dark Chocolate Filled Biscuits','Breads & Cereals','Cookies',14,29,'https://images.openfoodfacts.org/images/products/322/982/010/0234/front_fr.246.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3017620422003','Nutella Hazelnut Spread','Breads & Cereals','Spreads',28,50,'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.879.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3046920029759','Lindt Excellence 90% Dark','Breads & Cereals','Cookies',22,40,'https://images.openfoodfacts.org/images/products/304/692/002/9759/front_en.544.200.jpg',(select id from posinv_stores where name='Demo Store')),
('3760020507350','Pure Peanut Butter','Breads & Cereals','Spreads',26,48,'https://images.openfoodfacts.org/images/products/376/002/050/7350/front_en.403.200.jpg',(select id from posinv_stores where name='Demo Store'))
on conflict (store_id,sku) do update set image_url = excluded.image_url;
