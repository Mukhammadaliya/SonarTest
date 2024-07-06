create or replace package Biruni_Route is
  ----------------------------------------------------------------------------------------------------
  Procedure Clear_Globals;
  ----------------------------------------------------------------------------------------------------
  Function Context_Id return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Context_Begin(i_Request varchar2 := null);
  ----------------------------------------------------------------------------------------------------
  Procedure Run_Post_Callback;
  ----------------------------------------------------------------------------------------------------
  Procedure Context_End;
  ----------------------------------------------------------------------------------------------------
  Procedure Context_Set_Timezone(i_Timezone_Code varchar2 := null);
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Route
  (
    i_Request  varchar2,
    i_Input    Array_Varchar2,
    o_Response out Array_Varchar2,
    o_Output   out Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Runtime_Route
  (
    i_Review_Data varchar2,
    i_Input       Array_Varchar2,
    o_Response    out Array_Varchar2,
    o_Output      out Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Runtime_Route_Fail
  (
    i_Review_Data varchar2,
    i_Error       varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Lazy_Report
  (
    i_Register_Id number,
    o_Status      out varchar2,
    o_Report_Type out varchar2,
    o_Metadata    out clob
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Lazy_Report_File
  (
    i_Register_Id  number,
    i_Sha          varchar2,
    i_File_Size    number,
    i_Store_Kind   varchar2,
    i_File_Name    varchar2,
    i_Content_Type varchar2,
    o_Error        out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Update_Lazy_Report_Info
  (
    i_Register_Id     number,
    i_Status          varchar2,
    i_File_Sha        varchar2,
    i_Html_Sha        varchar2,
    i_Error_Message   varchar2,
    i_Error_Backtrace varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Error_With_Backtrace(i_Val boolean);
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
  Procedure Set_Report_Line_Count
  (
    i_Count number,
    i_Raw   boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Report_Redirect(i_Redirect Hashmap);
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Easy_Report(i_Easy_Report_Data Json_Object_t);
  ----------------------------------------------------------------------------------------------------
  Procedure Set_External_Service(i_External_Service_Data Json_Object_t);
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Onlyoffice(i_Onlyoffice_Data Json_Object_t);
  ----------------------------------------------------------------------------------------------------
  Procedure Log_Me;
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Post_Callback(i_Callback_Block varchar2);
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Uri return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Allowed_Auth_Types return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Scope return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Action_In return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Action_Out return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Session return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Method return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Url return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Server_Url return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Authorization return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Request_Context_Path return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Ip_Address return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Host_Name return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Host_User return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_User_Agent return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Request_Header(i_Key varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_Cookie(i_Key varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Request_File_Shas return Array_Varchar2;
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
  Function Runtime_Response_Action_In return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Runtime_Response_Action_Out return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Upload_Easy_Report_Metadata
  (
    i_Sha         varchar2,
    i_Metadata    Array_Varchar2,
    i_Definition  Array_Varchar2,
    i_Version     varchar2,
    i_Photo_Infos Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Clear_Easy_Report_Template(i_Sha varchar2);
end Biruni_Route;
/
create or replace package body Biruni_Route is
  ----------------------------------------------------------------------------------------------------
  g_Setting        Biruni_Settings%rowtype;
  g_Post_Callbacks Array_Varchar2;
  g_Request        Hashmap;
  g_Route          Biruni_Routes%rowtype;
  g_Log_Me         boolean;
  g_Context_Id     number;
  ----------------------------------------------------------------------------------------------------
  g_Response_Session      varchar2(4000);
  g_Response_Headers      Fazo.Varchar2_Code_Aat;
  g_Response_Cookies      Hashmap;
  g_With_Backtrace        boolean;
  g_Lang_Code             varchar2(5);
  g_Custom_Translate_Code varchar2(200);
  g_Report_Line_Count     number;
  g_Report_Raw_Line       boolean;
  g_Report_Redirect       Hashmap;
  g_Easy_Report_Data      Json_Object_t;
  g_External_Service_Data Json_Object_t;
  g_Onlyoffice_Data       Json_Object_t;
  ----------------------------------------------------------------------------------------------------
  g_Status                     varchar2(1);
  g_Error_Log                  varchar2(4000);
  g_Error_Result               varchar2(4000);
  g_Runtime_Service            Runtime_Service;
  g_Runtime_Review_Procedure   varchar2(120);
  g_Runtime_Response_Procedure varchar2(120);
  g_Runtime_Action_In          varchar2(1);
  g_Runtime_Action_Out         varchar2(1);
  ----------------------------------------------------------------------------------------------------
  Procedure Clear_Globals is
    v_Null Fazo.Varchar2_Code_Aat;
  begin
    g_Setting        := null;
    g_Post_Callbacks := null;
    g_Request        := null;
    g_Route          := null;
    g_Log_Me         := null;
    g_Context_Id     := null;
  
    g_Response_Session      := null;
    g_Response_Headers      := v_Null;
    g_Response_Cookies      := null;
    g_With_Backtrace        := null;
    g_Lang_Code             := null;
    g_Custom_Translate_Code := null;
    g_Report_Line_Count     := null;
    g_Report_Raw_Line       := null;
    g_Report_Redirect       := null;
    g_Easy_Report_Data      := null;
    g_External_Service_Data := null;
    g_Onlyoffice_Data       := null;
  
    g_Status                     := null;
    g_Error_Log                  := null;
    g_Error_Result               := null;
    g_Runtime_Service            := null;
    g_Runtime_Review_Procedure   := null;
    g_Runtime_Response_Procedure := null;
    g_Runtime_Action_In          := null;
    g_Runtime_Action_Out         := null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Context_Id return number is
  begin
    if g_Context_Id is null then
      g_Context_Id := Biruni_Context_Sq.Nextval;
    end if;
    return g_Context_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Context_Begin(i_Request varchar2 := null) is
  begin
    Clear_Globals;
  
    g_Setting        := Biruni_Core.Load_Setting;
    g_Lang_Code      := g_Setting.Lang_Code;
    g_Post_Callbacks := Array_Varchar2();
  
    g_Request := Fazo.Parse_Map(i_Request);
    if g_Request is null then
      g_Request := Hashmap();
    end if;
    g_Route := z_Biruni_Routes.Take(g_Request.o_Varchar2('uri'));
  
    g_Route.Log_Policy     := Nvl(g_Route.Log_Policy, g_Setting.Log_Policy);
    g_Route.Log_Time_Limit := Nvl(g_Route.Log_Time_Limit, g_Setting.Log_Time_Limit);
  
    g_Response_Session := g_Request.o_Varchar2('session');
  
    insert into Biruni_Anti_Commit
      (Dummy)
    values
      ('A');
  
    Context_Set_Timezone;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Post_Callback is
    v_Post_Callbacks Array_Varchar2 := g_Post_Callbacks;
  begin
    g_Post_Callbacks := Array_Varchar2();
  
    for i in 1 .. v_Post_Callbacks.Count
    loop
      execute immediate v_Post_Callbacks(i);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Context_End is
  begin
    Run_Post_Callback;
    g_Post_Callbacks := null; -- for checking recursive calling
  
    delete Biruni_Anti_Commit
     where Dummy = 'A';
    if sql%notfound then
      Raise_Application_Error(-20999, 'Do not use "rollback"');
    end if;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Context_Set_Timezone(i_Timezone_Code varchar2 := null) is
    v_Timezone_Code varchar2(64) := Nvl(i_Timezone_Code, g_Setting.Timezone_Code);
    v_Apostrophe    varchar2(1) := '''';
  begin
    if v_Timezone_Code is not null then
      if v_Timezone_Code in ('local', 'dbtimezone') then
        v_Apostrophe := '';
      end if;
    
      execute immediate 'alter session set TIME_ZONE=' || v_Apostrophe ||
                        replace(v_Timezone_Code, '''', '''''') || v_Apostrophe;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Failure(i_Status varchar2) is
  begin
    g_Status := i_Status;
  
    if sqlcode <> 0 then
      g_Error_Log := Dbms_Utility.Format_Error_Stack || Chr(13) ||
                     Dbms_Utility.Format_Error_Backtrace;
    end if;
  
    case
      when g_Status = Biruni_Core.c_s_Success then
        g_Error_Result := '';
      
      when g_Status = Biruni_Core.c_s_Unauthenticated and sqlcode <> -20000 then
        g_Error_Result := 'ROUTE: Unauthenticated';
      
      when g_Status = Biruni_Core.c_s_Payment_Required and sqlcode <> -20000 then
        g_Error_Result := 'ROUTE: Payment Required';
      
      when g_Status = Biruni_Core.c_s_Refused and sqlcode <> -20000 then
        g_Error_Result := 'ROUTE: Refused';
      
      when g_Status = Biruni_Core.c_s_Not_Found and sqlcode <> -20000 then
        g_Error_Result := 'ROUTE: Not found';
      
      when g_Status = Biruni_Core.c_s_Conflicts and sqlcode <> -20000 then
        g_Error_Result := 'ROUTE: Conflicts';
      
      when g_Status = Biruni_Core.c_s_Too_Many_Requests and sqlcode <> -20000 then
        g_Error_Result := 'ROUTE: Too Many Requests';
      
      else
        g_Error_Result := Dbms_Utility.Format_Error_Stack;
      
        if g_Error_Result like '%BIRUNI_ANTI_COMMIT%' then
          g_Error_Result := 'Do not use "commit"';
        else
          g_Error_Result := Regexp_Replace(g_Error_Result,
                                           'ORA-\d+:\s(line\s\d+,\scolumn\s\d+:\s)?(.+?)(ORA-\d+:.*)',
                                           '\2',
                                           1,
                                           1,
                                           'n');
        end if;
      
        if g_With_Backtrace then
          g_Error_Result := g_Error_Result || Chr(13) || '<pre>' ||
                            Substrb(Dbms_Utility.Format_Error_Backtrace, 1, 3000) || '</pre>';
        end if;
      
    end case;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Prepare_Runtime_Response(p_Output in out nocopy Array_Varchar2) is
  begin
    if g_Runtime_Service is not null then
      g_Runtime_Review_Procedure := g_Runtime_Service.Review_Procedure;
    
      g_Runtime_Response_Procedure := Nvl(g_Runtime_Service.Response_Procedure,
                                          Nvl(g_Runtime_Response_Procedure, g_Route.Action_Name) ||
                                          '_response');
    
      if g_Runtime_Response_Procedure = g_Route.Action_Name or
         g_Runtime_Review_Procedure = g_Route.Action_Name then
        Raise_Application_Error(-20000,
                                'Runtime service has cycle, check its response or review procedure');
      end if;
    
      g_Runtime_Action_In  := g_Runtime_Service.Action_In;
      g_Runtime_Action_Out := g_Runtime_Service.Action_Out;
    else
      Context_End;
    end if;
  
    p_Output := g_Runtime_Service.Data;
  
    if p_Output is null then
      p_Output := Array_Varchar2();
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Prepare_Response
  (
    p_Response in out nocopy Array_Varchar2,
    p_Output   in out nocopy Array_Varchar2
  ) is
    v_Res            Hashmap := Hashmap;
    v_Final_Services Arraylist;
  begin
    v_Res.Put('status', g_Status);
  
    if not g_Status = Biruni_Core.c_s_Success then
      -- retry after header can be added when too many requests error trown
      if g_Response_Headers.Exists('retry-after') then
        v_Res.Put('header',
                  Fazo.Zip_Map('content-type',
                               'text/plain;charset=UTF-8',
                               'retry-after',
                               g_Response_Headers('retry-after')));
      else
        v_Res.Put('header', Fazo.Zip_Map('content-type', 'text/plain;charset=UTF-8'));
      end if;
    
      if g_Route.Access_Type = 'E' then
        v_Res.Put('session', '');
      end if;
    
      p_Response := Fazo.To_Json(v_Res).Val;
      p_Output   := Array_Varchar2(g_Error_Result);
      return;
    end if;
  
    if g_Runtime_Service is not null then
      v_Res.Put('runtime_service', 'Y');
      v_Res.Put('class_name', g_Runtime_Service.Class_Name);
      v_Res.Put('detail', g_Runtime_Service.Detail);
    
      p_Response := Fazo.To_Json(v_Res).Val;
      return;
    end if;
  
    v_Res.Put('header',
              Fazo_Schema.Gws_Json_Value(Array_Varchar2(Biruni_Core.To_Json(g_Response_Headers))));
  
    if g_Response_Cookies is not null then
      v_Res.Put('cookie', g_Response_Cookies);
    end if;
  
    if g_Route.Access_Type = 'E' then
      v_Res.Put('session', g_Response_Session);
    end if;
  
    if g_Route.Action_Out = 'F' then
      v_Res.Put('action', 'file');
    
    elsif g_Route.Action_Out in ('LR', 'LC') then
      v_Res.Put('action', 'lazy_report');
    
    elsif g_Report_Redirect is not null then
      p_Output := Array_Varchar2(g_Report_Redirect.Json);
      v_Res.Put('action', 'redirect');
    
    elsif g_Easy_Report_Data is not null then
      p_Output := Fazo.Read_Clob(g_Easy_Report_Data.To_Clob);
      v_Res.Put('action', 'easy_report');
    
    elsif g_External_Service_Data is not null then
      p_Output := Fazo.Read_Clob(i_Clob => g_External_Service_Data.To_Clob);
      v_Res.Put('action', 'external_service');
    
    elsif g_Onlyoffice_Data is not null then
      p_Output := Fazo.Read_Clob(g_Onlyoffice_Data.To_Clob);
      v_Res.Put('action', 'onlyoffice');
    
    elsif g_Report_Line_Count > 0 then
      if not Nvl(g_Report_Raw_Line, false) then
        v_Res.Put('action', 'report');
      end if;
    
      if g_Report_Line_Count < 200 then
        select Line
          bulk collect
          into p_Output
          from Biruni_Report_Lines
         order by Table_Id, Order_No;
      else
        v_Res.Put('fetch_output', 'Y');
      end if;
    end if;
  
    v_Final_Services := Biruni_Service.Get_Final_Services();
  
    if v_Final_Services is not null then
      v_Res.Put('final_services', v_Final_Services);
    end if;
  
    p_Response := Fazo.To_Json(v_Res).Val;
  end;

  ----------------------------------------------------------------------
  Procedure Log_Result
  (
    i_Request     varchar2,
    i_Input       Array_Varchar2,
    i_Executed_In number
  ) is
    v_Policy     varchar2(20);
    v_Test_Query varchar2(4000);
    v_Log_Status varchar2(3);
    v_Input      clob;
  begin
    v_Policy := Regexp_Substr(g_Route.Log_Policy, g_Status || '[i]?');
  
    if v_Policy is not null or i_Executed_In > g_Route.Log_Time_Limit or g_Log_Me then
    
      if g_Log_Me then
        v_Log_Status := g_Status || 'im';
      elsif v_Policy like '%i' then
        v_Log_Status := g_Status || 'i';
      else
        v_Log_Status := g_Status;
      end if;
    
      if v_Log_Status like '%i%' then
        v_Input := Fazo.Make_Clob(i_Input);
        if g_Route.Action_Name is not null then
          v_Test_Query := Biruni_Core.Gen_Test_Query(g_Setting, g_Route);
        end if;
      else
        v_Test_Query := g_Route.Action_Name;
      end if;
    
      Biruni_Core.Save_Log(i_Status        => v_Log_Status,
                           i_Test_Query    => v_Test_Query,
                           i_Error_Message => g_Error_Log,
                           i_Detail        => g_Route.Uri,
                           i_Executed_In   => i_Executed_In,
                           i_Request       => i_Request,
                           i_Input         => v_Input);
    
    end if;
  
    if g_Status = Biruni_Core.c_s_Success then
      Biruni_Core.Save_Route_History;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Route
  (
    i_Request  varchar2,
    i_Input    Array_Varchar2,
    o_Response out Array_Varchar2,
    o_Output   out Array_Varchar2
  ) is
    v_Start_Time number := Dbms_Utility.Get_Time;
    ----------------------------------------------------------------------
    Procedure Review_File(i_Sha varchar2) is
    begin
      execute immediate 'BEGIN ' || g_Setting.Review_File_Procedure || '(:sha);END;'
        using i_Sha;
    end;
  
    ----------------------------------------------------------------------
    Procedure Eval_Files is
      v Arraylist := g_Request.o_Arraylist('files');
      r Biruni_Files%rowtype;
    begin
      -- TODO make files required
      if v is null then
        return;
      end if;
    
      for i in 1 .. v.Count
      loop
        r := z_Biruni_Files.To_Row(Treat(v.r_Hashmap(i) as Hashmap),
                                   z.Sha,
                                   z.File_Name,
                                   z.File_Size,
                                   z.Store_Kind,
                                   z.Content_Type);
      
        if r.Store_Kind is null then
          r.Store_Kind := 'D';
        end if;
      
        r.File_Name := Regexp_Replace(r.File_Name, '\W+', '.');
      
        if Lower(Regexp_Substr(r.File_Name, '^.*\.(\w+)$', 1, 1, 'i', 1)) member of
         Biruni_Pref.Dangerous_File_Extensions then
          b.Raise_Fatal('files that are not allowed to be saved');
        end if;
      
        r.Created_On := sysdate;
        z_Biruni_Files.Save_Row(r);
      
        Review_File(r.Sha);
      end loop;
    end;
  
    ----------------------------------------------------------------------
    Procedure Exec_Simple_Query is
      v_Query       varchar2(4000);
      v_Register_Id number;
    begin
      if g_Route.Action_Out in ('M', 'L', 'Q') then
        g_Response_Headers('Content-type') := 'application/json';
      elsif g_Route.Action_Out = 'F' then
        g_Response_Headers('Content-type') := 'image/jpeg';
      else
        g_Response_Headers('Content-type') := 'text/plain';
      end if;
    
      if g_Route.Action_Out in ('LR', 'LC') then
        v_Query := 'DECLARE input array_varchar2:=:input;output varchar2(10);d hashmap;BEGIN ' ||
                   Biruni_Core.Gen_Query(g_Route.Action_Name,
                                         g_Route.Action_In,
                                         g_Route.Action_Out,
                                         g_Setting.Check_Query_Procedure) ||
                   '; :output:=output;END;';
      
        if g_Route.Action_Out = 'LR' then
          v_Register_Id := Biruni_Api.Lazy_Report_Register_Save(i_Request_Uri   => g_Route.Uri,
                                                                i_Run_Procedure => v_Query,
                                                                i_Input_Data    => i_Input);
        else
          execute immediate v_Query
            using in i_Input, out v_Register_Id;
        end if;
      
        -- in order to prevent parallel generation
        execute immediate 'BEGIN ' || g_Setting.Lazy_Report_Review_Procedure ||
                          '(:register_id); END;'
          using in v_Register_Id;
      
        o_Output := Biruni_Util.Gen_Lazy_Report_Output(i_Register_Id => v_Register_Id,
                                                       i_Lang_Code   => g_Lang_Code);
      else
        v_Query := 'DECLARE input array_varchar2:=:input;output array_varchar2;d hashmap;BEGIN ' ||
                   Biruni_Core.Gen_Query(g_Route.Action_Name,
                                         g_Route.Action_In,
                                         g_Route.Action_Out,
                                         g_Setting.Check_Query_Procedure) ||
                   '; :output:=output;END;';
      
        execute immediate v_Query
          using in i_Input, out o_Output;
      
        if o_Output is null then
          o_Output := Array_Varchar2();
        end if;
      
        if g_Route.Review = 'Y' then
          execute immediate 'BEGIN ' || g_Setting.Review_Procedure || '(:a); END;'
            using in out o_Output;
        end if;
      end if;
    
      Context_End;
    end;
  
    ----------------------------------------------------------------------
    Procedure Exec_Runtime_Query is
      v_Query varchar2(4000);
    begin
      v_Query := 'DECLARE input array_varchar2:=:input;output runtime_service; BEGIN ' ||
                 Biruni_Core.Gen_Query(i_Action_Name     => g_Route.Action_Name,
                                       i_Action_In       => g_Route.Action_In,
                                       i_Action_Out      => g_Route.Action_Out,
                                       i_Check_Procedure => null) || '; :output:=output;END;';
    
      execute immediate v_Query
        using in i_Input, out g_Runtime_Service;
    
      Prepare_Runtime_Response(o_Output);
    end;
  
    ----------------------------------------------------------------------
    Procedure Exec_Query is
    begin
      Eval_Files;
    
      if g_Route.Action_Out = 'R' then
        Exec_Runtime_Query;
      else
        Exec_Simple_Query;
      end if;
    
      g_Status := Biruni_Core.c_s_Success;
    end;
  
    ----------------------------------------------------------------------
    Function Authenticate return boolean is
    begin
    
      execute immediate 'BEGIN ' || g_Setting.Authenticate_Procedure || ';END;';
      return true;
    
    exception
      when others then
        rollback;
        Set_Failure(Biruni_Core.c_s_Unauthenticated);
        return false;
    end;
  
    ----------------------------------------------------------------------
    Function Check_Session return boolean is
    begin
    
      execute immediate 'BEGIN ' || g_Setting.Check_Session_Procedure || ';END;';
      return true;
    
    exception
      when others then
        rollback;
        Set_Failure(Biruni_Core.c_s_Conflicts);
        return false;
    end;
  
    ----------------------------------------------------------------------
    Function Check_Subscription return boolean is
    begin
      if g_Setting.Check_Subscription_Procedure is null then
        return true;
      end if;
    
      execute immediate 'BEGIN ' || g_Setting.Check_Subscription_Procedure || ';END;';
      return true;
    
    exception
      when others then
        rollback;
        Set_Failure(Biruni_Core.c_s_Payment_Required);
        return false;
    end;
  
    ----------------------------------------------------------------------
    Function Authorize_Form return boolean is
    begin
    
      execute immediate 'BEGIN ' || g_Setting.Authorize_Form_Procedure || ';END;';
      return true;
    
    exception
      when others then
        rollback;
        Set_Failure(Biruni_Core.c_s_Refused);
        return false;
    end;
  
    ----------------------------------------------------------------------
    Function Authorize return boolean is
    begin
    
      execute immediate 'BEGIN ' || g_Setting.Authorize_Procedure || ';END;';
      return true;
    
    exception
      when others then
        rollback;
        Set_Failure(Biruni_Core.c_s_Refused);
        return false;
    end;
  
    ----------------------------------------------------------------------
    Procedure Run_Action is
    begin
      if g_Setting.Ip_Policy_Enabled = 'Y' and
         not Biruni_Core.Ip_Address_Permitted(Request_Ip_Address) then
        Raise_Application_Error(-20000,
                                'Access denied for ' || Request_Ip_Address || ' ip address');
      end if;
    
      if g_Setting.Service_Available = 'N' and g_Route.Uri <> '/fazo/metadata' then
        Raise_Application_Error(-20999, 'Service unavailable, try again later');
      end if;
    
      case g_Route.Access_Type
        when 'A' then
          if Authenticate and Check_Session and Check_Subscription and Authorize_Form and Authorize then
            Exec_Query;
          end if;
        
        when 'S' then
          if Authenticate and Check_Session and Check_Subscription and Authorize_Form then
            Exec_Query;
          end if;
        
        when 'P' then
          Exec_Query;
        
        when 'E' then
          Exec_Query;
        
        else
          raise Biruni_Core.e_Route_Not_Found;
        
      end case;
    exception
      when Biruni_Core.e_Unauthenticated then
        rollback;
        Set_Failure(Biruni_Core.c_s_Unauthenticated);
      when Biruni_Core.e_Payment_Required then
        rollback;
        Set_Failure(Biruni_Core.c_s_Payment_Required);
      when Biruni_Core.e_Unauthorized then
        rollback;
        Set_Failure(Biruni_Core.c_s_Refused);
      
      when Biruni_Core.e_Route_Not_Found then
        rollback;
        Set_Failure(Biruni_Core.c_s_Not_Found);
      
      when Biruni_Core.e_Conflicts then
        rollback;
        Set_Failure(Biruni_Core.c_s_Conflicts);
      
      when Biruni_Core.e_Too_Many_Requests then
        rollback;
        Set_Failure(Biruni_Core.c_s_Too_Many_Requests);
      
      when others then
        rollback;
        if sqlcode between - 20998 and - 20000 then
          Set_Failure(Biruni_Core.c_s_Error);
        else
          Set_Failure(Biruni_Core.c_s_Fatal);
        end if;
    end;
  
  begin
    Context_Begin(i_Request);
  
    Run_Action;
  
    if g_Status is not null then
      Prepare_Response(p_Response => o_Response, --
                       p_Output   => o_Output);
    
      Log_Result(i_Request     => i_Request,
                 i_Input       => i_Input,
                 i_Executed_In => (Dbms_Utility.Get_Time - v_Start_Time) * 10);
    else
      Raise_Application_Error(-20999, 'Biruni status is not defined.');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Runtime_Route
  (
    i_Review_Data varchar2,
    i_Input       Array_Varchar2,
    o_Response    out Array_Varchar2,
    o_Output      out Array_Varchar2
  ) is
    v_Start_Time number := Dbms_Utility.Get_Time;
    ----------------------------------------------------------------------
    Procedure Run_Action is
      v_Query varchar2(4000);
    begin
      if g_Runtime_Review_Procedure is not null then
        v_Query := 'DECLARE BEGIN ' || g_Runtime_Review_Procedure || '(:review_data); END;';
      
        execute immediate v_Query
          using in i_Review_Data;
      end if;
    
      v_Query := 'DECLARE input array_varchar2:=:input; output array_varchar2; BEGIN ' ||
                 Biruni_Core.Gen_Query(i_Action_Name     => g_Runtime_Response_Procedure,
                                       i_Action_In       => g_Runtime_Action_In,
                                       i_Action_Out      => g_Runtime_Action_Out,
                                       i_Check_Procedure => null) || '; :output:=output;END;';
    
      execute immediate v_Query
        using in i_Input, out o_Output;
    
      if o_Output is null then
        o_Output := Array_Varchar2();
      end if;
    
      g_Status := Biruni_Core.c_s_Success;
    
      Context_End;
    exception
      when others then
        rollback;
        if sqlcode between - 20998 and - 20000 then
          Set_Failure(Biruni_Core.c_s_Error);
        else
          Set_Failure(Biruni_Core.c_s_Fatal);
        end if;
    end;
  begin
    g_Status          := null;
    g_Error_Log       := null;
    g_Error_Result    := null;
    g_Runtime_Service := null;
  
    Run_Action;
    if g_Status is not null then
      Prepare_Response(p_Response => o_Response, --
                       p_Output   => o_Output);
    
      Log_Result(i_Request     => Substr(i_Review_Data, 1, 4000),
                 i_Input       => i_Input,
                 i_Executed_In => (Dbms_Utility.Get_Time - v_Start_Time) * 10);
    else
      Raise_Application_Error(-20999, 'Biruni status is not defined.');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Runtime_Route_Fail
  (
    i_Review_Data varchar2,
    i_Error       varchar2
  ) is
    v_Query varchar2(4000);
  begin
    begin
      if g_Runtime_Review_Procedure is not null then
        v_Query := 'DECLARE BEGIN ' || g_Runtime_Review_Procedure || '(:review_data); END;';
      
        execute immediate v_Query
          using in i_Review_Data;
      end if;
    exception
      when others then
        rollback;
    end;
  
    g_Status    := Biruni_Core.c_s_Error;
    g_Error_Log := Substr(i_Error, 1, 2000);
  
    Log_Result(i_Request     => '', --
               i_Input       => Array_Varchar2(),
               i_Executed_In => 0);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Lazy_Report
  (
    i_Register_Id number,
    o_Status      out varchar2,
    o_Report_Type out varchar2,
    o_Metadata    out clob
  ) is
    r_Register Biruni_Lazy_Report_Register%rowtype;
    --------------------------------------------------            
    Procedure Fetch_Report_Lines is
    begin
      Dbms_Lob.Createtemporary(Lob_Loc => o_Metadata, Cache => false);
      for r in (select Line
                  from Biruni_Report_Lines
                 order by Table_Id, Order_No)
      loop
        Dbms_Lob.Append(o_Metadata, r.Line);
      end loop;
    end;
    --------------------------------------------------
    Procedure Load_Metadata is
    begin
      select t.Metadata
        into o_Metadata
        from Biruni_Lazy_Report_Metadata t
       where t.Register_Id = r_Register.Register_Id;
    exception
      when No_Data_Found then
        null;
    end;
  begin
    r_Register := z_Biruni_Lazy_Report_Register.Load(i_Register_Id);
  
    Context_Begin('{"uri":"' || r_Register.Request_Uri || '"}');
  
    Biruni_Api.Lazy_Report_Register_Update(i_Register_Id => i_Register_Id,
                                           i_Status      => Option_Varchar2(Biruni_Pref.c_Lazy_Report_Status_Executing));
  
    if r_Register.Status = Biruni_Pref.c_Lazy_Report_Status_New then
      execute immediate 'BEGIN ' || g_Setting.Lazy_Report_Init_Procedure || '(:register_id); END;'
        using in i_Register_Id;
    
      execute immediate r_Register.Run_Procedure
        using in Fazo.Read_Clob(r_Register.Input_Data), out o_Report_Type;
    
      o_Report_Type := Biruni_Report.Report_Type;
    
      Fetch_Report_Lines;
      Biruni_Api.Lazy_Report_Metadata_Save(i_Register_Id => i_Register_Id,
                                           i_Metadata    => o_Metadata);
    elsif r_Register.Has_Metadata = 'Y' then
      if r_Register.File_Sha is null then
        o_Report_Type := Biruni_Report.Rt_Xlsx;
      else
        o_Report_Type := Biruni_Report.Rt_Html;
      end if;
    
      Load_Metadata;
    end if;
  
    if o_Metadata is null then
      Raise_Application_Error(-20999, 'Report lines is empty');
    end if;
  
    o_Status := Biruni_Pref.c_Lazy_Report_Status_Executing;
    Context_End;
  exception
    when others then
      rollback;
      o_Status      := Biruni_Pref.c_Lazy_Report_Status_Failed;
      o_Report_Type := Biruni_Util.Extract_Ora_Error_Message(sqlerrm);
      o_Metadata    := null;
    
      if r_Register.File_Sha is null and r_Register.Html_Sha is null then
        Biruni_Api.Lazy_Report_Register_Update(i_Register_Id     => i_Register_Id,
                                               i_Status          => Option_Varchar2(Biruni_Pref.c_Lazy_Report_Status_Failed),
                                               i_Error_Message   => Option_Varchar2(o_Report_Type),
                                               i_Error_Backtrace => Option_Varchar2(Dbms_Utility.Format_Error_Backtrace));
      else
        Biruni_Api.Lazy_Report_Register_Update(i_Register_Id => i_Register_Id,
                                               i_Status      => Option_Varchar2(Biruni_Pref.c_Lazy_Report_Status_Completed));
      end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Lazy_Report_File
  (
    i_Register_Id  number,
    i_Sha          varchar2,
    i_File_Size    number,
    i_Store_Kind   varchar2,
    i_File_Name    varchar2,
    i_Content_Type varchar2,
    o_Error        out varchar2
  ) is
    r_Register Biruni_Lazy_Report_Register%rowtype;
    --------------------------------------------------
    Procedure Review_File(i_Sha varchar2) is
    begin
      execute immediate 'BEGIN ' || g_Setting.Review_File_Procedure || '(:sha);END;'
        using i_Sha;
    end;
  
  begin
    r_Register := z_Biruni_Lazy_Report_Register.Load(i_Register_Id);
  
    Context_Begin('{"uri":"' || r_Register.Request_Uri || '"}');
  
    execute immediate 'BEGIN ' || g_Setting.Lazy_Report_Init_Procedure || '(:register_id); END;'
      using in i_Register_Id;
  
    z_Biruni_Files.Save_One(i_Sha          => i_Sha,
                            i_File_Size    => i_File_Size,
                            i_Store_Kind   => i_Store_Kind,
                            i_File_Name    => Regexp_Replace(i_File_Name, '\W+', '.') || '.xlsx',
                            i_Content_Type => i_Content_Type);
  
    Review_File(i_Sha);
  
    Context_End;
  exception
    when others then
      rollback;
      o_Error := Biruni_Util.Extract_Ora_Error_Message(sqlerrm);
    
      if r_Register.File_Sha is null and r_Register.Html_Sha is null then
        Biruni_Api.Lazy_Report_Register_Update(i_Register_Id     => i_Register_Id,
                                               i_Status          => Option_Varchar2(Biruni_Pref.c_Lazy_Report_Status_Failed),
                                               i_Error_Message   => Option_Varchar2(o_Error),
                                               i_Error_Backtrace => Option_Varchar2(Dbms_Utility.Format_Error_Backtrace));
      else
        Biruni_Api.Lazy_Report_Register_Update(i_Register_Id => i_Register_Id,
                                               i_Status      => Option_Varchar2(Biruni_Pref.c_Lazy_Report_Status_Completed));
      end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Update_Lazy_Report_Info
  (
    i_Register_Id     number,
    i_Status          varchar2,
    i_File_Sha        varchar2,
    i_Html_Sha        varchar2,
    i_Error_Message   varchar2,
    i_Error_Backtrace varchar2
  ) is
    r_Register Biruni_Lazy_Report_Register%rowtype;
    --------------------------------------------------
    Function Option_Value(i_Val varchar2) return Option_Varchar2 is
    begin
      if i_Val is null then
        return null;
      else
        return Option_Varchar2(i_Val);
      end if;
    end;
  
    --------------------------------------------------
    Procedure Notify is
    begin
      Context_Begin('{"uri":"' || r_Register.Request_Uri || '"}');
    
      execute immediate 'BEGIN ' || g_Setting.Lazy_Report_Notify_Procedure ||
                        '(:register_id, :status); END;'
        using in i_Register_Id, i_Status;
    
      Context_End;
    exception
      when others then
        null;
    end;
  begin
    r_Register := z_Biruni_Lazy_Report_Register.Load(i_Register_Id);
  
    if r_Register.File_Sha is not null or r_Register.Html_Sha is not null then
      Biruni_Api.Lazy_Report_Register_Update(i_Register_Id => i_Register_Id,
                                             i_Status      => Option_Varchar2(Biruni_Pref.c_Lazy_Report_Status_Completed),
                                             i_File_Sha    => Option_Value(i_File_Sha),
                                             i_Html_Sha    => Option_Value(i_Html_Sha));
    else
      Biruni_Api.Lazy_Report_Register_Update(i_Register_Id     => i_Register_Id,
                                             i_Status          => Option_Value(i_Status),
                                             i_File_Sha        => Option_Value(i_File_Sha),
                                             i_Html_Sha        => Option_Value(i_Html_Sha),
                                             i_Error_Message   => Option_Value(i_Error_Message),
                                             i_Error_Backtrace => Option_Value(i_Error_Backtrace));
    end if;
  
    Notify;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Error_With_Backtrace(i_Val boolean) is
  begin
    g_With_Backtrace := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Default_Lang_Code return varchar2 is
  begin
    return g_Setting.Lang_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Lang_Code return varchar2 is
  begin
    return g_Lang_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Code(i_Lang_Code varchar2) is
  begin
    if Regexp_Like(i_Lang_Code, '^[a-z]+$') then
      g_Lang_Code := i_Lang_Code;
    elsif i_Lang_Code is null then
      g_Lang_Code := g_Setting.Lang_Code;
    else
      Raise_Application_Error(-20999, 'Invalid lang code.');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Custom_Translate_Code return varchar2 is
  begin
    return g_Custom_Translate_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Custom_Translate_Code(i_Code varchar2) is
  begin
    g_Custom_Translate_Code := i_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Assert_Is_Route is
  begin
    if g_Request is null then
      Raise_Application_Error(-20999, 'Request is missing for route call.');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Report_Line_Count
  (
    i_Count number,
    i_Raw   boolean
  ) is
  begin
    Assert_Is_Route;
    g_Report_Line_Count := i_Count;
    g_Report_Raw_Line   := i_Raw;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Report_Redirect(i_Redirect Hashmap) is
  begin
    Assert_Is_Route;
    g_Report_Redirect := i_Redirect;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Easy_Report(i_Easy_Report_Data Json_Object_t) is
  begin
    Assert_Is_Route;
    g_Easy_Report_Data := i_Easy_Report_Data;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_External_Service(i_External_Service_Data Json_Object_t) is
  begin
    Assert_Is_Route;
    g_External_Service_Data := i_External_Service_Data;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Onlyoffice(i_Onlyoffice_Data Json_Object_t) is
  begin
    Assert_Is_Route;
    g_Onlyoffice_Data := i_Onlyoffice_Data;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Log_Me is
  begin
    g_Log_Me := true;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Post_Callback(i_Callback_Block varchar2) is
  begin
    if g_Post_Callbacks is null then
      Raise_Application_Error(-20999, 'BIRUNI: recursive calling Add_Post_Callback.');
    end if;
    if Fazo.Index_Of(g_Post_Callbacks, i_Callback_Block) = 0 then
      Fazo.Push(g_Post_Callbacks, i_Callback_Block);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Uri return varchar2 is
  begin
    Assert_Is_Route;
    return g_Route.Uri;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Allowed_Auth_Types return varchar2 is
  begin
    Assert_Is_Route;
    return g_Route.Allowed_Auth_Types;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Scope return varchar2 is
  begin
    Assert_Is_Route;
    return g_Route.Scope;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Action_In return varchar2 is
  begin
    Assert_Is_Route;
    return g_Route.Action_In;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Route_Action_Out return varchar2 is
  begin
    Assert_Is_Route;
    return g_Route.Action_Out;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Session return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('session');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Method return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('method');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Url return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('url');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Server_Url return varchar2 is
    v_Url         varchar2(4000);
    v_Servlet_Url varchar2(4000);
  begin
    Assert_Is_Route;
  
    v_Url         := g_Request.o_Varchar2('url');
    v_Servlet_Url := g_Request.o_Varchar2('servlet_path');
  
    return Substr(v_Url, 1, Length(v_Url) - Length(v_Servlet_Url));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Authorization return Hashmap is
    v_Authorization Hashmap;
  begin
    Assert_Is_Route;
  
    v_Authorization := g_Request.o_Hashmap('authorization');
  
    if v_Authorization is null then
      return Hashmap();
    end if;
  
    return v_Authorization;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Context_Path return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('context_path');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Ip_Address return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('ip_address');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Host_Name return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('host_name');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Host_User return varchar2 is
  begin
    Assert_Is_Route;
    return g_Request.o_Varchar2('host_user');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_User_Agent return Hashmap is
  begin
    Assert_Is_Route;
    return g_Request.o_Hashmap('user_agent');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Header(i_Key varchar2) return varchar2 is
    v_Headers Hashmap;
  begin
    if g_Request is null then
      return '';
    end if;
    --Assert_Is_Route;  to able to run within job
    v_Headers := g_Request.o_Hashmap('headers');
  
    if v_Headers is not null then
      return v_Headers.o_Varchar2(i_Key);
    else
      return '';
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_Cookie(i_Key varchar2) return varchar2 is
    v_Cookies Hashmap;
  begin
    if g_Request is null then
      return '';
    end if;
    --Assert_Is_Route;  to able to run within job
    v_Cookies := g_Request.o_Hashmap('cookies');
  
    if v_Cookies is not null then
      return v_Cookies.o_Varchar2(i_Key);
    else
      return '';
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Request_File_Shas return Array_Varchar2 is
    r_Files Arraylist;
    result  Array_Varchar2 := Array_Varchar2();
  begin
    Assert_Is_Route;
    r_Files := g_Request.o_Arraylist('files');
  
    for i in 1 .. r_Files.Count
    loop
      Fazo.Push(result, Treat(r_Files.r_Hashmap(i) as Hashmap).r_Varchar2('sha'));
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Response_Session return varchar2 is
  begin
    Assert_Is_Route;
    return g_Response_Session;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Session(i_Session varchar2) is
  begin
    Assert_Is_Route;
    -- g_Route.Access_Type is null check added temporarily for oneid servlet can create session
    if Nvl(g_Route.Access_Type, 'E') = 'E' then
      g_Response_Session := i_Session;
    else
      Raise_Application_Error(-20999, 'Not permitted to edit session');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Response_Set_Header
  (
    i_Key   varchar2,
    i_Value varchar2
  ) is
  begin
    Assert_Is_Route;
    g_Response_Headers(i_Key) := i_Value;
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
    Assert_Is_Route;
  
    if g_Response_Cookies is null then
      g_Response_Cookies := Hashmap;
    end if;
  
    g_Response_Cookies.Put(i_Key,
                           Fazo.Zip_Map('value', i_Value, 'path', i_Path, 'max_age', i_Max_Age));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Runtime_Response_Action_In return varchar2 is
  begin
    Assert_Is_Route;
    return g_Runtime_Action_In;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Runtime_Response_Action_Out return varchar2 is
  begin
    Assert_Is_Route;
    return g_Runtime_Action_Out;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Upload_Easy_Report_Metadata
  (
    i_Sha         varchar2,
    i_Metadata    Array_Varchar2,
    i_Definition  Array_Varchar2,
    i_Version     varchar2,
    i_Photo_Infos Array_Varchar2
  ) is
    v_Metadata    clob := Fazo.Make_Clob(i_Val => i_Metadata);
    v_Definition  clob := Fazo.Make_Clob(i_Val => i_Definition);
    v_Photo_Infos Arraylist := Fazo.Parse_Array(i_Src => i_Photo_Infos);
    v_Photo_Info  Hashmap;
    v_Photos_Sha  Array_Varchar2 := Array_Varchar2();
    v_Store_Kind  varchar2(1);
  begin
    update Biruni_Easy_Report_Templates
       set Metadata   = v_Metadata,
           Definition = v_Definition,
           Version    = i_Version
     where Sha = i_Sha;
    if sql%notfound then
      insert into Biruni_Easy_Report_Templates
        (Sha, Metadata, Definition, Version)
      values
        (i_Sha, v_Metadata, v_Definition, i_Version);
    end if;
  
    v_Store_Kind := z_Biruni_Files.Load(i_Sha).Store_Kind;
  
    for i in 1 .. v_Photo_Infos.Count
    loop
      v_Photo_Info := Treat(v_Photo_Infos.r_Hashmap(i) as Hashmap);
    
      z_Biruni_Files.Save_One(i_Sha          => v_Photo_Info.r_Varchar2('sha'),
                              i_File_Size    => v_Photo_Info.r_Number('photo_size'),
                              i_Store_Kind   => v_Store_Kind,
                              i_Content_Type => v_Photo_Info.r_Varchar2('content_type'));
    
      z_Biruni_Easy_Report_Template_Photos.Insert_Try(i_Sha       => i_Sha,
                                                      i_Photo_Sha => v_Photo_Info.r_Varchar2('sha'));
    
      v_Photos_Sha.Extend;
      v_Photos_Sha(i) := v_Photo_Info.r_Varchar2('sha');
    end loop;
  
    delete from Biruni_Easy_Report_Template_Photos t
     where t.Sha = i_Sha
       and t.Photo_Sha not member of v_Photos_Sha;
  
  exception
    when others then
      Raise_Application_Error(-20999, 'Upload easy report metadata error');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Clear_Easy_Report_Template(i_Sha varchar2) is
  begin
    execute immediate 'BEGIN ' || g_Setting.Review_Easy_Report_Procedure || '(:sha);END;'
      using i_Sha;
  end;

end Biruni_Route;
/
