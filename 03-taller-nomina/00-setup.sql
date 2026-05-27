-- ============================================================
-- TALLER AVANZADO PL/SQL — SETUP SCRIPT
-- Sistema de Liquidación de Nómina — HotelGroup S.A.
-- Oracle Database 19c
-- Ejecutar este script al inicio del taller (5 min)
-- ============================================================

-- Limpieza previa (por si se ejecuta más de una vez)
BEGIN
  FOR r IN (SELECT table_name FROM user_tables WHERE table_name IN (
    'PARAMETROS','SEDES','EMPLEADOS','HORAS_TRABAJADAS','SANCIONES',
    'LIBRANZAS','EMBARGOS','LIQUIDACION','LOG_NOMINA'
  )) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR r IN (SELECT sequence_name FROM user_sequences WHERE sequence_name IN (
    'SEQ_LIQUIDACION','SEQ_LOG'
  )) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || r.sequence_name;
  END LOOP;
END;
/

-- ============================================================
-- 1. TABLA DE PARÁMETROS (valores legales vigentes)
-- ============================================================
CREATE TABLE PARAMETROS (
  cod_parametro   VARCHAR2(30) PRIMARY KEY,
  valor_numerico  NUMBER(15,2),
  descripcion     VARCHAR2(100)
);

INSERT INTO PARAMETROS VALUES ('SMLMV', 1423500, 'Salario Mínimo Legal Mensual Vigente 2026');
INSERT INTO PARAMETROS VALUES ('AUX_TRANSPORTE', 200000, 'Auxilio de Transporte Mensual 2026');
INSERT INTO PARAMETROS VALUES ('PCT_SALUD', 4, 'Porcentaje aporte salud empleado');
INSERT INTO PARAMETROS VALUES ('PCT_PENSION', 4, 'Porcentaje aporte pensión empleado');
INSERT INTO PARAMETROS VALUES ('PCT_FONDO_SOLIDARIDAD', 1, 'Porcentaje fondo solidaridad (>4 SMLMV)');
INSERT INTO PARAMETROS VALUES ('UMBRAL_FONDO_SMLMV', 4, 'Número de SMLMV para fondo solidaridad');
INSERT INTO PARAMETROS VALUES ('RECARGO_NOCTURNO', 35, 'Porcentaje recargo hora nocturna');
INSERT INTO PARAMETROS VALUES ('RECARGO_DOMINICAL', 75, 'Porcentaje recargo hora dominical');
INSERT INTO PARAMETROS VALUES ('RECARGO_NOCT_DOM', 110, 'Porcentaje recargo nocturno dominical');
INSERT INTO PARAMETROS VALUES ('RET_SERVICIOS', 11, 'Porcentaje retención prestación servicios');
INSERT INTO PARAMETROS VALUES ('BONO_CLIMA_SMA', 80000, 'Bono clima quincenal sede Santa Marta');
INSERT INTO PARAMETROS VALUES ('APORTE_VOL_BOG', 20000, 'Aporte voluntario quincenal sede Bogotá');
COMMIT;

-- ============================================================
-- 2. SEDES
-- ============================================================
CREATE TABLE SEDES (
  cod_sede    VARCHAR2(5) PRIMARY KEY,
  nombre_sede VARCHAR2(50),
  ciudad      VARCHAR2(50)
);

INSERT INTO SEDES VALUES ('BOG', 'Hotel Capital', 'Bogotá');
INSERT INTO SEDES VALUES ('MED', 'Hotel Montaña', 'Medellín');
INSERT INTO SEDES VALUES ('SMA', 'Hotel Playa', 'Santa Marta');
INSERT INTO SEDES VALUES ('CTG', 'Hotel Colonial', 'Cartagena');
COMMIT;

-- ============================================================
-- 3. EMPLEADOS
-- ============================================================
CREATE TABLE EMPLEADOS (
  id_empleado       NUMBER(6) PRIMARY KEY,
  nombre            VARCHAR2(80) NOT NULL,
  tipo_contrato     VARCHAR2(20) NOT NULL CHECK (tipo_contrato IN ('PLANTA','TEMPORAL','SERVICIOS')),
  salario_base      NUMBER(12,2) NOT NULL,
  fecha_ingreso     DATE NOT NULL,
  cod_sede          VARCHAR2(5) REFERENCES SEDES(cod_sede),
  estado            VARCHAR2(10) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO','INACTIVO','SUSPENDIDO')),
  acepta_aporte_vol VARCHAR2(1) DEFAULT 'N' CHECK (acepta_aporte_vol IN ('S','N'))
);

-- Bogotá
INSERT INTO EMPLEADOS VALUES (1001, 'Carlos Méndez',     'PLANTA',    2500000, DATE '2018-03-15', 'BOG', 'ACTIVO', 'S');
INSERT INTO EMPLEADOS VALUES (1002, 'Ana Rodríguez',     'PLANTA',    1423500, DATE '2024-06-01', 'BOG', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1003, 'Pedro Suárez',      'TEMPORAL',  12500,   DATE '2025-01-10', 'BOG', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1004, 'Laura García',      'SERVICIOS', 5000000, DATE '2023-04-20', 'BOG', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1005, 'Miguel Torres',     'PLANTA',    7200000, DATE '2012-08-01', 'BOG', 'ACTIVO', 'S');

-- Medellín
INSERT INTO EMPLEADOS VALUES (1006, 'Sofía Herrera',     'PLANTA',    3200000, DATE '2020-02-14', 'MED', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1007, 'Diego Parra',       'TEMPORAL',  15000,   DATE '2024-11-01', 'MED', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1008, 'Andrea López',      'PLANTA',    1800000, DATE '2019-07-22', 'MED', 'ACTIVO', 'N');

-- Santa Marta
INSERT INTO EMPLEADOS VALUES (1009, 'Roberto Castro',    'PLANTA',    2800000, DATE '2016-01-05', 'SMA', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1010, 'María Jiménez',     'TEMPORAL',  11000,   DATE '2025-09-01', 'SMA', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1011, 'Fernando Ríos',     'SERVICIOS', 8000000, DATE '2021-03-15', 'SMA', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1012, 'Camila Vargas',     'PLANTA',    1423500, DATE '2022-05-10', 'SMA', 'ACTIVO', 'N');

-- Cartagena
INSERT INTO EMPLEADOS VALUES (1013, 'Andrés Moreno',     'PLANTA',    4500000, DATE '2015-11-20', 'CTG', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1014, 'Valentina Cruz',    'TEMPORAL',  13500,   DATE '2023-08-15', 'CTG', 'ACTIVO', 'N');
INSERT INTO EMPLEADOS VALUES (1015, 'Jorge Ramírez',     'PLANTA',    2200000, DATE '2021-04-01', 'CTG', 'ACTIVO', 'N');

-- Otros empleados
INSERT INTO EMPLEADOS VALUES (1016, 'Sandra Mejía',      'TEMPORAL',  14000,   DATE '2019-06-12', 'BOG', 'ACTIVO', 'N');  -- Temporal con 0 horas
INSERT INTO EMPLEADOS VALUES (1017, 'Ricardo Ortiz',     'PLANTA',    1500000, DATE '2020-03-01', 'MED', 'INACTIVO', 'N'); -- Inactivo
INSERT INTO EMPLEADOS VALUES (1018, 'Patricia Luna',     'PLANTA',    1600000, DATE '2024-02-15', 'CTG', 'ACTIVO', 'N');

-- EMP 1019 (Servicios Bogotá)
INSERT INTO EMPLEADOS VALUES (1019, 'Héctor Díaz',       'SERVICIOS', 6500000, DATE '2022-09-01', 'BOG', 'ACTIVO', 'N');

COMMIT;

-- ============================================================
-- 4. HORAS TRABAJADAS (quincena 2026-Q1-ENE = 1ra quincena enero 2026)
-- ============================================================
CREATE TABLE HORAS_TRABAJADAS (
  id_empleado     NUMBER(6) REFERENCES EMPLEADOS(id_empleado),
  id_quincena     VARCHAR2(15),
  tipo_hora       VARCHAR2(20) CHECK (tipo_hora IN ('NORMAL','NOCTURNA','DOMINICAL','NOCTURNA_DOM')),
  cantidad_horas  NUMBER(5,1),
  CONSTRAINT pk_horas PRIMARY KEY (id_empleado, id_quincena, tipo_hora)
);

-- EMP 1001 (Planta Bogotá) — horas extras solamente, su base es fija
INSERT INTO HORAS_TRABAJADAS VALUES (1001, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1001, '2026-Q1-ENE', 'NOCTURNA', 10);
INSERT INTO HORAS_TRABAJADAS VALUES (1001, '2026-Q1-ENE', 'DOMINICAL', 8);
INSERT INTO HORAS_TRABAJADAS VALUES (1001, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1002 (Planta Bogotá, salario mínimo)
INSERT INTO HORAS_TRABAJADAS VALUES (1002, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1002, '2026-Q1-ENE', 'NOCTURNA', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1002, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1002, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1003 (Temporal Bogotá, salario por hora)
INSERT INTO HORAS_TRABAJADAS VALUES (1003, '2026-Q1-ENE', 'NORMAL', 120);
INSERT INTO HORAS_TRABAJADAS VALUES (1003, '2026-Q1-ENE', 'NOCTURNA', 15);
INSERT INTO HORAS_TRABAJADAS VALUES (1003, '2026-Q1-ENE', 'DOMINICAL', 8);
INSERT INTO HORAS_TRABAJADAS VALUES (1003, '2026-Q1-ENE', 'NOCTURNA_DOM', 4);

-- EMP 1005 (Planta Bogotá, >10 años, alto salario)
INSERT INTO HORAS_TRABAJADAS VALUES (1005, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1005, '2026-Q1-ENE', 'NOCTURNA', 5);
INSERT INTO HORAS_TRABAJADAS VALUES (1005, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1005, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1006 (Planta Medellín)
INSERT INTO HORAS_TRABAJADAS VALUES (1006, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1006, '2026-Q1-ENE', 'NOCTURNA', 12);
INSERT INTO HORAS_TRABAJADAS VALUES (1006, '2026-Q1-ENE', 'DOMINICAL', 6);
INSERT INTO HORAS_TRABAJADAS VALUES (1006, '2026-Q1-ENE', 'NOCTURNA_DOM', 3);

-- EMP 1007 (Temporal Medellín)
INSERT INTO HORAS_TRABAJADAS VALUES (1007, '2026-Q1-ENE', 'NORMAL', 96);
INSERT INTO HORAS_TRABAJADAS VALUES (1007, '2026-Q1-ENE', 'NOCTURNA', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1007, '2026-Q1-ENE', 'DOMINICAL', 16);
INSERT INTO HORAS_TRABAJADAS VALUES (1007, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1009 (Planta Santa Marta, bono clima)
INSERT INTO HORAS_TRABAJADAS VALUES (1009, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1009, '2026-Q1-ENE', 'NOCTURNA', 8);
INSERT INTO HORAS_TRABAJADAS VALUES (1009, '2026-Q1-ENE', 'DOMINICAL', 10);
INSERT INTO HORAS_TRABAJADAS VALUES (1009, '2026-Q1-ENE', 'NOCTURNA_DOM', 5);

-- EMP 1010 (Temporal Santa Marta)
INSERT INTO HORAS_TRABAJADAS VALUES (1010, '2026-Q1-ENE', 'NORMAL', 80);
INSERT INTO HORAS_TRABAJADAS VALUES (1010, '2026-Q1-ENE', 'NOCTURNA', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1010, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1010, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1012 (Planta Santa Marta, salario mínimo)
INSERT INTO HORAS_TRABAJADAS VALUES (1012, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1012, '2026-Q1-ENE', 'NOCTURNA', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1012, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1012, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1013 (Planta Cartagena)
INSERT INTO HORAS_TRABAJADAS VALUES (1013, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1013, '2026-Q1-ENE', 'NOCTURNA', 6);
INSERT INTO HORAS_TRABAJADAS VALUES (1013, '2026-Q1-ENE', 'DOMINICAL', 4);
INSERT INTO HORAS_TRABAJADAS VALUES (1013, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1014 (Temporal Cartagena)
INSERT INTO HORAS_TRABAJADAS VALUES (1014, '2026-Q1-ENE', 'NORMAL', 110);
INSERT INTO HORAS_TRABAJADAS VALUES (1014, '2026-Q1-ENE', 'NOCTURNA', 20);
INSERT INTO HORAS_TRABAJADAS VALUES (1014, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1014, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1016 (Temporal Bogotá)
INSERT INTO HORAS_TRABAJADAS VALUES (1016, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1016, '2026-Q1-ENE', 'NOCTURNA', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1016, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1016, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1018 (Planta Cartagena)
INSERT INTO HORAS_TRABAJADAS VALUES (1018, '2026-Q1-ENE', 'NORMAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1018, '2026-Q1-ENE', 'NOCTURNA', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1018, '2026-Q1-ENE', 'DOMINICAL', 0);
INSERT INTO HORAS_TRABAJADAS VALUES (1018, '2026-Q1-ENE', 'NOCTURNA_DOM', 0);

-- EMP 1019 (Servicios Bogotá)
INSERT INTO HORAS_TRABAJADAS VALUES (1019, '2026-Q1-ENE', 'NORMAL', 50);
INSERT INTO HORAS_TRABAJADAS VALUES (1019, '2026-Q1-ENE', 'NOCTURNA', 20);
INSERT INTO HORAS_TRABAJADAS VALUES (1019, '2026-Q1-ENE', 'DOMINICAL', 10);
INSERT INTO HORAS_TRABAJADAS VALUES (1019, '2026-Q1-ENE', 'NOCTURNA_DOM', 5);

COMMIT;

-- ============================================================
-- 5. SANCIONES DISCIPLINARIAS
-- ============================================================
CREATE TABLE SANCIONES (
  id_sancion    NUMBER(6) PRIMARY KEY,
  id_empleado   NUMBER(6) REFERENCES EMPLEADOS(id_empleado),
  fecha_sancion DATE,
  motivo        VARCHAR2(200)
);

-- EMP 1006: 3 sanciones
INSERT INTO SANCIONES VALUES (1, 1006, DATE '2025-09-10', 'Llegada tardía reiterada');
INSERT INTO SANCIONES VALUES (2, 1006, DATE '2025-10-20', 'Ausencia sin justificación');
INSERT INTO SANCIONES VALUES (3, 1006, DATE '2025-12-05', 'Incumplimiento de protocolo');

-- EMP 1001: 1 sanción
INSERT INTO SANCIONES VALUES (4, 1001, DATE '2025-11-15', 'Llegada tardía');

-- EMP 1009: 2 sanciones
INSERT INTO SANCIONES VALUES (5, 1009, DATE '2024-12-01', 'Uso indebido de equipos');
INSERT INTO SANCIONES VALUES (6, 1009, DATE '2025-01-15', 'Ausencia sin justificación');

-- EMP 1013: 2 sanciones
INSERT INTO SANCIONES VALUES (7, 1013, DATE '2025-08-10', 'Conducta inapropiada');
INSERT INTO SANCIONES VALUES (8, 1013, DATE '2025-11-22', 'Llegada tardía');

COMMIT;

-- ============================================================
-- 6. LIBRANZAS (créditos con descuento quincenal)
-- ============================================================
CREATE TABLE LIBRANZAS (
  id_libranza    NUMBER(6) PRIMARY KEY,
  id_empleado    NUMBER(6) REFERENCES EMPLEADOS(id_empleado),
  entidad        VARCHAR2(50),
  cuota_mensual  NUMBER(10,2),
  saldo_pendiente NUMBER(12,2),
  estado         VARCHAR2(10) DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA','PAGADA','ANULADA'))
);

INSERT INTO LIBRANZAS VALUES (1, 1001, 'Banco Popular',   350000,  4200000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (2, 1005, 'Banco Davivienda', 800000, 9600000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (3, 1005, 'Cooperativa ABC',  200000, 1800000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (4, 1009, 'Banco BBVA',       250000, 3000000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (5, 1013, 'Banco Colpatria',  400000, 4800000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (6, 1018, 'Banco Popular',    500000, 2500000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (7, 1018, 'Cooperativa XYZ',  300000, 1500000, 'ACTIVA');
INSERT INTO LIBRANZAS VALUES (8, 1002, 'Banco Agrario',    100000,  800000, 'ACTIVA');

COMMIT;

-- ============================================================
-- 7. EMBARGOS JUDICIALES
-- ============================================================
CREATE TABLE EMBARGOS (
  id_embargo    NUMBER(6) PRIMARY KEY,
  id_empleado   NUMBER(6) REFERENCES EMPLEADOS(id_empleado),
  juzgado       VARCHAR2(100),
  porcentaje    NUMBER(4,1),
  estado        VARCHAR2(10) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO','LEVANTADO'))
);

INSERT INTO EMBARGOS VALUES (1, 1005, 'Juzgado 3ro Civil Bogotá',     15, 'ACTIVO');
INSERT INTO EMBARGOS VALUES (2, 1013, 'Juzgado 1ro Familia Cartagena', 20, 'ACTIVO');
INSERT INTO EMBARGOS VALUES (3, 1018, 'Juzgado 5to Civil Cartagena',   25, 'ACTIVO');

COMMIT;

-- ============================================================
-- 8. TABLA LIQUIDACIÓN (donde insertarán los resultados)
-- ============================================================
CREATE TABLE LIQUIDACION (
  id_liquidacion  NUMBER(10) PRIMARY KEY,
  id_empleado     NUMBER(6) REFERENCES EMPLEADOS(id_empleado),
  id_quincena     VARCHAR2(15),
  salario_base_q  NUMBER(12,2),
  recargos        NUMBER(12,2) DEFAULT 0,
  bonificacion    NUMBER(12,2) DEFAULT 0,
  auxilio_transp  NUMBER(12,2) DEFAULT 0,
  bono_sede       NUMBER(12,2) DEFAULT 0,
  bruto           NUMBER(12,2),
  deduccion_salud NUMBER(12,2) DEFAULT 0,
  deduccion_pension NUMBER(12,2) DEFAULT 0,
  fondo_solidaridad NUMBER(12,2) DEFAULT 0,
  embargo         NUMBER(12,2) DEFAULT 0,
  libranzas       NUMBER(12,2) DEFAULT 0,
  aporte_voluntario NUMBER(12,2) DEFAULT 0,
  total_deducciones NUMBER(12,2),
  neto            NUMBER(12,2),
  fecha_liquidacion DATE DEFAULT SYSDATE,
  CONSTRAINT uk_liq_emp_quin UNIQUE (id_empleado, id_quincena)
);

CREATE SEQUENCE SEQ_LIQUIDACION START WITH 1 INCREMENT BY 1;

-- ============================================================
-- 9. TABLA LOG DE NÓMINA (para auditoría)
-- ============================================================
CREATE TABLE LOG_NOMINA (
  id_log          NUMBER(10) PRIMARY KEY,
  fecha_hora      TIMESTAMP DEFAULT SYSTIMESTAMP,
  operacion       VARCHAR2(50),
  usuario         VARCHAR2(30) DEFAULT USER,
  detalle         VARCHAR2(500),
  empleados_ok    NUMBER(6) DEFAULT 0,
  empleados_error NUMBER(6) DEFAULT 0,
  monto_total     NUMBER(15,2) DEFAULT 0
);

CREATE SEQUENCE SEQ_LOG START WITH 1 INCREMENT BY 1;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT 'PARAMETROS'        AS tabla, COUNT(*) AS filas FROM PARAMETROS        UNION ALL
SELECT 'SEDES',                      COUNT(*)         FROM SEDES              UNION ALL
SELECT 'EMPLEADOS',                  COUNT(*)         FROM EMPLEADOS          UNION ALL
SELECT 'HORAS_TRABAJADAS',           COUNT(*)         FROM HORAS_TRABAJADAS   UNION ALL
SELECT 'SANCIONES',                  COUNT(*)         FROM SANCIONES          UNION ALL
SELECT 'LIBRANZAS',                  COUNT(*)         FROM LIBRANZAS          UNION ALL
SELECT 'EMBARGOS',                   COUNT(*)         FROM EMBARGOS           UNION ALL
SELECT 'LIQUIDACION',                COUNT(*)         FROM LIQUIDACION        UNION ALL
SELECT 'LOG_NOMINA',                 COUNT(*)         FROM LOG_NOMINA
ORDER BY 1;
