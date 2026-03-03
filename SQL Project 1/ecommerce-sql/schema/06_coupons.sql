-- ============================================================
-- Coupons / Discount Codes Table (MySQL Version)
-- ============================================================

CREATE TABLE IF NOT EXISTS coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    discount_type ENUM('percent', 'flat') NOT NULL DEFAULT 'percent',
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    max_discount DECIMAL(10, 2) DEFAULT NULL,
    max_uses INT DEFAULT NULL,
    times_used INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    starts_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coupons_code ON coupons (code);

-- ============================================================
-- Sample Coupon Data
-- ============================================================

INSERT INTO
    coupons (
        code,
        description,
        discount_type,
        discount_value,
        min_order_amount,
        max_discount,
        max_uses,
        is_active,
        starts_at,
        expires_at
    )
VALUES (
        'WELCOME10',
        '10% off for new users',
        'percent',
        10.00,
        500.00,
        1000.00,
        NULL,
        1,
        '2024-01-01 00:00:00',
        '2025-12-31 23:59:59'
    ),
    (
        'FLAT500',
        'Flat ₹500 off on orders above ₹5000',
        'flat',
        500.00,
        5000.00,
        NULL,
        100,
        1,
        '2024-01-01 00:00:00',
        '2025-06-30 23:59:59'
    ),
    (
        'SUMMER20',
        '20% off summer sale',
        'percent',
        20.00,
        1000.00,
        2000.00,
        500,
        1,
        '2024-04-01 00:00:00',
        '2024-06-30 23:59:59'
    ),
    (
        'ELECTRONICS15',
        '15% off on electronics',
        'percent',
        15.00,
        10000.00,
        5000.00,
        200,
        1,
        '2024-01-01 00:00:00',
        '2025-12-31 23:59:59'
    ),
    (
        'FREESHIP',
        'Free shipping on orders above ₹999',
        'flat',
        49.00,
        999.00,
        NULL,
        NULL,
        1,
        '2024-01-01 00:00:00',
        '2025-12-31 23:59:59'
    );