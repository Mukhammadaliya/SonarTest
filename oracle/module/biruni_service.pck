create or replace package Biruni_Service is
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Arraylist
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Broadcast
  (
    i_Message  varchar2,
    i_User_Ids Array_Number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Firebase
  (
    i_Fcm_Url          varchar2,
    i_Auth_Key         varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Priority         varchar2,
    i_Data             Hashmap,
    i_Notification     Hashmap := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Hms
  (
    i_Auth_Server_Url  varchar2,
    i_Send_Message_Url varchar2,
    i_Client_Id        varchar2,
    i_Client_Secret    varchar2,
    i_Access_Token     varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Data             Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Email
  (
    i_To                    varchar2,
    i_To_Address            varchar2,
    i_Subject               varchar2,
    i_Message               varchar2,
    i_Html_Url              varchar2,
    i_Html_Replacement_Keys Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Sms
  (
    i_Phone   varchar2,
    i_Message varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Get_Final_Services return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Hms_Token
  (
    i_Client_Id    varchar2,
    i_Access_Token varchar2,
    i_Expires_In   number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Final_Service_Log(i_Error varchar2);
end Biruni_Service;
/
create or replace package body Biruni_Service is
  ----------------------------------------------------------------------------------------------------
  g_Final_Services Biruni_Pref.Final_Services;
  ----------------------------------------------------------------------------------------------------
  g_Email_Messages Arraylist;
  g_Sms_Messages   Arraylist;
  ----------------------------------------------------------------------------------------------------
  c_Broadcast_Service_Class varchar2(100) := 'uz.greenwhite.biruni.service.finalservice.BroadcastService';
  c_Firebase_Service_Class  varchar2(100) := 'uz.greenwhite.biruni.service.finalservice.FCMessagingService';
  c_Hms_Service_Class       varchar2(100) := 'uz.greenwhite.biruni.service.finalservice.HMSMessagingService';
  c_Email_Service_Class     varchar2(100) := 'uz.greenwhite.biruni.service.finalservice.SendEmailService';
  c_Sms_Service_Class       varchar2(100) := 'uz.greenwhite.biruni.service.finalservice.SendSMSService';
  ----------------------------------------------------------------------------------------------------
  Procedure Push_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Fazo_Schema.w_Wrapper
  ) is
    v_Final_Service Biruni_Pref.Final_Service;
    v_Data          Arraylist;
  begin
    if i_Class_Name is null then
      Raise_Application_Error(-20999, 'Final service class name should be defined');
    end if;
  
    if g_Final_Services is null then
      g_Final_Services := Biruni_Pref.Final_Services();
    end if;
  
    for i in 1 .. g_Final_Services.Count
    loop
      if i_Class_Name = g_Final_Services(i).Class_Name then
        g_Final_Services(i).Data.Push(i_Data);
        return;
      end if;
    end loop;
  
    v_Data := Arraylist();
    v_Data.Push(i_Data);
    v_Final_Service.Class_Name := i_Class_Name;
    v_Final_Service.Data       := v_Data;
  
    g_Final_Services.Extend;
    g_Final_Services(g_Final_Services.Count) := v_Final_Service;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Hashmap
  ) is
  begin
    Push_Final_Service(i_Class_Name, i_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Arraylist
  ) is
  begin
    Push_Final_Service(i_Class_Name, i_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Broadcast
  (
    i_Message  varchar2,
    i_User_Ids Array_Number
  ) is
    v_User_Ids Array_Number := Array_Number();
    v_Data     Arraylist := Arraylist();
  begin
    for i in 1 .. i_User_Ids.Count
    loop
      if i_User_Ids(i) is not null then
        Fazo.Push(v_User_Ids, i_User_Ids(i));
      end if;
    end loop;
  
    if v_User_Ids.Count = 0 then
      Raise_Application_Error(-20999, 'BIRUNI: empty user while broadcasting message');
    end if;
  
    v_Data.Push(i_Message);
    v_Data.Push(i_User_Ids);
  
    Push_Final_Service(i_Class_Name => c_Broadcast_Service_Class, i_Data => v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Firebase
  (
    i_Fcm_Url          varchar2,
    i_Auth_Key         varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Priority         varchar2,
    i_Data             Hashmap,
    i_Notification     Hashmap := null
  ) is
    v_Data Arraylist := Arraylist();
  begin
    if i_Registration_Ids.Count = 0 then
      Raise_Application_Error(-20999, 'BIRUNI: empty user while firebase message');
    end if;
  
    v_Data.Push(i_Fcm_Url);
    v_Data.Push(i_Auth_Key);
    v_Data.Push(i_Registration_Ids);
    v_Data.Push(i_Priority);
    v_Data.Push(i_Data);
  
    if i_Notification is not null then
      v_Data.Push(i_Notification);
    else
      v_Data.Push(Hashmap());
    end if;
  
    Push_Final_Service(i_Class_Name => c_Firebase_Service_Class, i_Data => v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Hms
  (
    i_Auth_Server_Url  varchar2,
    i_Send_Message_Url varchar2,
    i_Client_Id        varchar2,
    i_Client_Secret    varchar2,
    i_Access_Token     varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Data             Hashmap
  ) is
    v_Data Arraylist := Arraylist();
  begin
    if i_Registration_Ids.Count = 0 then
      Raise_Application_Error(-20999, 'BIRUNI: empty user while HMS message');
    end if;
  
    if i_Auth_Server_Url is null or i_Send_Message_Url is null or i_Client_Id is null or
       i_Client_Secret is null then
      return;
    end if;
  
    v_Data.Push(i_Auth_Server_Url);
    v_Data.Push(i_Send_Message_Url);
    v_Data.Push(i_Client_Id);
    v_Data.Push(i_Client_Secret);
    v_Data.Push(i_Access_Token);
    v_Data.Push(i_Registration_Ids);
    v_Data.Push(i_Data);
  
    Push_Final_Service(i_Class_Name => c_Hms_Service_Class, i_Data => v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push_Email is
    v_Data    Arraylist;
    r_Setting Biruni_Messaging_Service_Setting%rowtype;
  begin
    r_Setting := z_Biruni_Messaging_Service_Setting.Take('U');
  
    if g_Email_Messages is not null and g_Email_Messages.Count > 0 then
      v_Data := Arraylist();
      v_Data.Push(r_Setting.Smtp_Host);
      v_Data.Push(r_Setting.Smtp_Port);
      v_Data.Push(r_Setting.Smtp_From_Name);
      v_Data.Push(r_Setting.Smtp_From_Address);
      v_Data.Push(r_Setting.Smtp_Password);
      v_Data.Push(r_Setting.Smtp_Transport_Strategy);
      v_Data.Push(g_Email_Messages);
    
      Push_Final_Service(c_Email_Service_Class, v_Data);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Email
  (
    i_To                    varchar2,
    i_To_Address            varchar2,
    i_Subject               varchar2,
    i_Message               varchar2,
    i_Html_Url              varchar2,
    i_Html_Replacement_Keys Hashmap
  ) is
    v_Data Arraylist;
  begin
    if g_Email_Messages is null then
      g_Email_Messages := Arraylist();
    end if;
  
    v_Data := Arraylist();
    v_Data.Push(i_To);
    v_Data.Push(i_To_Address);
    v_Data.Push(i_Subject);
    v_Data.Push(i_Message);
    v_Data.Push(i_Html_Url);
    v_Data.Push(i_Html_Replacement_Keys);
  
    g_Email_Messages.Push(v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push_Sms is
    v_Data    Arraylist;
    r_Setting Biruni_Messaging_Service_Setting%rowtype;
  begin
    r_Setting := z_Biruni_Messaging_Service_Setting.Take('U');
  
    if g_Sms_Messages is not null and g_Sms_Messages.Count > 0 then
      v_Data := Arraylist();
      v_Data.Push(r_Setting.Sms_Service_Url);
      v_Data.Push(r_Setting.Sms_Service_Auth_Key);
      v_Data.Push(g_Sms_Messages);
    
      Push_Final_Service(c_Sms_Service_Class, v_Data);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Sms
  (
    i_Phone   varchar2,
    i_Message varchar2
  ) is
    v_Data Arraylist;
  begin
    if g_Sms_Messages is null then
      g_Sms_Messages := Arraylist();
    end if;
  
    v_Data := Arraylist();
    v_Data.Push(i_Phone);
    v_Data.Push(i_Message);
  
    g_Sms_Messages.Push(v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Final_Services return Arraylist is
    result          Arraylist := Arraylist();
    v_Final_Service Arraylist;
  begin
    Push_Email;
    Push_Sms;
  
    if g_Final_Services is not null then
      for i in 1 .. g_Final_Services.Count
      loop
        v_Final_Service := Arraylist();
        v_Final_Service.Push(g_Final_Services(i).Class_Name);
        v_Final_Service.Push(g_Final_Services(i).Data);
        Result.Push(v_Final_Service);
      end loop;
    end if;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Hms_Token
  (
    i_Client_Id    varchar2,
    i_Access_Token varchar2,
    i_Expires_In   number
  ) is
    r_Setting Biruni_Settings%rowtype;
  begin
    r_Setting := Biruni_Core.Load_Setting;
  
    execute immediate 'BEGIN ' || r_Setting.Hms_Token_Save_Procedure ||
                      '(:client_id, :access_token, :expires_in); END;'
      using in i_Client_Id, i_Access_Token, i_Expires_In;
  exception
    when others then
      null;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Final_Service_Log(i_Error varchar2) is
  begin
    z_Biruni_Final_Service_Log.Save_One(i_Log_Id        => Biruni_Final_Service_Log_Sq.Nextval,
                                        i_Log_Date      => sysdate,
                                        i_Error_Message => i_Error);
  end;

end Biruni_Service;
/
