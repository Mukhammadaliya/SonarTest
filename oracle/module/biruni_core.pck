create or replace package Biruni_Core is
  ----------------------------------------------------------------------------------------------------
  c_s_Success           constant varchar2(1) := 'S'; -- 200 OK
  c_s_Error             constant varchar2(1) := 'E'; -- 400 Bad request
  c_s_Fatal             constant varchar2(1) := 'F'; -- 500 Internal server error
  c_s_Unauthenticated   constant varchar2(1) := 'U'; -- 401 Unauthorized
  c_s_Payment_Required  constant varchar2(1) := 'P'; -- 402 Payment Required
  c_s_Refused           constant varchar2(1) := 'R'; -- 403 Forbidden
  c_s_Not_Found         constant varchar2(1) := 'N'; -- 404 Not found
  c_s_Conflicts         constant varchar2(1) := 'C'; -- 409 Conflicts
  c_s_Too_Many_Requests constant varchar2(1) := 'T'; -- 429 Too many requests
  -- file not found                             -- 410 Gone
  ----------------------------------------------------------------------------------------------------
  c_At_Public         constant varchar2(1) := 'P';
  c_At_Edit_Session   constant varchar2(1) := 'E';
  c_At_Verify_Session constant varchar2(1) := 'S';
  c_At_Authorize      constant varchar2(1) := 'A';
  ----------------------------------------------------------------------------------------------------
  c_Job_Supervisor constant varchar2(30) := 'BIRUNI_JOB_SUPERVISOR';
  c_Job_Daily      constant varchar2(30) := 'BIRUNI_JOB_DAILY';
  c_Job_Worker     constant varchar2(30) := 'BIRUNI_JOB_WORKER';
  c_Job_Class      constant varchar2(30) := 'SCHED$_LOG_ON_ERRORS_CLASS';
  ----------------------------------------------------------------------------------------------------
  c_Job_Interval_In_Seconds constant number := 7200;
  ----------------------------------------------------------------------------------------------------
  e_Unauthorized      exception;
  e_Payment_Required  exception;
  e_Unauthenticated   exception;
  e_Route_Not_Found   exception;
  e_Conflicts         exception;
  e_Too_Many_Requests exception;
  --------------------------------e_Unauthorized--------------------------------------------------------------------  
  pragma exception_init(e_Unauthorized, -401);
  pragma exception_init(e_Payment_Required, -402);
  pragma exception_init(e_Unauthenticated, -403);
  pragma exception_init(e_Route_Not_Found, -404);
  pragma exception_init(e_Conflicts, -409);
  pragma exception_init(e_Too_Many_Requests, -429);
  ----------------------------------------------------------------------------------------------------
  Function Nvl_Setting(i_Setting Biruni_Settings%rowtype) return Biruni_Settings%rowtype;
  ----------------------------------------------------------------------------------------------------
  Function Load_Setting return Biruni_Settings%rowtype;
  ----------------------------------------------------------------------------------------------------
  Function Load_Auth_Setting return Biruni_Auth_Settings%rowtype;
  ----------------------------------------------------------------------------------------------------
  Function Ipv4_To_Number(i_Str varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Function Ip_Address_Permitted(i_Ip_Address varchar2) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Job_Enabled return boolean;
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Run_At
  (
    i_Procedure varchar2,
    i_Arguments varchar2 := null,
    i_At_Time   date := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Run
  (
    i_Procedure     varchar2,
    i_Arguments     varchar2 := null,
    i_After_Seconds number := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Enable(i_State varchar2);
  ----------------------------------------------------------------------------------------------------
  Function Job_Exists(i_Job_Name varchar2) return boolean;
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Start(i_Interval_In_Seconds number := null);
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Stop;
  ----------------------------------------------------------------------------------------------------
  Procedure j_Supervise_Jobs;
  ----------------------------------------------------------------------------------------------------
  Procedure j_Plan_Today;
  ----------------------------------------------------------------------------------------------------
  Procedure j_Execute_Procedure
  (
    i_Procedure varchar2,
    i_Arguments varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function j_Pop_Procedure return Biruni_Job_Once_Procedures%rowtype;
  ----------------------------------------------------------------------------------------------------
  Procedure j_Eval_Procedures;
  ----------------------------------------------------------------------------------------------------
  Function Pm(Input Array_Varchar2) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Pa(Input Array_Varchar2) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Pv(d Fazo_Schema.w_Wrapper) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Pv(d Json_Object_t) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Pv(d Json_Array_t) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Pf(d Fazo_Schema.Fazo_File) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Plr(d Lazy_Report) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Plrc(d Lazy_Report_Convertor) return number;
  ----------------------------------------------------------------------------------------------------
  Function Pq
  (
    i_Query           Fazo_Query,
    i_Params          Hashmap,
    i_Check_Procedure varchar2
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Pqb
  (
    o_Query           out nocopy varchar2,
    i_Execute         boolean,
    i_Query           Fazo_Query,
    i_Params          Hashmap,
    i_Check_Procedure varchar2
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Pjo(Input Array_Varchar2) return Json_Object_t;
  ----------------------------------------------------------------------------------------------------
  Function Pja(Input Array_Varchar2) return Json_Array_t;
  ----------------------------------------------------------------------------------------------------
  Function Gen_Query
  (
    i_Action_Name     varchar2,
    i_Action_In       varchar2,
    i_Action_Out      varchar2,
    i_Check_Procedure varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gen_Test_Query
  (
    i_Setting Biruni_Settings%rowtype,
    i_Route   Biruni_Routes%rowtype
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Log
  (
    i_Status        varchar2,
    i_Test_Query    varchar2,
    i_Error_Message varchar2,
    i_Detail        varchar2,
    i_Executed_In   number,
    i_Request       varchar2,
    i_Input         clob
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Route_History;
  ----------------------------------------------------------------------------------------------------
  Procedure Log_All;
  ----------------------------------------------------------------------------------------------------
  Procedure Log_Standart;
  ----------------------------------------------------------------------------------------------------
  Function Load_Log(i_Log_Id number) return Biruni_Log%rowtype;
  ----------------------------------------------------------------------------------------------------
  Function Take_Log_Input(i_Log_Id number) return Biruni_Log_Inputs%rowtype;
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code_Common(i_Lang_Code varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code_Custom(i_Lang_Code varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code(i_Lang_Code varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Take_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2,
    o_Text      out varchar2,
    o_Custom    out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Take_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2,
    i_Text      varchar2,
    i_Custom    varchar2 := null,
    i_Generated varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Function Take_Custom_Translation
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Custom_Translation
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Lang_Code varchar2,
    i_Text      varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Map Fazo.Varchar2_Code_Aat) return varchar2;
  ----------------------------------------------------------------------------------------------------   
  Procedure Run_Desolate_Procedure(i_Sha varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Bf_Try_Delete
  (
    i_Sha        varchar2,
    i_Store_Kind varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Bf_Cleaner;
  ----------------------------------------------------------------------------------------------------
  Procedure Biruni_Url_Params_Cleaner;
  ----------------------------------------------------------------------------------------------------
  Procedure Biruni_Log_Cleaner;
  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Cleaner;
end Biruni_Core;
/
create or replace package body Biruni_Core is
  ----------------------------------------------------------------------------------------------------
  Function Nvl_Setting(i_Setting Biruni_Settings%rowtype) return Biruni_Settings%rowtype is
    r Biruni_Settings%rowtype := i_Setting;
  begin
    r.Lang_Code                    := Nvl(r.Lang_Code, 'ru');
    r.Authenticate_Procedure       := Nvl(r.Authenticate_Procedure, 'b.Not_Implemented');
    r.Check_Session_Procedure      := Nvl(r.Check_Session_Procedure, 'b.Not_Implemented');
    r.Authorize_Procedure          := Nvl(r.Authorize_Procedure, 'b.Not_Implemented');
    r.Review_Procedure             := Nvl(r.Review_Procedure, 'b.Not_Implemented');
    r.Review_Easy_Report_Procedure := Nvl(r.Review_Easy_Report_Procedure, 'b.Not_Implemented');
    r.Lazy_Report_Review_Procedure := Nvl(r.Lazy_Report_Review_Procedure, 'b.Not_Implemented');
    r.Lazy_Report_Init_Procedure   := Nvl(r.Lazy_Report_Init_Procedure, 'b.Not_Implemented');
    r.Lazy_Report_Notify_Procedure := Nvl(r.Lazy_Report_Notify_Procedure, 'b.Not_Implemented');
    r.Hms_Token_Save_Procedure     := Nvl(r.Hms_Token_Save_Procedure, 'b.Not_Implemented');
    r.Log_Policy                   := Nvl(r.Log_Policy, 'FR');
    r.Log_Time_Limit               := Nvl(r.Log_Time_Limit, 2000);
    r.Job_Enabled                  := Nvl(r.Job_Enabled, 'Y');
    r.Job_Max_Workers              := Nvl(r.Job_Max_Workers, 5);
    r.Job_Interval_In_Seconds      := Nvl(r.Job_Interval_In_Seconds, c_Job_Interval_In_Seconds);
    r.Ip_Policy_Enabled            := Nvl(r.Ip_Policy_Enabled, 'N');
    r.Service_Available            := Nvl(r.Service_Available, 'Y');
    -- r.timezone_code normal to be null
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Setting return Biruni_Settings%rowtype is
  begin
    return Nvl_Setting(z_Biruni_Settings.Take('U'));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Nvl_Auth_Setting(i_Setting Biruni_Auth_Settings%rowtype)
    return Biruni_Auth_Settings%rowtype is
    r Biruni_Auth_Settings%rowtype := i_Setting;
  begin
    r.Close_Session_Procedure        := Nvl(r.Close_Session_Procedure, 'b.Not_Implemented');
    r.Check_Oauth2_Request_Procedure := Nvl(r.Check_Oauth2_Request_Procedure, 'b.Not_Implemented');
    r.Auth_Code_Procedure            := Nvl(r.Auth_Code_Procedure, 'b.Not_Implemented');
    r.Oauth2_Access_Token_Procedure  := Nvl(r.Oauth2_Access_Token_Procedure, 'b.Not_Implemented');
    r.Api_Access_Token_Procedure     := Nvl(r.Api_Access_Token_Procedure, 'b.Not_Implemented');
    r.Refresh_Token_Procedure        := Nvl(r.Refresh_Token_Procedure, 'b.Not_Implemented');
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Auth_Setting return Biruni_Auth_Settings%rowtype is
  begin
    return Nvl_Auth_Setting(z_Biruni_Auth_Settings.Take('U'));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Ipv4_To_Number(i_Str varchar2) return number as
    v_Dlm1 number;
    v_Dlm2 number;
    v_Dlm3 number;
  begin
    if not
        Regexp_Like(i_Str,
                    '^(([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$') then
      return null;
    end if;
  
    v_Dlm1 := Instr(i_Str, '.', 1, 1);
    v_Dlm2 := Instr(i_Str, '.', 1, 2);
    v_Dlm3 := Instr(i_Str, '.', 1, 3);
  
    return to_number(Substr(i_Str, 1, v_Dlm1 - 1)) * Power(256, 3) + --
    to_number(Substr(i_Str, v_Dlm1 + 1, v_Dlm2 - v_Dlm1 - 1)) * Power(256, 2) + --
    to_number(Substr(i_Str, v_Dlm2 + 1, v_Dlm3 - v_Dlm2 - 1)) * 256 + --
    to_number(Substr(i_Str, v_Dlm3 + 1));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Ip_Address_Permitted(i_Ip_Address varchar2) return boolean is
    v_Action varchar2(1);
    v_Value  number;
  begin
    v_Value := Ipv4_To_Number(i_Ip_Address);
  
    if v_Value is null then
      return true;
    end if;
  
    with Ordered_Query as
     (select t.Action
        from Biruni_Ip_Ranges t
       where v_Value between t.Value_Begin and t.Value_End
         and t.State = 'A'
       order by t.Order_No)
    select t.Action
      bulk into v_Action
      from Ordered_Query t
     where Rownum = 1;
  
    return v_Action = 'P';
  
  exception
    when No_Data_Found then
      return true;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Job_Enabled return boolean is
  begin
    return Load_Setting().Job_Enabled = 'Y';
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Run_At
  (
    i_Procedure varchar2,
    i_Arguments varchar2 := null,
    i_At_Time   date := null
  ) is
  begin
    z_Biruni_Job_Once_Procedures.Insert_One(i_Id             => Biruni_Job_Sq.Nextval,
                                            i_Start_Time     => Nvl(i_At_Time, sysdate),
                                            i_Procedure_Name => i_Procedure,
                                            i_Procedure_Args => i_Arguments);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Run
  (
    i_Procedure     varchar2,
    i_Arguments     varchar2 := null,
    i_After_Seconds number := null
  ) is
    v_At_Time date;
  begin
    if i_After_Seconds is not null then
      v_At_Time := sysdate + i_After_Seconds / 60 / 60 / 24;
    end if;
    Job_Run_At(i_Procedure => i_Procedure, i_Arguments => i_Arguments, i_At_Time => v_At_Time);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Enable(i_State varchar2) is
    pragma autonomous_transaction;
  begin
    update Biruni_Settings t
       set t.Job_Enabled = i_State;
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Job_Exists(i_Job_Name varchar2) return boolean is
  begin
    for r in (select *
                from User_Scheduler_Jobs t
               where t.Job_Name = i_Job_Name)
    loop
      return true;
    end loop;
    return false;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Start(i_Interval_In_Seconds number := null) is
    pragma autonomous_transaction;
    v_Interval varchar2(100);
    r_Setting  Biruni_Settings%rowtype := Load_Setting();
  begin
    if Job_Exists(c_Job_Supervisor) then
      return;
    end if;
  
    v_Interval := 'SYSTIMESTAMP + INTERVAL ''' ||
                  Nvl(i_Interval_In_Seconds, r_Setting.Job_Interval_In_Seconds) || ''' SECOND';
    Dbms_Scheduler.Create_Job(Job_Name        => c_Job_Supervisor,
                              Job_Type        => 'STORED_PROCEDURE',
                              Job_Action      => 'BIRUNI_CORE.J_SUPERVISE_JOBS',
                              Repeat_Interval => v_Interval,
                              Enabled         => true,
                              Job_Class       => c_Job_Class,
                              Comments        => 'Supervise jobs');
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Stop is
  begin
    if Job_Exists(c_Job_Daily) then
      Dbms_Scheduler.Drop_Job(c_Job_Daily);
    end if;
    if Job_Exists(c_Job_Supervisor) then
      Dbms_Scheduler.Drop_Job(c_Job_Supervisor);
    end if;
    for r in (select *
                from User_Scheduler_Jobs t
               where t.Job_Name like c_Job_Worker || '%')
    loop
      Dbms_Scheduler.Drop_Job(r.Job_Name);
    end loop;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure j_Supervise_Jobs is
    pragma autonomous_transaction;
    r_Setting  Biruni_Settings%rowtype := Load_Setting();
    v_Job_Name varchar2(200);
    v_Interval varchar2(100);
  begin
    if not Job_Exists(c_Job_Daily) then
      Dbms_Scheduler.Create_Job(Job_Name        => c_Job_Daily,
                                Job_Type        => 'STORED_PROCEDURE',
                                Job_Action      => 'BIRUNI_CORE.J_PLAN_TODAY',
                                Start_Date      => Trunc(Systimestamp),
                                Repeat_Interval => 'Freq=Daily;Interval=1',
                                Enabled         => true,
                                Job_Class       => c_Job_Class,
                                Comments        => 'Insert daily procedures into once procedures');
    end if;
  
    v_Interval := 'SYSTIMESTAMP + INTERVAL ''' || r_Setting.Job_Interval_In_Seconds || ''' SECOND';
  
    for i in 1 .. r_Setting.Job_Max_Workers
    loop
      v_Job_Name := c_Job_Worker || i;
      if not Job_Exists(v_Job_Name) then
        Dbms_Scheduler.Create_Job(Job_Name        => v_Job_Name,
                                  Job_Type        => 'STORED_PROCEDURE',
                                  Job_Action      => 'BIRUNI_CORE.J_EVAL_PROCEDURES',
                                  Repeat_Interval => v_Interval,
                                  Enabled         => true,
                                  Job_Class       => c_Job_Class,
                                  Comments        => 'Insert daily procedures into once procedures');
      end if;
    end loop;
  
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure j_Plan_Today is
    pragma autonomous_transaction;
    v_Today varchar2(10) := to_char(sysdate, 'yyyymmdd');
  begin
    if not Job_Enabled then
      return;
    end if;
    for r in (select *
                from Biruni_Job_Daily_Procedures)
    loop
      Job_Run_At(i_Procedure => r.Procedure_Name,
                 i_Arguments => null,
                 i_At_Time   => to_date(v_Today || r.Start_Time, 'yyyymmddhh24:mi'));
    end loop;
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure j_Execute_Procedure
  (
    i_Procedure varchar2,
    i_Arguments varchar2
  ) is
    pragma autonomous_transaction;
  begin
  
    if Regexp_Like(i_Procedure, '^[A-Za-z0-9._]+$') then
      if i_Arguments is not null then
        execute immediate 'BEGIN ' || i_Procedure || '(:1); END;'
          using in i_Arguments;
      else
        execute immediate 'BEGIN ' || i_Procedure || '; END;';
      end if;
    else
      Raise_Application_Error(-20999, 'Procedure syntax error.');
    end if;
  
    commit;
  
  exception
    when others then
      rollback;
      declare
        v_Status        varchar2(2 char);
        v_Test_Query    varchar2(4000);
        v_Error_Message varchar2(4000);
      begin
        if sqlcode between - 20998 and - 20000 then
          v_Status := c_s_Error;
        else
          v_Status := c_s_Fatal;
        end if;
        v_Test_Query := 'BEGIN Biruni_Core.Take_Log_input($log_id,:input);' || i_Procedure ||
                        '$args;END;';
        if i_Arguments is not null then
          v_Test_Query := replace(v_Test_Query, '$args', '(:input)');
        else
          v_Test_Query := replace(v_Test_Query, '$args', '');
        end if;
      
        v_Error_Message := sqlerrm || Chr(13) || Chr(13) || Dbms_Utility.Format_Error_Backtrace;
        Save_Log(i_Status        => v_Status || 'J',
                 i_Test_Query    => v_Test_Query,
                 i_Error_Message => v_Error_Message,
                 i_Detail        => i_Arguments,
                 i_Executed_In   => -1,
                 i_Request       => null,
                 i_Input         => null);
      end;
      commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Function j_Pop_Procedure return Biruni_Job_Once_Procedures%rowtype is
    pragma autonomous_transaction;
    v_Row Biruni_Job_Once_Procedures%rowtype;
    cursor c_Lock is
      select *
        from Biruni_Job_Once_Procedures t
       where t.Start_Time < sysdate
       order by Start_Time
         for update Skip Locked;
  begin
  
    open c_Lock;
    fetch c_Lock
      into v_Row;
    close c_Lock;
  
    delete Biruni_Job_Once_Procedures t
     where t.Id = v_Row.Id;
  
    commit;
    return v_Row;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure j_Eval_Procedures is
    p Biruni_Job_Once_Procedures%rowtype;
  begin
    loop
      exit when not Job_Enabled;
      p := j_Pop_Procedure;
      exit when p.Id is null;
      j_Execute_Procedure(p.Procedure_Name, p.Procedure_Args);
    end loop;
  
  exception
    when others then
      Save_Log(i_Status        => 'FJ',
               i_Test_Query    => null,
               i_Error_Message => sqlerrm || Chr(13) || Chr(13) ||
                                  Dbms_Utility.Format_Error_Backtrace,
               i_Detail        => null,
               i_Executed_In   => -1,
               i_Request       => null,
               i_Input         => null);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Info
  (
    Writer  in out nocopy Stream,
    i_Query Fazo_Query,
    i_Names Hashmap
  ) is
    v_Field        Arraylist;
    v_Count        number;
    v_Name         varchar2(50);
    v_Query        varchar2(4000);
    v_Table_Name   varchar2(4000);
    v_Code_Field   varchar2(100);
    v_Name_Field   varchar2(100);
    v_Parent_Field varchar2(100);
    v_Number_Type  boolean;
    v_Manual_Sort  boolean;
    v_Codes        Array_Varchar2;
    v_Elems        Array_Varchar2;
    v_Local_Writer Stream;
    v_Entry        Hashmap;
    v_Refer        Hashmap;
    v_Params       Hashmap := Nvl(i_Query.Params, Hashmap());
    v_Refers       Hashmap := Hashmap();
    v_Data         Hashmap := Hashmap();
  begin
    for i in 1 .. i_Names.Buckets.Count
    loop
      v_Entry        := Treat(i_Names.Buckets(i).Val as Hashmap);
      v_Refer        := Hashmap();
      v_Local_Writer := Stream();
      v_Name         := i_Names.Buckets(i).Key;
      v_Field        := i_Query.Fields.r_Arraylist(v_Name);
      if v_Field.r_Varchar2(1) = Fazo_Schema.Fazo_Util.c_f_Refer then
        v_Table_Name  := Nvl(v_Field.r_Varchar2(6), v_Field.r_Varchar2(3));
        v_Code_Field  := v_Field.r_Varchar2(4);
        v_Name_Field  := v_Field.r_Varchar2(5);
        v_Manual_Sort := v_Field.r_Varchar2(8) = 'Y';
      
        begin
          v_Query := 'SELECT COUNT(*) FROM ' || v_Table_Name;
          v_Count := Fazo_Schema.Fazo_Util.Execute_Count(i_Query => v_Query, i_Params => v_Params);
        exception
          when others then
            Raise_Application_Error(-20999, 'invalid query column=' || v_Name);
        end;
        v_Parent_Field := v_Entry.o_Varchar2('parent_field');
        if v_Parent_Field is not null then
          v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ', ' || v_Parent_Field ||
                     ' FROM ' || v_Table_Name;
        
          Fazo_Schema.Fazo_Util.Execute_Query(v_Query, v_Params, v_Local_Writer);
        
          v_Refer.Put('data', Fazo_Schema.Gws_Json_Value(v_Local_Writer.Val));
        elsif v_Count <= v_Entry.r_Number('limit') then
          v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ' FROM ' || v_Table_Name;
        
          if not v_Manual_Sort then
            v_Query := v_Query || ' order by ' || v_Name_Field;
          end if;
        
          Fazo_Schema.Fazo_Util.Execute_Query(v_Query, v_Params, v_Local_Writer);
        
          v_Refer.Put('data', Fazo_Schema.Gws_Json_Value(v_Local_Writer.Val));
        else
          v_Number_Type := i_Query.Fields.r_Arraylist(v_Field.r_Varchar2(2))
                           .r_Varchar2(1) = Fazo_Schema.Fazo_Util.c_f_Number;
          v_Codes       := v_Entry.o_Array_Varchar2('val');
        
          if not Fazo.Is_Empty(v_Codes) then
            v_Elems := Array_Varchar2();
            for i in 1 .. v_Codes.Count
            loop
              v_Params.Put('iv' || i, v_Codes(i));
              if v_Number_Type then
                Fazo.Push(v_Elems, 'to_number(:iv' || i || ')');
              else
                Fazo.Push(v_Elems, ':iv' || i);
              end if;
            end loop;
          
            v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ' FROM ' || v_Table_Name ||
                       ' WHERE ' || v_Code_Field || ' IN (' || Fazo.Gather(v_Elems, ',') || ')';
          
            Fazo_Schema.Fazo_Util.Execute_Query(v_Query, v_Params, v_Local_Writer);
          
            v_Refer.Put('val', Fazo_Schema.Gws_Json_Value(v_Local_Writer.Val));
          end if;
          v_Refer.Put('count', v_Count);
        end if;
        v_Refers.Put(v_Name, v_Refer);
      end if;
    end loop;
  
    v_Data.Put('fields', i_Query.Fields);
    v_Data.Put('refers', v_Refers);
  
    v_Data.Print_Json(Writer);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pm(Input Array_Varchar2) return Hashmap is
    result Hashmap := Fazo.Parse_Map(Input);
  begin
    if result is not null then
      return result;
    else
      return Hashmap();
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pa(Input Array_Varchar2) return Arraylist is
    result Arraylist := Fazo.Parse_Array(Input);
  begin
    if result is not null then
      return result;
    else
      return Arraylist();
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pv(d Fazo_Schema.w_Wrapper) return Array_Varchar2 is
  begin
    if d is null then
      return Array_Varchar2();
    else
      return Fazo.To_Json(d).Val;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pv(d Json_Object_t) return Array_Varchar2 is
  begin
    return Fazo.Read_Clob(d.To_Clob);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pv(d Json_Array_t) return Array_Varchar2 is
  begin
    return Fazo.Read_Clob(d.To_Clob);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pf(d Fazo_Schema.Fazo_File) return Array_Varchar2 is
    result Hashmap := Hashmap();
  begin
    if d is null then
      return Array_Varchar2();
    end if;
  
    Result.Put('command', d.l_Command_Type);
    Result.Put('attachment_name',
               Nvl(d.l_Attachment_Name,
                   'smartup_files(' || to_char(sysdate, 'DD.MM.YYYY+HH24:MI:SS') || ')'));
    Result.Put('files', Fazo_Schema.Gws_Json_Value(Fazo.To_Json(d.l_Files).Val));
  
    return Fazo.To_Json(result).Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Plr(d Lazy_Report) return varchar2 is
  begin
    return d.Get_Value;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Plrc(d Lazy_Report_Convertor) return number is
  begin
    return d.Get_Value;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pq
  (
    i_Query           Fazo_Query,
    i_Params          Hashmap,
    i_Check_Procedure varchar2
  ) return Array_Varchar2 is
    v_Do           varchar2(30) := i_Params.o_Varchar2('do');
    Writer         Stream := Stream();
    v_Manual_Sort  boolean;
    v_Query_Text   varchar2(4000);
    v_Limit        number;
    v_Rownum_Start number;
    v_Rownum_End   number;
    v_Sort         Array_Varchar2 := i_Params.o_Array_Varchar2('sort');
    v_Refer_Name   varchar2(100) := i_Params.o_Varchar2('refer_name');
    v_Refer_Field  Arraylist;
    v_Refer        Fazo_Query;
  begin
    execute immediate 'BEGIN ' || i_Check_Procedure || '(:cols);END;'
      using in i_Params.o_Array_Varchar2('column');
  
    v_Limit := Nvl(i_Params.o_Number('limit'), 100);
  
    if v_Limit < 1 then
      v_Limit := 100;
    elsif v_Limit > 1000 then
      v_Limit := 1000;
    end if;
  
    v_Rownum_Start := Nvl(i_Params.o_Number('offset'), 0);
    v_Rownum_End   := v_Rownum_Start + Nvl(v_Limit, 100) + 1;
  
    if v_Sort is null then
      v_Sort := Array_Varchar2();
    end if;
  
    if v_Refer_Name is not null then
      v_Refer_Field := i_Query.Fields.r_Arraylist(v_Refer_Name);
    
      if v_Refer_Field.r_Varchar2(1) != Fazo_Schema.Fazo_Util.c_f_Refer then
        Raise_Application_Error(-20999, 'Invalid query: field type is not refer');
      end if;
    
      v_Query_Text := 'SELECT ' || v_Refer_Field.r_Varchar2(4) || ' code,' ||
                      v_Refer_Field.r_Varchar2(5) || ' name FROM ' ||
                      Nvl(v_Refer_Field.r_Varchar2(6), v_Refer_Field.r_Varchar2(3));
    
      v_Manual_Sort := v_Refer_Field.r_Varchar2(8) = 'Y';
    
      if not v_Manual_Sort then
        v_Query_Text := v_Query_Text || ' order by ' || v_Refer_Field.r_Varchar2(5);
      end if;
    
      v_Refer := Fazo_Query(v_Query_Text);
    
      v_Refer.Varchar2_Field('code', 'name');
    
      Fazo_Schema.Fazo_Util.Execute_Query_Page(i_Query                => v_Refer.Query,
                                               i_Params               => i_Query.Params, -- query param
                                               i_Fields               => v_Refer.Fields,
                                               i_Columns_After_Filter => v_Refer.Columns_After_Filter,
                                               i_Column               => i_Params.r_Array_Varchar2('column'),
                                               i_Filter               => i_Params.o_Arraylist('filter'),
                                               i_Sort                 => Array_Varchar2(),
                                               i_Rownum_Start         => v_Rownum_Start,
                                               i_Rownum_End           => v_Rownum_End,
                                               i_Namespace            => 'b',
                                               Writer                 => Writer,
                                               i_Metadata             => v_Refer.Metadata);
    elsif v_Do is null then
      Fazo_Schema.Fazo_Util.Execute_Query_Page(i_Query                => i_Query.Query,
                                               i_Params               => i_Query.Params,
                                               i_Fields               => i_Query.Fields,
                                               i_Columns_After_Filter => i_Query.Columns_After_Filter,
                                               i_Column               => i_Params.r_Array_Varchar2('column'),
                                               i_Filter               => i_Params.o_Arraylist('filter'),
                                               i_Sort                 => v_Sort,
                                               i_Rownum_Start         => v_Rownum_Start,
                                               i_Rownum_End           => v_Rownum_End,
                                               i_Namespace            => 'b',
                                               Writer                 => Writer,
                                               i_Metadata             => i_Query.Metadata);
    elsif v_Do = '1' then
      Fields_Info(Writer  => Writer, --
                  i_Query => i_Query,
                  i_Names => i_Params.r_Hashmap('refers'));
    
    elsif v_Do = '2' then
      execute immediate 'begin biruni_grid.export(:1,:2);end;'
        using in i_Query, i_Params;
    
    else
      Raise_Application_Error(-20999, 'Invalid query request');
    end if;
  
    if Writer is not null then
      return Writer.Val;
    end if;
  
    return Array_Varchar2();
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pqb
  (
    o_Query           out nocopy varchar2,
    i_Execute         boolean,
    i_Query           Fazo_Query,
    i_Params          Hashmap,
    i_Check_Procedure varchar2
  ) return Array_Varchar2 is
    v_Name         varchar2(100) := i_Params.o_Varchar2('name');
    v_Column       Array_Varchar2 := i_Params.r_Array_Varchar2('column');
    v_Filter       Arraylist := i_Params.o_Arraylist('filter');
    v_Sort         Array_Varchar2 := i_Params.o_Array_Varchar2('sort');
    v_Offset       number := i_Params.o_Number('offset');
    v_Limit        number := Nvl(i_Params.o_Number('limit'), 20);
    v_Rownum_Start number := Nvl(v_Offset, 0);
    v_Rownum_End   number := v_Rownum_Start + Nvl(v_Limit, 20) + 1;
    Writer         Stream := Stream();
    v_Query        varchar2(32767);
    v_Params       Hashmap;
  begin
    execute immediate 'BEGIN ' || i_Check_Procedure || '(:cols);END;'
      using in i_Params.o_Array_Varchar2('column');
  
    if v_Limit not between 1 and 5000 then
      v_Limit := 20;
    end if;
  
    if v_Sort is null then
      v_Sort := Array_Varchar2();
    end if;
  
    if v_Name is null then
      Fazo_Schema.Fazo_Util.Build_Query_Page(i_Query                => i_Query.Query,
                                             i_Params               => i_Query.Params,
                                             i_Fields               => i_Query.Fields,
                                             i_Columns_After_Filter => i_Query.Columns_After_Filter,
                                             i_Column               => v_Column,
                                             i_Filter               => v_Filter,
                                             i_Sort                 => v_Sort,
                                             i_Rownum_Start         => v_Rownum_Start,
                                             i_Rownum_End           => v_Rownum_End,
                                             i_Namespace            => 'b',
                                             o_Query                => v_Query,
                                             o_Params               => v_Params);
      o_Query := Fazo_Schema.Fazo_Util.Serial_Query(v_Query, v_Params);
      if i_Execute then
        Fazo_Schema.Fazo_Util.Execute_Query_Page(i_Query        => i_Query.Query,
                                                 i_Params       => i_Query.Params,
                                                 i_Fields       => i_Query.Fields,
                                                 i_Column       => v_Column,
                                                 i_Filter       => v_Filter,
                                                 i_Sort         => v_Sort,
                                                 i_Rownum_Start => v_Rownum_Start,
                                                 i_Rownum_End   => v_Rownum_End,
                                                 i_Namespace    => 'b',
                                                 Writer         => Writer);
      end if;
    
    end if;
    if Writer is not null then
      return Writer.Val;
    end if;
    return Array_Varchar2();
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pjo(Input Array_Varchar2) return Json_Object_t is
  begin
    return Json_Object_t.Parse(Fazo.Make_Clob(Input));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pja(Input Array_Varchar2) return Json_Array_t is
  begin
    return Json_Array_t.Parse(Fazo.Make_Clob(Input));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Query
  (
    i_Action_Name     varchar2,
    i_Action_In       varchar2,
    i_Action_Out      varchar2,
    i_Check_Procedure varchar2
  ) return varchar2 is
    v_Query varchar2(4000);
  begin
  
    if i_Action_Out = 'Q' then
      v_Query := i_Action_Name || case i_Action_In
                   when 'M' then
                    '(d.o_hashmap(''d''))'
                   when 'L' then
                    '(d.o_arraylist(''d''))'
                   when 'A' then
                    '(d.o_array_varchar2(''d''))'
                   when 'V' then
                    '(d.o_varchar2(''d''))'
                   else
                    ''
                 end;
    else
      v_Query := i_Action_Name || case i_Action_In
                   when 'M' then
                    '(Biruni_Core.Pm(input))'
                   when 'L' then
                    '(Biruni_Core.Pa(input))'
                   when 'A' then
                    '(input)'
                   when 'V' then
                    '(Fazo.Gather(input, null))'
                   when 'JO' then
                    '(Biruni_Core.Pjo(input))'
                   when 'JA' then
                    '(Biruni_Core.Pja(input))'
                   else
                    ''
                 end;
    end if;
  
    v_Query := case i_Action_Out
                 when 'Q' then
                  'd:=Biruni_Core.Pm(input);output:=Biruni_Core.Pq(' || v_Query ||
                  ',d.r_hashmap(''p''),''' || i_Check_Procedure || ''')'
                 when 'M' then
                  'output:=Biruni_Core.Pv(' || v_Query || ')'
                 when 'L' then
                  'output:=Biruni_Core.Pv(' || v_Query || ')'
                 when 'A' then
                  'output:=' || v_Query
                 when 'V' then
                  'output:=array_varchar2(' || v_Query || ')'
                 when 'JO' then
                  'output:=Biruni_Core.Pv(' || v_Query || ')'
                 when 'JA' then
                  'output:=Biruni_Core.Pv(' || v_Query || ')'
                 when 'F' then
                  'output:=Biruni_Core.Pf(' || v_Query || ')'
                 when 'R' then
                  'output:=' || v_Query
                 when 'LR' then
                  'output:=Biruni_Core.Plr(' || v_Query || ')'
                 when 'LC' then
                  'output:=Biruni_Core.Plrc(' || v_Query || ')'
                 else
                  v_Query
               end;
  
    return v_Query;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Test_Query
  (
    i_Setting Biruni_Settings%rowtype,
    i_Route   Biruni_Routes%rowtype
  ) return varchar2 is
    v varchar2(4000);
  begin
  
    v := '-- ' || Rpad(i_Route.Action_Name, 100) || Chr(13) || Chr(10);
    v := v || 'declare r biruni_log_inputs%rowtype := biruni_core.take_log_input($log_id);';
    v := v || 'input array_varchar2:=fazo.read_clob(r.input);';
    v := v || 'output array_varchar2;d hashmap;BEGIN ';
    v := v || 'Biruni_Route.Context_Begin(r.request);';
  
    case i_Route.Access_Type
      when 'A' then
        v := v || i_Setting.Authenticate_Procedure || ';' || i_Setting.Authorize_Procedure || ';';
      when 'S' then
        v := v || i_Setting.Authenticate_Procedure || ';';
      else
        null;
    end case;
  
    v := v || Gen_Query(i_Action_Name     => i_Route.Action_Name,
                        i_Action_In       => i_Route.Action_In,
                        i_Action_Out      => i_Route.Action_Out,
                        i_Check_Procedure => i_Setting.Check_Query_Procedure);
    v := replace(v, 'Biruni_Core.Pq(', 'Biruni_Core.Pqb(:sql,false,') || ';';
  
    if i_Route.Access_Type = 'E' then
      v := v || ':old_session:=b_session.request_session;';
      v := v || ':new_session:=b_session.response_session;';
    end if;
  
    v := v || ':request:=r.request;';
    v := v || ':input:=fazo.make_clob(input);';
    v := v || ':output:=fazo.make_clob(output);';
    v := v || 'biruni_route.context_end;rollback;END;';
  
    return v;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Review_Log(i_Log_Id number) is
    v_Setting Biruni_Settings%rowtype := Load_Setting();
  begin
    execute immediate 'BEGIN ' || v_Setting.Review_Log_Procedure || '(:log_id); END;'
      using in i_Log_Id;
  exception
    when others then
      null;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Log
  (
    i_Status        varchar2,
    i_Test_Query    varchar2,
    i_Error_Message varchar2,
    i_Detail        varchar2,
    i_Executed_In   number,
    i_Request       varchar2,
    i_Input         clob
  ) is
    pragma autonomous_transaction;
    r_Log Biruni_Log%rowtype;
  begin
    r_Log.Log_Id        := Biruni_Log_Sq.Nextval;
    r_Log.Status        := i_Status;
    r_Log.Test_Query    := Substrb(replace(i_Test_Query, '$log_id', r_Log.Log_Id), 1, 4000);
    r_Log.Error_Message := Substrb(i_Error_Message, 1, 4000);
    r_Log.Detail        := Substrb(i_Detail, 1, 4000);
    r_Log.Executed_In   := i_Executed_In;
    r_Log.Created_On    := sysdate;
  
    insert into Biruni_Log
    values r_Log;
  
    if r_Log.Status like '_i%' then
    
      insert into Biruni_Log_Inputs
        (Log_Id, Request, Input)
      values
        (r_Log.Log_Id, i_Request, i_Input);
    
    end if;
  
    Review_Log(r_Log.Log_Id);
  
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Route_History is
    pragma autonomous_transaction;
    v_Setting Biruni_Settings%rowtype;
  begin
    v_Setting := Load_Setting();
  
    if v_Setting.Review_Route_History_Procedure is not null then
      execute immediate 'BEGIN ' || v_Setting.Review_Route_History_Procedure || '; END;';
    
      commit;
    end if;
  exception
    when others then
      rollback;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Log_All is
    pragma autonomous_transaction;
  begin
    z_Biruni_Settings.Update_One(i_Code => 'U', i_Log_Policy => Option_Varchar2('SiEiFiUiRiNi'));
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Log_Standart is
    pragma autonomous_transaction;
  begin
    z_Biruni_Settings.Update_One(i_Code => 'U', i_Log_Policy => Option_Varchar2('FiRi'));
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Log(i_Log_Id number) return Biruni_Log%rowtype is
    result Biruni_Log%rowtype;
  begin
    select t.*
      into result
      from Biruni_Log t
     where t.Log_Id = i_Log_Id;
    return result;
  exception
    when No_Data_Found then
      Raise_Application_Error(-20999, 'Log not found');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Take_Log_Input(i_Log_Id number) return Biruni_Log_Inputs%rowtype is
    r Biruni_Log_Inputs%rowtype;
  begin
    select t.*
      into r
      from Biruni_Log_Inputs t
     where t.Log_Id = i_Log_Id;
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code_Common(i_Lang_Code varchar2) is
    pragma autonomous_transaction;
  begin
    if Regexp_Like(i_Lang_Code, '^[A-Za-z0-9]+$') then
      execute immediate 'ALTER TABLE biruni_translations ADD text_' || i_Lang_Code ||
                        ' VARCHAR2(4000 CHAR)';
      Fazo_z.Run('biruni_translations');
    end if;
    commit;
  exception
    when others then
      Fazo_z.Run('biruni_translations');
      rollback;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code_Custom(i_Lang_Code varchar2) is
    pragma autonomous_transaction;
  begin
    if Regexp_Like(i_Lang_Code, '^[A-Za-z0-9]+$') then
      execute immediate 'ALTER TABLE biruni_custom_translations ADD text_' || i_Lang_Code ||
                        ' VARCHAR2(4000 CHAR)';
      Fazo_z.Run('biruni_custom_translations');
    end if;
    commit;
  exception
    when others then
      Fazo_z.Run('biruni_custom_translations');
      rollback;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code(i_Lang_Code varchar2) is
  begin
    Add_Lang_Code_Common(i_Lang_Code);
    Add_Lang_Code_Custom(i_Lang_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  -- DEPRECATED
  ----------------------------------------------------------------------------------------------------
  Procedure Take_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2,
    o_Text      out varchar2,
    o_Custom    out varchar2
  ) is
  begin
    Biruni_Util.Take_Translation(i_Message   => i_Message,
                                 i_Lang_Code => i_Lang_Code,
                                 o_Text      => o_Text,
                                 o_Custom    => o_Custom);
  end;

  ----------------------------------------------------------------------------------------------------
  -- DEPRECATED
  ----------------------------------------------------------------------------------------------------
  Function Take_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2 is
  begin
    return Biruni_Util.Take_Translation(i_Message => i_Message, i_Lang_Code => i_Lang_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2,
    i_Text      varchar2,
    i_Custom    varchar2 := null,
    i_Generated varchar2 := null
  ) is
    v_Custom varchar2(1) := Nvl(i_Custom, 'N');
  begin
    if not Regexp_Like(i_Lang_Code, '^[a-z]+$') then
      Raise_Application_Error(-20999, 'Invalid lang code');
    end if;
  
    execute immediate 'UPDATE biruni_translations SET text_' || i_Lang_Code ||
                      '=:v, custom =:c WHERE message=:m'
      using i_Text, v_Custom, i_Message;
  
    if sql%notfound then
      execute immediate 'INSERT INTO biruni_translations(message,text_' || i_Lang_Code ||
                        ',custom) VALUES (:m,:v,:c)'
        using i_Message, i_Text, v_Custom;
    end if;
  
    -- save generated translates
    if i_Text is not null and i_Generated = 'Y' then
      z_Biruni_Generated_Translations.Insert_Try(i_Message   => i_Message,
                                                 i_Lang_Code => i_Lang_Code);
    else
      z_Biruni_Generated_Translations.Delete_One(i_Message   => i_Message,
                                                 i_Lang_Code => i_Lang_Code);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  -- DEPRECATED
  ----------------------------------------------------------------------------------------------------
  Function Take_Custom_Translation
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2 is
  begin
    return Biruni_Util.Take_Custom_Translation(i_Code      => i_Code,
                                               i_Message   => i_Message,
                                               i_Lang_Code => i_Lang_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Custom_Translation
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Lang_Code varchar2,
    i_Text      varchar2
  ) is
  begin
    if not Regexp_Like(i_Lang_Code, '^[a-z]+$') then
      Raise_Application_Error(-20999, 'Invalid lang code');
    end if;
  
    execute immediate 'UPDATE biruni_custom_translations SET text_' || i_Lang_Code ||
                      '=:v WHERE code =:c AND message=:m'
      using i_Text, i_Code, i_Message;
  
    if sql%notfound then
      execute immediate 'INSERT INTO biruni_custom_translations(code,message,text_' || i_Lang_Code ||
                        ') VALUES (:m,:v,:c)'
        using i_Code, i_Message, i_Text;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Map Fazo.Varchar2_Code_Aat) return varchar2 is
    v_Key varchar2(23767);
    v     varchar2(32767) := '{';
    Function Entry
    (
      i_Key   varchar2,
      i_Value varchar2
    ) return varchar2 is
    begin
      return '"' || Fazo.Json_Escape(i_Key) || '":"' || Fazo.Json_Escape(i_Value) || '"';
    end;
  begin
    v_Key := i_Map.First;
    if v_Key is not null then
      v     := v || Entry(v_Key, i_Map(v_Key));
      v_Key := i_Map.Next(v_Key);
    end if;
    loop
      exit when v_Key is null;
      v     := v || ',' || Entry(v_Key, i_Map(v_Key));
      v_Key := i_Map.Next(v_Key);
    end loop;
  
    return v || '}';
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Desolate_Procedure(i_Sha varchar2) is
    v_Proc Array_Varchar2 := Array_Varchar2();
    ---- execute desolate procedure
    Procedure Execute_Procedure(i_Procedure varchar2) is
    begin
      execute immediate 'BEGIN ' || i_Procedure || '(:sha); END;'
        using in i_Sha;
    
      Fazo.Push(v_Proc, i_Procedure);
    exception
      when others then
        null;
    end;
  begin
    for r in (select *
                from Biruni_File_Desolates q
               where q.Sha = i_Sha)
    loop
      Execute_Procedure(r.Desolate_Procedure);
    end loop;
  
    if v_Proc.Count > 0 then
      delete Biruni_File_Desolates q
       where q.Sha = i_Sha
         and q.Desolate_Procedure member of v_Proc;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Bf_Try_Delete
  (
    i_Sha        varchar2,
    i_Store_Kind varchar2
  ) is
  begin
    delete from Biruni_Files
     where Sha = i_Sha;
  
    if i_Store_Kind = 'S' then
      insert into Biruni_Files_To_Delete
        (Sha, Status)
      values
        (i_Sha, 'N');
    end if;
  exception
    when others then
      -- ORA-00001: unique constraint violated
      -- ORA-02292: violated integrity constraint (owner.constraintname)- child record found
      if sqlcode not in (-1, -2292) then
        Raise_Application_Error(-20999, 'Unexpected error on Bf_Try_Delete');
      end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Bf_Cleaner is
  begin
    for r in (select q.Sha, q.Store_Kind
                from Biruni_Files q
               where not exists (select 1
                        from Biruni_File_Desolates w
                       where w.Sha = q.Sha))
    loop
      Bf_Try_Delete(r.Sha, r.Store_Kind);
    end loop;
  
    delete Biruni_Filespace q
     where not exists (select 1
              from Biruni_Files w
             where w.Sha = q.Sha);
  
    delete Biruni_File_Links q
     where q.Link_Expires_On < sysdate;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Biruni_Url_Params_Cleaner is
  begin
    delete Biruni_Url_Params q
     where q.Modified_On < Current_Timestamp - 1;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Biruni_Log_Cleaner is
  begin
    delete Biruni_Log q
     where q.Created_On < sysdate - 30;
  
    delete Biruni_Manual_Log q
     where q.Created_On < sysdate - 30;
  
    delete Biruni_App_Server_Exceptions_Today q
     where q.Created_On < sysdate - 30;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Cleaner is
  begin
    delete Biruni_Lazy_Report_Register q
     where q.Created_On > sysdate - 1
       and q.Status in (Biruni_Pref.c_Lazy_Report_Status_New, --
                        Biruni_Pref.c_Lazy_Report_Status_Executing);
  
    delete Biruni_Lazy_Report_Register q
     where q.Created_On > sysdate - 7
       and q.Status = Biruni_Pref.c_Lazy_Report_Status_Failed;
  
    delete Biruni_Lazy_Report_Register q
     where q.Created_On > sysdate - 90;
  end;

end Biruni_Core;
/
