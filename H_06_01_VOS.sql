CREATE TABLE interbank_index_ua_history
    (dt  DATE,
    id_api VARCHAR2(100),
    value NUMBER,
    special VARCHAR2(10));


select * from interbank_index_ua_history;


SET DEFINE OFF;

CREATE OR REPLACE VIEW interbank_index_ua_v ("DT", "ID_API", "VALUE", "SPECIAL") AS 
SELECT TO_DATE(tt.dt, 'dd.mm.yyyy'), tt.id_api, tt.value, tt.special  AS exchangedate
FROM (SELECT sys.get_nbu(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS json_value 
      FROM dual)
CROSS JOIN json_table
    (json_value, '$[*]'
    COLUMNS
    (dt VARCHAR2(100) PATH '$.dt',
    id_api VARCHAR2(100) PATH '$.id_api',
    value NUMBER PATH '$.value',
    special VARCHAR2(10) PATH '$.special')) TT;
    

CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS
BEGIN
    INSERT INTO interbank_index_ua_history
    SELECT * FROM interbank_index_ua_v;
    COMMIT;
END download_ibank_index_ua;
/


BEGIN 
    download_ibank_index_ua;
END;
/


BEGIN
sys.dbms_scheduler.create_job(job_name      => 'update_ibank_index',
                            job_type        => 'PLSQL_BLOCK',
                            job_action      => 'begin download_ibank_index_ua(); end;',
                            start_date      => SYSDATE,
                            repeat_interval => 'FREQ=DAILY;BYHOUR=9;BYMINUTE=00',
                            end_date        => TO_DATE(NULL),
                            job_class       => 'DEFAULT_JOB_CLASS',
                            enabled         => TRUE,
                            auto_drop       => FALSE,
                            comments        => 'Оновлення Українського індексу міжбанківських ставок овернайт');
END;
/



