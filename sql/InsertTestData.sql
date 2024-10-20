-- Insertion test data
BEGIN;

-- INSERT Warehouses
INSERT INTO Warehouses VALUES (1, 'Арбор',   '+79167130067', 'arbor@rental.com',   '125315, г. Москва, ул. Усиевича, дом 18');
INSERT INTO Warehouses VALUES (2, 'Флюмен',  '+79162103495', 'flumen@rental.com',  '980371, г. Москва, ул. Брянская, дом 8');
INSERT INTO Warehouses VALUES (3, 'Гелидус', '+79165499144', 'gelidus@rental.com', '980178, г. Москва, ул. Краснопрудная, дом 11');
INSERT INTO Warehouses VALUES (4, 'Монтис',  '+79168251546', 'montis@rental.com',  '983182, г. Санкт-Петербург, пр-кт Испытателей, дом 31');
INSERT INTO Warehouses VALUES (5, 'Сильва',  '+79165946514', 'silva@rental.com',   '420127, Респ. Татарстан, г. Казань, ул. Максимова, дом 2');
SELECT setval('warehouses_id_seq', (SELECT MAX(id) FROM Warehouses));

-- INSERT Items
INSERT INTO Items VALUES (1,  1, 'плиткорез',                            'Для точной резки плитки и керамики.',                    91,  300,  400 );
INSERT INTO Items VALUES (2,  1, 'пневматический гайковерт',             'Для быстрого и эффективного закручивания гаек.',         62,  900,  1300);
INSERT INTO Items VALUES (3,  1, 'лазерный уровень',                     'Для точной установки и выравнивания объектов.',          100, 400,  600 );
INSERT INTO Items VALUES (4,  2, 'тележка с ручным подъемником',         'Для легкого подъема и перемещения грузов.',              85,  1200, 1500);
INSERT INTO Items VALUES (5,  2, 'складской робот',                      'Автоматизированное устройство для перемещения товаров.', 64,  4000, 5500);
INSERT INTO Items VALUES (6,  3, 'кран-балка',                           'Для перемещения тяжелых предметов в пределах склада.',   54,  4000, 5500);
INSERT INTO Items VALUES (7,  2, 'конвейер',                             'Используется для перемещения товаров на складе.',        80,  1500, 2000);
INSERT INTO Items VALUES (8,  1, 'электрический погрузчик',              'Используется для перемещения тяжелых грузов.',           56,  2000, 2500);
INSERT INTO Items VALUES (9,  4, 'сварочный аппарат',                    'Для сварки металлов и других материалов.',               0,   700,  1000);
INSERT INTO Items VALUES (10, 4, 'компрессор',                           'Для подачи сжатого воздуха.',                            10,  700,  1000);
INSERT INTO Items VALUES (11, 5, 'фрезерный станок',                     'Для точной фрезеровки различных материалов.',            77,  2500, 3000);
INSERT INTO Items VALUES (12, 1, 'газовый резак',                        'Для резки металлов и других твердых материалов.',        95,  600,  800 );
INSERT INTO Items VALUES (13, 5, 'дрель-шуруповерт',                     'Для сверления и закручивания шурупов.',                  68,  700,  900 );
INSERT INTO Items VALUES (14, 3, 'плоскогубцы с изолированными ручками', 'Для работы с электрическими проводами и кабелями.',      35,  200,  300 );
INSERT INTO Items VALUES (15, 3, 'бетононасос',                          'Для перекачивания бетона на строительных площадках.',    84,  4000, 5500);
INSERT INTO Items VALUES (16, 3, 'вакуумный упаковщик',                  'Для упаковки продуктов в вакуумной упаковке.',           90,  2000, 2400);
SELECT setval('items_id_seq', (SELECT MAX(id) FROM Items));

-- INSERT Categories
INSERT INTO Categories VALUES (1, 'Инструменты');
INSERT INTO Categories VALUES (2, 'Обработка');
INSERT INTO Categories VALUES (3, 'Электрика');
INSERT INTO Categories VALUES (4, 'Строительная техника');
INSERT INTO Categories VALUES (5, 'Промышленная машина');
INSERT INTO Categories VALUES (6, 'Подъемное оборудование');
INSERT INTO Categories VALUES (7, 'Автоматизация');
INSERT INTO Categories VALUES (8, 'Пневматика');
INSERT INTO Categories VALUES (9, 'Упаковка');
SELECT setval('categories_id_seq', (SELECT MAX(id) FROM Categories));

-- INSERT ItemsCategories
INSERT INTO ItemsCategories VALUES (1, 1);
INSERT INTO ItemsCategories VALUES (1, 2);
INSERT INTO ItemsCategories VALUES (2, 1);
INSERT INTO ItemsCategories VALUES (2, 3);
INSERT INTO ItemsCategories VALUES (3, 1);
INSERT INTO ItemsCategories VALUES (3, 4);
INSERT INTO ItemsCategories VALUES (4, 5);
INSERT INTO ItemsCategories VALUES (4, 6);
INSERT INTO ItemsCategories VALUES (5, 5);
INSERT INTO ItemsCategories VALUES (5, 7);
INSERT INTO ItemsCategories VALUES (6, 5);
INSERT INTO ItemsCategories VALUES (6, 6);
INSERT INTO ItemsCategories VALUES (7, 5);
INSERT INTO ItemsCategories VALUES (7, 7);
INSERT INTO ItemsCategories VALUES (8, 5);
INSERT INTO ItemsCategories VALUES (8, 6);
INSERT INTO ItemsCategories VALUES (9, 1);
INSERT INTO ItemsCategories VALUES (10, 1);
INSERT INTO ItemsCategories VALUES (10, 8);
INSERT INTO ItemsCategories VALUES (11, 5);
INSERT INTO ItemsCategories VALUES (11, 2);
INSERT INTO ItemsCategories VALUES (12, 1);
INSERT INTO ItemsCategories VALUES (12, 2);
INSERT INTO ItemsCategories VALUES (13, 1);
INSERT INTO ItemsCategories VALUES (14, 1);
INSERT INTO ItemsCategories VALUES (15, 5);
INSERT INTO ItemsCategories VALUES (15, 4);
INSERT INTO ItemsCategories VALUES (16, 5);
INSERT INTO ItemsCategories VALUES (16, 9);

-- INSERT Discounts
INSERT INTO Discounts VALUES (1, 'Недельная господдержка промышленного производства', 'По указу №5 президента РФ на промышленное оборудование возлагается скидка 10%', 10, NOW(),                     NOW() + INTERVAL '7 days');
INSERT INTO Discounts VALUES (2, 'Пора накачать колеса!',                             'Давно проверяли давление в шинах? Скидка 5% на аренду компрессора',              5, NOW() - INTERVAL '2 days', NOW() + INTERVAL '1 day');
SELECT setval('discounts_id_seq', (SELECT MAX(id) FROM Discounts));

-- INSERT ItemsDiscounts
INSERT INTO ItemsDiscounts
    SELECT i.id, 1
    FROM Items AS i 
    JOIN ItemsCategories AS ic  
        ON i.id = ic.item_id
    JOIN Categories AS c
        ON ic.category_id = c.id
    WHERE c.category_name = 'Промышленная машина';
INSERT INTO ItemsCategories VALUES (10, 2);

-- INSERT Customers
INSERT INTO Customers VALUES (1, 'Арсений',   'Корнилов', '+7(909)445-14-88', 'arseniy6950@mail.ru',         '980484 г. Москва, ш. Дмитровское, дом 131 к. 2',                                     '4128 355647');
INSERT INTO Customers VALUES (2, 'Лариса',    'Горелова', '+7(924)855-68-37', 'larisa58@mail.ru',            '918820 г. Москва, ул. Тимирязевская, дом 38/25',                                     '4794 949570');
INSERT INTO Customers VALUES (3, 'Иван',      'Аксаков',  '+7(962)409-79-76', 'ivan03071980@mail.ru',        '109147 г. Москва, ул. Марксистская, дом 9',                                          '4459 152953');
INSERT INTO Customers VALUES (4, 'Павел',     'Исаев',    '+7(909)189-17-81', 'pavel62@yandex.ru',           '119021 г. Москва, пр-кт Комсомольский, дом 3',                                       '4338 106639');
INSERT INTO Customers VALUES (5, 'Роман',     'Ельченко', '+7(971)778-40-29', 'roman4159@yandex.ru',         '141011 обл. Московская, г. Мытищи, ул. 4-я Парковая, дом 16',                        '4396 605504');
INSERT INTO Customers VALUES (6, 'Елизавета', 'Мишина',   '+7(936)970-45-53', 'elizaveta3412@yandex.ru',     '919216 обл Московская, г Долгопрудный, ш Старое Дмитровское, дом 15',                '4072 639447');
INSERT INTO Customers VALUES (7, 'Максим',    'Гребнев',  '+7(925)930-73-21', 'max47@rambler.ru',            '143402 обл. Московская, г. Красногорск, проезд Железнодорожный, дом 9',              '4522 205106');
INSERT INTO Customers VALUES (8, 'Дмитрий',   'Коршиков', '+7(908)329-79-43', 'dmitriy.korshikov@gmail.com', '980243 г. Москва, ул. Перовская, дом 8 к. 1',                                        '4041 379819');
INSERT INTO Customers VALUES (9, 'Григорий',  'Кубланов', '+7(908)302-45-12', 'grigoriy_kub@gmail.com',      '919935 обл. Московская, г. Балашиха, мкр. Железнодорожный, ул. Маяковского, дом 25', '4396 255125');
SELECT setval('customers_id_seq', (SELECT MAX(id) FROM Customers));

-- INSERT ItemsDecommissioning
INSERT INTO ItemsDecommissioning VALUES (1, 9, 'Сгорели блок питания и плата управления. Восстановление не рентабельно.');
SELECT setval('itemsdecommissioning_id_seq', (SELECT MAX(id) FROM ItemsDecommissioning));

-- INSERT ItemsServiceHistory
INSERT INTO ItemsServiceHistory(item_id, new_quality, change_reason) VALUES (2, 60, 'Треснул корпус');
SELECT setval('itemsservicehistory_id_seq', (SELECT MAX(id) FROM ItemsServiceHistory));

-- INSERT WarehousesOrdersHistory
ALTER SEQUENCE public.warehousesordershistory_id_seq RESTART WITH 5;
INSERT INTO WarehousesOrdersHistory VALUES (1, 5,  3, 2, NOW() - INTERVAL '7 days',  NOW() - INTERVAL '3 days',  NULL);
INSERT INTO WarehousesOrdersHistory VALUES (2, 10, 1, 4, NOW() - INTERVAL '30 days', NOW() - INTERVAL '26 days', NULL);
INSERT INTO WarehousesOrdersHistory VALUES (3, 9,  1, 4, NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days', NULL);
INSERT INTO WarehousesOrdersHistory VALUES (4, 13, 3, 5, NOW() - INTERVAL '15 days', NOW() - INTERVAL '6 days',  NULL);
SELECT setval('warehousesordershistory_id_seq', (SELECT MAX(id) FROM WarehousesOrdersHistory));

-- INSERT WarehousesOrders
ALTER SEQUENCE public.warehousesorders_id_seq RESTART WITH 5;
INSERT INTO WarehousesOrders(item_id, destination_warehouse_id) VALUES (7, 4);

COMMIT;