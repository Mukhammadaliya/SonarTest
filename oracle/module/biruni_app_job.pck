create or replace package Biruni_App_Job is
  ----------------------------------------------------------------------------------------------------
  Procedure Application_Jobs_Info(o_Output out Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Application_Job_Log
  (
    i_Code          varchar2,
    i_Status        varchar2,
    i_Failed_In     varchar2 := null,
    i_Error_Message varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Request_Job
  (
    i_Request  varchar2,
    o_Response out varchar2,
    o_Output   out Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Response_Job
  (
    i_Request  varchar2,
    i_Input    Array_Varchar2,
    o_Response out varchar2
  );
end Biruni_App_Job;
/
create or replace package body Biruni_App_Job is
  ----------------------------------------------------------------------------------------------------
  Function Application_Job_Hash
  (
    i_Code       varchar2,
    i_Class_Name varchar2,
    i_Start_Time number,
    i_Period     number
  ) return varchar2 is
  begin
    return Fazo.Hash_Sha1(Fazo.Gather(Array_Varchar2(i_Code,
                                                     i_Class_Name,
                                                     to_char(i_Start_Time),
                                                     to_char(i_Period)),
                                      '#'));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Application_Jobs_Info(o_Output out Array_Varchar2) is
    v_Data Hashmap;
    result Arraylist := Arraylist();
  begin
    for r in (select q.Code, q.Class_Name, q.Start_Time, q.Period
                from Biruni_Application_Server_Jobs q
               where q.State = 'A')
    loop
      v_Data := Hashmap();
      v_Data.Put('code', r.Code);
      v_Data.Put('class_name', r.Class_Name);
      if r.Start_Time is null then
        v_Data.Put('delay', 0);
      else
        v_Data.Put('delay',
                   mod(1440 + r.Start_Time - Round((sysdate - Trunc(sysdate)) * 1440), 1440));
      end if;
    
      v_Data.Put('period', r.Period);
      v_Data.Put('hash',
                 Application_Job_Hash(i_Code       => r.Code,
                                      i_Class_Name => r.Class_Name,
                                      i_Start_Time => r.Start_Time,
                                      i_Period     => r.Period));
      Result.Push(v_Data);
    end loop;
  
    o_Output := Fazo.To_Json(result).Val;
  
  exception
    when others then
      o_Output := Fazo.To_Json(result).Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Application_Job_Log
  (
    i_Code          varchar2,
    i_Status        varchar2,
    i_Failed_In     varchar2,
    i_Error_Message varchar2
  ) is
    pragma autonomous_transaction;
  begin
    z_Biruni_App_Server_Job_Logs.Insert_One(i_Log_Id        => Biruni_App_Server_Job_Logs_Sq.Nextval,
                                            i_Code          => i_Code,
                                            i_Status        => i_Status,
                                            i_Log_Date      => sysdate,
                                            i_Failed_In     => i_Failed_In,
                                            i_Error_Message => Substr(i_Error_Message, 1, 500));
    commit;
  exception
    when others then
      null;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Request_Job
  (
    i_Request  varchar2,
    o_Response out varchar2,
    o_Output   out Array_Varchar2
  ) is
    r_Job  Biruni_Application_Server_Jobs%rowtype;
    v_Data Hashmap;
  begin
    o_Output := Array_Varchar2();
    v_Data   := Fazo.Parse_Map(i_Request);
    r_Job    := z_Biruni_Application_Server_Jobs.Take(v_Data.r_Varchar2('code'));
  
    if r_Job.Request_Procedure is not null then
      execute immediate 'declare output array_varchar2; begin ' || r_Job.Request_Procedure ||
                        '(output); :output := output; end;'
        using out o_Output;
    end if;
  
    o_Response := Fazo.Zip_Map('status', Biruni_Core.c_s_Success).Json;
    commit;
  exception
    when others then
      rollback;
      o_Response := Fazo.Zip_Map('status', Biruni_Core.c_s_Error,'error', sqlerrm).Json;
      o_Output   := Array_Varchar2();
    
      Save_Application_Job_Log(i_Code          => r_Job.Code,
                               i_Status        => 'F',
                               i_Failed_In     => 'RQ',
                               i_Error_Message => sqlerrm);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Response_Job
  (
    i_Request  varchar2,
    i_Input    Array_Varchar2,
    o_Response out varchar2
  ) is
    r_Job  Biruni_Application_Server_Jobs%rowtype;
    v_Data Hashmap;
  begin
    v_Data := Fazo.Parse_Map(i_Request);
    r_Job  := z_Biruni_Application_Server_Jobs.Take(v_Data.r_Varchar2('code'));
  
    if r_Job.Response_Procedure is not null then
      execute immediate 'begin ' || r_Job.Response_Procedure || '(:input); end;'
        using i_Input;
    end if;
  
    o_Response := Fazo.Zip_Map('status', Biruni_Core.c_s_Success).Json;
  
    Save_Application_Job_Log(i_Code => r_Job.Code, i_Status => 'S');
  exception
    when others then
      rollback;
      o_Response := Fazo.Zip_Map('status', Biruni_Core.c_s_Error,'error', sqlerrm).Json;
    
      Save_Application_Job_Log(i_Code          => r_Job.Code,
                               i_Status        => 'F',
                               i_Failed_In     => 'RS',
                               i_Error_Message => sqlerrm);
  end;

end Biruni_App_Job;
/
