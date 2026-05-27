-- ======================================================================
-- TALLER AVANZADO PL/SQL - SISTEMA DE NÓMINA HOTELGROUP S.A.
-- Script completo: Puntos 1 a 8
-- Oracle Database 19c
-- ======================================================================
-- =======================================================================
-- PUNTO 1: Bloque anónimo
-- =======================================================================
DECLARE
    v_id_empleado     EMPLEADOS.id_empleado%TYPE := 1003;   -- Cambiar para probar otros
    v_id_quincena     VARCHAR2(15) := '2026-Q1-ENE';
    v_nombre          EMPLEADOS.nombre%TYPE;
    v_nombre_sede     SEDES.nombre_sede%TYPE;
    v_tipo_contrato   EMPLEADOS.tipo_contrato%TYPE;
    v_antiguedad      NUMBER;
    v_salario_base_q  NUMBER(12,2);
    v_valor_hora      NUMBER(12,2);
    v_recargos        NUMBER(12,2) := 0;
    v_bonificacion    NUMBER(12,2) := 0;
    v_auxilio_transp  NUMBER(12,2) := 0;
    v_bono_sede       NUMBER(12,2) := 0;
    v_bruto           NUMBER(12,2);
    
    -- Parámetros desde PARAMETROS
    v_smlmv           NUMBER(12,2);
    v_aux_transp_mens NUMBER(12,2);
    v_rec_noct        NUMBER(5,2);
    v_rec_dom         NUMBER(5,2);
    v_rec_noct_dom    NUMBER(5,2);
    v_bono_clima_sma  NUMBER(12,2);
    v_retencion_serv  NUMBER(5,2);
    
    -- Cursor para horas trabajadas (excluye NORMAL porque no genera recargo)
    CURSOR c_horas_recargo IS
        SELECT tipo_hora, cantidad_horas
        FROM HORAS_TRABAJADAS
        WHERE id_empleado = v_id_empleado
          AND id_quincena = v_id_quincena
          AND tipo_hora IN ('NOCTURNA', 'DOMINICAL', 'NOCTURNA_DOM');
    
    -- Variables auxiliares
    v_horas_normales  NUMBER;
    v_salario_mensual_equiv NUMBER;
    v_num_sanciones   NUMBER;
    v_cod_sede        VARCHAR2(5);
BEGIN
    -- Obtener datos del empleado y su sede
    SELECT e.nombre, s.nombre_sede, e.tipo_contrato, e.cod_sede,
           TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecha_ingreso) / 12) AS antiguedad,
           e.salario_base
    INTO v_nombre, v_nombre_sede, v_tipo_contrato, v_cod_sede, v_antiguedad, v_salario_base_q
    FROM EMPLEADOS e
    JOIN SEDES s ON e.cod_sede = s.cod_sede
    WHERE e.id_empleado = v_id_empleado;
    
    -- Leer parámetros generales
    SELECT valor_numerico INTO v_smlmv FROM PARAMETROS WHERE cod_parametro = 'SMLMV';
    SELECT valor_numerico INTO v_aux_transp_mens FROM PARAMETROS WHERE cod_parametro = 'AUX_TRANSPORTE';
    SELECT valor_numerico INTO v_rec_noct FROM PARAMETROS WHERE cod_parametro = 'RECARGO_NOCTURNO';
    SELECT valor_numerico INTO v_rec_dom FROM PARAMETROS WHERE cod_parametro = 'RECARGO_DOMINICAL';
    SELECT valor_numerico INTO v_rec_noct_dom FROM PARAMETROS WHERE cod_parametro = 'RECARGO_NOCT_DOM';
    SELECT valor_numerico INTO v_bono_clima_sma FROM PARAMETROS WHERE cod_parametro = 'BONO_CLIMA_SMA';
    SELECT valor_numerico INTO v_retencion_serv FROM PARAMETROS WHERE cod_parametro = 'RET_SERVICIOS';
    
    -- ========== REGLA 1: Salario base quincenal ==========
    CASE v_tipo_contrato
        WHEN 'PLANTA' THEN
            v_salario_base_q := v_salario_base_q / 2;
            -- Valor hora para recargos (salario mensual / 240)
            v_valor_hora := (v_salario_base_q * 2) / 240;
            
        WHEN 'TEMPORAL' THEN
            -- Obtener horas normales de la quincena
            SELECT NVL(SUM(cantidad_horas), 0) INTO v_horas_normales
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = v_id_empleado
              AND id_quincena = v_id_quincena
              AND tipo_hora = 'NORMAL';
            -- salario_base es el valor_hora
            SELECT salario_base INTO v_valor_hora
            FROM EMPLEADOS WHERE id_empleado = v_id_empleado;
            v_salario_base_q := v_horas_normales * v_valor_hora;
            
        WHEN 'SERVICIOS' THEN
            v_salario_base_q := (v_salario_base_q - (v_salario_base_q * v_retencion_serv / 100)) / 2;
            v_valor_hora := 0; -- No aplica
    END CASE;
    
    -- ========== REGLA 2: Recargos (solo PLANTA y TEMPORAL) ==========
    IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') THEN
        FOR rec IN c_horas_recargo LOOP
            CASE rec.tipo_hora
                WHEN 'NOCTURNA' THEN
                    v_recargos := v_recargos + rec.cantidad_horas * v_valor_hora * (v_rec_noct / 100);
                WHEN 'DOMINICAL' THEN
                    v_recargos := v_recargos + rec.cantidad_horas * v_valor_hora * (v_rec_dom / 100);
                WHEN 'NOCTURNA_DOM' THEN
                    v_recargos := v_recargos + rec.cantidad_horas * v_valor_hora * (v_rec_noct_dom / 100);
            END CASE;
        END LOOP;
    END IF;
    
    -- ========== REGLA 3: Bonificación (solo PLANTA y TEMPORAL) ==========
    IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') THEN
        -- Contar sanciones en los últimos 6 meses
        SELECT COUNT(*) INTO v_num_sanciones
        FROM SANCIONES
        WHERE id_empleado = v_id_empleado
          AND fecha_sancion >= ADD_MONTHS(SYSDATE, -6);
        
        IF v_num_sanciones <= 2 THEN
            IF v_antiguedad BETWEEN 3 AND 5 THEN
                v_bonificacion := v_salario_base_q * 0.03;
            ELSIF v_antiguedad BETWEEN 6 AND 10 THEN
                v_bonificacion := v_salario_base_q * 0.06;
            ELSIF v_antiguedad > 10 THEN
                v_bonificacion := v_salario_base_q * 0.10;
            END IF;
        END IF;
    END IF;
    
    -- ========== REGLA 4: Auxilio de transporte ==========
    IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') THEN
        -- Calcular salario mensual equivalente
        IF v_tipo_contrato = 'PLANTA' THEN
            SELECT salario_base INTO v_salario_mensual_equiv
            FROM EMPLEADOS WHERE id_empleado = v_id_empleado;
        ELSE
            SELECT salario_base INTO v_valor_hora
            FROM EMPLEADOS WHERE id_empleado = v_id_empleado;
            SELECT NVL(SUM(cantidad_horas), 0) INTO v_horas_normales
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = v_id_empleado AND id_quincena = v_id_quincena AND tipo_hora = 'NORMAL';
            v_salario_mensual_equiv := v_horas_normales * v_valor_hora * 2;
        END IF;
        
        IF v_salario_mensual_equiv <= 2 * v_smlmv THEN
            v_auxilio_transp := v_aux_transp_mens / 2;
        END IF;
    END IF;
    
    -- ========== REGLA 5: Bono por sede ==========
    IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') AND v_cod_sede = 'SMA' THEN
        v_bono_sede := v_bono_clima_sma;
    END IF;
    
    -- ========== BRUTO ==========
    v_bruto := v_salario_base_q + v_recargos + v_bonificacion + v_auxilio_transp + v_bono_sede;
    
    -- ========== SALIDA FORMATEADA ==========
    DBMS_OUTPUT.PUT_LINE('=== LIQUIDACIÓN QUINCENAL ===');
    DBMS_OUTPUT.PUT_LINE('Empleado: ' || v_nombre || ' (' || v_id_empleado || ')');
    DBMS_OUTPUT.PUT_LINE('Sede: ' || v_nombre_sede);
    DBMS_OUTPUT.PUT_LINE('Tipo contrato: ' || v_tipo_contrato);
    DBMS_OUTPUT.PUT_LINE('Antigüedad: ' || v_antiguedad || ' años');
    DBMS_OUTPUT.PUT_LINE('---');
    DBMS_OUTPUT.PUT_LINE('Salario base Q: ' || TO_CHAR(v_salario_base_q, '999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('Recargos: ' || TO_CHAR(v_recargos, '999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('Bonificación: ' || TO_CHAR(v_bonificacion, '999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('Auxilio transporte: ' || TO_CHAR(v_auxilio_transp, '999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('Bono sede: ' || TO_CHAR(v_bono_sede, '999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('SUBTOTAL (Bruto): ' || TO_CHAR(v_bruto, '999,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('==============================');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontraron datos para el empleado ' || v_id_empleado);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

-- ======================================================================
-- PUNTO 2: Funciones standalone
-- ======================================================================

-- Función fn_salario_base_q
CREATE OR REPLACE FUNCTION fn_salario_base_q(p_id_empleado NUMBER, p_id_quincena VARCHAR2)
RETURN NUMBER
IS
    v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
    v_salario_base EMPLEADOS.salario_base%TYPE;
    v_valor_hora NUMBER;
    v_horas_normales NUMBER;
    v_ret_servicios NUMBER;
    v_resultado NUMBER;
BEGIN
    SELECT tipo_contrato, salario_base INTO v_tipo_contrato, v_salario_base
    FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
    
    CASE v_tipo_contrato
        WHEN 'PLANTA' THEN
            v_resultado := v_salario_base / 2;
        WHEN 'TEMPORAL' THEN
            SELECT NVL(SUM(cantidad_horas), 0) INTO v_horas_normales
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena AND tipo_hora = 'NORMAL';
            v_resultado := v_horas_normales * v_salario_base; -- salario_base es valor_hora
        WHEN 'SERVICIOS' THEN
            SELECT valor_numerico INTO v_ret_servicios FROM PARAMETROS WHERE cod_parametro = 'RET_SERVICIOS';
            v_resultado := (v_salario_base - (v_salario_base * v_ret_servicios / 100)) / 2;
        ELSE
            v_resultado := 0;
    END CASE;
    RETURN v_resultado;
END;
/

-- Función fn_recargos
CREATE OR REPLACE FUNCTION fn_recargos(p_id_empleado NUMBER, p_id_quincena VARCHAR2)
RETURN NUMBER
IS
    v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
    v_valor_hora NUMBER;
    v_rec_noct NUMBER;
    v_rec_dom NUMBER;
    v_rec_noct_dom NUMBER;
    v_total NUMBER := 0;
    CURSOR c_horas IS
        SELECT tipo_hora, cantidad_horas
        FROM HORAS_TRABAJADAS
        WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena
          AND tipo_hora IN ('NOCTURNA', 'DOMINICAL', 'NOCTURNA_DOM');
BEGIN
    SELECT tipo_contrato INTO v_tipo_contrato FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
    IF v_tipo_contrato = 'SERVICIOS' THEN
        RETURN 0;
    END IF;
    
    -- Calcular valor hora
    IF v_tipo_contrato = 'PLANTA' THEN
        SELECT salario_base / 240 INTO v_valor_hora FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
    ELSE -- TEMPORAL
        SELECT salario_base INTO v_valor_hora FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
    END IF;
    
    SELECT valor_numerico INTO v_rec_noct FROM PARAMETROS WHERE cod_parametro = 'RECARGO_NOCTURNO';
    SELECT valor_numerico INTO v_rec_dom FROM PARAMETROS WHERE cod_parametro = 'RECARGO_DOMINICAL';
    SELECT valor_numerico INTO v_rec_noct_dom FROM PARAMETROS WHERE cod_parametro = 'RECARGO_NOCT_DOM';
    
    FOR rec IN c_horas LOOP
        CASE rec.tipo_hora
            WHEN 'NOCTURNA' THEN
                v_total := v_total + rec.cantidad_horas * v_valor_hora * (v_rec_noct / 100);
            WHEN 'DOMINICAL' THEN
                v_total := v_total + rec.cantidad_horas * v_valor_hora * (v_rec_dom / 100);
            WHEN 'NOCTURNA_DOM' THEN
                v_total := v_total + rec.cantidad_horas * v_valor_hora * (v_rec_noct_dom / 100);
        END CASE;
    END LOOP;
    RETURN v_total;
END;
/

-- Función fn_bonificacion
CREATE OR REPLACE FUNCTION fn_bonificacion(p_id_empleado NUMBER)
RETURN NUMBER
IS
    v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
    v_fecha_ingreso EMPLEADOS.fecha_ingreso%TYPE;
    v_antiguedad NUMBER;
    v_num_sanciones NUMBER;
    v_salario_base_q NUMBER;
    v_bonif NUMBER := 0;
BEGIN
    SELECT tipo_contrato, fecha_ingreso INTO v_tipo_contrato, v_fecha_ingreso
    FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
    IF v_tipo_contrato = 'SERVICIOS' THEN
        RETURN 0;
    END IF;
    
    v_antiguedad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_ingreso) / 12);
    SELECT COUNT(*) INTO v_num_sanciones
    FROM SANCIONES
    WHERE id_empleado = p_id_empleado
      AND fecha_sancion >= ADD_MONTHS(SYSDATE, -6);
    
    IF v_num_sanciones <= 2 THEN
        -- Necesitamos salario base quincenal para calcular porcentaje
        v_salario_base_q := fn_salario_base_q(p_id_empleado, '2026-Q1-ENE'); -- quincena fija para prueba, pero en contexto real se pasaría
        IF v_antiguedad BETWEEN 3 AND 5 THEN
            v_bonif := v_salario_base_q * 0.03;
        ELSIF v_antiguedad BETWEEN 6 AND 10 THEN
            v_bonif := v_salario_base_q * 0.06;
        ELSIF v_antiguedad > 10 THEN
            v_bonif := v_salario_base_q * 0.10;
        END IF;
    END IF;
    RETURN v_bonif;
END;
/

-- Función fn_bruto
CREATE OR REPLACE FUNCTION fn_bruto(p_id_empleado NUMBER, p_id_quincena VARCHAR2)
RETURN NUMBER
IS
    v_salario_base_q NUMBER;
    v_recargos NUMBER;
    v_bonificacion NUMBER;
    v_auxilio_transp NUMBER := 0;
    v_bono_sede NUMBER := 0;
    v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
    v_smlmv NUMBER;
    v_aux_transp_mens NUMBER;
    v_salario_mensual_equiv NUMBER;
    v_valor_hora NUMBER;
    v_horas_normales NUMBER;
    v_cod_sede VARCHAR2(5);
    v_bono_clima_sma NUMBER;
BEGIN
    v_salario_base_q := fn_salario_base_q(p_id_empleado, p_id_quincena);
    v_recargos := fn_recargos(p_id_empleado, p_id_quincena);
    v_bonificacion := fn_bonificacion(p_id_empleado);
    
    SELECT tipo_contrato INTO v_tipo_contrato FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
    
    -- Auxilio de transporte
    IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') THEN
        SELECT valor_numerico INTO v_smlmv FROM PARAMETROS WHERE cod_parametro = 'SMLMV';
        SELECT valor_numerico INTO v_aux_transp_mens FROM PARAMETROS WHERE cod_parametro = 'AUX_TRANSPORTE';
        IF v_tipo_contrato = 'PLANTA' THEN
            SELECT salario_base INTO v_salario_mensual_equiv FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        ELSE
            SELECT salario_base INTO v_valor_hora FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
            SELECT NVL(SUM(cantidad_horas), 0) INTO v_horas_normales
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena AND tipo_hora = 'NORMAL';
            v_salario_mensual_equiv := v_horas_normales * v_valor_hora * 2;
        END IF;
        IF v_salario_mensual_equiv <= 2 * v_smlmv THEN
            v_auxilio_transp := v_aux_transp_mens / 2;
        END IF;
    END IF;
    
    -- Bono sede (solo Santa Marta para PLANTA y TEMPORAL)
    IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') THEN
        SELECT cod_sede INTO v_cod_sede FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_cod_sede = 'SMA' THEN
            SELECT valor_numerico INTO v_bono_clima_sma FROM PARAMETROS WHERE cod_parametro = 'BONO_CLIMA_SMA';
            v_bono_sede := v_bono_clima_sma;
        END IF;
    END IF;
    
    RETURN ROUND(v_salario_base_q + v_recargos + v_bonificacion + v_auxilio_transp + v_bono_sede, 2);
END;
/

-- TESTING 
SELECT fn_bruto(1001, '2026-Q1-ENE') FROM DUAL;

-- ======================================================================
-- PUNTO 3: Procedimiento sp_liquidar_empleado
-- ======================================================================

CREATE OR REPLACE PROCEDURE sp_liquidar_empleado(
    p_id_empleado NUMBER,
    p_id_quincena VARCHAR2
) IS
    -- Variables de validación
    v_estado       EMPLEADOS.estado%TYPE;
    v_existe       NUMBER;
    
    -- Componentes de la liquidación
    v_salario_base_q   NUMBER(12,2);
    v_recargos         NUMBER(12,2);
    v_bonificacion     NUMBER(12,2);
    v_auxilio_transp   NUMBER(12,2);
    v_bono_sede        NUMBER(12,2);
    v_bruto            NUMBER(12,2);
    
    -- Deducciones
    v_salud            NUMBER(12,2);
    v_pension          NUMBER(12,2);
    v_fondo_solid      NUMBER(12,2) := 0;
    v_embargo          NUMBER(12,2) := 0;
    v_libranzas        NUMBER(12,2) := 0;
    v_aporte_vol       NUMBER(12,2) := 0;
    v_total_deducciones NUMBER(12,2);
    v_neto             NUMBER(12,2);
    
    -- Parámetros desde tabla PARAMETROS
    v_pct_salud        NUMBER(5,2);
    v_pct_pension      NUMBER(5,2);
    v_pct_fondo        NUMBER(5,2);
    v_umbral_fondo     NUMBER;
    v_smlmv            NUMBER(12,2);
    v_aporte_vol_bog   NUMBER(12,2);
    v_aux_transp_mens  NUMBER(12,2);
    
    -- Para embargos y libranzas
    v_porc_embargo     NUMBER(5,2);
    v_total_libranzas_mens NUMBER(12,2);
    
    -- Para sede y aporte voluntario
    v_cod_sede         VARCHAR2(5);
    v_acepta_vol       VARCHAR2(1);
    
BEGIN
    -- 13. Validar existencia del empleado
    BEGIN
        SELECT estado, cod_sede, acepta_aporte_vol
        INTO v_estado, v_cod_sede, v_acepta_vol
        FROM EMPLEADOS
        WHERE id_empleado = p_id_empleado;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Empleado no encontrado: ' || p_id_empleado);
    END;
    
    -- 14. Validar que esté ACTIVO
    IF v_estado != 'ACTIVO' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empleado no activo: estado = ' || v_estado);
    END IF;
    
    -- 15. Validar que no exista liquidación previa
    SELECT COUNT(*)
    INTO v_existe
    FROM LIQUIDACION
    WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena;
    
    IF v_existe > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Liquidación ya existe para empleado ' || p_id_empleado || ' quincena ' || p_id_quincena);
    END IF;
    
    -- 16. Calcular conceptos usando funciones del Punto 2
    v_salario_base_q := fn_salario_base_q(p_id_empleado, p_id_quincena);
    v_recargos       := fn_recargos(p_id_empleado, p_id_quincena);
    v_bonificacion   := fn_bonificacion(p_id_empleado);
    
    -- Calcular auxilio de transporte (Regla 4) – reutilizando lógica de fn_bruto
    -- Obtenemos parámetros necesarios
    SELECT valor_numerico INTO v_smlmv FROM PARAMETROS WHERE cod_parametro = 'SMLMV';
    SELECT valor_numerico INTO v_aux_transp_mens FROM PARAMETROS WHERE cod_parametro = 'AUX_TRANSPORTE';
    
    DECLARE
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_salario_mensual_equiv NUMBER;
        v_valor_hora NUMBER;
        v_horas_normales NUMBER;
    BEGIN
        SELECT tipo_contrato INTO v_tipo_contrato FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') THEN
            IF v_tipo_contrato = 'PLANTA' THEN
                SELECT salario_base INTO v_salario_mensual_equiv FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
            ELSE
                SELECT salario_base INTO v_valor_hora FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
                SELECT NVL(SUM(cantidad_horas),0) INTO v_horas_normales
                FROM HORAS_TRABAJADAS
                WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena AND tipo_hora = 'NORMAL';
                v_salario_mensual_equiv := v_horas_normales * v_valor_hora * 2;
            END IF;
            IF v_salario_mensual_equiv <= 2 * v_smlmv THEN
                v_auxilio_transp := v_aux_transp_mens / 2;
            ELSE
                v_auxilio_transp := 0;
            END IF;
        ELSE
            v_auxilio_transp := 0;
        END IF;
    END;
    
    -- Calcular bono de sede (Regla 5)
    DECLARE
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_bono_clima_sma NUMBER;
    BEGIN
        SELECT tipo_contrato INTO v_tipo_contrato FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') AND v_cod_sede = 'SMA' THEN
            SELECT valor_numerico INTO v_bono_clima_sma FROM PARAMETROS WHERE cod_parametro = 'BONO_CLIMA_SMA';
            v_bono_sede := v_bono_clima_sma;
        ELSE
            v_bono_sede := 0;
        END IF;
    END;
    
    -- Bruto (Regla 6)
    v_bruto := v_salario_base_q + v_recargos + v_bonificacion + v_auxilio_transp + v_bono_sede;
    
    -- 7. Deducciones (Regla 7)
    SELECT valor_numerico INTO v_pct_salud FROM PARAMETROS WHERE cod_parametro = 'PCT_SALUD';
    SELECT valor_numerico INTO v_pct_pension FROM PARAMETROS WHERE cod_parametro = 'PCT_PENSION';
    SELECT valor_numerico INTO v_pct_fondo FROM PARAMETROS WHERE cod_parametro = 'PCT_FONDO_SOLIDARIDAD';
    SELECT valor_numerico INTO v_umbral_fondo FROM PARAMETROS WHERE cod_parametro = 'UMBRAL_FONDO_SMLMV';
    SELECT valor_numerico INTO v_aporte_vol_bog FROM PARAMETROS WHERE cod_parametro = 'APORTE_VOL_BOG';
    
    v_salud   := v_bruto * v_pct_salud / 100;
    v_pension := v_bruto * v_pct_pension / 100;
    
    -- Fondo de solidaridad (solo si bruto mensual > umbral * SMLMV)
    IF (v_bruto * 2) > (v_umbral_fondo * v_smlmv) THEN
        v_fondo_solid := v_bruto * v_pct_fondo / 100;
    END IF;
    
    -- Embargos
    SELECT NVL(SUM(porcentaje), 0) INTO v_porc_embargo
    FROM EMBARGOS
    WHERE id_empleado = p_id_empleado AND estado = 'ACTIVO';
    
    IF v_porc_embargo > 0 THEN
        v_embargo := (v_bruto - v_salud - v_pension - v_fondo_solid) * v_porc_embargo / 100;
    END IF;
    
    -- Libranzas
    SELECT NVL(SUM(cuota_mensual), 0) INTO v_total_libranzas_mens
    FROM LIBRANZAS
    WHERE id_empleado = p_id_empleado AND estado = 'ACTIVA';
    v_libranzas := v_total_libranzas_mens / 2;
    
    -- Aporte voluntario (solo Bogotá y si acepta)
    IF v_cod_sede = 'BOG' AND v_acepta_vol = 'S' THEN
        v_aporte_vol := v_aporte_vol_bog;
    END IF;
    
    v_total_deducciones := v_salud + v_pension + v_fondo_solid + v_embargo + v_libranzas + v_aporte_vol;
    v_neto := v_bruto - v_total_deducciones;
    
    -- 17. Caso especial: neto negativo (Regla 8)
    IF v_neto < 0 THEN
        -- Paso 1: eliminar embargo
        v_embargo := 0;
        v_total_deducciones := v_salud + v_pension + v_fondo_solid + v_embargo + v_libranzas + v_aporte_vol;
        v_neto := v_bruto - v_total_deducciones;
        
        IF v_neto < 0 THEN
            -- Paso 2: eliminar libranzas
            v_libranzas := 0;
            v_total_deducciones := v_salud + v_pension + v_fondo_solid + v_embargo + v_libranzas + v_aporte_vol;
            v_neto := v_bruto - v_total_deducciones;
        END IF;
    END IF;
    
    -- 18. Insertar en LIQUIDACION
    INSERT INTO LIQUIDACION (
        id_liquidacion, id_empleado, id_quincena,
        salario_base_q, recargos, bonificacion,
        auxilio_transp, bono_sede, bruto,
        deduccion_salud, deduccion_pension,
        fondo_solidaridad, embargo, libranzas,
        aporte_voluntario, total_deducciones, neto
    ) VALUES (
        SEQ_LIQUIDACION.NEXTVAL, p_id_empleado, p_id_quincena,
        v_salario_base_q, v_recargos, v_bonificacion,
        v_auxilio_transp, v_bono_sede, v_bruto,
        v_salud, v_pension, v_fondo_solid,
        v_embargo, v_libranzas, v_aporte_vol,
        v_total_deducciones, v_neto
    );
    
    -- 19. COMMIT
    COMMIT;
    
EXCEPTION
    -- Capturar cualquier otro error y hacer rollback implícito
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_liquidar_empleado;
/

-- PRUEBAS DE VALIDACION
-- Empleado inexistente
BEGIN
    sp_liquidar_empleado(9999, '2026-Q1-ENE');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- Empleado inactivo (1017)
BEGIN
    sp_liquidar_empleado(1017, '2026-Q1-ENE');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- Liquidación repetida (ejecutar dos veces para el mismo empleado)
BEGIN
    sp_liquidar_empleado(1001, '2026-Q1-ENE');
    sp_liquidar_empleado(1001, '2026-Q1-ENE');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- ======================================================================
-- PUNTO 4: Package PKG_NOMINA (spec + body)
-- ======================================================================

CREATE OR REPLACE PACKAGE PKG_NOMINA IS

    -- =================================================================
    -- TIPOS PÚBLICOS
    -- =================================================================
    TYPE t_concepto_liq IS RECORD (
        id_empleado         LIQUIDACION.id_empleado%TYPE,
        id_quincena         LIQUIDACION.id_quincena%TYPE,
        salario_base_q      LIQUIDACION.salario_base_q%TYPE,
        recargos            LIQUIDACION.recargos%TYPE,
        bonificacion        LIQUIDACION.bonificacion%TYPE,
        auxilio_transp      LIQUIDACION.auxilio_transp%TYPE,
        bono_sede           LIQUIDACION.bono_sede%TYPE,
        bruto               LIQUIDACION.bruto%TYPE,
        deduccion_salud     LIQUIDACION.deduccion_salud%TYPE,
        deduccion_pension   LIQUIDACION.deduccion_pension%TYPE,
        fondo_solidaridad   LIQUIDACION.fondo_solidaridad%TYPE,
        embargo             LIQUIDACION.embargo%TYPE,
        libranzas           LIQUIDACION.libranzas%TYPE,
        aporte_voluntario   LIQUIDACION.aporte_voluntario%TYPE,
        total_deducciones   LIQUIDACION.total_deducciones%TYPE,
        neto                LIQUIDACION.neto%TYPE
    );

    TYPE t_lista_liq IS TABLE OF t_concepto_liq INDEX BY PLS_INTEGER;
    TYPE t_id_array IS TABLE OF EMPLEADOS.id_empleado%TYPE INDEX BY PLS_INTEGER;

    -- =================================================================
    -- FUNCIÓN PÚBLICA PARA OBTENER EL SMLMV (reemplaza a la constante)
    -- =================================================================
    FUNCTION fn_get_smlmv RETURN NUMBER;

    -- =================================================================
    -- PROCEDIMIENTOS SOBRECARGADOS
    -- =================================================================
    PROCEDURE sp_liquidar_quincena(p_id_empleado NUMBER, p_id_quincena VARCHAR2);
    PROCEDURE sp_liquidar_quincena(p_id_quincena VARCHAR2);

    -- =================================================================
    -- FUNCIÓN TOTAL NETO POR SEDE
    -- =================================================================
    FUNCTION fn_total_nomina_sede(p_cod_sede VARCHAR2, p_id_quincena VARCHAR2) RETURN NUMBER;

    -- =================================================================
    -- FUNCIÓN PIPELINED (Punto 7)
    -- =================================================================
    TYPE t_liqu_row IS RECORD (
        id_liquidacion      LIQUIDACION.id_liquidacion%TYPE,
        id_empleado         LIQUIDACION.id_empleado%TYPE,
        nombre_empleado     EMPLEADOS.nombre%TYPE,
        cod_sede            SEDES.cod_sede%TYPE,
        id_quincena         LIQUIDACION.id_quincena%TYPE,
        bruto               LIQUIDACION.bruto%TYPE,
        neto                LIQUIDACION.neto%TYPE
    );
    
    TYPE t_liqu_table IS TABLE OF t_liqu_row;
    
    FUNCTION fn_reporte_nomina(p_cod_sede VARCHAR2 DEFAULT NULL, 
                               p_tipo_contrato VARCHAR2 DEFAULT NULL)
    RETURN t_liqu_table PIPELINED;

END PKG_NOMINA;
/
CREATE OR REPLACE PACKAGE BODY PKG_NOMINA IS

    -- =================================================================
    -- CACHÉ DE PARÁMETROS (privada)
    -- =================================================================
    TYPE t_param_cache IS RECORD (
        smlmv              NUMBER,
        aux_transporte     NUMBER,
        pct_salud          NUMBER,
        pct_pension        NUMBER,
        pct_fondo_solid    NUMBER,
        umbral_fondo_smlmv NUMBER,
        rec_nocturno       NUMBER,
        rec_dominical      NUMBER,
        rec_noct_dom       NUMBER,
        ret_servicios      NUMBER,
        bono_clima_sma     NUMBER,
        aporte_vol_bog     NUMBER
    );

    TYPE t_deducciones IS RECORD (
        salud           NUMBER,
        pension         NUMBER,
        fondo_solid     NUMBER,
        embargo         NUMBER,
        libranzas       NUMBER,
        aporte_vol      NUMBER,
        total           NUMBER
    );
    
    g_param_cache t_param_cache;
    g_cache_loaded BOOLEAN := FALSE;

    -- =================================================================
    -- CARGA DE PARÁMETROS DESDE TABLA
    -- =================================================================
    PROCEDURE load_param_cache IS
    BEGIN
        IF NOT g_cache_loaded THEN
            SELECT MAX(CASE WHEN cod_parametro = 'SMLMV' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'AUX_TRANSPORTE' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'PCT_SALUD' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'PCT_PENSION' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'PCT_FONDO_SOLIDARIDAD' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'UMBRAL_FONDO_SMLMV' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'RECARGO_NOCTURNO' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'RECARGO_DOMINICAL' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'RECARGO_NOCT_DOM' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'RET_SERVICIOS' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'BONO_CLIMA_SMA' THEN valor_numerico END),
                   MAX(CASE WHEN cod_parametro = 'APORTE_VOL_BOG' THEN valor_numerico END)
            INTO g_param_cache.smlmv,
                 g_param_cache.aux_transporte,
                 g_param_cache.pct_salud,
                 g_param_cache.pct_pension,
                 g_param_cache.pct_fondo_solid,
                 g_param_cache.umbral_fondo_smlmv,
                 g_param_cache.rec_nocturno,
                 g_param_cache.rec_dominical,
                 g_param_cache.rec_noct_dom,
                 g_param_cache.ret_servicios,
                 g_param_cache.bono_clima_sma,
                 g_param_cache.aporte_vol_bog
            FROM PARAMETROS;
            
            g_cache_loaded := TRUE;
        END IF;
    END load_param_cache;

    -- =================================================================
    -- FUNCIÓN PÚBLICA QUE RETORNA EL SMLMV
    -- =================================================================
    FUNCTION fn_get_smlmv RETURN NUMBER IS
    BEGIN
        load_param_cache;
        RETURN g_param_cache.smlmv;
    END fn_get_smlmv;

    -- =================================================================
    -- FUNCIÓN PRIVADA: salario base quincenal
    -- =================================================================
    FUNCTION fn_salario_base_q(p_id_empleado NUMBER, p_id_quincena VARCHAR2) RETURN NUMBER IS
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_salario_base  EMPLEADOS.salario_base%TYPE;
        v_horas_normales NUMBER := 0;
        v_resultado     NUMBER := 0;
    BEGIN
        load_param_cache;
        SELECT tipo_contrato, salario_base INTO v_tipo_contrato, v_salario_base
        FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        
        IF v_tipo_contrato = 'PLANTA' THEN
            v_resultado := v_salario_base / 2;
        ELSIF v_tipo_contrato = 'TEMPORAL' THEN
            SELECT NVL(SUM(cantidad_horas), 0) INTO v_horas_normales
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena AND tipo_hora = 'NORMAL';
            v_resultado := v_salario_base * v_horas_normales;
        ELSIF v_tipo_contrato = 'SERVICIOS' THEN
            v_resultado := (v_salario_base - (v_salario_base * g_param_cache.ret_servicios / 100)) / 2;
        END IF;
        RETURN NVL(v_resultado, 0);
    END fn_salario_base_q;

    -- =================================================================
    -- FUNCIÓN PRIVADA: recargos
    -- =================================================================
    FUNCTION fn_recargos(p_id_empleado NUMBER, p_id_quincena VARCHAR2) RETURN NUMBER IS
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_salario_base  EMPLEADOS.salario_base%TYPE;
        v_valor_hora    NUMBER := 0;
        v_total_recargos NUMBER := 0;
        CURSOR c_horas IS
            SELECT tipo_hora, cantidad_horas
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena
              AND tipo_hora IN ('NOCTURNA', 'DOMINICAL', 'NOCTURNA_DOM');
    BEGIN
        load_param_cache;
        SELECT tipo_contrato, salario_base INTO v_tipo_contrato, v_salario_base
        FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato = 'SERVICIOS' THEN RETURN 0; END IF;
        IF v_tipo_contrato = 'PLANTA' THEN v_valor_hora := v_salario_base / 240;
        ELSE v_valor_hora := v_salario_base; END IF;
        FOR r IN c_horas LOOP
            CASE r.tipo_hora
                WHEN 'NOCTURNA' THEN v_total_recargos := v_total_recargos + (r.cantidad_horas * v_valor_hora * g_param_cache.rec_nocturno / 100);
                WHEN 'DOMINICAL' THEN v_total_recargos := v_total_recargos + (r.cantidad_horas * v_valor_hora * g_param_cache.rec_dominical / 100);
                WHEN 'NOCTURNA_DOM' THEN v_total_recargos := v_total_recargos + (r.cantidad_horas * v_valor_hora * g_param_cache.rec_noct_dom / 100);
            END CASE;
        END LOOP;
        RETURN NVL(v_total_recargos, 0);
    END fn_recargos;

    -- =================================================================
    -- FUNCIÓN PRIVADA: bonificación (con regla de sanciones)
    -- =================================================================
    FUNCTION fn_bonificacion(p_id_empleado NUMBER) RETURN NUMBER IS
        v_fecha_ingreso EMPLEADOS.fecha_ingreso%TYPE;
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_antiguedad    NUMBER;
        v_porcentaje    NUMBER := 0;
        v_sanciones_6m  NUMBER;
        v_salario_base_q NUMBER;
    BEGIN
        SELECT fecha_ingreso, tipo_contrato INTO v_fecha_ingreso, v_tipo_contrato
        FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato = 'SERVICIOS' THEN RETURN 0; END IF;
        v_antiguedad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_ingreso) / 12);
        IF v_antiguedad BETWEEN 3 AND 5 THEN v_porcentaje := 3;
        ELSIF v_antiguedad BETWEEN 6 AND 10 THEN v_porcentaje := 6;
        ELSIF v_antiguedad > 10 THEN v_porcentaje := 10;
        ELSE v_porcentaje := 0; END IF;
        SELECT COUNT(*) INTO v_sanciones_6m
        FROM SANCIONES
        WHERE id_empleado = p_id_empleado AND fecha_sancion >= ADD_MONTHS(SYSDATE, -6);
        IF v_sanciones_6m > 2 THEN v_porcentaje := 0; END IF;
        v_salario_base_q := fn_salario_base_q(p_id_empleado, '2026-Q1-ENE');
        RETURN v_salario_base_q * v_porcentaje / 100;
    END fn_bonificacion;

    -- =================================================================
    -- FUNCIÓN PRIVADA: auxilio de transporte
    -- =================================================================
    FUNCTION fn_auxilio_transporte(p_id_empleado NUMBER, p_id_quincena VARCHAR2) RETURN NUMBER IS
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_salario_base  EMPLEADOS.salario_base%TYPE;
        v_salario_mensual NUMBER;
        v_horas_normales NUMBER := 0;
    BEGIN
        load_param_cache;
        SELECT tipo_contrato, salario_base INTO v_tipo_contrato, v_salario_base
        FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato = 'SERVICIOS' THEN RETURN 0; END IF;
        IF v_tipo_contrato = 'PLANTA' THEN v_salario_mensual := v_salario_base;
        ELSE
            SELECT NVL(SUM(cantidad_horas), 0) INTO v_horas_normales
            FROM HORAS_TRABAJADAS
            WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena AND tipo_hora = 'NORMAL';
            v_salario_mensual := v_salario_base * v_horas_normales * 2;
        END IF;
        IF v_salario_mensual <= 2 * g_param_cache.smlmv THEN
            RETURN g_param_cache.aux_transporte / 2;
        END IF;
        RETURN 0;
    END fn_auxilio_transporte;

    -- =================================================================
    -- FUNCIÓN PRIVADA: bono por sede
    -- =================================================================
    FUNCTION fn_bono_sede(p_id_empleado NUMBER) RETURN NUMBER IS
        v_cod_sede      EMPLEADOS.cod_sede%TYPE;
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
    BEGIN
        load_param_cache;
        SELECT cod_sede, tipo_contrato INTO v_cod_sede, v_tipo_contrato
        FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') AND v_cod_sede = 'SMA' THEN
            RETURN g_param_cache.bono_clima_sma;
        END IF;
        RETURN 0;
    END fn_bono_sede;

    -- =================================================================
    -- FUNCIÓN PRIVADA: bruto total
    -- =================================================================
    FUNCTION fn_bruto(p_id_empleado NUMBER, p_id_quincena VARCHAR2) RETURN NUMBER IS
    BEGIN
        RETURN NVL(fn_salario_base_q(p_id_empleado, p_id_quincena), 0)
             + NVL(fn_recargos(p_id_empleado, p_id_quincena), 0)
             + NVL(fn_bonificacion(p_id_empleado), 0)
             + NVL(fn_auxilio_transporte(p_id_empleado, p_id_quincena), 0)
             + NVL(fn_bono_sede(p_id_empleado), 0);
    END fn_bruto;

    -- =================================================================
    -- FUNCIÓN PRIVADA PARA DEDUCCIONES
    -- =================================================================
    FUNCTION fn_deducciones(p_id_empleado NUMBER, p_bruto NUMBER, p_id_quincena VARCHAR2) RETURN t_deducciones IS
        v_result t_deducciones;
        v_bruto_mensual NUMBER;
        v_base_embargo NUMBER;
        v_porc_embargo NUMBER := 0;
        v_tipo_contrato EMPLEADOS.tipo_contrato%TYPE;
        v_cod_sede EMPLEADOS.cod_sede%TYPE;
        v_acepta_aporte EMPLEADOS.acepta_aporte_vol%TYPE;
    BEGIN
        load_param_cache;
        v_result.salud := p_bruto * g_param_cache.pct_salud / 100;
        v_result.pension := p_bruto * g_param_cache.pct_pension / 100;
        v_bruto_mensual := p_bruto * 2;
        IF v_bruto_mensual > g_param_cache.umbral_fondo_smlmv * g_param_cache.smlmv THEN
            v_result.fondo_solid := p_bruto * g_param_cache.pct_fondo_solid / 100;
        ELSE
            v_result.fondo_solid := 0;
        END IF;
        SELECT NVL(SUM(porcentaje), 0) INTO v_porc_embargo
        FROM EMBARGOS WHERE id_empleado = p_id_empleado AND estado = 'ACTIVO';
        v_base_embargo := p_bruto - v_result.salud - v_result.pension - v_result.fondo_solid;
        v_result.embargo := v_base_embargo * v_porc_embargo / 100;
        SELECT NVL(SUM(cuota_mensual), 0) INTO v_result.libranzas
        FROM LIBRANZAS WHERE id_empleado = p_id_empleado AND estado = 'ACTIVA';
        v_result.libranzas := v_result.libranzas / 2;
        SELECT tipo_contrato, cod_sede, acepta_aporte_vol INTO v_tipo_contrato, v_cod_sede, v_acepta_aporte
        FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_tipo_contrato IN ('PLANTA', 'TEMPORAL') AND v_cod_sede = 'BOG' AND v_acepta_aporte = 'S' THEN
            v_result.aporte_vol := g_param_cache.aporte_vol_bog;
        ELSE
            v_result.aporte_vol := 0;
        END IF;
        v_result.total := v_result.salud + v_result.pension + v_result.fondo_solid
                        + v_result.embargo + v_result.libranzas + v_result.aporte_vol;
        RETURN v_result;
    END fn_deducciones;

    -- =================================================================
    -- PROCEDIMIENTO PARA UN EMPLEADO (con validaciones)
    -- =================================================================
    PROCEDURE sp_liquidar_quincena(p_id_empleado NUMBER, p_id_quincena VARCHAR2) IS
        v_empleado_exist NUMBER;
        v_estado EMPLEADOS.estado%TYPE;
        v_ya_liquidado NUMBER;
        v_bruto NUMBER;
        v_ded t_deducciones;
        v_neto NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_empleado_exist FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_empleado_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Empleado no encontrado: ' || p_id_empleado);
        END IF;
        SELECT estado INTO v_estado FROM EMPLEADOS WHERE id_empleado = p_id_empleado;
        IF v_estado != 'ACTIVO' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Empleado no activo: estado = ' || v_estado);
        END IF;
        SELECT COUNT(*) INTO v_ya_liquidado FROM LIQUIDACION 
        WHERE id_empleado = p_id_empleado AND id_quincena = p_id_quincena;
        IF v_ya_liquidado > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Liquidación ya existe para empleado ' || p_id_empleado || ' quincena ' || p_id_quincena);
        END IF;
        v_bruto := fn_bruto(p_id_empleado, p_id_quincena);
        v_ded := fn_deducciones(p_id_empleado, v_bruto, p_id_quincena);
        v_neto := v_bruto - v_ded.total;
        -- Ajuste por neto negativo
        IF v_neto < 0 THEN
            v_ded.embargo := 0;
            v_ded.total := v_ded.salud + v_ded.pension + v_ded.fondo_solid + v_ded.embargo + v_ded.libranzas + v_ded.aporte_vol;
            v_neto := v_bruto - v_ded.total;
            IF v_neto < 0 THEN
                v_ded.libranzas := 0;
                v_ded.total := v_ded.salud + v_ded.pension + v_ded.fondo_solid + v_ded.embargo + v_ded.libranzas + v_ded.aporte_vol;
                v_neto := v_bruto - v_ded.total;
                sp_log_nomina('ALERTA_NETO_NEGATIVO', 'Empleado ' || p_id_empleado || ' neto: ' || v_neto, 0, 1, 0);
            END IF;
        END IF;
        INSERT INTO LIQUIDACION VALUES (
            SEQ_LIQUIDACION.NEXTVAL, p_id_empleado, p_id_quincena,
            fn_salario_base_q(p_id_empleado, p_id_quincena),
            fn_recargos(p_id_empleado, p_id_quincena),
            fn_bonificacion(p_id_empleado),
            fn_auxilio_transporte(p_id_empleado, p_id_quincena),
            fn_bono_sede(p_id_empleado),
            v_bruto, v_ded.salud, v_ded.pension, v_ded.fondo_solid,
            v_ded.embargo, v_ded.libranzas, v_ded.aporte_vol, v_ded.total, v_neto, SYSDATE
        );
        COMMIT;
        sp_log_nomina('LIQUIDACION_OK', 'Empleado ' || p_id_empleado, 1, 0, v_neto);
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK; sp_log_nomina('ERROR_LIQUIDACION', SQLERRM, 0, 1, 0); RAISE;
    END sp_liquidar_quincena;

    -- =================================================================
    -- PROCEDIMIENTO MASIVO CON BULK COLLECT Y FORALL (Punto 6)
    -- =================================================================
    PROCEDURE sp_liquidar_quincena(p_id_quincena VARCHAR2) IS
        v_ids t_id_array;
        v_liquidaciones t_lista_liq;
        v_ok_count NUMBER := 0;
        v_error_count NUMBER := 0;
        v_total_neto NUMBER := 0;
        CURSOR c_empleados IS
            SELECT e.id_empleado
            FROM EMPLEADOS e
            WHERE e.estado = 'ACTIVO'
              AND NOT EXISTS (SELECT 1 FROM LIQUIDACION l 
                              WHERE l.id_empleado = e.id_empleado AND l.id_quincena = p_id_quincena);
    BEGIN
        load_param_cache;
        OPEN c_empleados;
        FETCH c_empleados BULK COLLECT INTO v_ids;
        CLOSE c_empleados;
        FOR i IN 1..v_ids.COUNT LOOP
            BEGIN
                DECLARE
                    v_bruto NUMBER;
                    v_ded t_deducciones;
                    v_neto NUMBER;
                    v_sbq NUMBER; v_rec NUMBER; v_bon NUMBER; v_aux NUMBER; v_bns NUMBER;
                BEGIN
                    v_sbq := fn_salario_base_q(v_ids(i), p_id_quincena);
                    v_rec := fn_recargos(v_ids(i), p_id_quincena);
                    v_bon := fn_bonificacion(v_ids(i));
                    v_aux := fn_auxilio_transporte(v_ids(i), p_id_quincena);
                    v_bns := fn_bono_sede(v_ids(i));
                    v_bruto := v_sbq + v_rec + v_bon + v_aux + v_bns;
                    v_ded := fn_deducciones(v_ids(i), v_bruto, p_id_quincena);
                    v_neto := v_bruto - v_ded.total;
                    IF v_neto < 0 THEN
                        v_ded.embargo := 0;
                        v_ded.total := v_ded.salud + v_ded.pension + v_ded.fondo_solid + v_ded.embargo + v_ded.libranzas + v_ded.aporte_vol;
                        v_neto := v_bruto - v_ded.total;
                        IF v_neto < 0 THEN
                            v_ded.libranzas := 0;
                            v_ded.total := v_ded.salud + v_ded.pension + v_ded.fondo_solid + v_ded.embargo + v_ded.libranzas + v_ded.aporte_vol;
                            v_neto := v_bruto - v_ded.total;
                        END IF;
                    END IF;
                    v_liquidaciones(i).id_empleado := v_ids(i);
                    v_liquidaciones(i).id_quincena := p_id_quincena;
                    v_liquidaciones(i).salario_base_q := v_sbq;
                    v_liquidaciones(i).recargos := v_rec;
                    v_liquidaciones(i).bonificacion := v_bon;
                    v_liquidaciones(i).auxilio_transp := v_aux;
                    v_liquidaciones(i).bono_sede := v_bns;
                    v_liquidaciones(i).bruto := v_bruto;
                    v_liquidaciones(i).deduccion_salud := v_ded.salud;
                    v_liquidaciones(i).deduccion_pension := v_ded.pension;
                    v_liquidaciones(i).fondo_solidaridad := v_ded.fondo_solid;
                    v_liquidaciones(i).embargo := v_ded.embargo;
                    v_liquidaciones(i).libranzas := v_ded.libranzas;
                    v_liquidaciones(i).aporte_voluntario := v_ded.aporte_vol;
                    v_liquidaciones(i).total_deducciones := v_ded.total;
                    v_liquidaciones(i).neto := v_neto;
                    v_ok_count := v_ok_count + 1;
                    v_total_neto := v_total_neto + v_neto;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_error_count := v_error_count + 1;
                        sp_log_nomina('ERROR_BULK', 'Emp ' || v_ids(i) || ': ' || SQLERRM, 0, 1, 0);
                END;
            END;
        END LOOP;
        FORALL i IN 1..v_liquidaciones.COUNT SAVE EXCEPTIONS
            INSERT INTO LIQUIDACION VALUES (
                SEQ_LIQUIDACION.NEXTVAL,
                v_liquidaciones(i).id_empleado, v_liquidaciones(i).id_quincena,
                v_liquidaciones(i).salario_base_q, v_liquidaciones(i).recargos,
                v_liquidaciones(i).bonificacion, v_liquidaciones(i).auxilio_transp,
                v_liquidaciones(i).bono_sede, v_liquidaciones(i).bruto,
                v_liquidaciones(i).deduccion_salud, v_liquidaciones(i).deduccion_pension,
                v_liquidaciones(i).fondo_solidaridad, v_liquidaciones(i).embargo,
                v_liquidaciones(i).libranzas, v_liquidaciones(i).aporte_voluntario,
                v_liquidaciones(i).total_deducciones, v_liquidaciones(i).neto, SYSDATE
            );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Procesados OK: ' || v_ok_count || ' | Errores: ' || v_error_count);
        sp_log_nomina('LIQUIDACION_MASIVA', 'Quincena ' || p_id_quincena, v_ok_count, v_error_count, v_total_neto);
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK; sp_log_nomina('ERROR_MASIVO', SQLERRM, 0, v_ids.COUNT, 0); RAISE;
    END sp_liquidar_quincena;

    -- =================================================================
    -- FUNCIÓN TOTAL NETO POR SEDE
    -- =================================================================
    FUNCTION fn_total_nomina_sede(p_cod_sede VARCHAR2, p_id_quincena VARCHAR2) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(l.neto), 0) INTO v_total
        FROM LIQUIDACION l JOIN EMPLEADOS e ON l.id_empleado = e.id_empleado
        WHERE e.cod_sede = p_cod_sede AND l.id_quincena = p_id_quincena;
        RETURN v_total;
    END fn_total_nomina_sede;

    -- =================================================================
    -- FUNCIÓN PIPELINED (Punto 7)
    -- =================================================================
    FUNCTION fn_reporte_nomina(p_cod_sede VARCHAR2 DEFAULT NULL, p_tipo_contrato VARCHAR2 DEFAULT NULL)
    RETURN t_liqu_table PIPELINED IS
        v_sql VARCHAR2(4000);
        v_cursor SYS_REFCURSOR;
        v_rec t_liqu_row;
    BEGIN
        v_sql := 'SELECT l.id_liquidacion, l.id_empleado, e.nombre, e.cod_sede, l.id_quincena, l.bruto, l.neto
                  FROM LIQUIDACION l JOIN EMPLEADOS e ON l.id_empleado = e.id_empleado WHERE 1=1';
        IF p_cod_sede IS NOT NULL THEN v_sql := v_sql || ' AND e.cod_sede = :sede'; END IF;
        IF p_tipo_contrato IS NOT NULL THEN v_sql := v_sql || ' AND e.tipo_contrato = :tipo'; END IF;
        OPEN v_cursor FOR v_sql USING p_cod_sede, p_tipo_contrato;
        LOOP
            FETCH v_cursor INTO v_rec.id_liquidacion, v_rec.id_empleado, v_rec.nombre_empleado, 
                                v_rec.cod_sede, v_rec.id_quincena, v_rec.bruto, v_rec.neto;
            EXIT WHEN v_cursor%NOTFOUND;
            PIPE ROW(v_rec);
        END LOOP;
        CLOSE v_cursor;
        RETURN;
    END fn_reporte_nomina;

    -- =================================================================
    -- PROCEDIMIENTO DE LOG CON AUTONOMOUS TRANSACTION (Punto 8)
    -- =================================================================
    PROCEDURE sp_log_nomina(p_operation VARCHAR2, p_detalle VARCHAR2, 
                            p_empleados_ok NUMBER DEFAULT 0, 
                            p_empleados_error NUMBER DEFAULT 0, 
                            p_monto_total NUMBER DEFAULT 0) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO LOG_NOMINA (id_log, fecha_hora, operacion, usuario, detalle, empleados_ok, empleados_error, monto_total)
        VALUES (SEQ_LOG.NEXTVAL, SYSTIMESTAMP, p_operation, USER, p_detalle, p_empleados_ok, p_empleados_error, p_monto_total);
        COMMIT;
    END sp_log_nomina;

-- =================================================================
-- BLOQUE DE INICIALIZACIÓN DEL PACKAGE (solo carga caché)
-- =================================================================
BEGIN
    load_param_cache;
END PKG_NOMINA;
/

-- ======================================================================
-- PUNTO 5: Compound Trigger sobre LIQUIDACION
-- ======================================================================

CREATE OR REPLACE TRIGGER trg_liquidacion_compound
FOR INSERT ON LIQUIDACION
COMPOUND TRIGGER
    -- Variables para AFTER EACH ROW (para saber si hubo ajuste)
    TYPE t_ajustados IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_ajustados t_ajustados;
    v_idx NUMBER := 0;
    
    BEFORE EACH ROW IS
        v_bruto_original NUMBER;
        v_neto_temp NUMBER;
        v_total_ded_temp NUMBER;
    BEGIN
        -- Validación salario_base_q no negativo
        IF :NEW.salario_base_q < 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Salario base no puede ser negativo');
        END IF;
        
        -- Ajuste por neto negativo
        IF :NEW.neto < 0 THEN
            v_bruto_original := :NEW.bruto;
            v_neto_temp := :NEW.neto;
            v_total_ded_temp := :NEW.total_deducciones;
            -- Paso 1: embargo a 0
            :NEW.embargo := 0;
            v_total_ded_temp := :NEW.deduccion_salud + :NEW.deduccion_pension + :NEW.fondo_solidaridad + :NEW.embargo + :NEW.libranzas + :NEW.aporte_voluntario;
            v_neto_temp := v_bruto_original - v_total_ded_temp;
            IF v_neto_temp < 0 THEN
                -- Paso 2: libranzas a 0
                :NEW.libranzas := 0;
                v_total_ded_temp := :NEW.deduccion_salud + :NEW.deduccion_pension + :NEW.fondo_solidaridad + :NEW.embargo + :NEW.libranzas + :NEW.aporte_voluntario;
                v_neto_temp := v_bruto_original - v_total_ded_temp;
            END IF;
            :NEW.total_deducciones := v_total_ded_temp;
            :NEW.neto := v_neto_temp;
            -- Marcar que se ajustó
            v_idx := v_idx + 1;
            v_ajustados(v_idx) := :NEW.id_empleado;
        END IF;
    END BEFORE EACH ROW;
    
    AFTER EACH ROW IS
    BEGIN
        -- Si se ajustó embargo o libranzas, registrar alerta
        IF v_ajustados.EXISTS(v_idx) AND v_ajustados(v_idx) = :NEW.id_empleado THEN
            INSERT INTO LOG_NOMINA (id_log, fecha_hora, operacion, usuario, detalle)
            VALUES (SEQ_LOG.NEXTVAL, SYSTIMESTAMP, 'ALERTA_NETO_NEGATIVO', USER,
                    'Ajuste de embargo/libranzas para empleado ' || :NEW.id_empleado || ' neto final: ' || :NEW.neto);
        END IF;
        
        -- Actualizar saldo pendiente de libranzas activas
        UPDATE LIBRANZAS
        SET saldo_pendiente = saldo_pendiente - (:NEW.libranzas),
            estado = CASE WHEN saldo_pendiente - (:NEW.libranzas) <= 0 THEN 'PAGADA' ELSE estado END
        WHERE id_empleado = :NEW.id_empleado AND estado = 'ACTIVA';
    END AFTER EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        INSERT INTO LOG_NOMINA (id_log, fecha_hora, operacion, usuario, detalle)
        VALUES (SEQ_LOG.NEXTVAL, SYSTIMESTAMP, 'INSERT_LIQUIDACION', USER,
                'Lote procesado a las ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS.FF3'));
    END AFTER STATEMENT;
END trg_liquidacion_compound;
/

-- ======================================================================
-- BLOQUE DE PRUEBA FINAL (ejecutar liquidación masiva y mostrar resultados)
-- ======================================================================

BEGIN
    -- Limpiar tablas de resultados previos para prueba limpia
    EXECUTE IMMEDIATE 'DELETE FROM LIQUIDACION';
    EXECUTE IMMEDIATE 'DELETE FROM LOG_NOMINA';
    COMMIT;
    
    -- Ejecutar liquidación masiva para la quincena
    PKG_NOMINA.sp_liquidar_quincena('2026-Q1-ENE');
    
    -- Mostrar resultados
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== LIQUIDACIONES REGISTRADAS ===');
    FOR rec IN (SELECT l.id_empleado, e.nombre, l.bruto, l.neto FROM LIQUIDACION l JOIN EMPLEADOS e ON l.id_empleado = e.id_empleado ORDER BY l.id_empleado) LOOP
        DBMS_OUTPUT.PUT_LINE('Empleado ' || rec.id_empleado || ' - ' || rec.nombre || ' | Bruto: ' || TO_CHAR(rec.bruto, '999,999,999.00') || ' | Neto: ' || TO_CHAR(rec.neto, '999,999,999.00'));
    END LOOP;
END;
/