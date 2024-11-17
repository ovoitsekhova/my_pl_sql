--У специфікацію

    TYPE rec_value_list IS RECORD (region_name VARCHAR2(100),
                                   employees   NUMBER);
    TYPE tab_value_list IS TABLE OF rec_value_list;
    
    FUNCTION get_region_cnt_emp (p_department_id IN NUMBER DEFAULT NULL) RETURN tab_value_list PIPELINED; 
    
--У тіло

FUNCTION get_region_cnt_emp (p_department_id IN NUMBER DEFAULT NULL) RETURN tab_value_list PIPELINED IS    

out_rec tab_value_list := tab_value_list();
l_cur SYS_REFCURSOR;

BEGIN

    OPEN l_cur FOR
    
    SELECT r.REGION_NAME, COUNT(DISTINCT em.employee_id) employees
    FROM hr.regions r
    LEFT JOIN hr.countries c ON c.region_id = r.region_id
    LEFT JOIN hr.locations l on l.country_id = c.country_id
    LEFT JOIN hr.departments d on d.location_id = l.location_id
    LEFT JOIN hr.employees em on em.department_id = d.department_id
    WHERE (em.department_id = p_department_id or p_department_id is null)
    GROUP BY r.REGION_NAME;
    
    BEGIN
        LOOP
        EXIT WHEN l_cur%NOTFOUND;
        FETCH l_cur BULK COLLECT
        INTO out_rec;
            FOR i IN 1 .. out_rec.count LOOP
                PIPE ROW(out_rec(i));
            END LOOP;
        END LOOP;
        CLOSE l_cur;
    
    EXCEPTION
        WHEN OTHERS THEN
            IF (l_cur%ISOPEN) THEN
                CLOSE l_cur;
                RAISE;
            ELSE
                RAISE;
            END IF;
    END;

END get_region_cnt_emp;


--Виклик

SELECT *
FROM TABLE(util.get_region_cnt_emp(p_department_id => 20));
