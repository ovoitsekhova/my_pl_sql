DECLARE
    v_date date := TO_DATE('17.05.2024', 'DD.MM.YYYY');
    v_day number;
BEGIN

    v_day := to_number(to_char(v_date, 'dd'));
    
    IF v_date = (last_day(trunc(v_date))) THEN 
        dbms_output.put_line('Виплата зарплати');
    ELSIF v_day = 15 THEN  
        dbms_output.put_line('Виплата авансу');
    ELSIF v_day < 15 THEN 
        dbms_output.put_line('Чекаємо на аванс');
    ELSIF v_day > 15 THEN 
        dbms_output.put_line('Чекаємо на зарплату');
    END IF;

END;
/