show user;

BEGIN
    SELECT COUNT(*)
    INTO V_1
    FROM COUNTRIES
    WHERE COUNTRY_NAME = 'bogota';

    IF V_1 = 0 THEN 
        RAISE exc_registros;
    END IF;

    V_3 := V_1/V_2;

EXCEPTION
    WHEN exc_registros THEN
        dbms_output.PUT_LINE('pailas mijo');
    WHEN ZERO_DIVIDE THEN
        dbms_output.PUT_LINE('division por cero');
END;
/

SELECT * 
FROM USER_SYS_PRIVS
WHERE PRIVILEGE;
SELECT *
FROM USER_SYS_PRIVS;