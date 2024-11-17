CREATE OR REPLACE TRIGGER hire_date_update
    BEFORE UPDATE ON employees
    FOR EACH ROW

BEGIN
    IF :OLD.job_id != :NEW.job_id THEN
        :NEW.hire_date := TRUNC(SYSDATE, 'DD');
    END IF;
END hire_date_update;
