/*
File: 06-window-functions.sql
Purpose: Ejemplos de funciones analíticas (RANK, LAG, RUNNING TOTAL, NTILE) en HR.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

-- RANK / DENSE_RANK / ROW_NUMBER
SELECT employee_id,
       department_id,
       salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS vn_rank,
       DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS vn_dense_rank,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS vn_row_number
  FROM hr.employees
 ORDER BY department_id, salary DESC;

-- LAG / LEAD
SELECT employee_id,
       hire_date,
       salary,
       LAG(salary, 1) OVER (ORDER BY hire_date) AS vn_salario_prev,
       LEAD(salary, 1) OVER (ORDER BY hire_date) AS vn_salario_next
  FROM hr.employees
 ORDER BY hire_date;

-- Running total por departamento
SELECT employee_id,
       department_id,
       hire_date,
       salary,
       SUM(salary) OVER (
         PARTITION BY department_id
         ORDER BY hire_date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS vn_running_total
  FROM hr.employees
 ORDER BY department_id, hire_date;

-- NTILE (cuartiles de salario)
SELECT employee_id,
       salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS vn_cuartil
  FROM hr.employees
 ORDER BY salary DESC;
