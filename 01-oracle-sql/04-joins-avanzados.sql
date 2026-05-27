/*
File: 04-joins-avanzados.sql
Purpose: Ejemplos de SELF JOIN, FULL OUTER JOIN y CROSS JOIN en esquema HR.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

-- SELF JOIN (jerarquía de 2 niveles)
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS vv_empleado,
       m.employee_id AS vn_manager_id,
       m.first_name || ' ' || m.last_name AS vv_manager,
       mm.employee_id AS vn_super_manager_id,
       mm.first_name || ' ' || mm.last_name AS vv_super_manager
  FROM hr.employees e
  LEFT JOIN hr.employees m
    ON e.manager_id = m.employee_id
  LEFT JOIN hr.employees mm
    ON m.manager_id = mm.employee_id
 ORDER BY e.employee_id;

-- FULL OUTER JOIN
SELECT d.department_id,
       d.department_name AS vv_departamento,
       e.employee_id,
       e.first_name || ' ' || e.last_name AS vv_empleado
  FROM hr.departments d
  FULL OUTER JOIN hr.employees e
    ON e.department_id = d.department_id
 ORDER BY d.department_id, e.employee_id;

-- CROSS JOIN
SELECT r.region_name AS vv_region,
       j.job_title AS vv_job_title
  FROM hr.regions r
 CROSS JOIN hr.jobs j
 ORDER BY r.region_name, j.job_title;
