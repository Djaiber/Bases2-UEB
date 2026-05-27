/*
File: 07-cursores.sql
Purpose: Ejemplos de cursores explícitos, parametrizados y FOR UPDATE en HR.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

SET SERVEROUTPUT ON;

-- Cursor explícito
DECLARE
  CURSOR c_emp IS
    SELECT employee_id, first_name, last_name
      FROM hr.employees
     WHERE department_id = 10;
  vn_employee_id hr.employees.employee_id%TYPE;
  vv_first_name hr.employees.first_name%TYPE;
  vv_last_name hr.employees.last_name%TYPE;
BEGIN
  OPEN c_emp;
  LOOP
    FETCH c_emp INTO vn_employee_id, vv_first_name, vv_last_name;
    EXIT WHEN c_emp%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(vn_employee_id || ' - ' || vv_first_name || ' ' || vv_last_name);
  END LOOP;
  CLOSE c_emp;
END;
/

-- Cursor parametrizado
DECLARE
  CURSOR c_emp_depto(param_depto_id NUMBER) IS
    SELECT employee_id, salary
      FROM hr.employees
     WHERE department_id = param_depto_id;
  vn_total NUMBER := 0;
BEGIN
  FOR rec IN c_emp_depto(50) LOOP
    vn_total := vn_total + rec.salary;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Total salario depto 50: ' || vn_total);
END;
/

-- Cursor FOR UPDATE
DECLARE
  CURSOR c_salarios(param_depto_id NUMBER) IS
    SELECT employee_id, salary
      FROM hr.employees
     WHERE department_id = param_depto_id
       FOR UPDATE;
BEGIN
  FOR rec IN c_salarios(60) LOOP
    UPDATE hr.employees
       SET salary = salary * 1.05
     WHERE CURRENT OF c_salarios;
  END LOOP;
  COMMIT;
END;
/
