DECLARE
    v_year NUMBER := 2041;
    v_check_year NUMBER;
BEGIN

    v_check_year := mod(v_year, 4);   
    
    IF v_check_year = 0 THEN 
        dbms_output.put_line('������c��� ��');
    ELSE 
        dbms_output.put_line('�� ������c��� ��');
    END IF;
    
END;
/