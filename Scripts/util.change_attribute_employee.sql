--вдалий кейс
BEGIN
    olxga_irn.util.change_attribute_employee(
        p_employee_id => 140,
        p_first_name => 'Jenny',
        p_last_name => NULL,
        p_salary => 8000
    );
END;
/

--невдалий кейс
BEGIN
    olxga_irn.util.change_attribute_employee(
        p_employee_id => 140,
        p_last_name => NULL
    );
END;
/
