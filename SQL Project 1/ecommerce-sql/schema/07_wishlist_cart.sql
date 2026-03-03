-- ============================================================
-- Wishlist & Cart Tables (MySQL Version)
-- ============================================================

-- ---- WISHLISTS ----
CREATE TABLE IF NOT EXISTS wishlists (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE
);

CREATE INDEX idx_wishlists_user ON wishlists (user_id);

-- ---- CART ITEMS ----
CREATE TABLE IF NOT EXISTS cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE
);

CREATE INDEX idx_cart_items_user ON cart_items (user_id);

-- ============================================================
-- Sample Wishlist Data
-- ============================================================
INSERT INTO
    wishlists (user_id, product_id)
VALUES (1, 4), -- Aarav wishlisted MacBook Air M2
    (1, 5), -- Aarav wishlisted Dell XPS 15
    (2, 1), -- Priya wishlisted iPhone 15
    (3, 8), -- Rohit wishlisted Floral Kurta Set
    (4, 10), -- Sneha wishlisted Atomic Habits
    (5, 4), -- Karan wishlisted MacBook Air M2
    (6, 12), -- Divya wishlisted Yoga Mat
    (7, 3), -- Arjun wishlisted OnePlus 12
    (8, 6);
-- Pooja wishlisted Classic Oxford Shirt

-- ============================================================
-- Sample Cart Data
-- ============================================================
INSERT INTO
    cart_items (user_id, product_id, quantity)
VALUES (1, 10, 1), -- Aarav has Atomic Habits in cart
    (2, 4, 1), -- Priya has MacBook Air M2 in cart
    (3, 7, 2), -- Rohit has 2x Slim Fit Jeans in cart
    (4, 12, 1), -- Sneha has Yoga Mat in cart
    (5, 11, 1), -- Karan has Induction Cooktop in cart
    (8, 1, 1);
-- Pooja has iPhone 15 in cart