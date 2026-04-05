CREATE TABLE salon (
  id_salon NUMBER PRIMARY KEY,
  nombre VARCHAR2(20),
  capacidad NUMBER
);

CREATE TABLE estudiante (
  id_estudiante NUMBER PRIMARY KEY,
  nombre VARCHAR2(50),
  correo VARCHAR2(100)
);

CREATE TABLE materia (
  id_materia NUMBER PRIMARY KEY,
  nombre VARCHAR2(50),
  id_salon NUMBER,
  CONSTRAINT fk_materia_salon
    FOREIGN KEY (id_salon) REFERENCES salon(id_salon)
);

CREATE TABLE inscripcion (
  id_estudiante NUMBER,
  id_materia NUMBER,
  fecha DATE,
  CONSTRAINT pk_inscripcion PRIMARY KEY (id_estudiante, id_materia),
  CONSTRAINT fk_ins_est FOREIGN KEY (id_estudiante)
    REFERENCES estudiante(id_estudiante),
  CONSTRAINT fk_ins_mat FOREIGN KEY (id_materia)
    REFERENCES materia(id_materia)
);

INSERT INTO salon VALUES (1, 'A101', 30);
INSERT INTO salon VALUES (2, 'B202', 40);
INSERT INTO salon VALUES (3, 'C303', 35);
INSERT INTO salon VALUES (4, 'D404', 25);
INSERT INTO salon VALUES (5, 'E505', 45);
INSERT INTO salon VALUES (6, 'F606', 50);
INSERT INTO salon VALUES (7, 'G707', 20);
INSERT INTO salon VALUES (8, 'H808', 60);
INSERT INTO salon VALUES (9, 'I909', 30);
INSERT INTO salon VALUES (10, 'J010', 40);

INSERT INTO estudiante VALUES (1, 'Juan Gómez', 'juan@mail.com');
INSERT INTO estudiante VALUES (2, 'Mariana Pérez', 'mariana@mail.com');
INSERT INTO estudiante VALUES (3, 'Valentina Gutiérrez', 'valentina@mail.com');
INSERT INTO estudiante VALUES (4, 'Carlos Rodríguez', 'carlos@mail.com');
INSERT INTO estudiante VALUES (5, 'Laura Martínez', 'laura@mail.com');
INSERT INTO estudiante VALUES (6, 'Andrés López', 'andres@mail.com');
INSERT INTO estudiante VALUES (7, 'Sofía Ramírez', 'sofia@mail.com');
INSERT INTO estudiante VALUES (8, 'Daniel Torres', 'daniel@mail.com');
INSERT INTO estudiante VALUES (9, 'Camila Vargas', 'camila@mail.com');
INSERT INTO estudiante VALUES (10, 'Mateo Herrera', 'mateo@mail.com');

INSERT INTO materia VALUES (1, 'Bases de Datos', 1);
INSERT INTO materia VALUES (2, 'Programación', 2);
INSERT INTO materia VALUES (3, 'Inteligencia Artificial', 3);
INSERT INTO materia VALUES (4, 'Estructuras de Datos', 4);
INSERT INTO materia VALUES (5, 'Sistemas Operativos', 5);
INSERT INTO materia VALUES (6, 'Redes de Computadores', 6);
INSERT INTO materia VALUES (7, 'Ingeniería de Software', 7);
INSERT INTO materia VALUES (8, 'Arquitectura de Computadores', 8);
INSERT INTO materia VALUES (9, 'Seguridad Informática', 9);
INSERT INTO materia VALUES (10, 'Análisis de Algoritmos', 10);

INSERT INTO inscripcion VALUES (1, 1, SYSDATE);
INSERT INTO inscripcion VALUES (2, 2, SYSDATE);
INSERT INTO inscripcion VALUES (3, 3, SYSDATE);
INSERT INTO inscripcion VALUES (4, 4, SYSDATE);
INSERT INTO inscripcion VALUES (5, 5, SYSDATE);
INSERT INTO inscripcion VALUES (6, 6, SYSDATE);
INSERT INTO inscripcion VALUES (7, 7, SYSDATE);
INSERT INTO inscripcion VALUES (8, 8, SYSDATE);
INSERT INTO inscripcion VALUES (9, 9, SYSDATE);
INSERT INTO inscripcion VALUES (10, 10, SYSDATE);

CREATE USER benchmarksql
        IDENTIFIED BY "Bmsql123456#"
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


DROP TABLE bmsql_history;
DROP TABLE bmsql_customer;
DROP TABLE bmsql_district;
DROP TABLE bmsql_warehouse;
DROP TABLE bmsql_config;
DROP SEQUENCE bmsql_hist_id_seq;

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

insert into bmsql_config (cfg_name, cfg_value) values ('warehouses', '1');
insert into bmsql_config (cfg_name, cfg_value) values ('loadWorkers', '2');
commit;

insert into bmsql_config (cfg_name, cfg_value) values ('nURandCLast', '179');
insert into bmsql_config (cfg_name, cfg_value) values ('nURandCC_ID', '986');
insert into bmsql_config (cfg_name, cfg_value) values ('nURandCI_ID', '5765');
commit;

DELETE FROM bmsql_config;
DELETE FROM bmsql_item;
DELETE FROM bmsql_stock;
DELETE FROM bmsql_order_line;
DELETE FROM bmsql_oorder;
DELETE FROM bmsql_new_order;
DELETE FROM bmsql_history;
DELETE FROM bmsql_customer;
DELETE FROM bmsql_district;
DELETE FROM bmsql_warehouse;
COMMIT;

alter table bmsql_warehouse add constraint bmsql_warehouse_pkey primary key (w_id);
alter table bmsql_district add constraint bmsql_district_pkey primary key (d_w_id, d_id);
alter table bmsql_customer add constraint bmsql_customer_pkey primary key (c_w_id, c_d_id, c_id);
alter table bmsql_oorder add constraint bmsql_oorder_pkey primary key (o_w_id, o_d_id, o_id);
alter table bmsql_new_order add constraint bmsql_new_order_pkey primary key (no_w_id, no_d_id, no_o_id);
alter table bmsql_order_line add constraint bmsql_order_line_pkey primary key (ol_w_id, ol_d_id, ol_o_id, ol_number);
alter table bmsql_stock add constraint bmsql_stock_pkey primary key (s_w_id, s_i_id);
alter table bmsql_item add constraint bmsql_item_pkey primary key (i_id);

select concat('select count(1) from ', table_name) from user_tables;

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