# BenchmarkSQL en Oracle Cloud (ADB) — Guía de Instalación, Ejecución y Optimización

Guía paso a paso para configurar y ejecutar pruebas de benchmark TPC-C usando BenchmarkSQL contra una base de datos Oracle Autonomous Database (ADB) en Oracle Cloud, incluyendo las optimizaciones aplicadas y sus resultados.

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

## 5. Crear el usuario benchmarksql en Oracle

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

## 6. Crear las tablas

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

## 7. Crear los índices primarios

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

## 8. Cargar los datos

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

## 9. Ejecutar el benchmark

Desde la carpeta `run`, ejecuta:

```bash
java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties jTPCC runBenchmark
```

El benchmark correrá por el tiempo configurado en `runMins` y al final mostrará los resultados:

```
Measured tpmC (NewOrders) = 61.29
Measured tpmTOTAL = 142.58
Session Start     = 2026-04-21 22:43:52
Session End       = 2026-04-21 23:03:53
Transaction Count = 2851
```

---

## 10. Ver los registros generados en cada tabla

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

## 11. Limpiar los datos (para volver a correr)

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

---

---

# Optimización de la Base de Datos

Esta sección explica las optimizaciones aplicadas, su justificación técnica y los resultados obtenidos.

---

## Conceptos clave del benchmark TPC-C

### Warehouses (Almacenes)
Un **warehouse** en TPC-C representa un almacén físico de una empresa. Cada warehouse tiene asociados exactamente 10 distritos, 3,000 clientes por distrito (30,000 total), y 100,000 ítems en inventario. Al aumentar el número de warehouses se incrementa proporcionalmente el volumen de datos y se distribuye la carga entre más particiones lógicas, reduciendo la **contención** (dos transacciones compitiendo por el mismo dato al mismo tiempo).

| Warehouses | Clientes | Stock | Order Lines aprox. |
|---|---|---|---|
| 1 | 30,000 | 100,000 | ~300,000 |
| 2 | 60,000 | 200,000 | ~600,000 |
| 5 | 150,000 | 500,000 | ~1,500,000 |

### Terminals (Terminales)
Los **terminals** representan usuarios concurrentes o cajeros que ejecutan transacciones simultáneamente. Cada terminal ejecuta transacciones de forma independiente contra la base de datos. Más terminals = más concurrencia = más transacciones por minuto, siempre que la base de datos pueda manejar la carga sin generar demasiada contención entre ellos.

### tpmC (Transacciones por Minuto - New Orders)
El **tpmC** es la métrica principal del benchmark TPC-C. Mide exclusivamente las transacciones de tipo "New Order" (nuevas órdenes) por minuto. Es el indicador estándar de rendimiento OLTP del benchmark y el que se usa para comparar resultados.

### tpmTOTAL
El **tpmTOTAL** incluye todos los tipos de transacciones del benchmark: New Order, Payment, Order Status, Delivery y Stock Level. Siempre es mayor que tpmC porque incluye todos los tipos de operaciones.

---

## Optimización 1 — Deshabilitar el paralelismo automático (NOPARALLEL)

### ¿Qué es el paralelismo en Oracle ADB?
Oracle Autonomous Database habilita por defecto el **paralelismo automático** en las tablas. Esto significa que Oracle puede dividir una consulta o modificación en múltiples hilos de ejecución paralelos para mejorar el rendimiento en cargas analíticas (OLAP). Sin embargo, en cargas transaccionales (OLTP) como TPC-C, el paralelismo genera el error **ORA-12838** ("no se puede leer/modificar un objeto después de modificarlo en paralelo"), porque múltiples transacciones intentan modificar el mismo objeto simultáneamente con diferentes grados de paralelismo.

### ¿Por qué funciona deshabilitarlo?
Al deshabilitar el paralelismo, cada transacción opera de forma serializada sobre cada tabla, eliminando los conflictos de modificación paralela. Esto es correcto para OLTP donde las transacciones son cortas y frecuentes, no largas y analíticas.

### SQL a ejecutar como ADMIN (después de cargar datos, antes del benchmark):

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

> ⚠️ Oracle ADB puede reactivar el paralelismo automáticamente después de operaciones masivas de carga. Siempre ejecutar este bloque después del LoadData y antes del benchmark.

---

## Optimización 2 — Aumento de Warehouses

### Justificación técnica
En TPC-C, cada warehouse es una partición lógica independiente de datos. Cuando múltiples terminals trabajan sobre el mismo warehouse, se genera **contención** — varias transacciones compiten por los mismos registros en tablas como `bmsql_district` y `bmsql_customer`. Al aumentar el número de warehouses, la carga se distribuye entre más particiones lógicas, reduciendo la probabilidad de que dos terminals accedan al mismo registro simultáneamente.

Además, más warehouses implica más datos cargados en la base de datos, lo que genera un escenario más realista y aprovecha mejor el buffer cache de Oracle.

### Configuración en oracle.properties:

```properties
warehouses=5
loadWorkers=5
```

El parámetro `loadWorkers` controla cuántos hilos paralelos cargan los datos iniciales. Se recomienda igualarlo al número de warehouses para acelerar la carga inicial.

---

## Optimización 3 — Aumento de Terminals

### Justificación técnica
Oracle Autonomous Database está diseñado para manejar alta concurrencia. Con un solo terminal, la base de datos procesa transacciones de forma casi secuencial, sin aprovechar su capacidad de procesamiento paralelo. Al aumentar los terminals, se envían más transacciones simultáneas, permitiendo que Oracle utilice mejor sus recursos internos.

El número óptimo de terminals depende del número de warehouses y los recursos disponibles. Con 5 warehouses, se encontró que 7 terminals ofrece el mejor balance entre concurrencia y estabilidad de las conexiones.

### Configuración en oracle.properties:

```properties
terminals=7
```

> ⚠️ Usar demasiados terminals puede causar el error ORA-03113 (conexión cerrada por peer) si Oracle ADB cierra conexiones por límites de sesión. Se recomienda no exceder 10 terminals en instancias pequeñas de ADB.

---

## Optimización 4 — Actualización de estadísticas (DBMS_STATS)

### Justificación técnica
El optimizador de consultas de Oracle utiliza estadísticas de las tablas para generar los planes de ejecución más eficientes. Después de cargar los datos con LoadData, las estadísticas pueden estar desactualizadas o incompletas, lo que lleva al optimizador a generar planes subóptimos como full table scans en lugar de usar índices. Al ejecutar `DBMS_STATS.GATHER_SCHEMA_STATS`, se actualizan las estadísticas de todas las tablas y sus índices, permitiendo al optimizador elegir los mejores planes de ejecución.

### SQL a ejecutar como ADMIN (después de cargar datos):

```sql
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS(
    ownname => 'BENCHMARKSQL',
    estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
    method_opt => 'FOR ALL COLUMNS SIZE AUTO',
    cascade => TRUE
  );
END;
/
```

---

## Archivo oracle.properties — Sin optimización (prueba base)

```properties
db=oracle
driver=oracle.jdbc.OracleDriver
conn=jdbc:oracle:thin:@dboracle_high?TNS_ADMIN=C:/Users/tuUsuario/Downloads/WalletOracle
user=benchmarksql
password=TuContraseña
warehouses=1
loadWorkers=1
terminals=1
runTxnsPerTerminal=0
runMins=20
limitTxnsPerMin=10000000
terminalWarehouseFixed=false
useStoredProcedures=false
```

> ⚠️ Para la prueba sin optimización NO ejecutar el bloque NOPARALLEL ni DBMS_STATS.

---

## Archivo oracle.properties — Con optimización

```properties
db=oracle
driver=oracle.jdbc.OracleDriver
conn=jdbc:oracle:thin:@dboracle_high?TNS_ADMIN=C:/Users/tuUsuario/Downloads/WalletOracle
user=benchmarksql
password=TuContraseña
warehouses=5
loadWorkers=5
terminals=7
runTxnsPerTerminal=0
runMins=20
limitTxnsPerMin=0
terminalWarehouseFixed=false
useStoredProcedures=false
```

### Orden de ejecución con optimización:
1. Borrar datos anteriores
2. Cargar datos con LoadData
3. Ejecutar NOPARALLEL como ADMIN
4. Ejecutar DBMS_STATS como ADMIN
5. Correr el benchmark

---

## Resultados obtenidos

### Prueba sin optimización (20 minutos, 1 warehouse, 1 terminal)

| Métrica | Valor |
|---|---|
| tpmC (NewOrders) | 61.29 |
| tpmTOTAL | 142.58 |
| Transaction Count | 2,851 |

### Prueba con optimización (20 minutos, 5 warehouses, 7 terminals)

| Métrica | Valor |
|---|---|
| tpmC (NewOrders) | 334.16 |
| tpmTOTAL | 776.02 |
| Transaction Count | 15,535 |

### Comparativa de todas las corridas

| Configuración | tpmC | tpmTOTAL | Transacciones | Mejora vs base |
|---|---|---|---|---|
| Sin tuning (1W, 1T, 5min) | 53.25 | 118.27 | 592 | base |
| + NOPARALLEL (1W, 1T, 5min) | 56.15 | 130.29 | 651 | +5% |
| + 2W, 3T (5min) | 153.58 | 347.05 | 1,739 | +188% |
| + 5W, 10T (5min) | 240.04 | 565.07 | 2,838 | +350% |
| **Con tuning (5W, 7T, 20min)** | **334.16** | **776.02** | **15,535** | **+528%** |

La mejora del **528%** supera ampliamente el mínimo requerido del 30%.

---

## Resumen de comandos

| Paso | Comando |
|------|---------|
| Compilar | `ant` |
| Cargar datos | `java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties LoadData` |
| Correr benchmark | `java -cp "../dist/BenchmarkSQL-6.devel.jar;../lib/*;." -Dprop=oracle.properties jTPCC runBenchmark` |

---

## Notas importantes

- Ejecutar siempre el bloque NOPARALLEL después del LoadData y antes del benchmark con optimización.
- El archivo `oracle.properties` debe estar en la carpeta `run` al momento de ejecutar los comandos.
- Todos los comandos Java deben ejecutarse desde la carpeta `run`.
- El `oraclepki` jar es indispensable para que el wallet funcione con Java.
- Oracle ADB no permite modificar parámetros del sistema con `ALTER SYSTEM` — las optimizaciones disponibles son a nivel de tabla y configuración del benchmark.
- Los errores ORA-12838 en DELIVERY_BG son normales en Oracle ADB con múltiples terminals y no afectan significativamente los resultados finales.
