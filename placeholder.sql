/*
    Nombre: Jaiber Diaz
    Fecha: 2026-02-28
    descripción: Este script muestra cómo usar placeholders en una consulta SQL dinámica con EXECUTE IMMEDIATE.
*/

-- Replicacion de la tabla de empleados para pruebas
CREATE TABLE JDemployees AS SELECT * FROM HR.employees;

SELECT * FROM jdemployees;


DECLARE
    v_id NUMBER := 205;
    v_depto VARCHAR2(20) := 'AC_MGR';
    v_salario NUMBER;
BEGIN
    EXECUTE IMMEDIATE 
        'SELECT salary FROM jdemployees WHERE employee_id = :x AND job_id = :y'
        INTO v_salario
        USING v_id, v_depto;  -- Mismo orden que los placeholders
        
    DBMS_OUTPUT.PUT_LINE('Salario: ' || v_salario || CHR(10)||
                        'id_empleado: ' || v_id || CHR(10)||
                        'departamento: ' || v_depto );
END;
/