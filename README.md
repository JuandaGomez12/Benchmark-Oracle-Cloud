# BenchmarkSQL en Oracle Cloud (ADB) — Guía de Instalación y Ejecución

Guía paso a paso para configurar y ejecutar pruebas de benchmark TPC-C usando BenchmarkSQL contra una base de datos Oracle Autonomous Database (ADB) en Oracle Cloud.

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Java JDK 21** o superior
- **Apache Ant**
- **Maven**
- **DBeaver** o **SQL Developer** (para ejecutar SQL)
- Acceso a una instancia de **Oracle Autonomous Database** en Oracle Cloud
- El **Wallet** de conexión descargado desde OCI Console

---

## 1. Descargar BenchmarkSQL

1. Ve a: https://github.com/petergeoghegan/benchmarksql
2. Haz clic en **Code → Download ZIP**
3. Descomprime en una carpeta, por ejemplo:
```
C:\Users\tuUsuario\Downloads\benchmarksql
```

---

## 2. Descargar el Wallet de Oracle Cloud

1. Entra a **OCI Console → Autonomous Database → tu instancia → DB Connection**
2. Haz clic en **Download Wallet**
3. Ponle una contraseña (la necesitarás después)
4. Descomprime el wallet en una carpeta, por ejemplo:
```
C:\Users\tuUsuario\Downloads\WalletOracle
```

El wallet debe contener estos archivos:
- `cwallet.sso`
- `ewallet.p12`
- `keystore.jks`
- `ojdbc.properties`
- `sqlnet.ora`
- `tnsnames.ora`
- `truststore.jks`

### Editar sqlnet.ora

Abre el archivo `sqlnet.ora` con el Bloc de notas y asegúrate de que el `DIRECTORY` apunte a tu carpeta del wallet:

```
NAMES.DIRECTORY_PATH = (TNSNAMES, EZCONNECT)
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="C:\Users\tuUsuario\Downloads\WalletOracle")))
SSL_SERVER_DN_MATCH=yes
```

---

## 3. Compilar BenchmarkSQL

Abre una terminal (cmd) en la carpeta raíz de BenchmarkSQL y ejecuta:

```bash
ant
```

Deberías ver `BUILD SUCCESSFUL` al final.

---

## 4. Agregar el Driver JDBC de Oracle

BenchmarkSQL necesita el driver JDBC de Oracle. Descarga el `ojdbc11.jar` del **Oracle Instant Client** y cópialo a la carpeta `lib`:

```bash
copy "ruta\al\ojdbc11.jar" "ruta\benchmarksql\lib"
```

También necesitas el jar `oraclepki` para manejar el wallet. Descárgalo con Maven:

```bash
cd "ruta\benchmarksql\lib"
mvn dependency:get -Dartifact=com.oracle.database.security:oraclepki:23.6.0.24.10 -Ddest=.
```

Luego busca el jar descargado y cópialo a `lib`:
```bash
copy "%USERPROFILE%\.m2\repository\com\oracle\database\security\oraclepki\23.6.0.24.10\oraclepki-23.6.0.24.10.jar" "ruta\benchmarksql\lib"
```

---

## 5. Configurar el archivo de propiedades

Ve a la carpeta `run` de BenchmarkSQL, copia el archivo de ejemplo y edítalo:

```bash
cd ruta\benchmarksql\run
copy sample.oracle.properties oracle.properties
notepad oracle.properties
```

Reemplaza todo el contenido con:

```properties
db=oracle
driver=oracle.jdbc.OracleDriver
conn=jdbc:oracle:thin:@ALIAS_TNS?TNS_ADMIN=C:/Users/tuUsuario/Downloads/WalletOracle
user=benchmarksql
password=TuContraseñaDelUsuario
warehouses=1
loadWorkers=1
terminals=1
runTxnsPerTerminal=0
runMins=5
limitTxnsPerMin=10000000
terminalWarehouseFixed=false
useStoredProcedures=false
```

Donde `ALIAS_TNS` es el nombre del alias que aparece en el archivo `tnsnames.ora` del wallet (por ejemplo `midb_high`).

---

## 6. Crear el usuario benchmarksql en Oracle

Conéctate a la base de datos como **ADMIN** en DBeaver o SQL Developer y ejecuta:

```sql
CREATE USER benchmarksql
        IDENTIFIED BY "TuContraseña12#"
        DEFAULT TABLESPACE users
        TEMPORARY TABLESPACE temp;
GRANT CONNECT TO benchmarksql;
GRANT CREATE PROCEDURE TO benchmarksql;
GRANT CREATE SEQUENCE TO benchmarksql;
GRANT CREATE SESSION TO benchmarksql;
GRANT CREATE TABLE TO benchmarksql;
GRANT CREATE TRIGGER TO benchmarksql;
GRANT CREATE TYPE TO benchmarksql;
GRANT UNLIMITED TABLESPACE TO benchmarksql;
```

> ⚠️ Oracle ADB requiere contraseñas de mínimo 12 caracteres con mayúsculas, números y caracteres especiales.

---

## 7. Crear las tablas

Conéctate como el usuario **benchmarksql** y ejecuta el siguiente SQL:

```sql
create table bmsql_config (
  cfg_name    varchar2(30) primary key,
  cfg_value   varchar2(50)
);
create table bmsql_warehouse (
  w_id        integer   not null,
  w_ytd       number(12,2),
  w_tax       number(4,4),
  w_name      varchar2(10),
  w_street_1  varchar2(20),
  w_street_2  varchar2(20),
  w_city      varchar2(20),
  w_state     char(2),
  w_zip       char(9)
);
create table bmsql_district (
  d_w_id       integer       not null,
  d_id         integer       not null,
  d_ytd        number(12,2),
  d_tax        number(4,4),
  d_next_o_id  integer,
  d_name       varchar2(10),
  d_street_1   varchar2(20),
  d_street_2   varchar2(20),
  d_city       varchar2(20),
  d_state      char(2),
  d_zip        char(9)
);
create table bmsql_customer (
  c_w_id         integer        not null,
  c_d_id         integer        not null,
  c_id           integer        not null,
  c_discount     number(4,4),
  c_credit       char(2),
  c_last         varchar2(16),
  c_first        varchar2(16),
  c_credit_lim   number(12,2),
  c_balance      number(12,2),
  c_ytd_payment  number(12,2),
  c_payment_cnt  integer,
  c_delivery_cnt integer,
  c_street_1     varchar2(20),
  c_street_2     varchar2(20),
  c_city         varchar2(20),
  c_state        char(2),
  c_zip          char(9),
  c_phone        char(16),
  c_since        timestamp,
  c_middle       char(2),
  c_data         varchar2(500)
);
create sequence bmsql_hist_id_seq;
create table bmsql_history (
  hist_id  integer,
  h_c_id   integer,
  h_c_d_id integer,
  h_c_w_id integer,
  h_d_id   integer,
  h_w_id   integer,
  h_date   timestamp,
  h_amount number(6,2),
  h_data   varchar2(24)
);
create table bmsql_new_order (
  no_w_id  integer   not null,
  no_d_id  integer   not null,
  no_o_id  integer   not null
);
create table bmsql_oorder (
  o_w_id       integer      not null,
  o_d_id       integer      not null,
  o_id         integer      not null,
  o_c_id       integer,
  o_carrier_id integer,
  o_ol_cnt     integer,
  o_all_local  integer,
  o_entry_d    timestamp
);
create table bmsql_order_line (
  ol_w_id         integer   not null,
  ol_d_id         integer   not null,
  ol_o_id         integer   not null,
  ol_number       integer   not null,
  ol_i_id         integer   not null,
  ol_delivery_d   timestamp,
  ol_amount       number(6,2),
  ol_supply_w_id  integer,
  ol_quantity     integer,
  ol_dist_info    char(24)
);
create table bmsql_item (
  i_id     integer      not null,
  i_name   varchar2(24),
  i_price  number(5,2),
  i_data   varchar2(50),
  i_im_id  integer
);
create table bmsql_stock (
  s_w_id       integer       not null,
  s_i_id       integer       not null,
  s_quantity   integer,
  s_ytd        integer,
  s_order_cnt  integer,
  s_remote_cnt integer,
  s_data       varchar2(50),
  s_dist_01    char(24),
  s_dist_02    char(24),
  s_dist_03    char(24),
  s_dist_04    char(24),
  s_dist_05    char(24),
  s_dist_06    char(24),
  s_dist_07    char(24),
  s_dist_08    char(24),
  s_dist_09    char(24),
  s_dist_10    char(24)
);
```

---

## 8. Ajuste de rendimiento — Deshabilitar paralelismo

Oracle ADB habilita paralelismo automático que interfiere con BenchmarkSQL. Para deshabilitarlo, conéctate como **ADMIN** y ejecuta:

```sql
ALTER TABLE benchmarksql.bmsql_warehouse NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_district NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_customer NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_history NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_new_order NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_oorder NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_order_line NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_item NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_stock NOPARALLEL;
ALTER TABLE benchmarksql.bmsql_config NOPARALLEL;
```

---

## 9. Cargar los datos

Desde la carpeta `run` de BenchmarkSQL, ejecuta:

```bash
java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties LoadData
```

Deberías ver algo como:
```
Worker 000: Loading ITEM
Worker 000: Loading ITEM done
Worker 000: Loading Warehouse      1
Worker 000: Loading Warehouse      1 done
```

---

## 10. Crear los índices

Conéctate como **benchmarksql** y ejecuta:

```sql
alter table bmsql_warehouse add constraint bmsql_warehouse_pkey primary key (w_id);
alter table bmsql_district add constraint bmsql_district_pkey primary key (d_w_id, d_id);
alter table bmsql_customer add constraint bmsql_customer_pkey primary key (c_w_id, c_d_id, c_id);
alter table bmsql_oorder add constraint bmsql_oorder_pkey primary key (o_w_id, o_d_id, o_id);
alter table bmsql_new_order add constraint bmsql_new_order_pkey primary key (no_w_id, no_d_id, no_o_id);
alter table bmsql_order_line add constraint bmsql_order_line_pkey primary key (ol_w_id, ol_d_id, ol_o_id, ol_number);
alter table bmsql_stock add constraint bmsql_stock_pkey primary key (s_w_id, s_i_id);
alter table bmsql_item add constraint bmsql_item_pkey primary key (i_id);
```

---

## 11. Ejecutar el benchmark

Desde la carpeta `run`, ejecuta:

```bash
java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties jTPCC runBenchmark
```

El benchmark correrá por el tiempo configurado en `runMins` y al final mostrará los resultados:

```
Measured tpmC (NewOrders) = 56.15
Measured tpmTOTAL = 130.29
Session Start     = 2026-03-31 20:53:46
Session End       = 2026-03-31 20:58:46
Transaction Count = 651
```

---

## 12. Ver los registros generados en cada tabla

Ejecuta esto en SQL Developer como **benchmarksql**:

```sql
select concat('select count(1) from ', table_name) from user_tables;
```

O directamente:

```sql
select count(1) from BMSQL_CONFIG;
select count(1) from BMSQL_WAREHOUSE;
select count(1) from BMSQL_DISTRICT;
select count(1) from BMSQL_CUSTOMER;
select count(1) from BMSQL_HISTORY;
select count(1) from BMSQL_NEW_ORDER;
select count(1) from BMSQL_OORDER;
select count(1) from BMSQL_ORDER_LINE;
select count(1) from BMSQL_ITEM;
select count(1) from BMSQL_STOCK;
```

---

## 13. Limpiar los datos (para volver a correr)

Si quieres borrar los datos y volver a cargarlos:

```sql
DELETE FROM bmsql_order_line;
DELETE FROM bmsql_new_order;
DELETE FROM bmsql_oorder;
DELETE FROM bmsql_history;
DELETE FROM bmsql_customer;
DELETE FROM bmsql_stock;
DELETE FROM bmsql_item;
DELETE FROM bmsql_district;
DELETE FROM bmsql_warehouse;
DELETE FROM bmsql_config;
COMMIT;
```

Luego vuelve al paso 9.

---

## Resumen de comandos

| Paso | Comando |
|------|---------|
| Compilar | `ant` |
| Cargar datos | `java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties LoadData` |
| Correr benchmark | `java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties jTPCC runBenchmark` |

---

## Notas importantes

- El archivo `oracle.properties` debe estar en la carpeta `run` al momento de ejecutar los comandos.
- Todos los comandos Java deben ejecutarse desde la carpeta `run`.
- El `oraclepki` jar es indispensable para que el wallet funcione con Java.
- El ajuste de `NOPARALLEL` mejora el rendimiento en Oracle ADB aproximadamente un 10%.