-- ============================================================
-- Triggers (MySQL Version)
-- Auto-update `updated_at` timestamps on row changes
-- ============================================================

-- ---- USERS: auto-update updated_at ----
DROP TRIGGER IF EXISTS trg_users_updated_at;

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
    SET NEW.updated_at = NOW();

-- ---- PRODUCTS: auto-update updated_at ----
DROP TRIGGER IF EXISTS trg_products_updated_at;

CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
    SET NEW.updated_at = NOW();

-- ---- ORDERS: auto-update updated_at ----
DROP TRIGGER IF EXISTS trg_orders_updated_at;

CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
    SET NEW.updated_at = NOW();