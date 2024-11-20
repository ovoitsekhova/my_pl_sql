--Успішно
BEGIN
    olxga_irn.util.fire_an_employee(p_employee_id      => 201);
END;
/

--Неуспішно 
BEGIN
    olxga_irn.util.fire_an_employee(p_employee_id      => 10);
END;
/


SELECT * FROM olxga_irn.logs;

SELECT * FROM olxga_irn.employees_history;
