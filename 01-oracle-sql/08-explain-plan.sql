/*
File: 08-explain-plan.sql
Purpose: Ejemplos de EXPLAIN PLAN comparando NATURAL JOIN vs JOIN explícito.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

-- NATURAL JOIN
EXPLAIN PLAN FOR
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS vv_empleado,
       d.department_name AS vv_departamento
  FROM hr.employees e
 NATURAL JOIN hr.departments d;

SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY);

-- JOIN explícito
EXPLAIN PLAN FOR
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS vv_empleado,
       d.department_name AS vv_departamento
  FROM hr.employees e
  JOIN hr.departments d
    ON e.department_id = d.department_id;

SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY);
