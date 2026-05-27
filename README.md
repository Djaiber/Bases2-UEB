# 📦 Bases de Datos 2 — UEB

Repositorio del curso **Bases de Datos 2** de la Universidad El Bosque (UEB).  
Contiene todos los scripts, ejercicios y talleres ejecutados durante el semestre, cubriendo **Oracle SQL**, **PL/SQL** y **MongoDB**.

---

## 🗂️ Estructura del Repositorio

```
Bases2-UEB/
│
├── 📄 01-oracle-sql
│   ├── 00-kick-off.sql
│   ├── 01-employee-salary-country.sql
│   ├── 02-username-substr.sql
│   ├── 03-job-salary.sql
│   ├── 04-joins-avanzados.sql
│   ├── 05-subconsultas.sql
│   ├── 06-window-functions.sql
│   ├── 07-rollup-cube-listagg.sql
│   └── 08-explain-plan.sql
│
├── 📘 02-plsql-fundamentos
│   ├── 01-variables-tipos.sql
│   ├── 02-control-structures.sql
│   ├── 03-placeholders-dynamic.sql
│   ├── 04-exceptions.sql
│   ├── 05-exceptions-raise.sql
│   ├── 06-subprograms.sql
│   ├── 07-cursores.sql
│   └── 08-packages.sql
│
├── 📕 03-taller-nomina
│   ├── 00-setup.sql
│   ├── 01-esquema-nomina.sql
│   ├── 02-taller-avanzado.sql
│   ├── 03-bloque-anonimo.sql
│   ├── 04-taller-completo.sql
│   ├── 05-pkg-nomina-v1.sql
│   └── 06-pkg-nomina-v2.sql
│
├── 📗 04-sql-book
│   ├── chapter1-tables-inserts.sql
│   └── chapter2-joins-agg.sql
│
├── 🔗 05-connectivity
│   ├── dblink.sql
│   ├── andromeda-permisos.sql
│   ├── show-user-privs.sql
│   └── utl-smtp-email.sql
│
├── 🍃 06-mongodb
│   ├── 01-crud-basics.mongodb
│   ├── 02-filters-operators.mongodb
│   ├── 03-practice-airbnb.mongodb
│   ├── 04-schema-validation.mongodb
│   ├── 05-mundial2026.mongodb
│   ├── 06-aggregations.mongodb
│   ├── 07-indexes-performance.mongodb
│   └── 08-transactions.mongodb
│
└── ⚙️ config
    ├── dml-policy.json
    └── mysql-snapshot-hook.json
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
@02-plsql-fundamentos/01-variables-tipos.sql
```

### MongoDB

1. Abrir MongoDB Compass → Open MongoDB Playground
2. O ejecutar directamente con `mongosh`:

```bash
mongosh < 06-mongodb/02-filters-operators.mongodb
```

> Para `03-practice-airbnb.mongodb` se necesita el dataset `sample_airbnb` (disponible en MongoDB Atlas).

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
