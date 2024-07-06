create or replace package Biruni_Api is
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Enable;
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Disable;
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Start(i_Interval_In_Seconds number := null);
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Stop;
  ----------------------------------------------------------------------------------------------------
  Procedure Log_All;
  ----------------------------------------------------------------------------------------------------
  Procedure Log_Standart;
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code(i_Lang_Code varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Service_Available(i_State boolean);
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Setting
  (
    i_Lang_Code               Option_Varchar2 := null,
    i_Authenticate_Procedure  Option_Varchar2 := null,
    i_Authorize_Procedure     Option_Varchar2 := null,
    i_Review_Procedure        Option_Varchar2 := null,
    i_Log_Policy              Option_Varchar2 := null,
    i_Log_Time_Limit          Option_Number := null,
    i_Job_Enabled             Option_Varchar2 := null,
    i_Job_Max_Workers         Option_Number := null,
    i_Job_Interval_In_Seconds Option_Number := null,
    i_Timezone_Code           Option_Varchar2 := null,
    i_Ip_Policy_Enabled       Option_Varchar2 := null,
    i_Service_Available       Option_Varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Route
  (
    i_Uri                varchar2,
    i_Action_Name        varchar2,
    i_Access_Type        varchar2,
    i_Allowed_Auth_Types varchar2,
    i_Review             varchar2 := null,
    i_Log_Policy         varchar2 := null,
    i_Log_Time_Limit     varchar2 := null,
    i_Scope              varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Ip_Range_Save
  (
    i_Order_No number,
    i_Ip_Begin varchar2,
    i_Ip_End   varchar2,
    i_Action   varchar2,
    i_State    varchar2,
    i_Note     varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Ip_Range_Delete(i_Order_No number);
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Desolate_File
  (
    i_Sha       varchar2,
    i_Procedure varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Desolate_Files;
  ----------------------------------------------------------------------------------------------------  
  Function Manual_Log_Save
  (
    i_Origin        varchar2,
    i_Error_Message varchar2,
    i_Detail        varchar2 := null,
    i_Executed_In   number := null
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Function Lazy_Report_Register_Save
  (
    i_Request_Uri   varchar2,
    i_Run_Procedure varchar2,
    i_Input_Data    Array_Varchar2
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Register_Update
  (
    i_Register_Id     number,
    i_Status          Option_Varchar2 := null,
    i_Run_Procedure   Option_Varchar2 := null,
    i_Input_Data      Option_Varchar2 := null,
    i_File_Sha        Option_Varchar2 := null,
    i_Html_Sha        Option_Varchar2 := null,
    i_Has_Metadata    Option_Varchar2 := null,
    i_Error_Message   Option_Varchar2 := null,
    i_Error_Backtrace Option_Varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Register_Delete(i_Register_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Metadata_Save
  (
    i_Register_Id number,
    i_Metadata    clob
  );
end Biruni_Api;
/
create or replace package body Biruni_Api is
  ----------------------------------------------------------------------------------------------------
  Procedure Job_Enable is
  begin
    Biruni_Core.Job_Enable('Y');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Disable is
  begin
    Biruni_Core.Job_Enable('N');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Start(i_Interval_In_Seconds number := null) is
  begin
    Biruni_Core.Job_Start(i_Interval_In_Seconds);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Job_Stop is
  begin
    Biruni_Core.Job_Stop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Log_All is
  begin
    Biruni_Core.Log_All;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Log_Standart is
  begin
    Biruni_Core.Log_Standart;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Lang_Code(i_Lang_Code varchar2) is
  begin
    Biruni_Core.Add_Lang_Code(i_Lang_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Service_Available(i_State boolean) is
    pragma autonomous_transaction;
  begin
    if i_State then
      z_Biruni_Settings.Update_One(i_Code => 'U', i_Service_Available => Option_Varchar2('Y'));
    else
      z_Biruni_Settings.Update_One(i_Code => 'U', i_Service_Available => Option_Varchar2('N'));
    end if;
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Setting
  (
    i_Lang_Code               Option_Varchar2 := null,
    i_Authenticate_Procedure  Option_Varchar2 := null,
    i_Authorize_Procedure     Option_Varchar2 := null,
    i_Review_Procedure        Option_Varchar2 := null,
    i_Log_Policy              Option_Varchar2 := null,
    i_Log_Time_Limit          Option_Number := null,
    i_Job_Enabled             Option_Varchar2 := null,
    i_Job_Max_Workers         Option_Number := null,
    i_Job_Interval_In_Seconds Option_Number := null,
    i_Timezone_Code           Option_Varchar2 := null,
    i_Ip_Policy_Enabled       Option_Varchar2 := null,
    i_Service_Available       Option_Varchar2 := null
  ) is
  begin
    z_Biruni_Settings.Update_One(i_Code                    => Biruni_Core.Load_Setting().Code,
                                 i_Lang_Code               => i_Lang_Code,
                                 i_Authenticate_Procedure  => i_Authenticate_Procedure,
                                 i_Authorize_Procedure     => i_Authorize_Procedure,
                                 i_Review_Procedure        => i_Review_Procedure,
                                 i_Log_Policy              => i_Log_Policy,
                                 i_Log_Time_Limit          => i_Log_Time_Limit,
                                 i_Job_Enabled             => i_Job_Enabled,
                                 i_Job_Max_Workers         => i_Job_Max_Workers,
                                 i_Job_Interval_In_Seconds => i_Job_Interval_In_Seconds,
                                 i_Timezone_Code           => i_Timezone_Code,
                                 i_Ip_Policy_Enabled       => i_Ip_Policy_Enabled,
                                 i_Service_Available       => i_Service_Available);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Route
  (
    i_Uri                varchar2,
    i_Action_Name        varchar2,
    i_Access_Type        varchar2,
    i_Allowed_Auth_Types varchar2,
    i_Review             varchar2 := null,
    i_Log_Policy         varchar2 := null,
    i_Log_Time_Limit     varchar2 := null,
    i_Scope              varchar2 := null
  ) is
    v_Action_In  varchar2(2);
    v_Action_Out varchar2(2);
    r            Biruni_Routes%rowtype;
  begin
    begin
      select case
                when t.Data_Type = 'VARCHAR2' then
                 'V'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'HASHMAP' then
                 'M'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'ARRAYLIST' then
                 'L'
                when t.Data_Type = 'TABLE' and t.Type_Name = 'ARRAY_VARCHAR2' then
                 'A'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'JSON_OBJECT_T' then
                 'JO'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'JSON_ARRAY_T' then
                 'JA'
              end case
        into v_Action_In
        from User_Arguments t
       where t.Package_Name || '.' || t.Object_Name = Upper(i_Action_Name)
         and t.Argument_Name is not null
         and t.Data_Level = 0
         and t.In_Out = 'IN';
    exception
      when No_Data_Found then
        v_Action_In := null;
    end;
  
    begin
      select case
                when t.Data_Type = 'VARCHAR2' then
                 'V'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'HASHMAP' then
                 'M'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'ARRAYLIST' then
                 'L'
                when t.Data_Type = 'TABLE' and t.Type_Name = 'ARRAY_VARCHAR2' then
                 'A'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'JSON_OBJECT_T' then
                 'JO'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'JSON_ARRAY_T' then
                 'JA'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'FAZO_QUERY' then
                 'Q'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'FAZO_FILE' then
                 'F'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'RUNTIME_SERVICE' then
                 'R'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'LAZY_REPORT' then
                 'LR'
                when t.Data_Type = 'OBJECT' and t.Type_Name = 'LAZY_REPORT_CONVERTOR' then
                 'LC'
              end case
        into v_Action_Out
        from User_Arguments t
       where t.Package_Name || '.' || t.Object_Name = Upper(i_Action_Name)
         and t.Argument_Name is null
         and t.Data_Level = 0
         and t.In_Out = 'OUT';
    exception
      when No_Data_Found then
        v_Action_Out := null;
    end;
  
    r.Uri                := i_Uri;
    r.Action_Name        := i_Action_Name;
    r.Action_In          := v_Action_In;
    r.Action_Out         := v_Action_Out;
    r.Access_Type        := i_Access_Type;
    r.Allowed_Auth_Types := i_Allowed_Auth_Types;
    r.Review             := i_Review;
    r.Log_Policy         := i_Log_Policy;
    r.Log_Time_Limit     := i_Log_Time_Limit;
    r.Scope              := i_Scope;
  
    update Biruni_Routes q
       set row = r
     where q.Uri = r.Uri;
  
    if sql%notfound then
      insert into Biruni_Routes
      values r;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Ip_Range_Save
  (
    i_Order_No number,
    i_Ip_Begin varchar2,
    i_Ip_End   varchar2,
    i_Action   varchar2,
    i_State    varchar2,
    i_Note     varchar2
  ) is
    r_Data Biruni_Ip_Ranges%rowtype;
  begin
    r_Data.Order_No    := i_Order_No;
    r_Data.Ip_Begin    := i_Ip_Begin;
    r_Data.Ip_End      := i_Ip_End;
    r_Data.Value_Begin := Biruni_Core.Ipv4_To_Number(r_Data.Ip_Begin);
    r_Data.Value_End   := Biruni_Core.Ipv4_To_Number(r_Data.Ip_End);
    r_Data.Action      := i_Action;
    r_Data.State       := i_State;
    r_Data.Note        := i_Note;
  
    if r_Data.Value_Begin is null then
      b.Raise_Error('Invalid begin ip address $1', r_Data.Ip_Begin);
    end if;
    if r_Data.Value_End is null then
      b.Raise_Error('Invalid end ip address $2', r_Data.Ip_End);
    end if;
  
    z_Biruni_Ip_Ranges.Save_Row(r_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Ip_Range_Delete(i_Order_No number) is
  begin
    z_Biruni_Ip_Ranges.Delete_One(i_Order_No => i_Order_No);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Desolate_File
  (
    i_Sha       varchar2,
    i_Procedure varchar2
  ) is
  begin
    z_Biruni_File_Desolates.Insert_Try(i_Sha                => i_Sha, --
                                       i_Desolate_Procedure => i_Procedure);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Desolate_Files is
    v_Shas Array_Varchar2 := Biruni_Route.Request_File_Shas;
  begin
    for i in 1 .. v_Shas.Count
    loop
      Biruni_Core.Run_Desolate_Procedure(v_Shas(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Manual_Log_Save
  (
    i_Origin        varchar2,
    i_Error_Message varchar2,
    i_Detail        varchar2 := null,
    i_Executed_In   number := null
  ) return number is
    v_Log_Id number := Biruni_Manual_Log_Sq.Nextval;
  begin
    z_Biruni_Manual_Log.Insert_One(i_Log_Id        => v_Log_Id,
                                   i_Origin        => i_Origin,
                                   i_Error_Message => i_Error_Message,
                                   i_Detail        => i_Detail,
                                   i_Executed_In   => i_Executed_In);
  
    return v_Log_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Lazy_Report_Register_Save
  (
    i_Request_Uri   varchar2,
    i_Run_Procedure varchar2,
    i_Input_Data    Array_Varchar2
  ) return number is
    r_Register Biruni_Lazy_Report_Register%rowtype;
  begin
    r_Register.Register_Id   := Biruni_Lazy_Report_Register_Sq.Nextval;
    r_Register.Status        := Biruni_Pref.c_Lazy_Report_Status_New;
    r_Register.Request_Uri   := i_Request_Uri;
    r_Register.Run_Procedure := i_Run_Procedure;
    r_Register.Input_Data    := Fazo.Make_Clob(i_Input_Data);
    r_Register.File_Sha      := null;
    r_Register.Html_Sha      := null;
    r_Register.Has_Metadata  := 'N';
    r_Register.Error_Message := null;
  
    z_Biruni_Lazy_Report_Register.Insert_Row(r_Register);
  
    return r_Register.Register_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Register_Update
  (
    i_Register_Id     number,
    i_Status          Option_Varchar2 := null,
    i_Run_Procedure   Option_Varchar2 := null,
    i_Input_Data      Option_Varchar2 := null,
    i_File_Sha        Option_Varchar2 := null,
    i_Html_Sha        Option_Varchar2 := null,
    i_Has_Metadata    Option_Varchar2 := null,
    i_Error_Message   Option_Varchar2 := null,
    i_Error_Backtrace Option_Varchar2 := null
  ) is
    pragma autonomous_transaction;
  begin
    z_Biruni_Lazy_Report_Register.Update_One(i_Register_Id     => i_Register_Id,
                                             i_Status          => i_Status,
                                             i_Run_Procedure   => i_Run_Procedure,
                                             i_Input_Data      => i_Input_Data,
                                             i_File_Sha        => i_File_Sha,
                                             i_Html_Sha        => i_Html_Sha,
                                             i_Has_Metadata    => i_Has_Metadata,
                                             i_Error_Message   => i_Error_Message,
                                             i_Error_Backtrace => i_Error_Backtrace);
    commit;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Register_Delete(i_Register_Id number) is
    r_Register Biruni_Lazy_Report_Register%rowtype;
  begin
    r_Register := z_Biruni_Lazy_Report_Register.Take(i_Register_Id);
  
    if r_Register.Register_Id is not null then
      if r_Register.Status in
         (Biruni_Pref.c_Lazy_Report_Status_New, Biruni_Pref.c_Lazy_Report_Status_Executing) then
        b.Raise_Error('Deleting report with status $1 is not allowed', r_Register.Status);
      end if;
    
      z_Biruni_Lazy_Report_Register.Delete_One(i_Register_Id);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Lazy_Report_Metadata_Save
  (
    i_Register_Id number,
    i_Metadata    clob
  ) is
  begin
    insert into Biruni_Lazy_Report_Metadata
      (Register_Id, Metadata)
    values
      (i_Register_Id, i_Metadata);
  
    Lazy_Report_Register_Update(i_Register_Id  => i_Register_Id,
                                i_Has_Metadata => Option_Varchar2('Y'));
  end;

end Biruni_Api;
/
