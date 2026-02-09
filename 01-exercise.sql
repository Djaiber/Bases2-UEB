-- Jaiber Duvan Diaz Leon
-- 2. Escriba una consulta SQL que muestre el nombre del empleado y su
SELECT 
    e.FIRST_NAME  AS NOMBRE_EMPLEADO,
    '**' || SUBSTR(e.EMAIL,1,6) AS USERNAME
FROM HR.EMPLOYEES e