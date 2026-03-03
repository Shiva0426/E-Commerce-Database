-- ============================================================
-- Stored Procedures (MySQL Version)
-- Order Placement Workflow
-- ============================================================

DELIMITER / /

-- ============================================================
-- PlaceOrder: Full order placement workflow
-- Accepts: user_id, address_id, JSON items array, payment method
-- Example: CALL PlaceOrder(1, 1, '[{"product_id":12,"quantity":2}]', 'upi');
-- ============================================================
CREATE PROCEDURE PlaceOrder(
    IN p_user_id INT,
    IN p_address_id INT,
    IN p_items JSON,
    IN p_payment_method VARCHAR(30)
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_item_count INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_item_subtotal DECIMAL(12,2);

    -- Error handler: rollback on any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order placement failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Get number of items in JSON array
    SET v_item_count = JSON_LENGTH(p_items);

    IF v_item_count = 0 OR v_item_count IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order must contain at least one item.';
    END IF;

    -- ---- PHASE 1: Validate stock for all items ----
    WHILE v_i < v_item_count DO
        SET v_product_id = JSON_EXTRACT(p_items, CONCAT('$[', v_i, '].product_id'));
        SET v_quantity   = JSON_EXTRACT(p_items, CONCAT('$[', v_i, '].quantity'));

        SELECT stock_qty, price INTO v_stock, v_price
        FROM products
        WHERE product_id = v_product_id AND is_active = 1;

        IF v_stock IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Product not found or inactive.';
        END IF;

        IF v_stock < v_quantity THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Insufficient stock for one or more products.';
        END IF;

        SET v_total = v_total + (v_price * v_quantity);
        SET v_i = v_i + 1;
    END WHILE;

    -- ---- PHASE 2: Create the order ----
    INSERT INTO orders (user_id, address_id, status, total_amount)
    VALUES (p_user_id, p_address_id, 'confirmed', v_total);

    SET v_order_id = LAST_INSERT_ID();

    -- ---- PHASE 3: Insert order items & decrement stock ----
    SET v_i = 0;
    WHILE v_i < v_item_count DO
        SET v_product_id = JSON_EXTRACT(p_items, CONCAT('$[', v_i, '].product_id'));
        SET v_quantity   = JSON_EXTRACT(p_items, CONCAT('$[', v_i, '].quantity'));

        SELECT price INTO v_price FROM products WHERE product_id = v_product_id;

        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (v_order_id, v_product_id, v_quantity, v_price);

        UPDATE products
        SET stock_qty = stock_qty - v_quantity
        WHERE product_id = v_product_id;

        SET v_i = v_i + 1;
    END WHILE;

    -- ---- PHASE 4: Create payment record ----
    INSERT INTO payments (order_id, amount, method, status)
    VALUES (v_order_id, v_total, p_payment_method, 'pending');

    COMMIT;

    -- Return the new order details
    SELECT v_order_id AS order_id, v_total AS total_amount, 'confirmed' AS status;
END //

-- ============================================================
-- CancelOrder: Cancel an order and restore stock
-- ============================================================
CREATE PROCEDURE CancelOrder(
    IN p_order_id INT
)
BEGIN
    DECLARE v_status VARCHAR(30);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order cancellation failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    SELECT status INTO v_status FROM orders WHERE order_id = p_order_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order not found.';
    END IF;

    IF v_status IN ('delivered', 'cancelled') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot cancel a delivered or already cancelled order.';
    END IF;

    -- Restore stock
    UPDATE products p
    JOIN order_items oi ON oi.product_id = p.product_id
    SET p.stock_qty = p.stock_qty + oi.quantity
    WHERE oi.order_id = p_order_id;

    -- Update order status
    UPDATE orders SET status = 'cancelled' WHERE order_id = p_order_id;

    -- Update payment status
    UPDATE payments SET status = 'refunded' WHERE order_id = p_order_id;

    COMMIT;

    SELECT p_order_id AS order_id, 'cancelled' AS status, 'Stock restored' AS note;
END //

DELIMITER;