/*
File: 05-subconsultas.sql
Purpose: Subconsultas escalares, EXISTS, NOT IN vs NOT EXISTS e inline views en HR.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

-- Subconsulta escalar
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS vv_empleado,
       (SELECT d.department_name
          FROM hr.departments d
         WHERE d.department_id = e.department_id) AS vv_departamento
  FROM hr.employees e
 ORDER BY e.employee_id;

-- EXISTS
SELECT d.department_id,
       d.department_name AS vv_departamento
  FROM hr.departments d
 WHERE EXISTS (
       SELECT 1
         FROM hr.employees e
        WHERE e.department_id = d.department_id
          AND e.salary > 8000
     )
 ORDER BY d.department_id;

-- NOT IN (puede verse afectado por NULL)
SELECT d.department_id,
       d.department_name AS vv_departamento
  FROM hr.departments d
 WHERE d.department_id NOT IN (
       SELECT e.department_id
         FROM hr.employees e
     )
 ORDER BY d.department_id;

-- NOT EXISTS (recomendado)
SELECT d.department_id,
       d.department_name AS vv_departamento
  FROM hr.departments d
 WHERE NOT EXISTS (
       SELECT 1
         FROM hr.employees e
        WHERE e.department_id = d.department_id
     )
 ORDER BY d.department_id;

-- Inline view
SELECT iv.department_id,
       iv.vn_promedio_salario
  FROM (
       SELECT e.department_id,
              ROUND(AVG(e.salary), 2) AS vn_promedio_salario
         FROM hr.employees e
        GROUP BY e.department_id
  ) iv
 WHERE iv.vn_promedio_salario > 7000
 ORDER BY iv.department_id;
