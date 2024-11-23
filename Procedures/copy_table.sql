 CREATE OR REPLACE PROCEDURE copy_table (p_source_scheme IN VARCHAR2,
                                         p_target_scheme IN VARCHAR2 DEFAULT USER,
                                         p_list_table    IN VARCHAR2,
                                         p_copy_data     IN BOOLEAN DEFAULT FALSE,
                                         po_result       OUT VARCHAR2) IS
                                       
    v_dynamic_sql VARCHAR2(4000);
    v_is_exist_target NUMBER;
                                       
    PROCEDURE do_create_table (p_sql IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        EXECUTE IMMEDIATE p_sql;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            olxga_irn.log_util.log_error('do_create_table', SQLERRM, 'Помилка створення таблиці');
    END;

BEGIN

    olxga_irn.log_util.log_start('copy_table', 'Запуск процедури copy_table.');

    FOR table_rec IN (
        SELECT table_name, ddl_code
        FROM (
            SELECT table_name,
                   'CREATE TABLE ' || table_name || ' (' ||
                   LISTAGG(column_name || ' ' || data_type || NVL(count_symbol, ''), ', ') 
                   WITHIN GROUP (ORDER BY column_id) || ')' AS ddl_code
            FROM (
                SELECT table_name,
                       column_name,
                       data_type,
                       CASE
                           WHEN data_type IN ('VARCHAR2', 'CHAR') THEN '(' || data_length || ')'
                           WHEN data_type = 'DATE' THEN NULL
                           WHEN data_type = 'NUMBER' THEN REPLACE('(' || data_precision || ',' || data_scale || ')', '(,)', NULL)
                       END AS count_symbol,
                       column_id
                FROM all_tab_columns
                WHERE owner = UPPER(p_source_scheme)
                  AND table_name IN (
                    SELECT UPPER(value_list)
                    FROM TABLE(olxga_irn.util.table_from_list(p_list_table)))
                  )
            GROUP BY table_name  
        )
    ) LOOP

         BEGIN

            SELECT COUNT(*)
            INTO v_is_exist_target
            FROM all_tables
            WHERE owner = UPPER(p_target_scheme)
              AND table_name = UPPER(table_rec.table_name);
            
            IF v_is_exist_target > 0 THEN
                olxga_irn.log_util.log_error('copy_table', SQLERRM, 'Таблиця ' || table_rec.table_name || ' вже існує в схемі ' || p_target_scheme);
                CONTINUE; 
            END IF;

            do_create_table(table_rec.ddl_code);

            IF p_copy_data = TRUE THEN
                v_dynamic_sql := 'INSERT INTO ' || p_target_scheme || '.' || table_rec.table_name || 
                                 ' SELECT * FROM ' || p_source_scheme || '.' || table_rec.table_name;
                EXECUTE IMMEDIATE v_dynamic_sql;
                olxga_irn.to_log('copy_table', 'Дані таблиці ' || table_rec.table_name || ' успішно скопійовані');
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                olxga_irn.log_util.log_error('copy_table', SQLERRM, 'Помилка при копіюванні таблиці ' || table_rec.table_name);
                CONTINUE; 
        END;

    END LOOP;

    po_result := 'Копіювання завершено.';
    olxga_irn.log_util.log_finish('copy_table', po_result);    

EXCEPTION
    WHEN OTHERS THEN
        po_result := 'Помилка при копіюванні: ' || SQLERRM;
        olxga_irn.log_util.log_error('copy_table', SQLERRM, 'Помилка при копіюванні таблиць');
END;
