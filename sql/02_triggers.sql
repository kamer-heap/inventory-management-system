-- Create auto-increment triggers
CREATE OR REPLACE TRIGGER TRG_ROLE_AUTOINC
BEFORE INSERT ON ROLE
FOR EACH ROW
BEGIN
    IF :NEW.role_id IS NULL THEN
        SELECT SEQ_ROLE.NEXTVAL INTO :NEW.role_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_USER_AUTOINC
BEFORE INSERT ON USER_TABLE
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT SEQ_USER.NEXTVAL INTO :NEW.user_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_CUSTOMER_AUTOINC
BEFORE INSERT ON CUSTOMER
FOR EACH ROW
BEGIN
    IF :NEW.customer_id IS NULL THEN
        SELECT SEQ_CUSTOMER.NEXTVAL INTO :NEW.customer_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_SUPPLIER_AUTOINC
BEFORE INSERT ON SUPPLIER
FOR EACH ROW
BEGIN
    IF :NEW.supplier_id IS NULL THEN
        SELECT SEQ_SUPPLIER.NEXTVAL INTO :NEW.supplier_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_CATEGORY_AUTOINC
BEFORE INSERT ON CATEGORY
FOR EACH ROW
BEGIN
    IF :NEW.category_id IS NULL THEN
        SELECT SEQ_CATEGORY.NEXTVAL INTO :NEW.category_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_WAREHOUSE_AUTOINC
BEFORE INSERT ON WAREHOUSE
FOR EACH ROW
BEGIN
    IF :NEW.warehouse_id IS NULL THEN
        SELECT SEQ_WAREHOUSE.NEXTVAL INTO :NEW.warehouse_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_ITEM_AUTOINC
BEFORE INSERT ON ITEM
FOR EACH ROW
BEGIN
    IF :NEW.item_id IS NULL THEN
        SELECT SEQ_ITEM.NEXTVAL INTO :NEW.item_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_PURCHASE_AUTOINC
BEFORE INSERT ON PURCHASE
FOR EACH ROW
BEGIN
    IF :NEW.purchase_id IS NULL THEN
        SELECT SEQ_PURCHASE.NEXTVAL INTO :NEW.purchase_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_PURCHASE_DETAIL_AUTOINC
BEFORE INSERT ON PURCHASE_DETAIL
FOR EACH ROW
BEGIN
    IF :NEW.purchase_detail_id IS NULL THEN
        SELECT SEQ_PURCHASE_DETAIL.NEXTVAL INTO :NEW.purchase_detail_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_SALE_AUTOINC
BEFORE INSERT ON SALE
FOR EACH ROW
BEGIN
    IF :NEW.sale_id IS NULL THEN
        SELECT SEQ_SALE.NEXTVAL INTO :NEW.sale_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_SALES_DETAIL_AUTOINC
BEFORE INSERT ON SALES_DETAIL
FOR EACH ROW
BEGIN
    IF :NEW.sales_details_id IS NULL THEN
        SELECT SEQ_SALES_DETAIL.NEXTVAL INTO :NEW.sales_details_id FROM DUAL;
    END IF;
END;
/

-- Create update timestamp triggers
CREATE OR REPLACE TRIGGER trg_role_updated
BEFORE UPDATE ON ROLE
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_user_updated
BEFORE UPDATE ON USER_TABLE
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_customer_updated
BEFORE UPDATE ON CUSTOMER
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_supplier_updated
BEFORE UPDATE ON SUPPLIER
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_category_updated
BEFORE UPDATE ON CATEGORY
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_warehouse_updated
BEFORE UPDATE ON WAREHOUSE
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_item_updated
BEFORE UPDATE ON ITEM
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/


CREATE OR REPLACE TRIGGER trg_purchase_updated
BEFORE UPDATE ON PURCHASE
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_purchasedetail_updated
BEFORE UPDATE ON PURCHASE_DETAIL
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_sale_updated
BEFORE UPDATE ON SALE
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_salesdetail_updated
BEFORE UPDATE ON SALES_DETAIL
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Stock management trigger for purchases
CREATE OR REPLACE TRIGGER trg_update_stock_on_purchase
AFTER INSERT OR UPDATE ON PURCHASE_DETAIL
FOR EACH ROW
DECLARE
    v_warehouse_id NUMBER;
BEGIN
    SELECT warehouse_id INTO v_warehouse_id
    FROM PURCHASE
    WHERE purchase_id = :NEW.purchase_id;
    
    MERGE INTO STOCK s
    USING DUAL
    ON (s.warehouse_id = v_warehouse_id AND s.item_id = :NEW.item_id)
    WHEN MATCHED THEN
        UPDATE SET s.quantity = s.quantity + :NEW.quantity,
                   s.last_updated = SYSTIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (warehouse_id, item_id, quantity, last_updated)
        VALUES (v_warehouse_id, :NEW.item_id, :NEW.quantity, SYSTIMESTAMP);
END;
/

-- Stock management trigger for sales
CREATE OR REPLACE TRIGGER TRG_UPDATE_STOCK_ON_SALE
AFTER INSERT ON SALES_DETAIL
FOR EACH ROW
DECLARE
    v_warehouse_id NUMBER;
    v_current_stock NUMBER;
    v_available_warehouse NUMBER;
BEGIN

    BEGIN
        SELECT warehouse_id, quantity 
        INTO v_available_warehouse, v_current_stock
        FROM STOCK
        WHERE item_id = :NEW.item_id
          AND quantity >= :NEW.quantity
          AND ROWNUM = 1;  
        v_warehouse_id := v_available_warehouse;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            
            RAISE_APPLICATION_ERROR(-20004, 
                'Item not found in stock or insufficient quantity. Item ID: ' || :NEW.item_id);
    END;
    
    
    UPDATE STOCK
    SET quantity = quantity - :NEW.quantity
    WHERE item_id = :NEW.item_id
      AND warehouse_id = v_warehouse_id;
    
    DBMS_OUTPUT.PUT_LINE('Item ' || :NEW.item_id || ' sold from warehouse ' || v_warehouse_id);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error in stock update: ' || SQLERRM);
END;
/