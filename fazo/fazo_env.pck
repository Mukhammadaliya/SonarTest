create or replace package Fazo_Schema.Fazo_Env authid current_user is
  ----------------------------------------------------------------------------------------------------
  Procedure Set_User_Id(i_User_Id number);
  ----------------------------------------------------------------------------------------------------
  Function Get_User_Id return number;
end Fazo_Env;
/
create or replace package body Fazo_Schema.Fazo_Env is
  ----------------------------------------------------------------------------------------------------
  g_User_Id number;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_User_Id(i_User_Id number) is
  begin
    g_User_Id := i_User_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_User_Id return number is
  begin
    return g_User_Id;
  end;

end Fazo_Env;
/
