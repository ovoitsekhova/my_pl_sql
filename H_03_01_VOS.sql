CREATE OR REPLACE PROCEDURE del_jobs (p_job_id  IN  VARCHAR2,
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
/


--Виклик процедури
DECLARE
    v_result VARCHAR2(100);
BEGIN
    del_jobs(p_job_id  => 'IT_PROG',
             po_result => v_result);
    dbms_output.put_line(v_result);
END;
/

