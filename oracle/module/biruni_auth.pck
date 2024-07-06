create or replace package Biruni_Auth is
  ----------------------------------------------------------------------------------------------------
  Procedure Close_Session(i_Session_Val varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Oauth2_Server_Info
  (
    i_Code   in varchar2,
    o_Output out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Oauth2_Apply_Info
  (
    i_Code    varchar2,
    i_Request varchar2,
    i_Input   varchar2,
    o_Output  out varchar2
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Oauth2_Check_Request
  (
    i_Response_Type varchar2,
    i_Client_Id     varchar2,
    i_Scope         varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Generate_Oauth2_Code
  (
    i_Response_Type varchar2,
    i_Client_Id     varchar2,
    i_Credentials   varchar2,
    i_Redirect_Url  varchar2,
    i_Scope         varchar2,
    i_State         varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  );
  ---------------------------------------------------------------------------------------------------- 
  Procedure Generate_Oauth2_Access_Token
  (
    i_Grant_Type    varchar2,
    i_Auth_Code     varchar2,
    i_Client_Id     varchar2,
    i_Client_Secret varchar2,
    i_Redirect_Url  varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Generate_Api_Access_Token
  (
    i_Grant_Type    varchar2,
    i_Credentials   varchar2,
    i_Client_Id     varchar2,
    i_Client_Secret varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Refresh_Access_Token
  (
    i_Grant_Type    varchar2,
    i_Refresh_Token varchar2,
    i_Client_Id     varchar2,
    i_Client_Secret varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  );
end Biruni_Auth;
/
create or replace package body Biruni_Auth is
  ----------------------------------------------------------------------------------------------------  
  g_Auth_Setting Biruni_Auth_Settings%rowtype;
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Auth_Setting is
  begin
    g_Auth_Setting := Biruni_Core.Load_Auth_Setting;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Close_Session(i_Session_Val varchar2) is
  begin
    Biruni_Route.Context_Begin;
  
    Load_Auth_Setting;
  
    execute immediate 'BEGIN ' || g_Auth_Setting.Close_Session_Procedure || '(:session_val);END;'
      using i_Session_Val;
  
    Biruni_Route.Context_End;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Oauth2_Server_Info
  (
    i_Code   in varchar2,
    o_Output out varchar2
  ) is
    v_Sqlerrm varchar2(500 char);
    r_Server  Biruni_Oauth2_Servers%rowtype;
  begin
    r_Server := z_Biruni_Oauth2_Servers.Load(i_Code);
    o_Output := z_Biruni_Oauth2_Servers.To_Map(r_Server, z.Authorize_Url, z.Client_Id, z.Client_Secret, z.Scope).Json;
  exception
    when others then
      v_Sqlerrm := Substr(sqlerrm, 1, 500);
    
      insert into Biruni_Oauth2_Logs
        (Log_Date, Code, Error)
      values
        (sysdate, i_Code, v_Sqlerrm);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Oauth2_Apply_Info
  (
    i_Code    varchar2,
    i_Request varchar2,
    i_Input   varchar2,
    o_Output  out varchar2
  ) is
    r_Server Biruni_Oauth2_Servers%rowtype;
  
    v_Sqlerrm         varchar2(500 char);
    v_Status          varchar2(1);
    v_Redirect_Params Hashmap;
  
    result Hashmap := Hashmap();
  begin
    Biruni_Route.Context_Begin(i_Request);
  
    r_Server := z_Biruni_Oauth2_Servers.Load(i_Code);
  
    execute immediate 'begin ' || r_Server.Apply_Procedure || '(:1,:2,:3); end;'
      using i_Input, out v_Status, out v_Redirect_Params;
  
    if v_Status = Biruni_Core.c_s_Success then
      Result.Put('status', Biruni_Core.c_s_Success);
    else
      Result.Put('status', Biruni_Core.c_s_Error);
    end if;
  
    Result.Put('redirect_url',
               Biruni_Route.Request_Context_Path ||
               Biruni_Util.Prepare_Url(i_Uri    => Biruni_Pref.c_Oauth2_Redirect_Uri,
                                       i_Params => v_Redirect_Params));
    Result.Put('session', Biruni_Route.Response_Session);
  
    o_Output := Result.Json;
  
    Biruni_Route.Context_End;
    commit;
  exception
    when others then
      rollback;
      v_Sqlerrm := Substr(sqlerrm, 1, 500);
    
      insert into Biruni_Oauth2_Logs
        (Log_Date, Code, Request, Error)
      values
        (sysdate, i_Code, i_Request, v_Sqlerrm);
    
      result := Hashmap();
    
      Result.Put('status', Biruni_Core.c_s_Error);
      Result.Put('redirect_url',
                 Biruni_Route.Request_Context_Path ||
                 Biruni_Util.Prepare_Url(i_Uri    => Biruni_Pref.c_Oauth2_Redirect_Uri,
                                         i_Params => Fazo.Zip_Map('action', 'E', 'error', sqlerrm)));
    
      o_Output := Result.Json;
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
  Procedure Oauth2_Check_Request
  (
    i_Response_Type varchar2,
    i_Client_Id     varchar2,
    i_Scope         varchar2,
    o_Status        out varchar2,
    o_Error_Message out varchar2
  ) is
    v_Query varchar2(300);
  begin
    Biruni_Route.Context_Begin;
  
    Load_Auth_Setting;
  
    v_Query := 'BEGIN ' || g_Auth_Setting.Check_Oauth2_Request_Procedure ||
               '(:response_type, :client_id, :scope); END;';
  
    execute immediate v_Query
      using i_Response_Type, i_Client_Id, i_Scope;
  
    o_Status := Biruni_Core.c_s_Success;
  
    Biruni_Route.Context_End;
  exception
    when others then
      Prepare_Error(o_Status, o_Error_Message);
      Biruni_Route.Context_End;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Generate_Oauth2_Code
  (
    i_Response_Type varchar2,
    i_Client_Id     varchar2,
    i_Credentials   varchar2,
    i_Redirect_Url  varchar2,
    i_Scope         varchar2,
    i_State         varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  ) is
    v_Code  varchar2(256);
    v_Query varchar2(300);
  begin
    Biruni_Route.Context_Begin;
  
    Load_Auth_Setting;
  
    v_Query := 'BEGIN ' || g_Auth_Setting.Auth_Code_Procedure ||
               '(:response_type, :client_id, :credentials, :redirect_url, :scope, :code); END;';
  
    execute immediate v_Query
      using i_Response_Type, i_Client_Id, i_Credentials, i_Redirect_Url, i_Scope, out v_Code;
  
    o_Status := Biruni_Core.c_s_Success;
    o_Output := Fazo.Zip_Map('code', v_Code,'state', i_State).Json;
  
    Biruni_Route.Context_End;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
      Biruni_Route.Context_End;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Procedure Generate_Oauth2_Access_Token
  (
    i_Grant_Type    varchar2,
    i_Auth_Code     varchar2,
    i_Client_Id     varchar2,
    i_Client_Secret varchar2,
    i_Redirect_Url  varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  ) is
    v_Query         varchar2(300);
    v_Token_Type    varchar2(10);
    v_Access_Token  varchar2(128);
    v_Refresh_Token varchar2(128);
    v_Expires_In    number;
  begin
    Biruni_Route.Context_Begin;
  
    Load_Auth_Setting;
  
    v_Query := 'BEGIN ' || g_Auth_Setting.Oauth2_Access_Token_Procedure ||
               '(:grant_type, :code, :client_id, :client_secret, :redirect_url, 
                 :token_type, :access_token, :refresh_token, :expires_in); END;';
  
    execute immediate v_Query
      using i_Grant_Type, i_Auth_Code, i_Client_Id, i_Client_Secret, i_Redirect_Url, --
    out v_Token_Type, out v_Access_Token, out v_Refresh_Token, out v_Expires_In;
  
    o_Status := Biruni_Core.c_s_Success;
    o_Output := Fazo.Zip_Map('token_type', v_Token_Type, --,
                'access_token', v_Access_Token, --
                'refresh_token', v_Refresh_Token, --
                'expires_in', v_Expires_In).Json;
  
    Biruni_Route.Context_End;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
      Biruni_Route.Context_End;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Generate_Api_Access_Token
  (
    i_Grant_Type    varchar2,
    i_Credentials   varchar2,
    i_Client_Id     varchar2,
    i_Client_Secret varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  ) is
    v_Query         varchar2(300);
    v_Token_Type    varchar2(10);
    v_Access_Token  varchar2(128);
    v_Refresh_Token varchar2(128);
    v_Expires_In    number;
  begin
    Biruni_Route.Context_Begin;
  
    Load_Auth_Setting;
  
    v_Query := 'BEGIN ' || g_Auth_Setting.Api_Access_Token_Procedure ||
               '(:grant_type, :credentials, :client_id, :client_secret,
                 :token_type, :access_token, :refresh_token, :expires_in); END;';
  
    execute immediate v_Query
      using i_Grant_Type, i_Credentials, i_Client_Id, i_Client_Secret, --
    out v_Token_Type, out v_Access_Token, out v_Refresh_Token, out v_Expires_In;
  
    o_Status := Biruni_Core.c_s_Success;
    o_Output := Fazo.Zip_Map('token_type', v_Token_Type, --,
                'access_token', v_Access_Token, --
                'refresh_token', v_Refresh_Token, --
                'expires_in', v_Expires_In).Json;
  
    Biruni_Route.Context_End;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
      Biruni_Route. Context_End;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Refresh_Access_Token
  (
    i_Grant_Type    varchar2,
    i_Refresh_Token varchar2,
    i_Client_Id     varchar2,
    i_Client_Secret varchar2,
    o_Status        out varchar2,
    o_Output        out varchar2
  ) is
    v_Query         varchar2(300);
    v_Token_Type    varchar2(10);
    v_Access_Token  varchar2(128);
    v_Refresh_Token varchar2(128);
    v_Expires_In    number;
  begin
    Biruni_Route. Context_Begin;
  
    Load_Auth_Setting;
  
    v_Query := 'BEGIN ' || g_Auth_Setting.Refresh_Token_Procedure ||
               '(:grant_type, :old_refresh_token, :client_id, :client_secret,
                :token_type, :access_token, :refresh_token, :expires_in); END;';
  
    execute immediate v_Query
      using i_Grant_Type, i_Refresh_Token, i_Client_Id, i_Client_Secret, --
    out v_Token_Type, out v_Access_Token, out v_Refresh_Token, out v_Expires_In;
  
    o_Status := Biruni_Core.c_s_Success;
    o_Output := Fazo.Zip_Map('token_type', v_Token_Type, --,
                'access_token', v_Access_Token, --
                'refresh_token', v_Refresh_Token, --
                'expires_in', v_Expires_In).Json;
  
    Biruni_Route. Context_End;
  exception
    when others then
      Prepare_Error(o_Status, o_Output);
      Biruni_Route.Context_End;
  end;

end Biruni_Auth;
/
