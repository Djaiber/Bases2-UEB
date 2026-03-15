DECLARE
    err_num NUMBER;
    exc_miPrimeraException EXCEPTION;
    err_msg VARCHAR2(255);
    result NUMBER;
BEGIN
    IF 1 = 0 THEN
        RAISE exc_miPrimeraException;
    ELSE
        SELECT 1/0 INTO result FROM DUAL;
    END IF;

EXCEPTION
    WHEN exc_miPrimeraException THEN
        DBMS_OUTPUT.PUT_LINE('Penalti para el yuyu');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20455, 'Les dije que pongan cuidado');
END;
/

SELECT sysdate
FROM HR.EMPLOYEES;

SELECT sysdate
FROM DUAL;

select * from table(dbms_xplan.display_cursor(sql_id=>'80qxzd37nu8jb', format=>'ALLSTATS LAST'));

select * from table(dbms_xplan.display_cursor(sql_id=>'97t2kxuftnk6r', format=>'ALLSTATS LAST'));


