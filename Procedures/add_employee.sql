CREATE OR REPLACE PROCEDURE add_employee(p_first_name     IN VARCHAR2,
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
              
    v_today            VARCHAR2(10) := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_time             NUMBER       := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24MI'));
                      
    v_employee_id      NUMBER;
    v_message          VARCHAR2(4000);

    BEGIN

        log_util.log_start('add_employee', 'Додавання нового співробітника');

        SELECT COUNT(*)
        INTO v_job_id
        FROM jobs
        WHERE job_id = p_job_id;

        IF v_job_id = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Введено неіснуючий код посади');
        END IF;

        SELECT COUNT(*)
        INTO v_department_id
        FROM departments
        WHERE department_id = p_department_id;

        IF v_department_id = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Введено неіснуючий ідентифікатор відділу');
        END IF;

        SELECT min_salary, max_salary
        INTO v_min_salary, v_max_salary
        FROM jobs
        WHERE job_id = p_job_id;

        IF p_salary < v_min_salary OR p_salary > v_max_salary THEN
            RAISE_APPLICATION_ERROR(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');
        END IF;

        IF v_today IN ('SAT', 'SUN') OR v_time < 800 OR v_time > 1800 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
        END IF;

        SELECT NVL(MAX(employee_id), 0) + 1
        INTO v_employee_id
        FROM employees;

        BEGIN
            INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date,
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
                RAISE;
        END;

        log_util.log_finish('add_employee', v_message);

    END add_employee;
