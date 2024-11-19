--Успішно
BEGIN
    util.fire_an_employee(p_employee_id      => 201);
END;
/

--Неуспішно 
BEGIN
    util.fire_an_employee(p_employee_id      => 10);
END;
/


SELECT * FROM logs;

SELECT * FROM employees_history;
