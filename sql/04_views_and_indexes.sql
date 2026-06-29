SET SERVEROUTPUT ON;

-- 1. Create Non-Key Indexes
CREATE INDEX idx_customer_contact ON CUSTOMER(contact);
CREATE INDEX idx_item_selling_price ON ITEM(selling_price);

-- 2. Create Views
CREATE OR REPLACE VIEW VW_STOCK_SUMMARY AS
SELECT 
    w.warehouse_name,
    c.category_name,
    i.item_name,
    s.quantity AS current_stock,
    i.min_stock_level,
    CASE 
        WHEN s.quantity <= i.min_stock_level THEN 'LOW STOCK'
        WHEN s.quantity <= (i.min_stock_level * 1.5) THEN 'MEDIUM STOCK'
        ELSE 'GOOD STOCK'
    END AS stock_status,
    (s.quantity * i.selling_price) AS stock_value,
    s.last_updated
FROM STOCK s
JOIN WAREHOUSE w ON s.warehouse_id = w.warehouse_id
JOIN ITEM i ON s.item_id = i.item_id
JOIN CATEGORY c ON i.category_id = c.category_id
ORDER BY w.warehouse_name, c.category_name, i.item_name;

CREATE OR REPLACE VIEW VW_MONTHLY_SALES_PERFORMANCE AS
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS sale_month,
    c.customer_name,
    u.name AS sales_person,
    COUNT(DISTINCT s.sale_id) AS total_sales,
    SUM(s.total_amount) AS total_revenue,
    COUNT(DISTINCT sd.item_id) AS unique_items_sold,
    SUM(sd.quantity) AS total_quantity_sold,
    ROUND(AVG(s.total_amount), 2) AS avg_sale_value,
    MAX(s.total_amount) AS max_sale_value,
    MIN(s.total_amount) AS min_sale_value
FROM SALE s
JOIN CUSTOMER c ON s.customer_id = c.customer_id
JOIN USER_TABLE u ON s.user_id = u.user_id
JOIN SALES_DETAIL sd ON s.sale_id = sd.sale_id
WHERE s.sale_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), c.customer_name, u.name
ORDER BY sale_month DESC, total_revenue DESC;

-- 3. Test and Show Results
SELECT 'Indexes and Views Created Successfully!' AS message FROM dual;

SELECT '1. idx_customer_contact created' AS result FROM dual
UNION ALL
SELECT '2. idx_item_selling_price created' FROM dual
UNION ALL
SELECT '3. VW_STOCK_SUMMARY view created' FROM dual
UNION ALL
SELECT '4. VW_MONTHLY_SALES_PERFORMANCE view created' FROM dual;

-- Show sample data from views
SELECT 'Sample from VW_STOCK_SUMMARY:' AS view_name FROM dual;
SELECT warehouse_name, item_name, current_stock, stock_status 
FROM VW_STOCK_SUMMARY 
WHERE ROWNUM <= 3;