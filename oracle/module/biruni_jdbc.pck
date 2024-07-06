create or replace package Biruni_Jdbc is
  ---------------------------------------------------------------------------------------------------- 
  Procedure Save_App_Server_Exception
  (
    i_Source     varchar2,
    i_Detail     varchar2,
    i_Stacktrace clob
  );
end Biruni_Jdbc;
/
create or replace package body Biruni_Jdbc is
  ---------------------------------------------------------------------------------------------------- 
  Procedure Save_App_Server_Exception
  (
    i_Source     varchar2,
    i_Detail     varchar2,
    i_Stacktrace clob
  ) is
    pragma autonomous_transaction;
    v_Log_Id number := Biruni_App_Server_Exceptions_Sq.Nextval;
  begin
    insert into Biruni_App_Server_Exceptions
      (Log_Id, Source_Class, Detail, Stacktrace, Created_On)
    values
      (v_Log_Id, i_Source, i_Detail, i_Stacktrace, sysdate);
    commit;
  exception
    when others then
      rollback;
  end;

end Biruni_Jdbc;
/
