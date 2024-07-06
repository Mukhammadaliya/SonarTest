create or replace package b_Session is
  ----------------------------------------------------------------------------------------------------
  Function Context_Id return number;
  ----------------------------------------------------------------------------------------------------
  Function Get_Default_Lang_Code return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Get_Lang_Code return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Code(i_Lang_Code varchar2);
  ----------------------------------------------------------------------------------------------------
  Function Get_Custom_Translate_Code return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Custom_Translate_Code(i_Code varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Error_With_Backtrace(i_Val boolean);
  ----------------------------------------------------------------------------------------------------
  Procedure Log_Me;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Uri return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Allowed_Auth_Types return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Scope return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Session return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Token return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Method return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Url return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Server_Url return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Context_Path return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Ip_Address return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Host_Name return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Host_User return varchar2;
  ----------------------------------------------------------------------------------------------------  
  Procedure Request_User_Agent
  (
    o_User_Agent out varchar2,
    o_Os         out varchar2,
    o_Device     out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Request_Header(i_Key varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Cookie(i_Key varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Response_Session return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Session(i_Session varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Header
  (
    i_Key   varchar2,
    i_Value varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Cookie
  (
    i_Key     varchar2,
    i_Value   varchar2,
    i_Path    varchar2,
    i_Max_Age number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Response_Content_Type(i_Value varchar2);
  ----------------------------------------------------------------------------------------------------
  Function Is_Session_Authorization return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Is_Token_Authorization return boolean;
  ----------------------------------------------------------------------------------------------------  
  Function Is_Bearer_Authorization return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Get_Bearer_Token return varchar2;
  ----------------------------------------------------------------------------------------------------  
  Function Is_Basic_Authorization return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Get_Basic_Credentials return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Get_Authorization_Type return varchar2;
end b_Session;
/
create or replace package body b_Session is
  ----------------------------------------------------------------------------------------------------
  Function Context_Id return number is
  begin
    return Biruni_Route.Context_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Default_Lang_Code return varchar2 is
  begin
    return Biruni_Route.Get_Default_Lang_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Lang_Code return varchar2 is
  begin
    return Biruni_Route.Get_Lang_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Code(i_Lang_Code varchar2) is
  begin
    Biruni_Route.Set_Lang_Code(i_Lang_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Custom_Translate_Code return varchar2 is
  begin
    return Biruni_Route.Get_Custom_Translate_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Custom_Translate_Code(i_Code varchar2) is
  begin
    Biruni_Route.Set_Custom_Translate_Code(i_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Error_With_Backtrace(i_Val boolean) is
  begin
    Biruni_Route.Set_Error_With_Backtrace(i_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Log_Me is
  begin
    Biruni_Route.Log_Me;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Uri return varchar2 is
  begin
    return Biruni_Route.Request_Route_Uri;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Allowed_Auth_Types return varchar2 is
  begin
    return Biruni_Route.Request_Route_Allowed_Auth_Types;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Scope return varchar2 is
  begin
    return Biruni_Route.Request_Route_Scope;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Session return varchar2 is
  begin
    return Biruni_Route.Request_Session;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Token return varchar2 is
  begin
    return Request_Header('token');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Method return varchar2 is
  begin
    return Biruni_Route.Request_Method;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Url return varchar2 is
  begin
    return Biruni_Route.Request_Url;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Server_Url return varchar2 is
  begin
    return Biruni_Route.Request_Server_Url;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Context_Path return varchar2 is
  begin
    return Biruni_Route.Request_Context_Path;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Ip_Address return varchar2 is
  begin
    return Biruni_Route.Request_Ip_Address;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Host_Name return varchar2 is
  begin
    return Biruni_Route.Request_Host_Name;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Host_User return varchar2 is
  begin
    return Biruni_Route.Request_Host_User;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Request_User_Agent
  (
    o_User_Agent out varchar2,
    o_Os         out varchar2,
    o_Device     out varchar2
  ) is
    v_Agent Hashmap := Biruni_Route.Request_User_Agent;
  begin
    if v_Agent is null then
      return;
    end if;
  
    o_User_Agent := v_Agent.o_Varchar2('user_agent');
    o_Os         := v_Agent.o_Varchar2('os');
    o_Device     := v_Agent.o_Varchar2('device');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Header(i_Key varchar2) return varchar2 is
  begin
    return Biruni_Route.Request_Header(i_Key);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Cookie(i_Key varchar2) return varchar2 is
  begin
    return Biruni_Route.Request_Cookie(i_Key);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Response_Session return varchar2 is
  begin
    return Biruni_Route.Response_Session;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Session(i_Session varchar2) is
  begin
    Biruni_Route.Response_Set_Session(i_Session);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Header
  (
    i_Key   varchar2,
    i_Value varchar2
  ) is
  begin
    Biruni_Route.Response_Set_Header(i_Key, i_Value);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Cookie
  (
    i_Key     varchar2,
    i_Value   varchar2,
    i_Path    varchar2,
    i_Max_Age number
  ) is
  begin
    Biruni_Route.Response_Set_Cookie(i_Key     => i_Key,
                                     i_Value   => i_Value,
                                     i_Path    => i_Path,
                                     i_Max_Age => i_Max_Age);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Response_Content_Type(i_Value varchar2) is
  begin
    Biruni_Route.Response_Set_Header(Biruni_Pref.c_Content_Type, i_Value);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Session_Authorization return boolean is
  begin
    return Request_Session is not null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Token_Authorization return boolean is
  begin
    return Request_Token is not null;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Is_Bearer_Authorization return boolean is
    v_Authorization Hashmap := Biruni_Route.Request_Authorization;
  begin
    return Fazo.Equal(v_Authorization.o_Varchar2('type'), 'Bearer');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Bearer_Token return varchar2 is
    v_Authorization Hashmap := Biruni_Route.Request_Authorization;
  begin
    return v_Authorization.o_Varchar2('token');
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Is_Basic_Authorization return boolean is
    v_Authorization Hashmap := Biruni_Route.Request_Authorization;
  begin
    return Fazo.Equal(v_Authorization.o_Varchar2('type'), 'Basic');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Basic_Credentials return varchar2 is
    v_Authorization Hashmap := Biruni_Route.Request_Authorization;
  begin
    return v_Authorization.o_Varchar2('credentials');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Authorization_Type return varchar2 is
  begin
    if Is_Session_Authorization then
      return Biruni_Pref.c_Route_Auth_Type_Session;
    elsif Is_Token_Authorization then
      return Biruni_Pref.c_Route_Auth_Type_Token;
    elsif Is_Bearer_Authorization then
      return Biruni_Pref.c_Route_Auth_Type_Bearer;
    elsif Is_Basic_Authorization then
      return Biruni_Pref.c_Route_Auth_Type_Basic;
    else
      return null;
    end if;
  end;

end b_Session;
/
