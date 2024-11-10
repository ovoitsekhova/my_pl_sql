create or replace PACKAGE body util AS
    
FUNCTION get_sum_price_sales (p_table VARCHAR2 DEFAULT 'products_old') RETURN NUMBER IS
                                  v_sum NUMBER;
                                  v_message logs.message%TYPE;
                                  v_dynamic_sql VARCHAR2(500);
BEGIN

    IF p_table NOT IN ('products', 'products_old') THEN
        v_message := 'Неприпустиме значення! Очікується products або products_old';
        to_log(p_appl_proc => 'util.get_sum_price_sales', p_message => v_message);
        raise_application_error(-20001, v_message);
    END IF;
    
    v_dynamic_sql := 'SELECT SUM(p.price_sales) FROM hr.' || p_table || ' p';
    
    EXECUTE IMMEDIATE v_dynamic_sql INTO v_sum;
    
    dbms_output.put_line(v_sum);
    
    RETURN v_sum;
    --COMMIT;
END get_sum_price_sales;

END util;
/

