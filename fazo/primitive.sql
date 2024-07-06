create or replace type fazo_schema.array_varchar2 force is table of varchar2(32767)
/
create or replace type fazo_schema.array_number force is table of number;
/
create or replace type fazo_schema.array_date force is table of date;
/
create or replace type fazo_schema.array_timestamp force is table of timestamp;
/
create or replace type fazo_schema.matrix_varchar2 force is table of fazo_schema.array_varchar2 not null;
/
create or replace type fazo_schema.matrix_number force is table of fazo_schema.array_number not null;
/
create or replace type fazo_schema.matrix_date force is table of fazo_schema.array_date not null;
/
create or replace type fazo_schema.matrix_timestamp force is table of fazo_schema.array_timestamp not null;
/
