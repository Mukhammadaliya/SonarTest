create or replace package Biruni is
  c_Version varchar2(25) := '7.14.0';
  ----------------------------------------------------------------------------------------------------
  Procedure Get_Version(o_Output out varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Get_Project_Codes(o_Output out varchar2);
end Biruni;
/
create or replace package body Biruni is
  ----------------------------------------------------------------------------------------------------
  Procedure Get_Version(o_Output out varchar2) is
  begin
    o_Output := c_Version;
  end;

  ----------------------------------------------------------------------------------------------------  
  -- Used only dev purpose
  ----------------------------------------------------------------------------------------------------
  Procedure Get_Project_Codes(o_Output out varchar2) is
    v_Project_Codes Array_Varchar2;
  begin
    execute immediate 'SELECT Dev_Core.Get_Project_Codes() FROM DUAL'
      into v_Project_Codes;
  
    o_Output := Fazo.Gather(v_Project_Codes, ';');
  exception
    when others then
      o_Output := sqlerrm;
  end;

end Biruni;
/
