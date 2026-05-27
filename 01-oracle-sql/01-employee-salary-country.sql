-- Jaiber Duvan Diaz Leon
-- 1. Escriba una consulta SQL que muestre el nombre completo del empleado, su rango salarial y el país donde trabaja.
SELECT
    e.FIRST_NAME ||' '|| e.LAST_NAME AS NOMBRE_EMPLEADO,
    e.SALARY AS RANGO_SALARIO,
    c.COUNTRY_NAME AS PAIS
FROM HR.EMPLOYEES e
JOIN HR.DEPARTMENTS d
    ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
JOIN HR.LOCATIONS l
    ON d.LOCATION_ID = l.LOCATION_ID
JOIN HR.COUNTRIES c
    ON l.COUNTRY_ID = c.COUNTRY_ID

WHERE c.REGION_ID = 10;
   -- AND e.SALARY BETWEEN 6000 AND 10000;
