create or replace package b_Messaging is
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Email
  (
    i_Receiver_Name  varchar2,
    i_Receiver_Email varchar2,
    i_Subject        varchar2,
    i_Message        varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Email
  (
    i_Receiver_Name         varchar2,
    i_Receiver_Email        varchar2,
    i_Subject               varchar2,
    i_Html_Uri              varchar2,
    i_Html_Replacement_Keys Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Sms
  (
    i_Phone   varchar2,
    i_Message varchar2
  );
end b_Messaging;
/
create or replace package body b_Messaging is
  ----------------------------------------------------------------------------------------------------
  Procedure Check_Send_Email_Service is
    r_Setting Biruni_Messaging_Service_Setting%rowtype;
  begin
    r_Setting := z_Biruni_Messaging_Service_Setting.Take('U');
  
    if r_Setting.Smtp_Host is null or r_Setting.Smtp_Port is null or
       r_Setting.Smtp_From_Name is null or r_Setting.Smtp_From_Address is null or
       r_Setting.Smtp_Password is null or r_Setting.Smtp_Transport_Strategy is null then
      b.Raise_Fatal('Send email service is not configured');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Email
  (
    i_Receiver_Name  varchar2,
    i_Receiver_Email varchar2,
    i_Subject        varchar2,
    i_Message        varchar2
  ) is
  begin
    Check_Send_Email_Service;
    Biruni_Service.Send_Email(i_To                    => i_Receiver_Name,
                              i_To_Address            => i_Receiver_Email,
                              i_Subject               => i_Subject,
                              i_Message               => i_Message,
                              i_Html_Url              => '',
                              i_Html_Replacement_Keys => Hashmap);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Email
  (
    i_Receiver_Name         varchar2,
    i_Receiver_Email        varchar2,
    i_Subject               varchar2,
    i_Html_Uri              varchar2,
    i_Html_Replacement_Keys Hashmap
  ) is
  begin
    Check_Send_Email_Service;
  
    Biruni_Service.Send_Email(i_To                    => i_Receiver_Name,
                              i_To_Address            => i_Receiver_Email,
                              i_Subject               => i_Subject,
                              i_Message               => '',
                              i_Html_Url              => i_Html_Uri,
                              i_Html_Replacement_Keys => i_Html_Replacement_Keys);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Check_Send_Sms_Service is
    r_Setting Biruni_Messaging_Service_Setting%rowtype;
  begin
    r_Setting := z_Biruni_Messaging_Service_Setting.Take('U');
  
    if r_Setting.Sms_Service_Auth_Key is null or r_Setting.Sms_Service_Url is null then
      b.Raise_Fatal('Send sms service is not configured');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Sms
  (
    i_Phone   varchar2,
    i_Message varchar2
  ) is
  begin
    Check_Send_Sms_Service;
  
    Biruni_Service.Send_Sms(i_Phone => i_Phone, i_Message => i_Message);
  end;

end b_Messaging;
/
