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
INSERT INTO Items VALUES (1,  1, 'плиткорез',                            'Для точной резки плитки и керамики.',                    NULL, 91,  300,  400 , FALSE, 'plitkorez.webp');
INSERT INTO Items VALUES (2,  1, 'пневматический гайковерт',             'Для быстрого и эффективного закручивания гаек.',         NULL, 62,  900,  1300, FALSE, 'pnevmaticheskij_gajkovert.webp');
INSERT INTO Items VALUES (3,  1, 'лазерный уровень',                     'Для точной установки и выравнивания объектов.',          NULL, 100, 400,  600 , FALSE, 'lazernyj_uroven.webp');
INSERT INTO Items VALUES (4,  2, 'тележка с ручным подъемником',         'Для легкого подъема и перемещения грузов.',              NULL, 85,  1200, 1500, FALSE, 'telezhka_s_ruchnym_podemnikom.webp');
INSERT INTO Items VALUES (5,  2, 'складской робот',                      'Автоматизированное устройство для перемещения товаров.', NULL, 64,  4000, 5500, FALSE, 'skladskoj_robot.webp');
INSERT INTO Items VALUES (6,  3, 'кран-балка',                           'Для перемещения тяжелых предметов в пределах склада.',   NULL, 54,  4000, 5500, FALSE, 'kran-balka.webp');
INSERT INTO Items VALUES (7,  2, 'конвейер',                             'Используется для перемещения товаров на складе.',        NULL, 80,  1500, 2000, FALSE, 'konvejer.webp');
INSERT INTO Items VALUES (8,  1, 'электрический погрузчик',              'Используется для перемещения тяжелых грузов.',           NULL, 56,  2000, 2500, FALSE, 'elektricheskij_pogruzchik.webp');
INSERT INTO Items VALUES (9,  4, 'сварочный аппарат',                    'Для сварки металлов и других материалов.',               NULL, 0,   700,  1000, FALSE, 'svarochnyj_apparat.webp');
INSERT INTO Items VALUES (10, 4, 'компрессор',                           'Для подачи сжатого воздуха.',                            NULL, 10,  700,  1000, FALSE, 'kompressor.webp');
INSERT INTO Items VALUES (11, 5, 'фрезерный станок',                     'Для точной фрезеровки различных материалов.',            NULL, 77,  2500, 3000, FALSE, 'frezernyj_stanok.webp');
INSERT INTO Items VALUES (12, 1, 'газовый резак',                        'Для резки металлов и других твердых материалов.',        NULL, 95,  600,  800,  FALSE, 'gazovyj_rezak.webp');
INSERT INTO Items VALUES (13, 5, 'дрель-шуруповерт',                     'Для сверления и закручивания шурупов.',                  NULL, 68,  700,  900,  FALSE, 'drel-shurupovert.webp');
INSERT INTO Items VALUES (14, 3, 'плоскогубцы с изолированными ручками', 'Для работы с электрическими проводами и кабелями.',      NULL, 35,  200,  300,  FALSE, 'ploskogubcy_s_izolirovannymi_ruchkami.webp');
INSERT INTO Items VALUES (15, 3, 'бетононасос',                          'Для перекачивания бетона на строительных площадках.',    NULL, 84,  4000, 5500, FALSE, 'betononasos.webp');
INSERT INTO Items VALUES (16, 3, 'вакуумный упаковщик',                  'Для упаковки продуктов в вакуумной упаковке.',           NULL, 90,  2000, 2400, FALSE, 'vakuumnyj_upakovschik.webp');
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
INSERT INTO Discounts VALUES (1, 'Недельная господдержка промышленного производства', 'По указу №5 президента РФ на промышленное оборудование возлагается скидка 10%', 10, NOW(), NOW() + INTERVAL '7 days');
INSERT INTO Discounts VALUES (2, 'Пора накачать колеса!',                             'Давно проверяли давление в шинах? Скидка 5% на аренду компрессора',              5, NOW(), NOW() + INTERVAL '3 day');
SELECT setval('discounts_id_seq', (SELECT MAX(id) FROM Discounts));

-- INSERT ItemsDiscounts - скидка на котегорию "Промышленная машина"
INSERT INTO ItemsDiscounts
    SELECT i.id, 1
    FROM Items AS i 
    JOIN ItemsCategories AS ic  
        ON i.id = ic.item_id
    JOIN Categories AS c
        ON ic.category_id = c.id
    WHERE c.category_name = 'Промышленная машина';
-- Скидка на компрессор
INSERT INTO ItemsCategories VALUES (10, 2);

-- INSERT CustomersAuth
INSERT INTO CustomersAuth VALUES (1, 'user1', '$2a$10$5HuBPDLMfeeTLRpLGE45T.E4P3Hsf/klVh49QE4aXg.uOkZovCyQe');
INSERT INTO CustomersAuth VALUES (2, 'user2', '$2a$10$ggSprWpngDlu67b3vJ1MgOS5RN/o4tmvHNBjXbPgQHTHr5FWHOvu6');
INSERT INTO CustomersAuth VALUES (3, 'user3', '$2a$10$SN0Yp3oLp69h9i1WlAhUbuA47ULaAnkq5YGs4FdgLivP6ix3i6Cem');
INSERT INTO CustomersAuth VALUES (4, 'user4', '$2a$10$ouT74F/az1issWaGZYz6nOhpcTX7ktrRciXQ1FpVYQciVcKX7H3KG');
INSERT INTO CustomersAuth VALUES (5, 'user5', '$2a$10$W/aQACmhkhGCUFVdBCiF4OuLWTORxubiDKMUZU8i9.WKGOZ7fcTuC');
INSERT INTO CustomersAuth VALUES (6, 'user6', '$2a$10$rx5Offi3VObA2LUgUR2yzu4HO2Txv3R3EVvI.ln2Qy81IR1ZTv.nm');
INSERT INTO CustomersAuth VALUES (7, 'user7', '$2a$10$L0aqk0w675Rt2f8EdNq5g.pFccEMcN0aJ8ExnXl89fJ1cXwLkKW1K');
INSERT INTO CustomersAuth VALUES (8, 'user8', '$2a$10$6EplL.Zn.EgEOjmOa5wp4.2JvHHhWE.yGrdB21Pce0QW6jcaFe9AC');
INSERT INTO CustomersAuth VALUES (9, 'user9', '$2a$10$LQxqrfHQ3zEeSC2ZWPjare9f4a4I7gsYXHjssn17eBRb5iYZFiADq');
SELECT setval('customersauth_id_seq', (SELECT MAX(id) FROM CustomersAuth));

-- INSERT CustomersInfo
UPDATE CustomersInfo SET firstname = 'Арсений',  lastname = 'Корнилов', phone = '+7(909)445-14-88', phone_verified = TRUE,  email = 'arseniy6950@mail.ru',         email_verified = TRUE,  passport = '4128 355647', passport_verified = TRUE  WHERE id = 1;
UPDATE CustomersInfo SET firstname = 'Лариса',   lastname = 'Горелова', phone = '+7(924)855-68-37', phone_verified = TRUE,  email = 'larisa58@mail.ru',            email_verified = FALSE, passport = '4794 949570', passport_verified = FALSE WHERE id = 2;
UPDATE CustomersInfo SET firstname = 'Иван',     lastname = 'Аксаков',  phone = '+7(962)409-79-76', phone_verified = TRUE,  email = 'ivan03071980@mail.ru',        email_verified = FALSE, passport = '4459 152953', passport_verified = TRUE  WHERE id = 3;
UPDATE CustomersInfo SET firstname = 'Павел',    lastname = 'Исаев',    phone = '+7(909)189-17-81', phone_verified = FALSE, email = 'pavel62@yandex.ru',           email_verified = FALSE, passport = '4338 106639', passport_verified = FALSE WHERE id = 4;
UPDATE CustomersInfo SET firstname = 'Роман',    lastname = 'Ельченко', phone = NULL,               phone_verified = FALSE, email = NULL,                          email_verified = FALSE, passport = NULL,          passport_verified = FALSE WHERE id = 5;
UPDATE CustomersInfo SET firstname = NULL,       lastname = NULL,       phone = NULL,               phone_verified = FALSE, email = NULL,                          email_verified = FALSE, passport = NULL,          passport_verified = FALSE WHERE id = 6;
UPDATE CustomersInfo SET firstname = 'Максим',   lastname = 'Гребнев',  phone = '+7(925)930-73-21', phone_verified = TRUE,  email = 'max47@rambler.ru',            email_verified = TRUE,  passport = '4522 205106', passport_verified = TRUE  WHERE id = 7;
UPDATE CustomersInfo SET firstname = 'Дмитрий',  lastname = 'Коршиков', phone = '+7(908)329-79-43', phone_verified = TRUE,  email = 'dmitriy.korshikov@gmail.com', email_verified = TRUE,  passport = NULL,          passport_verified = FALSE WHERE id = 8;
UPDATE CustomersInfo SET firstname = 'Григорий', lastname = 'Кубланов', phone = '+7(908)302-45-12', phone_verified = TRUE,  email = NULL,                          email_verified = FALSE, passport = '4396 255125', passport_verified = TRUE  WHERE id = 9;
SELECT setval('customersinfo_id_seq', (SELECT MAX(id) FROM CustomersInfo));

-- INSERT ItemsDecommissioning
INSERT INTO ItemsDecommissioning VALUES (1, 9, 'Сгорели блок питания и плата управления. Восстановление не рентабельно.');
SELECT setval('itemsdecommissioning_id_seq', (SELECT MAX(id) FROM ItemsDecommissioning));

-- INSERT ItemsServiceHistory
INSERT INTO ItemsServiceHistory(item_id, new_quality, change_reason) VALUES (2, 60, 'Треснул корпус');
SELECT setval('itemsservicehistory_id_seq', (SELECT MAX(id) FROM ItemsServiceHistory));

COMMIT;