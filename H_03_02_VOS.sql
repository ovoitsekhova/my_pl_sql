CREATE FUNCTION get_dep_name (p_employee_id IN NUMBER) RETURN VARCHAR IS

    v_department_name departments.department_name%TYPE;

BEGIN
    SELECT d.department_name
    INTO v_department_name
    FROM olxga_irn.employees em
    JOIN olxga_irn.departments d
    ON em.department_id = d.department_id
    WHERE em.employee_id = p_employee_id;
    
    RETURN v_department_name;
    
END get_dep_name;
/

--Виклик функцій
SELECT em.employee_id,
       em.first_name,
       em.last_name,
       get_job_title(p_employee_id => em.employee_id) as job_title,
       get_dep_name (p_employee_id => em.employee_id) as department_name
FROM olxga_irn.employees em
