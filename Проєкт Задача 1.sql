--Ñïåöèô³êàö³ÿ
CREATE OR REPLACE PACKAGE log_util AS

    PROCEDURE log_start (p_proc_name IN VARCHAR2, 
                         p_text IN VARCHAR2 DEFAULT NULL);
                         
    PROCEDURE log_finish (p_proc_name IN VARCHAR2, 
                          p_text IN VARCHAR2 DEFAULT NULL);
                          
    PROCEDURE log_error(p_proc_name IN VARCHAR2, 
                        p_sqlerrm IN VARCHAR2, 
                        p_text IN VARCHAR2 DEFAULT NULL);
END log_util;
/


--Ò³ëî
CREATE OR REPLACE PACKAGE BODY log_util AS

    PROCEDURE to_log (p_appl_proc IN VARCHAR2,
                      p_message   IN VARCHAR2) IS
    PRAGMA autonomous_transaction;
    
    BEGIN
        INSERT INTO logs (id, appl_proc, message)
        VALUES (log_seq.NEXTVAL, p_appl_proc, p_message);
        COMMIT;
    END to_log;


    PROCEDURE log_start (p_proc_name IN VARCHAR2, 
                         p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(4000);
        
    BEGIN
        IF p_text IS NULL THEN
            v_text := 'Ñòàðò ëîãóâàííÿ, íàçâà ïðîöåñó = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;

        to_log (p_appl_proc => p_proc_name, 
                p_message   => v_text);      
    END log_start;


    PROCEDURE log_finish (p_proc_name IN VARCHAR2, 
                          p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(4000);
        
    BEGIN
        IF p_text IS NULL THEN
            v_text := 'Çàâåðøåííÿ ëîãóâàííÿ, íàçâà ïðîöåñó = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;

        to_log(p_appl_proc => p_proc_name, 
               p_message   => v_text);
    END log_finish;


    PROCEDURE log_error (p_proc_name IN VARCHAR2, 
                         p_sqlerrm IN VARCHAR2, 
                         p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(4000);
        
    BEGIN
        IF p_text IS NULL THEN
            v_text := 'Â ïðîöåäóð³ ' || p_proc_name || ' ñòàëàñÿ ïîìèëêà. ' || p_sqlerrm;
        ELSE
            v_text := p_text;
        END IF;

        to_log(p_appl_proc => p_proc_name, 
               p_message   => v_text);
    END log_error;

END log_util;
/
