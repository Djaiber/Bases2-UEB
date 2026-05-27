# 📦 Bases de Datos 2 — UEB

Repositorio del curso **Bases de Datos 2** de la Universidad El Bosque (UEB).  
Contiene todos los scripts, ejercicios y talleres ejecutados durante el semestre, cubriendo **Oracle SQL**, **PL/SQL** y **MongoDB**.

---

## 🗂️ Estructura del Repositorio

```
Bases2-UEB/
│
├── 📄 Oracle SQL — Consultas básicas
│   ├── kick-off.sql              # Exploración inicial del esquema HR
│   ├── 00-exercise.sql           # Nombre completo, salario y país del empleado
│   ├── 01-exercise.sql           # Generación de usernames con SUBSTR
│   ├── 02-exercise.sql           # Salario y cargo del empleado
│   └── show_user.sql             # Permisos y privilegios del usuario
│
├── 📘 PL/SQL — Fundamentos
│   ├── BasisPlSql.sql            # Variables, tipos de datos, SELECT INTO
│   ├── controlStruc.sql          # IF/ELSIF, GOTO, número primo
│   ├── placeholder.sql           # EXECUTE IMMEDIATE con bind variables
│   ├── exceptions.sql            # Excepciones predefinidas y ZERO_DIVIDE
│   ├── exceptionsError.sql       # RAISE_APPLICATION_ERROR + DBMS_XPLAN
│   └── subPrograms.sql           # Stored Procedures, funciones, triggers
│
├── 📕 PL/SQL — Taller Avanzado (Nómina HotelGroup S.A.)
│   ├── setup_nomina(1).sql       # Script de setup: tablas, datos, parámetros
│   ├── Nomina.sql                # Creación del esquema completo (copia de HR)
│   ├── TallerAvanzado.sql        # Exploración de tablas del taller
│   ├── plSqlP1.sql               # Punto 1: bloque anónimo de liquidación
│   ├── tallerplSql.sql           # Puntos 1–8: taller completo
│   ├── punto4SQLAv.sql           # PKG_NOMINA v1 (package de liquidación)
│   └── punto4SQLAvV2.sql         # PKG_NOMINA v2 (versión mejorada)
│
├── 📗 SQL — Learn SQL in a Month of Lunches
│   ├── chapter1.sql              # Cap 1: tablas, constraints, inserts (SQL Novel)
│   └── Chapter2.sql              # Cap 2: joins, subqueries, aggregates
│
├── 🔗 Conectividad
│   ├── dblink.sql                # Database Links (TNS y sin tnsnames.ora)
│   └── ANDromendaSantiago.sql    # Verificación de privilegios en esquema remoto
│
├── 🍃 mongo/ — MongoDB
│   ├── miprimerscripts.mongodb   # Primeros inserts (Mundial 2026)
│   ├── use ("mudial2026").mongodb # Selecciones del mundial
│   ├── mongo101.mongodb          # Filtros: $gte, $and, $nin, $exists, $regex
│   ├── practice.mongodb          # Queries sobre sample_airbnb (Porto)
│   ├── playground_Metrical_Zone_Of_Wines.mongodb  # Schema validation + wine reviews
│   └── aggreate.mongodb          # Aggregation framework (WIP)
│
└── ⚙️ Config
    ├── dml-policy.json           # Política DML
    └── mysql-snapshot-hook.json   # Hook de snapshot MySQL
```

---

## 🛠️ Tecnologías

| Tecnología | Versión | Uso |
|---|---|---|
| Oracle Database | 19c | Motor principal del curso |
| PL/SQL | — | Procedimientos, funciones, packages, triggers |
| MongoDB | 6.x+ | Base de datos documental, aggregation framework |
| SQL Developer / SQLcl | — | IDE para Oracle |
| MongoDB Compass | — | GUI + Playground para scripts `.mongodb` |

---

## 🚀 Cómo usar

### Oracle SQL / PL/SQL

1. Conectarse a una instancia Oracle con acceso al esquema `HR`
2. Ejecutar `SET SERVEROUTPUT ON;` antes de los scripts PL/SQL
3. Para el taller de nómina, ejecutar primero `setup_nomina(1).sql`

```sql
-- Ejemplo rápido
SET SERVEROUTPUT ON;
@BasisPlSql.sql
```

### MongoDB

1. Abrir MongoDB Compass → Open MongoDB Playground
2. O ejecutar directamente con `mongosh`:

```bash
mongosh < mongo/mongo101.mongodb
```

> Para `practice.mongodb` se necesita el dataset `sample_airbnb` (disponible en MongoDB Atlas).

---

## 📐 Convenciones del Curso

### Variables PL/SQL

| Prefijo | Tipo | Ejemplo |
|---|---|---|
| `vv_` | VARCHAR2 | `vv_nombre` |
| `vn_` | NUMBER | `vn_salario` |
| `vd_` | DATE | `vd_fecha` |
| `vi_` | INTEGER | `vi_contador` |
| `vdo_` | DOUBLE | `vdo_tasa` |
| `cn_` | Constante numérica | `cn_pi` |

### Nomenclatura de Subprogramas

| Prefijo | Tipo | Ejemplo |
|---|---|---|
| `sp_` | Stored Procedure | `sp_liquidar_quincena` |
| `fn_` | Function | `fn_get_smlmv` |
| `trg_` | Trigger | `trg_audit_emp` |
| `PKG_` | Package | `PKG_NOMINA` |
| `param_` | Parámetro | `param_nombre` |

---

## 📊 Evaluación

| Componente | Peso |
|---|---|
| Quizzes | 25% |
| Parciales | 40% |
| Examen final | 35% |

---

## 📎 Recursos

- 🔗 [Notion — Bases de datos 2](https://www.notion.so/Bases-de-datos-2-2fc7902d39c6801aa67aeeaec03a7ecb)
- 📖 [Oracle PL/SQL Docs](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/)
- 📖 [UTL_SMTP — Enviar correo desde la DB](https://docs.oracle.com/en/database/oracle/oracle-database/18/arpls/UTL_SMTP.html)
- 📖 [MongoDB Manual](https://www.mongodb.com/docs/manual/)
- 📖 *Learn SQL in a Month of Lunches* — book del curso

---

## 👤 Autor

**Jaiber Duván Díaz León**  
Universidad El Bosque — Bases de Datos 2, 2026-I  
Equipo Proyecto Final: **ACIDos**
