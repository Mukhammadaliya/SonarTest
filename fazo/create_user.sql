set define off;
declare
  v number;
begin
  select 1
    into v
    from All_Users t
   where t.Username = 'FAZO_SCHEMA';
exception
  when No_Data_Found then
    execute immediate 'create user fazo_schema identified by "' || Dbms_Random.String('A', 20) || '"';
end;
/
grant execute on sys.dbms_crypto to public;
