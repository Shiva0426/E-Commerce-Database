-- ============================================================
-- Sample Data for E-Commerce Database (MySQL Version)
-- ============================================================

-- USERS
INSERT INTO users (first_name, last_name, email, phone, password_hash) VALUES
('Aarav',   'Sharma',  'aarav.sharma@email.com',  '9876543210', 'hashed_pw_1'),
('Priya',   'Patel',   'priya.patel@email.com',   '9123456789', 'hashed_pw_2'),
('Rohit',   'Verma',   'rohit.verma@email.com',   '9988776655', 'hashed_pw_3'),
('Sneha',   'Iyer',    'sneha.iyer@email.com',    '9876012345', 'hashed_pw_4'),
('Karan',   'Mehta',   'karan.mehta@email.com',   '9001234567', 'hashed_pw_5'),
('Divya',   'Nair',    'divya.nair@email.com',    '9876543000', 'hashed_pw_6'),
('Arjun',   'Gupta',   'arjun.gupta@email.com',   '9111222333', 'hashed_pw_7'),
('Pooja',   'Singh',   'pooja.singh@email.com',   '9444555666', 'hashed_pw_8');

-- ADDRESSES
INSERT INTO addresses (user_id, label, street, city, state, postal_code, country, is_default) VALUES
(1, 'home', '12 MG Road',       'Bengaluru',  'Karnataka',     '560001', 'India', 1),
(2, 'home', '45 Anna Nagar',    'Chennai',    'Tamil Nadu',    '600040', 'India', 1),
(3, 'work', '7 Connaught Place','New Delhi',  'Delhi',         '110001', 'India', 1),
(4, 'home', '88 Bandra West',   'Mumbai',     'Maharashtra',   '400050', 'India', 1),
(5, 'home', '3 Park Street',    'Kolkata',    'West Bengal',   '700016', 'India', 1),
(6, 'home', '22 Jubilee Hills', 'Hyderabad',  'Telangana',     '500033', 'India', 1),
(7, 'home', '9 Civil Lines',    'Jaipur',     'Rajasthan',     '302006', 'India', 1),
(8, 'home', '56 FC Road',       'Pune',       'Maharashtra',   '411004', 'India', 1);

-- CATEGORIES (with sub-categories)
INSERT INTO categories (name, parent_id, description) VALUES
('Electronics',   NULL, 'All electronic devices and accessories'),
('Clothing',      NULL, 'Men and women apparel'),
('Books',         NULL, 'Physical and digital books'),
('Home & Kitchen',NULL, 'Furniture, appliances, and kitchenware'),
('Sports',        NULL, 'Sports equipment and fitness gear'),
('Mobiles',       1,    'Smartphones and accessories'),
('Laptops',       1,    'Laptops and peripherals'),
('Men''s Wear',   2,    'Shirts, trousers, jeans for men'),
('Women''s Wear', 2,    'Kurtas, sarees, tops for women'),
('Fiction',       3,    'Fiction novels and stories'),
('Non-Fiction',   3,    'Self-help, biography, science books');

-- PRODUCTS
INSERT INTO products (category_id, name, description, price, stock_qty, sku, brand) VALUES
(6,  'iPhone 15',             'Apple iPhone 15 128GB Blue',             79999, 50,  'APL-IP15-128-BLU', 'Apple'),
(6,  'Samsung Galaxy S24',    'Samsung Galaxy S24 256GB Phantom Black', 74999, 35,  'SAM-S24-256-BLK',  'Samsung'),
(6,  'OnePlus 12',            'OnePlus 12 256GB Flowy Emerald',         64999, 60,  'OP-12-256-GRN',    'OnePlus'),
(7,  'MacBook Air M2',        'Apple MacBook Air 13-inch M2 Chip 8GB',  114999,20,  'APL-MBA-M2-8GB',   'Apple'),
(7,  'Dell XPS 15',           'Dell XPS 15 Intel i7 16GB 512GB SSD',    129999,15,  'DEL-XPS15-I7-16',  'Dell'),
(8,  'Classic Oxford Shirt',  'Men cotton Oxford shirt slim fit',        1299, 200, 'CLO-MEN-OXF-S',    'FabIndia'),
(8,  'Slim Fit Jeans',        'Men dark blue slim fit jeans',            1999, 150, 'CLO-MEN-JNS-BLU',  'Levis'),
(9,  'Floral Kurta Set',      'Women cotton floral kurta with dupatta',  1799, 180, 'CLO-WOM-KUR-FLR',  'Biba'),
(10, 'The Alchemist',         'Paulo Coelho bestselling novel',          299,  500, 'BK-FIC-ALC-PC',    'HarperCollins'),
(10, 'Atomic Habits',         'James Clear - Build good habits',         399,  400, 'BK-NFC-AHB-JC',    'Penguin'),
(4,  'Prestige Induction Cooktop','1600W induction cooktop with timer',  2499, 80,  'HK-IND-PRE-1600',  'Prestige'),
(5,  'Yoga Mat',              'Anti-slip 6mm thick yoga mat',            799,  250, 'SPT-YOG-MAT-6MM',  'Boldfit');

-- PRODUCT IMAGES
INSERT INTO product_images (product_id, image_url, is_primary) VALUES
(1,  'https://images.example.com/iphone15_front.jpg',    1),
(1,  'https://images.example.com/iphone15_back.jpg',     0),
(2,  'https://images.example.com/galaxys24_front.jpg',   1),
(3,  'https://images.example.com/oneplus12_front.jpg',   1),
(4,  'https://images.example.com/macbookarim2.jpg',      1),
(5,  'https://images.example.com/dellxps15.jpg',         1),
(9,  'https://images.example.com/alchemist_cover.jpg',   1),
(10, 'https://images.example.com/atomichabits_cover.jpg',1);

-- ORDERS
INSERT INTO orders (user_id, address_id, status, total_amount, discount_amount, tax_amount, shipping_fee) VALUES
(1, 1, 'delivered', 80998.00, 1000, 7199, 0),
(2, 2, 'shipped',   65299.00, 700,  5827, 0),
(3, 3, 'confirmed', 1598.00,  0,    143,  49),
(4, 4, 'pending',   115199.00,800,  10296, 0),
(5, 5, 'delivered', 698.00,   0,    62,   49),
(6, 6, 'cancelled', 74999.00, 0,    6699, 0),
(7, 7, 'delivered', 3298.00,  200,  277,  0),
(8, 8, 'shipped',   2798.00,  0,    250,  49);

-- ORDER ITEMS
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1,  1, 79999),  -- iPhone 15
(1, 9,  1, 299),    -- The Alchemist
(2, 3,  1, 64999),  -- OnePlus 12
(2, 10, 1, 399),    -- Atomic Habits
(3, 6,  1, 1299),   -- Oxford Shirt
(3, 9,  1, 299),    -- The Alchemist
(4, 4,  1, 114999), -- MacBook Air M2
(5, 9,  1, 299),    -- The Alchemist
(5, 10, 1, 399),    -- Atomic Habits
(6, 2,  1, 74999),  -- Galaxy S24 (cancelled)
(7, 11, 1, 2499),   -- Induction Cooktop
(7, 12, 1, 799),    -- Yoga Mat
(8, 8,  1, 1799),   -- Floral Kurta
(8, 10, 2, 399);    -- Atomic Habits x2

-- PAYMENTS
INSERT INTO payments (order_id, amount, method, status, transaction_id, paid_at) VALUES
(1, 80998.00, 'upi',         'completed', 'TXN10001ABC', '2024-01-10 10:30:00'),
(2, 65299.00, 'credit_card', 'completed', 'TXN10002DEF', '2024-01-15 14:15:00'),
(3, 1598.00,  'net_banking', 'completed', 'TXN10003GHI', '2024-01-18 09:45:00'),
(4, 115199.00,'upi',         'pending',   NULL,           NULL),
(5, 698.00,   'cod',         'completed', 'TXN10005JKL', '2024-02-01 17:00:00'),
(6, 74999.00, 'credit_card', 'refunded',  'TXN10006MNO', '2024-02-05 11:20:00'),
(7, 3298.00,  'wallet',      'completed', 'TXN10007PQR', '2024-02-10 08:10:00'),
(8, 2798.00,  'upi',         'completed', 'TXN10008STU', '2024-02-14 13:55:00');

-- REVIEWS
INSERT INTO reviews (product_id, user_id, rating, title, body, is_verified) VALUES
(1,  1, 5, 'Excellent phone!',       'Camera quality is top notch. Very happy.',          1),
(3,  2, 4, 'Great value phone',      'Good performance. Battery could be better.',         1),
(9,  5, 5, 'Life changing book',     'Everyone must read this. Beautifully written.',      1),
(10, 2, 5, 'Best self-help book',    'Changed my habits completely. Highly recommend.',    1),
(4,  4, 5, 'Amazing laptop',         'M2 chip is blazing fast. Worth every rupee.',        0),
(11, 7, 4, 'Good cooktop',           'Heats up fast, easy to clean. Happy with purchase.', 1),
(12, 7, 5, 'Best yoga mat',          'Non-slip, thick and comfortable.',                   1),
(8,  8, 4, 'Pretty kurta set',       'Good quality fabric. Fits true to size.',            1);