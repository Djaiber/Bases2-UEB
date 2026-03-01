-- Procedimientos almacenados 
-- Funciones 
-- Triggers
-- Subprogramas en blopques anónimos


-- Procedimientos almacenados IS LIKE METHOD ON JAVA (VOID)
--- Nomenclatura de SP (Stored Procedure)
-- sp_xxxx
-- Nomenclatura de Paramatros
-- param__xxx
-- usar el nombre del procedure al final (criteria class)

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE sp_saludo_personalido (param_nombre IN VARCHAR2)
/*
Autor: Jaiber Diaz
Fecha: Feb 23/2026
Descripcion: Este SP crea un mensaje personalizado como saludo
*/
IS 
    vv_mensaje VARCHAR2(100);
BEGIN 
    vv_mensaje := 'Hola individuo ' || param_nombre || ' tu papa' ;
    dbms_output.put_line(vv_mensaje);
END sp_saludo_personalido;
/

BEGIN 
    sp_saludo_personalido('jaiber');
END;
/

DROP PROCEDURE sp_saludo_personalido;

CREATE OR REPLACE PROCEDURE sp_saludo_with_default (param_nombre IN VARCHAR2 DEFAULT 'anonimo')
/*
Autor: Jaiber Diaz
Fecha: Feb 23/2026
Descripcion: Este SP crea un mensaje personalizado como saludo, con default sino hay parametro
*/
IS 
    vv_mensaje VARCHAR2(100);
BEGIN 
    vv_mensaje := 'Hola individuo ' || param_nombre || ' tu papa' ;
    dbms_output.put_line(vv_mensaje);
END sp_saludo_with_default;
/

BEGIN 
    sp_saludo_with_default();
END;
/
CREATE OR REPLACE PROCEDURE sp_saludo_with_last_friday (param_nombre IN VARCHAR2 DEFAULT 'anonimo', param_month IN DATE SYSDATE)
/*
Autor: Jaiber Diaz
Fecha: Feb 23/2026
Descripcion: Este SP crea un mensaje personalizado como saludo, con default sino hay parametro
*/
IS 
    vv_mensaje VARCHAR2(100);
BEGIN 
    vv_mensaje := 'Hola individuo ' || param_nombre || ' tu papa' ;
    dbms_output.put_line(vv_mensaje);
END sp_saludo_with_default;
/



BEGIN 
    sp_saludo_with_default();
END;

CREATE OR REPLACE PROCEDURE sp_saludar (param_nombre IN VARCHAR2 DEFAULT 'Millos', param_fecha IN DATE DEFAULT SYSDATE)
--METER PARAMETRO MONTH
/*
AUTOR: SANTIAGO PINZÓN VÁSQUEZ
FECHA: 23/02/2026
DESCRIPCIÓN: Este sp genera un texto saludando a alguien
*/
IS -- o AS (da igual)
vv_textoConcatenado VARCHAR2(100);
vd_ultimoViernes DATE;

BEGIN
vv_textoConcatenado := 'Hola, ' || param_nombre || ' tu papá ';
dbms_output.put_line(vv_textoConcatenado);

 vd_ultimoViernes := NEXT_DAY(LAST_DAY(param_fecha) - 7, 'VIERNES');
 dbms_output.put_line ('El ultimo viernes es ' || vd_ultimoViernes);

END sp_saludar;
/
-- Funciones 
-- Triggers
-- Subprogramas en blopques anónimos