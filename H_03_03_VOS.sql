--Specification
CREATE OR REPLACE PACKAGE util AS
    
    FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR;
    
    FUNCTION get_dep_name (p_employee_id IN NUMBER) RETURN VARCHAR;
    
    PROCEDURE del_jobs (p_job_id  IN  VARCHAR2,
                        po_result OUT VARCHAR2);
    
END util;

--Body
CREATE OR REPLACE PACKAGE body util AS
    
    FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR IS

    v_job_title jobs.job_title%TYPE;

BEGIN
    SELECT j.job_title
    INTO v_job_title
    FROM employees em
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
    FROM employees em
    JOIN departments d
    ON em.department_id = d.department_id
    WHERE em.employee_id = p_employee_id;

    RETURN v_department_name;

END get_dep_name;


PROCEDURE del_jobs (p_job_id  IN  VARCHAR2,
                    po_result OUT VARCHAR2) IS

    v_is_exist_job NUMBER;

BEGIN

    SELECT COUNT(j.job_id)
    INTO v_is_exist_job
    FROM olxga_irn.jobs j
    WHERE j.job_id = p_job_id;

    IF v_is_exist_job = 0 THEN
        po_result := 'Посада '|| p_job_id ||' не існує';
    ELSE
        DELETE FROM jobs jj
        WHERE jj.job_id = p_job_id;
        COMMIT;
        po_result := 'Посада ' || p_job_id || ' успішно видалена';

    END IF;

END del_jobs;

END util;


--Drop
DROP FUNCTION get_job_title;

DROP FUNCTION get_dep_name;

DROP PROCEDURE del_jobs;


--Виклик функцій 
SELECT em.employee_id,
       em.first_name,
       em.last_name,
       util.get_job_title(p_employee_id => em.employee_id) as job_title,
       util.get_dep_name (p_employee_id => em.employee_id) as department_name
FROM olxga_irn.employees em


--Виклик процедури
DECLARE
    v_result VARCHAR2(100);
BEGIN
    util.del_jobs(p_job_id  => 'IT_PROG',
             po_result => v_result);
    dbms_output.put_line(v_result);
END;
/

