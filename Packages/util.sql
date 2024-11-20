--Специфікація
CREATE OR REPLACE PACKAGE olxga_irn.util AS

    TYPE rec_value_list IS RECORD (region_name VARCHAR2(100),
                                   employees   NUMBER);
    TYPE tab_value_list IS TABLE OF rec_value_list;
    
    FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR;
    
    FUNCTION get_dep_name (p_employee_id IN NUMBER) RETURN VARCHAR;
    
    FUNCTION get_sum_price_sales (p_table VARCHAR2 DEFAULT 'products_old') RETURN NUMBER;
    
    FUNCTION get_region_cnt_emp (p_department_id IN NUMBER DEFAULT NULL) RETURN tab_value_list PIPELINED;    
    
    PROCEDURE del_jobs    (p_job_id  IN  VARCHAR2,
                           po_result OUT VARCHAR2);
                        
    PROCEDURE add_new_jobs(p_job_id IN VARCHAR2,
                           p_job_title IN VARCHAR2,
                           p_min_salary IN NUMBER,
                           p_max_salary IN NUMBER DEFAULT NULL,
                           po_err OUT VARCHAR2);
                           
    PROCEDURE add_employee(p_first_name     IN VARCHAR2,
                           p_last_name      IN VARCHAR2,
                           p_email          IN VARCHAR2,
                           p_phone_number   IN VARCHAR2,
                           p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'dd'),
                           p_job_id         IN VARCHAR2,
                           p_salary         IN NUMBER,
                           p_commission_pct IN NUMBER DEFAULT NULL,
                           p_manager_id     IN NUMBER DEFAULT 100,
                           p_department_id  IN NUMBER);                         

    PROCEDURE fire_an_employee(p_employee_id IN NUMBER);
    
END util;



--Тіло
CREATE OR REPLACE PACKAGE BODY olxga_irn.util AS
    
    FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR IS
    
        v_job_title jobs.job_title%TYPE;
    
    BEGIN
        SELECT j.job_title
        INTO v_job_title
        FROM olxga_irn.employees em
        JOIN jobs j
        ON em.job_id = j.job_id
        WHERE em.employee_id = p_employee_id;
        
        RETURN v_job_title;
        
    END get_job_title;
    
    
    FUNCTION get_dep_name (p_employee_id IN NUMBER) RETURN VARCHAR IS
    
        v_department_name departments.department_name%TYPE;
    
    BEGIN
        SELECT d.department_name
        INTO v_department_name
        FROM olxga_irn.employees em
        JOIN departments d
        ON em.department_id = d.department_id
        WHERE em.employee_id = p_employee_id;
    
        RETURN v_department_name;
    
    END get_dep_name;
    
    
    FUNCTION get_sum_price_sales (p_table VARCHAR2 DEFAULT 'products_old') RETURN NUMBER IS
        v_sum NUMBER;
        v_message logs.message%TYPE;
        v_dynamic_sql VARCHAR2(500);
    BEGIN
    
        IF p_table NOT IN ('products', 'products_old') THEN
            v_message := 'Неприпустиме значення! Очікується products або products_old';
            olxga_irn.to_log(p_appl_proc => 'util.get_sum_price_sales', p_message => v_message);
            raise_application_error(-20001, v_message);
        END IF;
        
        v_dynamic_sql := 'SELECT SUM(p.price_sales) FROM hr.' || p_table || ' p';
        
        EXECUTE IMMEDIATE v_dynamic_sql INTO v_sum;
        
        dbms_output.put_line(v_sum);
        
        RETURN v_sum;
        --COMMIT;
    END get_sum_price_sales;
    
        
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
       
    
    PROCEDURE check_work_time IS
    
    BEGIN
    
        IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN', 'MON') THEN
            raise_application_error (-20205, 'Ви можете вносити зміни лише у робочі дні');
        END IF;
        
    END check_work_time;
    
    
    PROCEDURE check_working_hours IS
        v_today            VARCHAR2(10) := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
        v_time             NUMBER       := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24MI'));
    
    BEGIN
    
        IF v_today IN ('SAT', 'SUN') OR v_time < 800 OR v_time > 1800 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ви можете додавати чи видаляти співробітника лише в робочий час');
        END IF;
        
    END check_working_hours;
    
    
    PROCEDURE del_jobs (p_job_id  IN  VARCHAR2,
                        po_result OUT VARCHAR2) IS
        v_delete_no_data_found EXCEPTION;
    BEGIN
        check_work_time;
        
        BEGIN
            DELETE FROM jobs jj
            WHERE jj.job_id = p_job_id;
     
            IF SQL%ROWCOUNT = 0 THEN
                RAISE v_delete_no_data_found;
            ELSE
                po_result := 'Посада ' || p_job_id || ' успішно видалена'; 
            END IF;
    
            
        EXCEPTION 
            WHEN v_delete_no_data_found THEN
                raise_application_error(-20004,  'Посада '|| p_job_id ||' не існує');
        
        --COMMIT;
        END;
    
    END del_jobs;




    PROCEDURE add_new_jobs(p_job_id IN VARCHAR2,
                    p_job_title IN VARCHAR2,
                    p_min_salary IN NUMBER,
                    p_max_salary IN NUMBER DEFAULT NULL,
                    po_err OUT VARCHAR2) IS
                    v_max_salary jobs.max_salarY%TYPE;
                    salary_err EXCEPTION;
                    c_percent_of_min_salary CONSTANT NUMBER := 1.5;
    BEGIN
    
        check_work_time;   
        
        IF p_max_salary IS NULL THEN
            v_max_salary := p_min_salary * c_percent_of_min_salary;
        ELSE
            v_max_salary := p_max_salary;
        END IF;
        
        BEGIN
            IF (p_min_salary < 2000 OR p_max_salary < 2000) THEN
                RAISE salary_err;
            END IF;
            
            INSERT INTO olxga_irn.jobs (job_id, job_title, min_salary, max_salary)
            VALUES (p_job_id, p_job_title, p_min_salary, v_max_salary);
            po_err := 'Посада '||p_job_id||' успішно додана';
        
        EXCEPTION
            WHEN salary_err THEN
                raise_application_error(-20001, 'Передана зарплата менша за 2000');
            WHEN dup_val_on_index THEN
                raise_application_error(-20002, 'Посада '||p_job_id||' вже існує');
            WHEN OTHERS THEN
                raise_application_error(-20003, 'Виникла помилка при додаванні нової посади. '|| SQLERRM);
        END;
    COMMIT;
    
    END add_new_jobs;

    
    PROCEDURE add_employee(p_first_name     IN VARCHAR2,
                       p_last_name      IN VARCHAR2,
                       p_email          IN VARCHAR2,
                       p_phone_number   IN VARCHAR2,
                       p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'dd'),
                       p_job_id         IN VARCHAR2,
                       p_salary         IN NUMBER,
                       p_commission_pct IN NUMBER DEFAULT NULL,
                       p_manager_id     IN NUMBER DEFAULT 100,
                       p_department_id  IN NUMBER) IS
                           
        v_job_id           VARCHAR2(10);
        v_department_id    NUMBER;
        v_min_salary       NUMBER;
        v_max_salary       NUMBER;
        
        v_employee_id      NUMBER;
        v_message          VARCHAR2(4000);

    BEGIN

        log_util.log_start('add_employee', 'Додавання нового співробітника');

        SELECT COUNT(*)
        INTO v_job_id
        FROM olxga_irn.jobs
        WHERE job_id = p_job_id;

        IF v_job_id = 0 THEN
            raise_application_error(-20001, 'Введено неіснуючий код посади');
        END IF;

        SELECT COUNT(*)
        INTO v_department_id
        FROM olxga_irn.departments
        WHERE department_id = p_department_id;

        IF v_department_id = 0 THEN
            raise_application_error(-20001, 'Введено неіснуючий ідентифікатор відділу');
        END IF;

        SELECT min_salary, max_salary
        INTO v_min_salary, v_max_salary
        FROM olxga_irn.jobs
        WHERE job_id = p_job_id;

        IF p_salary < v_min_salary OR p_salary > v_max_salary THEN
            raise_application_error(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');
        END IF;

        check_working_hours;

        SELECT NVL(MAX(employee_id), 0) + 1
        INTO v_employee_id
        FROM olxga_irn.employees;

        BEGIN
            INSERT INTO olxga_irn.employees (employee_id, first_name, last_name, email, phone_number, hire_date,
                job_id, salary, commission_pct, manager_id, department_id) 
                VALUES 
                (v_employee_id, p_first_name, p_last_name, p_email, p_phone_number,
                p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);

            v_message := 'Співробітник ' || p_first_name || ' ' || p_last_name || ', '
                         || p_job_id || ', ' || p_department_id || ' успішно додано до системи';
            DBMS_OUTPUT.PUT_LINE(v_message);

        EXCEPTION
            WHEN OTHERS THEN
                log_util.log_error('add_employee', SQLERRM, 'Помилка при додаванні співробітника');
                raise_application_error(-20001, 'Помилка при додаванні співробітника: ' || SQLERRM);

        END;

        log_util.log_finish('add_employee', v_message);

    END add_employee;
    
    
PROCEDURE fire_an_employee(p_employee_id IN NUMBER) IS
        v_employee_id   NUMBER;
        v_first_name    VARCHAR2(50);
        v_last_name     VARCHAR2(50);
        v_job_id        VARCHAR2(10);
        v_department_id NUMBER;
        v_manager_id    NUMBER;        
        v_hire_date     DATE;
        v_fire_date     DATE := SYSDATE;
        v_message       VARCHAR2(4000);

    BEGIN
        log_util.log_start('fire_an_employee', 'Звільнення співробітника');
        
        check_working_hours;
        
        SELECT COUNT(*)
        INTO v_employee_id
        FROM olxga_irn.employees
        WHERE employee_id = p_employee_id;

        IF v_employee_id = 0 THEN
            raise_application_error(-20001, 'Переданого співробітника не існує');
        END IF;
       
        SELECT first_name, last_name, job_id, department_id, manager_id, hire_date
        INTO v_first_name, v_last_name, v_job_id, v_department_id, v_manager_id, v_hire_date
        FROM olxga_irn.employees
        WHERE employee_id = p_employee_id;
        
        BEGIN
            DELETE FROM olxga_irn.employees
            WHERE employee_id = p_employee_id;

          
            v_message :=  'Співробітник ' || v_first_name || ' ' || v_last_name || ', ' || v_job_id || 
                ', ' || v_department_id || ' успішно звільнений.';
            DBMS_OUTPUT.PUT_LINE(v_message);
            
            EXCEPTION
                WHEN OTHERS THEN
                log_util.log_error('fire_an_employee', SQLERRM, 'Помилка при звільненні співробітника.');
                raise_application_error(-20001, 'Помилка при звільненні співробітника: ' || SQLERRM);
            END;
            
            INSERT INTO olxga_irn.employees_history (
                employee_id, first_name, last_name, job_id, department_id, manager_id, hire_date, fire_date, reason)
            VALUES 
                (p_employee_id, v_first_name, v_last_name, v_job_id, v_department_id, v_manager_id, v_hire_date, v_fire_date, 'Звільнення');

        log_util.log_finish('fire_an_employee', v_message);
            
    END fire_an_employee; 

END util;
