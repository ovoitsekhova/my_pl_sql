DECLARE
    v_recipient VARCHAR2(50);
    v_subject VARCHAR2(50) := 'test_subject';
    v_mes VARCHAR2(5000) := 'Вітаю! </br> Висилаю звіт по департаментах нашої компанії: </br></br>';
BEGIN
SELECT
    v_mes||'<!DOCTYPE html>
    <html>
    <head>
    <title></title>
    <style>
    table, th, td {border: 1px solid;}
    .center{text-align: center;}
    </style>
    </head>
    <body>
    <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
    <thead>
    <tr align=left>
    <th>Назва департаменту</th>
    <th>Кількість співробітників</th>
    </tr>
    </thead>
    <tbody>
    '|| list_html || '
    </tbody>
    </table>
    </body>
    </html>' AS html_table
    
INTO v_mes

FROM (
SELECT LISTAGG('<tr align=left>
                <td>' || department_name || '</td>' || '
                <td class=''center''> ' || cnt_empl||'</td>
                </tr>', '<tr>')
WITHIN GROUP(ORDER BY cnt_empl desc) AS list_html
FROM (SELECT 
        d.department_name,
        count(e.employee_id) cnt_empl
      FROM employees e
      LEFT JOIN departments d on d.department_id = e.department_id
      WHERE d.department_name is not null
      GROUP BY d.department_name)); 
        
v_mes := v_mes || '</br></br> З повагою, Ольга';
    
    SELECT email  || '@gmail.com' INTO v_recipient
    FROM employees
    WHERE employee_id = 250;

sys.sendmail(p_recipient => v_recipient,
             p_subject   => v_subject,
             p_message   => v_mes || ' ');
END;
/
