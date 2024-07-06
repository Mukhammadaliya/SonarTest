create or replace package Biruni_Qlik is
  ---------------------------------------------------------------------------------------------------- 
  Procedure Open_Qlik_Session
  (
    i_Session_Uuid  varchar2,
    i_Session_Val   varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Validate_Qlik_Session
  (
    i_Session_Uuid  varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Close_Qlik_Session
  (
    i_Session_Uuid  varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Check_Qlik_Session
  (
    i_Session_Uuid varchar2,
    i_Session_Val  varchar2,
    o_Status       out varchar2,
    o_Output       out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Qlik_Settings
  (
    o_Status out varchar2,
    o_Output out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Qlik_Data
  (
    i_Session_Val  varchar2,
    i_Project_Code varchar2,
    i_Filial_Id    number,
    o_Status       out varchar2,
    o_Output       out varchar2
  );
end Biruni_Qlik;
/
create or replace package body Biruni_Qlik is
  ----------------------------------------------------------------------------------------------------
  Function Nvl_Qlik_Settings(i_Settings Biruni_Qlik_Settings%rowtype)
    return Biruni_Qlik_Settings%rowtype is
    r Biruni_Qlik_Settings%rowtype := i_Settings;
  begin
    r.Open_Session_Procedure     := Nvl(r.Open_Session_Procedure, 'b.Not_Implemented');
    r.Validate_Session_Procedure := Nvl(r.Validate_Session_Procedure, 'b.Not_Implemented');
    r.Close_Session_Procedure    := Nvl(r.Close_Session_Procedure, 'b.Not_Implemented');
    r.Check_Session_Procedure    := Nvl(r.Check_Session_Procedure, 'b.Not_Implemented');
    r.Load_Settings_Procedure    := Nvl(r.Load_Settings_Procedure, 'b.Not_Implemented');
    r.Load_Data_Procedure        := Nvl(r.Load_Data_Procedure, 'b.Not_Implemented');
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Qlik_Settings return Biruni_Qlik_Settings%rowtype Result_Cache is
  begin
    return Nvl_Qlik_Settings(z_Biruni_Qlik_Settings.Take('U'));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Prepare_Error
  (
    o_Status  out varchar2,
    o_Message out varchar2
  ) is
  begin
    o_Status  := Biruni_Core.c_s_Error;
    o_Message := Regexp_Replace(Dbms_Utility.Format_Error_Stack,
                                'ORA-\d+:\s(line\s\d+,\scolumn\s\d+:\s)?(.+?)(ORA-\d+:.*)',
                                '\2',
                                1,
                                1,
                                'n');
  end;

  ---------------------------------------------------------------------------------------------------- 
  Procedure Open_Qlik_Session
  (
    i_Session_Uuid  varchar2,
    i_Session_Val   varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  ) is
    v_Query         varchar2(300);
    r_Qlik_Settings Biruni_Qlik_Settings%rowtype := Load_Qlik_Settings;
  begin
    v_Query := 'BEGIN ' || r_Qlik_Settings.Open_Session_Procedure ||
               '(:session_uuid, :session_val); END;';
  
    execute immediate v_Query
      using i_Session_Uuid, i_Session_Val;
  
    o_Status := Biruni_Core.c_s_Success;
  exception
    when others then
      Prepare_Error(o_Status, o_Error_Message);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Validate_Qlik_Session
  (
    i_Session_Uuid  varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  ) is
    v_Query         varchar2(300);
    r_Qlik_Settings Biruni_Qlik_Settings%rowtype := Load_Qlik_Settings;
  begin
    v_Query := 'BEGIN ' || r_Qlik_Settings.Validate_Session_Procedure || '(:session_uuid); END;';
  
    execute immediate v_Query
      using i_Session_Uuid;
  
    o_Status := Biruni_Core.c_s_Success;
  exception
    when others then
      Prepare_Error(o_Status, o_Error_Message);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Close_Qlik_Session
  (
    i_Session_Uuid  varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  ) is
    v_Query         varchar2(300);
    r_Qlik_Settings Biruni_Qlik_Settings%rowtype := Load_Qlik_Settings;
  begin
    v_Query := 'BEGIN ' || r_Qlik_Settings.Close_Session_Procedure || '(:session_uuid); END;';
  
    execute immediate v_Query
      using i_Session_Uuid;
  
    o_Status := Biruni_Core.c_s_Success;
  exception
    when others then
      Prepare_Error(o_Status, o_Error_Message);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Check_Qlik_Session
  (
    i_Session_Uuid varchar2,
    i_Session_Val  varchar2,
    o_Status       out varchar2,
    o_Output       out varchar2
  ) is
    v_Query         varchar2(300);
    r_Qlik_Settings Biruni_Qlik_Settings%rowtype := Load_Qlik_Settings;
  begin
    v_Query := 'BEGIN ' || r_Qlik_Settings.Check_Session_Procedure ||
               '(:session_uuid, :session_val, :is_active_session); END;';
  
    execute immediate v_Query
      using i_Session_Uuid, i_Session_Val, --
    out o_Output;
  
    o_Status := Biruni_Core.c_s_Success;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Load_Qlik_Settings
  (
    o_Status out varchar2,
    o_Output out varchar2
  ) is
    v_Query         varchar2(300);
    v_Settings      Hashmap;
    r_Qlik_Settings Biruni_Qlik_Settings%rowtype := Load_Qlik_Settings;
  begin
    v_Query := 'BEGIN ' || r_Qlik_Settings.Load_Settings_Procedure || '(:settings); END;';
  
    execute immediate v_Query
      using out v_Settings;
  
    o_Status := Biruni_Core.c_s_Success;
    o_Output := v_Settings.Json;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Load_Qlik_Data
  (
    i_Session_Val  varchar2,
    i_Project_Code varchar2,
    i_Filial_Id    number,
    o_Status       out varchar2,
    o_Output       out varchar2
  ) is
    v_Query         varchar2(300);
    v_Data          Hashmap;
    r_Qlik_Settings Biruni_Qlik_Settings%rowtype := Load_Qlik_Settings;
  begin
    v_Query := 'BEGIN ' || r_Qlik_Settings.Load_Data_Procedure ||
               '(:session_val, :project_code, :filial_id, :data); END;';
  
    execute immediate v_Query
      using i_Session_Val, i_Project_Code, i_Filial_Id, out v_Data;
  
    o_Status := Biruni_Core.c_s_Success;
    o_Output := v_Data.Json;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
  end;

end Biruni_Qlik;
/
