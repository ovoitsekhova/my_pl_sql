--Успішно
BEGIN
    olxga_irn.util.add_employee(p_first_name      => 'Olha',
                                p_last_name       => 'Voitsekhova',
                                p_email           => 'ovoitsekhova@gmail.com', 
                                p_phone_number    => '0938888888',
                                p_job_id          => 'MK_MAN',
                                p_salary          => 12000,
                                p_manager_id      => 201,
                                p_department_id   => 20);

END;
/

--Неуспішно 1
BEGIN
    olxga_irn.util.add_employee(p_first_name      => 'Olha',
                                p_last_name       => 'Voitsekhova',
                                p_email           => 'ovoitsekhova@gmail.com', 
                                p_phone_number    => '0938888888',
                                p_job_id          => 'MK_MAN',
                                p_salary          => 12000,
                                p_manager_id      => 201,
                                p_department_id   => 2);

END;
/

--Неуспішно 2
BEGIN
    olxga_irn.util.add_employee(p_first_name      => 'Olha',
                                p_last_name       => 'Voitsekhova',
                                p_email           => 'ovoitsekhova@gmail.com', 
                                p_phone_number    => '0938888888',
                                p_job_id          => 'MK_MAN',
                                p_salary          => 120000,
                                p_manager_id      => 201,
                                p_department_id   => 20);

END;
/


--Неуспішно 3
BEGIN
    olxga_irn.util.add_employee(p_first_name      => 'Olha',
                                p_last_name       => 'Voitsekhova',
                                p_email           => 'ovoitsekhova@gmail.com', 
                                p_phone_number    => '0938888888',
                                p_job_id          => 'MK_MA',
                                p_salary          => 12000,
                                p_manager_id      => 201,
                                p_department_id   => 20);

END;
/
