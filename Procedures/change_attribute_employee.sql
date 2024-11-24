CREATE OR REPLACE PROCEDURE change_attribute_employee(p_employee_id      IN NUMBER,
                                                      p_first_name       IN VARCHAR2 DEFAULT NULL,
                                                      p_last_name        IN VARCHAR2 DEFAULT NULL,
                                                      p_email            IN VARCHAR2 DEFAULT NULL,
                                                      p_phone_number     IN VARCHAR2 DEFAULT NULL,
                                                      p_job_id           IN VARCHAR2 DEFAULT NULL,
                                                      p_salary           IN NUMBER DEFAULT NULL,
                                                      p_commission_pct   IN NUMBER DEFAULT NULL,
                                                      p_manager_id       IN NUMBER DEFAULT NULL,
                                                      p_department_id    IN NUMBER DEFAULT NULL) IS
    
    TYPE t_column_value IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(30);
    v_column_value     t_column_value;
    
    v_dynamic_sql      VARCHAR2(4000);
    v_set_clause       VARCHAR2(4000);
    v_attribute_to_upd NUMBER := 0;
    v_message          VARCHAR2(4000);
    
BEGIN
    olxga_irn.log_util.log_start('change_attribute_employee', 'Зміна атрибутів співробітника');

    v_column_value('first_name') := p_first_name;
    v_column_value('last_name') := p_last_name;
    v_column_value('email') := p_email;
    v_column_value('phone_number') := p_phone_number;
    v_column_value('job_id') := p_job_id;
    v_column_value('salary') := CASE WHEN p_salary IS NOT NULL THEN TO_CHAR(p_salary) ELSE NULL END;
    v_column_value('commission_pct') := CASE WHEN p_commission_pct IS NOT NULL THEN TO_CHAR(p_commission_pct) ELSE NULL END;
    v_column_value('manager_id') := CASE WHEN p_manager_id IS NOT NULL THEN TO_CHAR(p_manager_id) ELSE NULL END;
    v_column_value('department_id') := CASE WHEN p_department_id IS NOT NULL THEN TO_CHAR(p_department_id) ELSE NULL END;

    FOR column_name IN v_column_value.FIRST .. v_column_value.LAST LOOP
        IF v_column_value.EXISTS(column_name) AND v_column_value(column_name) IS NOT NULL THEN
            IF v_set_clause IS NOT NULL THEN
                v_set_clause := v_set_clause || ', ';
            END IF;

            v_set_clause := v_set_clause || column_name || ' = ' || 
                            CASE
                                WHEN column_name IN ('first_name', 'last_name', 'email', 'phone_number', 'job_id') THEN
                                    '''' || v_column_value(column_name) || ''''
                                ELSE
                                    v_column_value(column_name)
                            END;
            v_attribute_to_upd := v_attribute_to_upd + 1;
        END IF;
    END LOOP;

    IF v_attribute_to_upd = 0 THEN
        olxga_irn.log_util.log_finish('change_attribute_employee', 'Не вказано жодного параметра для оновлення.');
        RAISE_APPLICATION_ERROR(-20001, 'Не вказано жодного параметра для оновлення.');
    END IF;

    v_dynamic_sql := 'UPDATE employees SET ' || v_set_clause || ' WHERE employee_id = ' || p_employee_id;

    BEGIN
        EXECUTE IMMEDIATE v_dynamic_sql;

        v_message := 'У співробітника ' || p_employee_id || ' успішно оновлено ' || v_attribute_to_upd || ' атрибути(-ів).';
        olxga_irn.log_util.log_finish('change_attribute_employee', v_message);

    EXCEPTION
        WHEN OTHERS THEN
            olxga_irn.log_util.log_error('change_attribute_employee', SQLERRM, 'Помилка при оновленні атрибутів');
            RAISE_APPLICATION_ERROR(-20002, 'Помилка при оновленні атрибутів: ' || SQLERRM);
    END;
END change_attribute_employee;
/
