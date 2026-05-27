DECLARE
    err_num NUMBER;
    exc_PrimeraException EXCEPTION;
    err_msg VARCHAR2(255);
    result NUMBER;
BEGIN
    IF 1 > 1 THEN
        RAISE exc_PrimeraException;
    ELSE
        SELECT 1/0 INTO result FROM DUAL;
    END IF;

EXCEPTION
    WHEN exc_PrimeraException THEN
        DBMS_OUTPUT.PUT_LINE('Penalti para el yoyo');

    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Junior no es el papa de nadie');

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE(err_num || ' - ' || err_msg);
END;
/