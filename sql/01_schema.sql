SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting FULL data insertion...');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
END;
/

---------------------------------------------------------
-- RESET ALL SEQUENCES TO START FROM 1
---------------------------------------------------------
DROP SEQUENCE SEQ_ROLE;
CREATE SEQUENCE SEQ_ROLE START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_USER;
CREATE SEQUENCE SEQ_USER START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_CUSTOMER;
CREATE SEQUENCE SEQ_CUSTOMER START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_SUPPLIER;
CREATE SEQUENCE SEQ_SUPPLIER START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_CATEGORY;
CREATE SEQUENCE SEQ_CATEGORY START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_WAREHOUSE;
CREATE SEQUENCE SEQ_WAREHOUSE START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_ITEM;
CREATE SEQUENCE SEQ_ITEM START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_PURCHASE;
CREATE SEQUENCE SEQ_PURCHASE START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_PURCHASE_DETAIL;
CREATE SEQUENCE SEQ_PURCHASE_DETAIL START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_SALE;
CREATE SEQUENCE SEQ_SALE START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE SEQ_SALES_DETAIL;
CREATE SEQUENCE SEQ_SALES_DETAIL START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ All sequences reset to 1');
END;
/

---------------------------------------------------------
-- 1: ROLE (5 INSERTS)
---------------------------------------------------------
INSERT INTO ROLE (role_name, permissions, description) 
VALUES ('Admin', '{"all": true}', 'Full system access');

INSERT INTO ROLE (role_name, permissions, description) 
VALUES ('Manager', '{"sales": true, "purchase": true, "reports": true}', 'Department manager');

INSERT INTO ROLE (role_name, permissions, description) 
VALUES ('Sales Person', '{"sales": true, "view_stock": true}', 'Sales operations only');

INSERT INTO ROLE (role_name, permissions, description) 
VALUES ('Purchase Officer', '{"purchase": true, "view_stock": true}', 'Purchase operations');

INSERT INTO ROLE (role_name, permissions, description) 
VALUES ('Warehouse Manager', '{"stock": true, "warehouse": true}', 'Warehouse operations');

---------------------------------------------------------
-- 2: USER_TABLE (7 INSERTS)
---------------------------------------------------------
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (1, 'admin', 'admin123', 'Ahmed Ali');
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (2, 'manager1', 'mgr123', 'Fatima Khan');
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (3, 'sales1', 'sales123', 'Hassan Raza');
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (3, 'sales2', 'sales123', 'Ayesha Malik');
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (4, 'purchase1', 'pur123', 'Usman Sheikh');
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (5, 'warehouse1', 'wh123', 'Imran Butt');
INSERT INTO USER_TABLE (role_id, username, password, name) VALUES (2, 'manager2', 'mgr123', 'Sara Ahmed');

---------------------------------------------------------
-- 3: CUSTOMER (5 INSERTS)
---------------------------------------------------------
INSERT INTO CUSTOMER (customer_name, contact, address) VALUES ('Metro Cash & Carry', '0300-1234567', 'Gulberg Lahore');
INSERT INTO CUSTOMER (customer_name, contact, address) VALUES ('Imtiaz Super Market', '0321-9876543', 'MM Alam Lahore');
INSERT INTO CUSTOMER (customer_name, contact, address) VALUES ('Al-Fatah Shopping Mall', '0333-5551234', 'Fortress Lahore');
INSERT INTO CUSTOMER (customer_name, contact, address) VALUES ('Carrefour Pakistan', '0300-7778888', 'Packages Mall');
INSERT INTO CUSTOMER (customer_name, contact, address) VALUES ('Chase Up Supermarket', '0321-4445566', 'DHA Lahore');

---------------------------------------------------------
-- 4: SUPPLIER (5 INSERTS)
---------------------------------------------------------
INSERT INTO SUPPLIER (supplier_name, contact, address) VALUES ('National Foods Ltd', '042-35111222', 'Kot Lakhpat');
INSERT INTO SUPPLIER (supplier_name, contact, address) VALUES ('Unilever Pakistan', '042-35888999', 'Sundar Estate');
INSERT INTO SUPPLIER (supplier_name, contact, address) VALUES ('Nestle Pakistan', '042-36666777', 'Sheikhupura Road');
INSERT INTO SUPPLIER (supplier_name, contact, address) VALUES ('Shan Foods', '042-37777888', 'Raiwind Road');
INSERT INTO SUPPLIER (supplier_name, contact, address) VALUES ('Tapal Tea', '042-35444555', 'Multan Road');

---------------------------------------------------------
-- 5: CATEGORY (6 INSERTS)
---------------------------------------------------------
INSERT INTO CATEGORY (category_name) VALUES ('Groceries');
INSERT INTO CATEGORY (category_name) VALUES ('Beverages');
INSERT INTO CATEGORY (category_name) VALUES ('Personal Care');
INSERT INTO CATEGORY (category_name) VALUES ('Household Items');
INSERT INTO CATEGORY (category_name) VALUES ('Snacks');
INSERT INTO CATEGORY (category_name) VALUES ('Dairy Products');

---------------------------------------------------------
-- 6: WAREHOUSE (3 INSERTS)
---------------------------------------------------------
INSERT INTO WAREHOUSE (warehouse_name, location, capacity, contact) VALUES ('Main Warehouse', 'Shahdara Lahore', 50000, '042-37001122');
INSERT INTO WAREHOUSE (warehouse_name, location, capacity, contact) VALUES ('South Warehouse', 'Sundar Lahore', 30000, '042-35002233');
INSERT INTO WAREHOUSE (warehouse_name, location, capacity, contact) VALUES ('North Warehouse', 'Shahdara Town', 40000, '042-36003344');

---------------------------------------------------------
-- 7: ITEM (10 INSERTS)
---------------------------------------------------------
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (1, 'Basmati Rice 5kg', 1200, 100, 'Premium basmati');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (1, 'Cooking Oil 5L', 1500, 80, 'Pure oil');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (2, 'Tapal Tea 950g', 850, 150, 'Danedar Tea');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (2, 'Nestle Milk Pack 1L', 280, 200, 'Fresh Milk');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (3, 'Lux Soap 3pk', 250, 120, 'Soap Pack');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (3, 'Fair & Lovely 50g', 420, 90, 'Fairness Cream');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (4, 'Surf Excel 3kg', 980, 100, 'Washing Powder');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (5, 'Kolson Noodles Box', 480, 150, '12pk Box');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (5, 'Lays Family Pack', 180, 200, 'Potato Chips');
INSERT INTO ITEM (category_id, item_name, selling_price, min_stock_level, description) VALUES (6, 'Olpers Cream 200ml', 320, 80, 'Cooking Cream');

---------------------------------------------------------
-- 8: PURCHASE (3 INSERTS)
---------------------------------------------------------
INSERT INTO PURCHASE (supplier_id, user_id, warehouse_id, total_amount, purchase_date) 
VALUES (1, 5, 1, 150000, TO_DATE('2024-12-01','YYYY-MM-DD'));

INSERT INTO PURCHASE (supplier_id, user_id, warehouse_id, total_amount, purchase_date) 
VALUES (2, 5, 2, 95000, TO_DATE('2024-12-02','YYYY-MM-DD'));

INSERT INTO PURCHASE (supplier_id, user_id, warehouse_id, total_amount, purchase_date) 
VALUES (3, 5, 1, 125000, TO_DATE('2024-12-03','YYYY-MM-DD'));

INSERT INTO PURCHASE (supplier_id, user_id, warehouse_id, total_amount, purchase_date) 
VALUES (4, 5, 1, 50000, TO_DATE('2024-12-04','YYYY-MM-DD'));

---------------------------------------------------------
-- 9: PURCHASE_DETAIL (6 INSERTS)
---------------------------------------------------------
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (1, 1, 150, 1000);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (1, 2, 100, 1300);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (2, 5, 200, 200);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (2, 6, 150, 350);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (3, 3, 250, 750);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (3, 4, 300, 250);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (4, 8, 100, 400);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (4, 9, 300, 150);
INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price) VALUES (4, 10, 100, 280);

---------------------------------------------------------
-- 10: SALE (5 INSERTS)
---------------------------------------------------------
INSERT INTO SALE (customer_id, user_id, total_amount, sale_date) VALUES (1, 3, 85000, TO_DATE('2024-12-05','YYYY-MM-DD'));
INSERT INTO SALE (customer_id, user_id, total_amount, sale_date) VALUES (2, 4, 32000, TO_DATE('2024-12-06','YYYY-MM-DD'));
INSERT INTO SALE (customer_id, user_id, total_amount, sale_date) VALUES (3, 3, 45000, TO_DATE('2024-12-07','YYYY-MM-DD'));
INSERT INTO SALE (customer_id, user_id, total_amount, sale_date) VALUES (4, 4, 27000, TO_DATE('2024-12-08','YYYY-MM-DD'));
INSERT INTO SALE (customer_id, user_id, total_amount, sale_date) VALUES (5, 3, 15000, TO_DATE('2024-12-09','YYYY-MM-DD'));

---------------------------------------------------------
-- 11: SALES_DETAIL (8 INSERTS)
---------------------------------------------------------
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (1, 1, 50, 1200);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (1, 10, 30, 320);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (2, 9, 60, 180);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (2, 8, 20, 480);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (3, 3, 80, 850);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (3, 4, 50, 280);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (4, 2, 30, 1500);
INSERT INTO SALES_DETAIL (sale_id, item_id, quantity, selling_price) VALUES (5, 5, 40, 250);


COMMIT;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================');
    DBMS_OUTPUT.PUT_LINE('  FULL DATA INSERTION COMPLETED!');
    DBMS_OUTPUT.PUT_LINE('=======================================');
END;
/
