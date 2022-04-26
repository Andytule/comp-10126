-- Andy Le
-- Q1  
SET SERVEROUTPUT ON;
SET VERIFY OFF;
CLEAR SCREEN;

CREATE OR REPLACE TRIGGER items_au AFTER
    UPDATE ON items
    FOR EACH ROW
DECLARE
    v_poi purchase_orders.purchase_order_id%TYPE;
BEGIN
    IF :new.quantity_on_hand <= :new.order_point THEN
        SELECT
            MAX(purchase_order_id)
        INTO v_poi
        FROM
            purchase_orders;

        v_poi := v_poi + 1;
        INSERT INTO purchase_orders VALUES (
            v_poi,
            sysdate,
            NULL,
            :new.primary_vendor_id,
            :new.item_cost * :new.order_quantity,
            'ACTIVE'
        );

        INSERT INTO purchase_order_lines VALUES (
            v_poi,
            1,
            :new.item_id,
            :new.order_quantity,
            :new.item_cost,
            0,
            0,
            NULL
        );

    END IF;
END;