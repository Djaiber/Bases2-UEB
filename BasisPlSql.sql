SET SERVEROUTPUT ON;--- COMANDO MAGICO PARA ESTABLECER LA CONEXION
/*
Acuerdo de clase:
VARIABLES
vi_xxxx variables integer
vn_XXXX variables numericas (num)
vd_xxxx variables de fechas (date)
vv_xxxx varaables de texto (varchar)
vdo_xxx variables doble (double)
CONSTANTES
cn_xxxx 
cd_xxxx
cv_xxxx
cdo_xxxx
*/
--primera manera de pasar una variable
DECLARE
    vv_miPrimeraVariable VARCHAR2(50);
BEGIN
    vv_miPrimeraVariable := 'Hola mundo';
    dbms_output.put_line(vv_miPrimeraVariable);
END;
/
--segunda manera de pasar una variable
DECLARE
    vv_miPrimeraVariable  VARCHAR2(50) := 'Hola mundo';
BEGIN
    dbms_output.put_line(vv_miPrimeraVariable);
END;
/
-- Traer los nombres del empleado 110
DECLARE
    vv_nombre VARCHAR2(50);
    vv_apellido VARCHAR2(50);
    
BEGIN
    SELECT first_name,
           last_name INTO vv_nombre, vv_apellido
    FROM HR.employees
    WHERE employee_id = 110;
    dbms_output.put_line('El empleado del empelado es: ' || vv_nombre || ' '|| vv_apellido);
END;
/
-- Traer todos los atributos del empleado 110
DECLARE
    vv_nombre HR.employees.first_name%TYPE; --hereda el tipo de dato en la tabla
    vv_apellido HR.employees.last_name%TYPE;
BEGIN
    SELECT first_name,
           last_name INTO vv_nombre, vv_apellido
    FROM HR.employees
    WHERE employee_id = 110;
    dbms_output.put_line('El empleado del empelado es: ' || vv_nombre || ' '|| vv_apellido);
END;
/
-- traer los atributos con ROWTYPE del empleado
DECLARE
    vv_empleado HR.employees%ROWTYPE; 
BEGIN
    SELECT * INTO vv_empleado
    FROM HR.employees
    WHERE employee_id = 110;
    dbms_output.put_line('El empleado del empelado es: ' || vv_empleado.first_name || ' '|| vv_empleado.last_name);
END;
/
-- traer los atributos con ROWTYPE del empleado
DECLARE
    vv_empleado HR.employees%ROWTYPE; 
BEGIN
    SELECT * INTO vv_empleado
    FROM HR.employees
    WHERE employee_id = 110 IN (110,108);
    dbms_output.put_line('El empleado del empelado es: ' || vv_empleado.first_name || ' '|| vv_empleado.last_name);
END;
/

