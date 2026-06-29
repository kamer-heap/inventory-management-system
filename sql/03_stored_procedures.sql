-- ============================================
-- ADVANCED STORED PROCEDURES FOR INVENTORY SYSTEM - FIXED VERSION
-- ============================================
SET SERVEROUTPUT ON SIZE 1000000;
SET LINESIZE 200;

-- First, fix the CENTER function to handle odd/even lengths properly
CREATE OR REPLACE FUNCTION CENTER(
    p_string IN VARCHAR2,
    p_width IN NUMBER
) RETURN VARCHAR2 IS
    v_padding NUMBER;
BEGIN
    v_padding := (p_width - LENGTH(p_string)) / 2;
    IF v_padding < 0 THEN
        RETURN RPAD(p_string, p_width);
    ELSE
        RETURN LPAD(' ', CEIL(v_padding)) || p_string || LPAD(' ', FLOOR(v_padding));
    END IF;
END;
/

PROMPT ===============================================
PROMPT 1. PROCEDURE: GENERATE MONTHLY FINANCIAL REPORT
PROMPT ===============================================

-- Check if procedure exists
SELECT object_name, status 
FROM user_objects 
WHERE object_name = 'PROC_MONTHLY_BUSINESS_PROCESSING'
AND object_type = 'PROCEDURE';

PROMPT
PROMPT Testing existing procedure...
BEGIN
    PROC_MONTHLY_BUSINESS_PROCESSING('12-2024');
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'SUCCESS: Existing procedure works!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Procedure error: ' || SQLERRM);
END;
/

PROMPT ===============================================
PROMPT 2. PROCEDURE: PROCESS BULK PURCHASE ORDER
PROMPT ===============================================

CREATE OR REPLACE PROCEDURE PROC_PROCESS_BULK_PURCHASE (
    p_supplier_id    IN NUMBER,
    p_user_id        IN NUMBER,
    p_warehouse_id   IN NUMBER,
    p_item_list      IN VARCHAR2,
    p_notes          IN VARCHAR2 DEFAULT NULL
) AS
    v_purchase_id    NUMBER;
    v_total_amount   NUMBER := 0;
    v_item_id        NUMBER;
    v_quantity       NUMBER;
    v_price          NUMBER;
    v_start_pos      NUMBER;
    v_end_pos        NUMBER;
    v_item_string    VARCHAR2(100);
    v_item_count     NUMBER := 0;
    v_success_count  NUMBER := 0;
    v_error_count    NUMBER := 0;
    invalid_item EXCEPTION;
    
    -- Simple ASCII divider
    v_divider VARCHAR2(100) := '==========================================================';
    
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || v_divider);
    DBMS_OUTPUT.PUT_LINE(CENTER('PROCESSING BULK PURCHASE ORDER', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE('Supplier ID: ' || p_supplier_id);
    DBMS_OUTPUT.PUT_LINE('Warehouse ID: ' || p_warehouse_id);
    DBMS_OUTPUT.PUT_LINE('User ID: ' || p_user_id);
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
    SAVEPOINT start_purchase;
    
    -- Create purchase header
    INSERT INTO PURCHASE (supplier_id, user_id, warehouse_id, total_amount, purchase_date)
    VALUES (p_supplier_id, p_user_id, p_warehouse_id, 0, SYSDATE)
    RETURNING purchase_id INTO v_purchase_id;
    
    DBMS_OUTPUT.PUT_LINE('Purchase ID Created: ' || v_purchase_id);
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
    -- Parse and process each item
    v_start_pos := 1;
    WHILE v_start_pos <= LENGTH(p_item_list) LOOP
        v_end_pos := INSTR(p_item_list, ',', v_start_pos);
        IF v_end_pos = 0 THEN
            v_end_pos := LENGTH(p_item_list) + 1;
        END IF;
        
        v_item_string := SUBSTR(p_item_list, v_start_pos, v_end_pos - v_start_pos);
        v_item_count := v_item_count + 1;
        
        BEGIN
            v_item_id := TO_NUMBER(SUBSTR(v_item_string, 1, INSTR(v_item_string, ':') - 1));
            v_quantity := TO_NUMBER(
                SUBSTR(v_item_string, 
                       INSTR(v_item_string, ':') + 1,
                       INSTR(v_item_string, ':', 1, 2) - INSTR(v_item_string, ':') - 1
                )
            );
            v_price := TO_NUMBER(SUBSTR(v_item_string, INSTR(v_item_string, ':', 1, 2) + 1));
            
            DECLARE
                v_item_exists NUMBER;
            BEGIN
                SELECT COUNT(*) INTO v_item_exists
                FROM ITEM
                WHERE item_id = v_item_id;
                
                IF v_item_exists = 0 THEN
                    RAISE invalid_item;
                END IF;
                
                INSERT INTO PURCHASE_DETAIL (purchase_id, item_id, quantity, purchase_price)
                VALUES (v_purchase_id, v_item_id, v_quantity, v_price);
                
                v_total_amount := v_total_amount + (v_quantity * v_price);
                v_success_count := v_success_count + 1;
                
                DBMS_OUTPUT.PUT_LINE('SUCCESS - Item ' || v_item_id || 
                                   ' | Qty: ' || v_quantity ||
                                   ' | Price: ' || v_price);
                
            EXCEPTION
                WHEN invalid_item THEN
                    DBMS_OUTPUT.PUT_LINE('FAILED - Item ' || v_item_id || ' does not exist');
                    v_error_count := v_error_count + 1;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('FAILED - Error processing item ' || v_item_id || 
                                       ': ' || SQLERRM);
                    v_error_count := v_error_count + 1;
            END;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('FAILED - Invalid format for item: ' || v_item_string);
                v_error_count := v_error_count + 1;
        END;
        
        v_start_pos := v_end_pos + 1;
    END LOOP;
    
    -- Update purchase total
    UPDATE PURCHASE
    SET total_amount = v_total_amount
    WHERE purchase_id = v_purchase_id;
    
    COMMIT;
    
    -- Display summary
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE(CENTER('PROCESSING SUMMARY', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE('Items Processed: ' || v_item_count);
    DBMS_OUTPUT.PUT_LINE('Successful: ' || v_success_count);
    DBMS_OUTPUT.PUT_LINE('Errors: ' || v_error_count);
    DBMS_OUTPUT.PUT_LINE('Total Amount: ' || TO_CHAR(v_total_amount, 'FM999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO start_purchase;
        DBMS_OUTPUT.PUT_LINE('TRANSACTION FAILED: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE(v_divider);
        RAISE;
END;
/

PROMPT ===============================================
PROMPT 3. PROCEDURE: ANALYZE INVENTORY PERFORMANCE - FIXED
PROMPT ===============================================

CREATE OR REPLACE PROCEDURE PROC_ANALYZE_INVENTORY_PERFORMANCE (
    p_start_date IN DATE DEFAULT SYSDATE - 90,
    p_end_date IN DATE DEFAULT SYSDATE
) AS
    CURSOR c_top_selling IS
        SELECT i.item_id, i.item_name, 
               SUM(sd.quantity) AS units_sold,
               SUM(sd.quantity * sd.selling_price) AS revenue,
               ROUND(AVG(sd.selling_price), 2) AS avg_selling_price
        FROM ITEM i
        JOIN SALES_DETAIL sd ON i.item_id = sd.item_id
        JOIN SALE s ON sd.sale_id = s.sale_id
        WHERE s.sale_date BETWEEN p_start_date AND p_end_date
        GROUP BY i.item_id, i.item_name
        ORDER BY revenue DESC;
    
    CURSOR c_stock_turnover IS
        SELECT i.item_id, i.item_name,
               s.quantity AS current_stock,
               COALESCE(sales.units_sold, 0) AS units_sold,
               CASE 
                   WHEN s.quantity > 0 
                   THEN ROUND(COALESCE(sales.units_sold, 0) / s.quantity, 2)
                   ELSE 0 
               END AS turnover_ratio,
               CASE
                   WHEN s.quantity <= i.min_stock_level THEN 'REORDER NOW'
                   WHEN s.quantity <= (i.min_stock_level * 1.5) THEN 'MONITOR'
                   ELSE 'HEALTHY'
               END AS stock_status
        FROM ITEM i
        LEFT JOIN STOCK s ON i.item_id = s.item_id
        LEFT JOIN (
            SELECT sd.item_id, SUM(sd.quantity) AS units_sold
            FROM SALES_DETAIL sd
            JOIN SALE s ON sd.sale_id = s.sale_id
            WHERE s.sale_date BETWEEN p_start_date AND p_end_date
            GROUP BY sd.item_id
        ) sales ON i.item_id = sales.item_id
        WHERE s.warehouse_id = 1
        ORDER BY turnover_ratio DESC NULLS LAST;
    
    v_total_revenue NUMBER := 0;
    v_total_items NUMBER := 0;
    v_high_demand_items NUMBER := 0;
    v_low_stock_items NUMBER := 0;
    v_report_date VARCHAR2(50);
    v_row_count NUMBER := 0;
    
    -- ASCII dividers
    v_divider VARCHAR2(80) := '==============================================================================';
    v_thin_divider VARCHAR2(80) := '------------------------------------------------------------------------------';
    
BEGIN
    v_report_date := TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS');
    
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE(CENTER('INVENTORY PERFORMANCE ANALYSIS REPORT', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || 
                       ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('Report Date: ' || v_report_date);
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
    -- SECTION 1: TOP SELLING ITEMS
    DBMS_OUTPUT.PUT_LINE(CENTER('TOP 5 SELLING ITEMS', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE('Item                          Units Sold  Revenue        Avg Price');
    DBMS_OUTPUT.PUT_LINE(v_thin_divider);
    
    v_row_count := 0;
    FOR rec IN c_top_selling LOOP
        v_row_count := v_row_count + 1;
        EXIT WHEN v_row_count > 5;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.item_name, 30) ||
            RPAD(TO_CHAR(rec.units_sold, 'FM999,999'), 12) ||
            RPAD(TO_CHAR(rec.revenue, 'FM999,999,999'), 15) ||
            TO_CHAR(rec.avg_selling_price, 'FM999,999.99')
        );
        v_total_revenue := v_total_revenue + rec.revenue;
    END LOOP;
    
    -- SECTION 2: STOCK TURNOVER ANALYSIS
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE(CENTER('STOCK TURNOVER ANALYSIS', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE('Item                          Current Stock  Units Sold  Turnover  Status');
    DBMS_OUTPUT.PUT_LINE(v_thin_divider);
    
    v_total_items := 0;
    FOR rec IN c_stock_turnover LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.item_name, 30) ||
            RPAD(TO_CHAR(rec.current_stock, 'FM999,999'), 15) ||
            RPAD(TO_CHAR(rec.units_sold, 'FM999,999'), 12) ||
            RPAD(TO_CHAR(rec.turnover_ratio, 'FM0.99'), 10) ||
            rec.stock_status
        );
        
        v_total_items := v_total_items + 1;
        IF rec.turnover_ratio > 2 THEN
            v_high_demand_items := v_high_demand_items + 1;
        END IF;
        IF rec.stock_status = 'REORDER NOW' THEN
            v_low_stock_items := v_low_stock_items + 1;
        END IF;
    END LOOP;
    
    -- SECTION 3: SUMMARY STATISTICS
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE(CENTER('SUMMARY STATISTICS', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
    DBMS_OUTPUT.PUT_LINE('Total Items Analyzed: ' || v_total_items);
    DBMS_OUTPUT.PUT_LINE('High Demand Items (Turnover > 2): ' || v_high_demand_items);
    DBMS_OUTPUT.PUT_LINE('Items Needing Reorder: ' || v_low_stock_items);
    DBMS_OUTPUT.PUT_LINE('Total Revenue in Period: ' || TO_CHAR(v_total_revenue, 'FM999,999,999'));
    DBMS_OUTPUT.PUT_LINE('Avg Revenue per Item: ' || 
                       TO_CHAR(v_total_revenue / NULLIF(v_total_items, 0), 'FM999,999'));
    
    -- RECOMMENDATIONS - FIXED TO ALWAYS SHOW
    DBMS_OUTPUT.PUT_LINE(v_divider);
    DBMS_OUTPUT.PUT_LINE(CENTER('RECOMMENDATIONS', LENGTH(v_divider)));
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
    IF v_low_stock_items > 0 THEN
        DBMS_OUTPUT.PUT_LINE('ALERT: ' || v_low_stock_items || ' items need immediate reordering');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ALERT: 0 items need immediate reordering');
    END IF;
    
    IF v_high_demand_items > (v_total_items * 0.3) THEN
        DBMS_OUTPUT.PUT_LINE('NOTE: Consider increasing stock for high-demand items');
    ELSE
        DBMS_OUTPUT.PUT_LINE('NOTE: Stock levels appear adequate for current demand');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(v_divider);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Analysis failed: ' || SQLERRM);
END;
/

PROMPT ===============================================
PROMPT TESTING WITH CLEAN OUTPUT
PROMPT ===============================================

PROMPT 1. Testing Bulk Purchase Procedure...
BEGIN
    PROC_PROCESS_BULK_PURCHASE(
        p_supplier_id => 1,
        p_user_id => 5,
        p_warehouse_id => 1,
        p_item_list => '1:50:1000,2:30:1300,3:100:750,4:200:250'
    );
END;
/

PROMPT
PROMPT 2. Testing Inventory Analysis Procedure...
BEGIN
    PROC_ANALYZE_INVENTORY_PERFORMANCE(
        p_start_date => DATE '2024-12-01',
        p_end_date => DATE '2024-12-31'
    );
END;
/

PROMPT ================================================
PROMPT QUICK TEST SCRIPT
PROMPT ================================================

PROMPT Test 1: Normal bulk purchase
BEGIN
    PROC_PROCESS_BULK_PURCHASE(
        p_supplier_id => 1,
        p_user_id => 1,
        p_warehouse_id => 1,
        p_item_list => '1:10:1000,2:5:1500,3:8:800'
    );
END;
/

PROMPT
PROMPT Test 2: Inventory analysis for current month
BEGIN
    PROC_ANALYZE_INVENTORY_PERFORMANCE(
        p_start_date => TRUNC(SYSDATE, 'MM'),
        p_end_date => SYSDATE
    );
END;
/

PROMPT
PROMPT ================================================
PROMPT PROCEDURE STATUS VERIFICATION
PROMPT ================================================

SELECT object_name, object_type, status, 
       TO_CHAR(created, 'DD-MON-YY HH24:MI') as created_time
FROM user_objects 
WHERE object_type = 'PROCEDURE'
AND object_name LIKE 'PROC_%'
ORDER BY created DESC;

PROMPT
PROMPT ================================================
PROMPT SCRIPT COMPLETED SUCCESSFULLY
PROMPT ================================================