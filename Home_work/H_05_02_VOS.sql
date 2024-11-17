CREATE OR REPLACE VIEW rep_project_dep_v AS

SELECT ext_fl.project_id,
       ext_fl.project_name,
       d.department_name,
       COUNT(e.employee_id) employees_num,
       COUNT(DISTINCT e.manager_id) managers_num,
       SUM(e.salary) salary

FROM EXTERNAL ( ( project_id NUMBER, 
                  project_name VARCHAR2(500), 
                  department_id NUMBER)
TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER
ACCESS PARAMETERS ( records delimited BY newline
                    nologfile
                    nobadfile
                    fields terminated BY ','
                    missing field VALUES are NULL )
LOCATION('PROJECTS.csv')
REJECT LIMIT UNLIMITED) ext_fl

LEFT JOIN departments d on d.department_id = ext_fl.department_id
LEFT JOIN employees e on e.department_id = d.department_id

GROUP BY ext_fl.project_id,
         ext_fl.project_name,
         d.department_name
         
ORDER BY ext_fl.project_id;


CREATE OR REPLACE PROCEDURE write_file_to_disk IS
    file_handle UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200) := 'FILES_FROM_SERVER';
    file_name VARCHAR2(200) := 'TOTAL_PROJ_INDEX_vos.csv';
    file_content VARCHAR2(4000);
BEGIN

    FOR cc IN (SELECT v.project_id ||','|| v.project_name ||','|| v.department_name ||','|| v.employees_num ||','|| v.managers_num ||','|| v.salary AS file_content
               FROM rep_project_dep_v v) LOOP
        file_content := file_content || cc.file_content||CHR(10);
    END LOOP;

file_handle := UTL_FILE.FOPEN(file_location, file_name, 'W');

UTL_FILE.PUT_RAW(file_handle, UTL_RAW.CAST_TO_RAW(file_content));

UTL_FILE.FCLOSE(file_handle);

EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END write_file_to_disk;
/
         







         






