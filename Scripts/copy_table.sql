--вдалий кейс
DECLARE
    v_err VARCHAR2(100);
BEGIN 
    copy_table(p_source_scheme => 'hr',
               p_list_table => 'countries,sales',
               p_copy_data => TRUE,
               po_result => v_err);
    dbms_output.put_line(v_err);
END;
/

--невдалий кейс
DECLARE
    v_err VARCHAR2(100);
BEGIN 
    copy_table(p_source_scheme => 'hr',
               p_list_table => 'employees',
               p_copy_data => TRUE,
               po_result => v_err);
    dbms_output.put_line(v_err);
END;
/
