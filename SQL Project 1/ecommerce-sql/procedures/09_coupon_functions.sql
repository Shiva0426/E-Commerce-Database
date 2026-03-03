-- ============================================================
-- Coupon Functions (MySQL Version)
-- Validate and apply coupon codes to orders
-- ============================================================

DELIMITER / /

-- ============================================================
-- ApplyCoupon: Validates a coupon and returns discounted total
-- Returns: JSON with status, discount, and final amount
-- ============================================================
CREATE FUNCTION CalculateDiscount(
    p_coupon_code VARCHAR(50),
    p_order_amount DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_discount_type ENUM('percent', 'flat');
    DECLARE v_discount_value DECIMAL(10,2);
    DECLARE v_min_order DECIMAL(10,2);
    DECLARE v_max_discount DECIMAL(10,2);
    DECLARE v_max_uses INT;
    DECLARE v_times_used INT;
    DECLARE v_is_active TINYINT(1);
    DECLARE v_starts_at TIMESTAMP;
    DECLARE v_expires_at TIMESTAMP;
    DECLARE v_discount DECIMAL(12,2) DEFAULT 0;

    -- Fetch coupon details
    SELECT discount_type, discount_value, min_order_amount,
           max_discount, max_uses, times_used, is_active,
           starts_at, expires_at
    INTO v_discount_type, v_discount_value, v_min_order,
         v_max_discount, v_max_uses, v_times_used, v_is_active,
         v_starts_at, v_expires_at
    FROM coupons
    WHERE code = p_coupon_code;

    -- Coupon not found
    IF v_discount_type IS NULL THEN
        RETURN -1;
    END IF;

    -- Coupon inactive
    IF v_is_active = 0 THEN
        RETURN -2;
    END IF;

    -- Coupon expired
    IF v_expires_at IS NOT NULL AND NOW() > v_expires_at THEN
        RETURN -3;
    END IF;

    -- Coupon not started yet
    IF v_starts_at IS NOT NULL AND NOW() < v_starts_at THEN
        RETURN -4;
    END IF;

    -- Max uses exceeded
    IF v_max_uses IS NOT NULL AND v_times_used >= v_max_uses THEN
        RETURN -5;
    END IF;

    -- Minimum order not met
    IF p_order_amount < v_min_order THEN
        RETURN -6;
    END IF;

    -- Calculate discount
    IF v_discount_type = 'percent' THEN
        SET v_discount = p_order_amount * (v_discount_value / 100);
        IF v_max_discount IS NOT NULL AND v_discount > v_max_discount THEN
            SET v_discount = v_max_discount;
        END IF;
    ELSE
        SET v_discount = v_discount_value;
    END IF;

    -- Discount cannot exceed order amount
    IF v_discount > p_order_amount THEN
        SET v_discount = p_order_amount;
    END IF;

    RETURN ROUND(v_discount, 2);
END //

-- ============================================================
-- ApplyCoupon: Applies a coupon to an order (procedure)
-- Validates, calculates discount, updates order, increments usage
-- ============================================================
CREATE PROCEDURE ApplyCoupon(
    IN p_order_id INT,
    IN p_coupon_code VARCHAR(50)
)
BEGIN
    DECLARE v_order_amount DECIMAL(12,2);
    DECLARE v_discount DECIMAL(12,2);
    DECLARE v_status VARCHAR(30);

    -- Get order details
    SELECT total_amount, status INTO v_order_amount, v_status
    FROM orders
    WHERE order_id = p_order_id;

    IF v_order_amount IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order not found.';
    END IF;

    IF v_status IN ('cancelled', 'delivered') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot apply coupon to cancelled or delivered orders.';
    END IF;

    -- Calculate discount
    SET v_discount = CalculateDiscount(p_coupon_code, v_order_amount);

    -- Handle error codes
    IF v_discount = -1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coupon code not found.';
    ELSEIF v_discount = -2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coupon is inactive.';
    ELSEIF v_discount = -3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coupon has expired.';
    ELSEIF v_discount = -4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coupon is not yet active.';
    ELSEIF v_discount = -5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coupon usage limit reached.';
    ELSEIF v_discount = -6 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order does not meet minimum amount.';
    END IF;

    -- Apply discount to order
    UPDATE orders
    SET discount_amount = v_discount,
        total_amount = total_amount - v_discount
    WHERE order_id = p_order_id;

    -- Increment coupon usage
    UPDATE coupons
    SET times_used = times_used + 1
    WHERE code = p_coupon_code;

    -- Return result
    SELECT
        p_order_id AS order_id,
        p_coupon_code AS coupon_applied,
        v_discount AS discount_amount,
        (v_order_amount - v_discount) AS final_amount;
END //

DELIMITER;