/*
File: 08-packages.sql
Purpose: Paquete PKG_HR_UTILS con función y procedimiento sobre HR.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE PKG_HR_UTILS IS
  FUNCTION fn_nombre_completo(param_emp_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE sp_listar_depto(param_depto_id IN NUMBER);
END PKG_HR_UTILS;
/

CREATE OR REPLACE PACKAGE BODY PKG_HR_UTILS IS
  FUNCTION fn_nombre_completo(param_emp_id IN NUMBER) RETURN VARCHAR2 IS
    vv_nombre VARCHAR2(200);
  BEGIN
    SELECT first_name || ' ' || last_name
      INTO vv_nombre
      FROM hr.employees
     WHERE employee_id = param_emp_id;
    RETURN vv_nombre;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Empleado no encontrado';
  END fn_nombre_completo;

  PROCEDURE sp_listar_depto(param_depto_id IN NUMBER) IS
  BEGIN
    FOR rec IN (
      SELECT employee_id, first_name, last_name
        FROM hr.employees
       WHERE department_id = param_depto_id
       ORDER BY employee_id
    ) LOOP
      DBMS_OUTPUT.PUT_LINE(rec.employee_id || ' - ' || rec.first_name || ' ' || rec.last_name);
    END LOOP;
  END sp_listar_depto;
END PKG_HR_UTILS;
/
