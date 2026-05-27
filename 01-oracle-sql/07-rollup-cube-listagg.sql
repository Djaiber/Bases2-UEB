/*
File: 07-rollup-cube-listagg.sql
Purpose: Ejemplos de ROLLUP, CUBE y LISTAGG en HR.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

-- ROLLUP
SELECT department_id,
       job_id,
       SUM(salary) AS vn_total_salario
  FROM hr.employees
 GROUP BY ROLLUP (department_id, job_id)
 ORDER BY department_id, job_id;

-- CUBE
SELECT department_id,
       job_id,
       COUNT(*) AS vn_total_empleados
  FROM hr.employees
 GROUP BY CUBE (department_id, job_id)
 ORDER BY department_id, job_id;

-- LISTAGG
SELECT d.department_id,
       d.department_name AS vv_departamento,
       LISTAGG(e.first_name || ' ' || e.last_name, ', ')
         WITHIN GROUP (ORDER BY e.last_name) AS vv_empleados
  FROM hr.departments d
  LEFT JOIN hr.employees e
    ON e.department_id = d.department_id
 GROUP BY d.department_id, d.department_name
 ORDER BY d.department_id;
