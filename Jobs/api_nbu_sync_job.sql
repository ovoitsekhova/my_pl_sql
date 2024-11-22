BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'api_nbu_sync_job',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN olxga_irn.util.api_nbu_sync; END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; BYHOUR=6',
        enabled         => TRUE
    );
END;
/
