DECLARE
    v_err VARCHAR2(100);
BEGIN 
    copy_table(p_source_scheme => 'HR',
               p_list_table => 'REGIONS',
               po_result => v_err);
    dbms_output.put_line(v_err);
END;
/
