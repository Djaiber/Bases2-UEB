-- Estructuras de Control PL/SQL
-- IF ELSE structure
-- Tomar el dia de hoy e.g 18 y definir si es primo o no
SET SERVEROUTPUT ON;


DECLARE
    vd_hoy INT;
BEGIN
    SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'DD')) INTO vd_hoy FROM DUAL;
    
    IF vd_hoy = 2 THEN
        DBMS_OUTPUT.PUT_LINE(' ES PRIMO');
    ELSIF vd_hoy <= 1 OR MOD(vd_hoy, 2) = 0 THEN
        DBMS_OUTPUT.PUT_LINE(' NO ES PRIMO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ES PRIMO (POSIBLEMENTE)');
    END IF;
END;
/

-- GOTO structure

GOTO
DECLARE

    vd_current_date NUMBER := TO_NUMBER(TO_CHAR(SYSDATE, 'DD')); 

BEGIN

    IF vd_current_date IN (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31) THEN
        GOTO primo;
    ELSE 
        GOTO noprimo;

    END IF; 
<<primo>>
        dbms_output.put_line('HOLA PRIMO');
<<noprimo>>
       dbms_output.put_line('NO ES PRIMO');
END;
/

-- LOOP Structure
-- Imprimir la serie fibonnacci hasta  100 terminos
-- LOOP Structure
-- Imprimir la serie fibonacci hasta 100 términos
DECLARE
    vn_term1 NUMBER := 0;
    vn_term2 NUMBER := 1;
    vn_next NUMBER;
    vn_counter NUMBER := 1;
BEGIN  
    -- Primer termino
    DBMS_OUTPUT.PUT_LINE('Término ' || vn_counter || ': ' || vn_term1);
    vn_counter := vn_counter + 1;
    
    -- Segundo termino
    IF vn_counter <= 100 THEN
        DBMS_OUTPUT.PUT_LINE('Término ' || vn_counter || ': ' || vn_term2);
        vn_counter := vn_counter + 1;
    END IF;
    
    -- Loop para generar los siguientes términos hasta llegar a 100
    LOOP
        EXIT WHEN vn_counter > 100;
        
        vn_next := vn_term1 + vn_term2;
        DBMS_OUTPUT.PUT_LINE('Término ' || vn_counter || ': ' || vn_next);
        
        -- Actualizar valores para la siguiente iteración
        vn_term1 := vn_term2;
        vn_term2 := vn_next;
        vn_counter := vn_counter + 1;
    END LOOP;
END;
/
    -- WHILE Structure 
    -- minino comun multiplo vn_number1 NUMBER, vn_number2 NUMBER ;
DECLARE
    vn_number1 NUMBER := 32;
    vn_number2 NUMBER := 12;
    vn_module NUMBER;
BEGIN 
    
    WHILE(vn_module!=0)
    vn_module := vn_number1 mod vn_number2;
    vn_number1 := vn_number2;
    vn_number2 := vn_module;
    ---por completar
    
--- FOR LOOP structure
-- A partir de un numero obtener la raiz cuadrado (Solo cuadrados perfectos)
-- usa minimo comum multiplo del numero y con simetria
    
 