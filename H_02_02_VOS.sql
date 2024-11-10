DECLARE
    v_def_percent VARCHAR2(30);
    v_percent VARCHAR2(5);
    v_dep_id NUMBER := 80;
    v_manager_id NUMBER := 100;
BEGIN

    FOR cc IN (SELECT em.first_name || ' ' || em.last_name as emp_name, 
                      em.commission_pct*100 as percent_of_salary,
                      em.manager_id
               FROM hr.employees em
               WHERE em.department_id = v_dep_id
               ORDER BY em.first_name
               ) LOOP
               
                IF cc.manager_id = v_manager_id THEN                
                    dbms_output.put_line('Співробітник - ' || cc.emp_name || ', процент до зарплати на зараз заборонений');
                CONTINUE;
                END IF;
                
                IF cc.percent_of_salary BETWEEN 10 AND 20 THEN 
                    v_def_percent := 'мінімальний';
                ELSIF cc.percent_of_salary BETWEEN 25 AND 30 THEN 
                    v_def_percent := 'середній';
                ELSIF cc.percent_of_salary BETWEEN 35 AND 40 THEN          
                    v_def_percent := 'максимальний';
                END IF;
                    
                v_percent := CONCAT(cc.percent_of_salary, '%');
                dbms_output.put_line('Співробітник - ' || cc.emp_name || '; процент до зарплати - ' || v_percent || '; опис процента - ' || v_def_percent);
                 
     END LOOP;           
END;
/