create or replace package Biruni_Pref is
  ----------------------------------------------------------------------------------------------------
  c_Route_Auth_Type_Session constant varchar2(2) := 'S';
  c_Route_Auth_Type_Token   constant varchar2(2) := 'T';
  c_Route_Auth_Type_Bearer  constant varchar2(2) := 'BR';
  c_Route_Auth_Type_Basic   constant varchar2(2) := 'BS';
  ----------------------------------------------------------------------------------------------------
  c_Route_Scope_Read  constant varchar2(1) := 'R';
  c_Route_Scope_Write constant varchar2(1) := 'W';
  ----------------------------------------------------------------------------------------------------
  c_Content_Type constant varchar2(20) := 'Content-type';
  ----------------------------------------------------------------------------------------------------
  c_Oauth2_Oneid    constant varchar2(20) := 'oneid';
  c_Oauth2_Google   constant varchar2(20) := 'google';
  c_Oauth2_Facebook constant varchar2(20) := 'facebook';
  ----------------------------------------------------------------------------------------------------
  c_Oauth2_Redirect_Uri constant varchar2(100) := '/oneid_redirect.html';
  c_Change_Password_Uri constant varchar2(100) := '/change_password.html';
  -- TODO move to core
  c_Recover_Password_Message_Html      constant varchar2(100) := '/recover_password_message.html';
  c_Recover_Password_Code_Use_Limit    constant number := 4;
  c_Recover_Password_Code_Expired_Time constant number := 300; --in seconds
  ----------------------------------------------------------------------------------------------------
  -- SMTP Transport Strategy
  ----------------------------------------------------------------------------------------------------
  c_Transport_Strategy_Smtp_Tls constant varchar2(1) := 'T';
  c_Transport_Strategy_Smtps    constant varchar2(1) := 'S';
  c_Transport_Strategy_Smtp     constant varchar2(1) := 'H';
  ----------------------------------------------------------------------------------------------------
  c_Rs_Action_In_Out_Varchar2       constant varchar2(1) := 'V';
  c_Rs_Action_In_Out_Array_Varchar2 constant varchar2(1) := 'A';
  c_Rs_Action_In_Out_Hashmap        constant varchar2(1) := 'M';
  c_Rs_Action_In_Out_Arraylist      constant varchar2(1) := 'L';
  ----------------------------------------------------------------------------------------------------
  -- External service authorization type
  ----------------------------------------------------------------------------------------------------
  c_External_Service_Auth_Type_Basic  constant varchar2(10) := 'Basic';
  c_External_Service_Auth_Type_Bearer constant varchar2(10) := 'Bearer';
  ----------------------------------------------------------------------------------------------------
  -- Lazy report statuses
  ----------------------------------------------------------------------------------------------------
  c_Lazy_Report_Status_New       constant varchar2(1) := 'N';
  c_Lazy_Report_Status_Executing constant varchar2(1) := 'E';
  c_Lazy_Report_Status_Completed constant varchar2(1) := 'C';
  c_Lazy_Report_Status_Failed    constant varchar2(1) := 'F';
  ----------------------------------------------------------------------------------------------------
  -- Lazy report request wait time in seconds
  ----------------------------------------------------------------------------------------------------
  c_Lazy_Report_Request_Wait_Time constant number := 60;
  ----------------------------------------------------------------------------------------------------
  -- File redirect type
  ----------------------------------------------------------------------------------------------------
  c_File_Redirect_Load     constant varchar2(1) := 'L';
  c_File_Redirect_Download constant varchar2(1) := 'D';
  ----------------------------------------------------------------------------------------------------
  type Final_Service is record(
    Class_Name varchar2(100),
    Data       Arraylist);
  ----------------------------------------------------------------------------------------------------
  type Final_Services is table of Final_Service;
  ----------------------------------------------------------------------------------------------------
  Function Rsa_Private_Key return varchar2;
  Function Rsa_Public_Key return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Decode_Auth_Type(i_Auth_Type varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Dangerous_File_Extensions return Array_Varchar2;
end Biruni_Pref;
/
create or replace package body Biruni_Pref is
  ----------------------------------------------------------------------------------------------------
  Function Rsa_Private_Key return varchar2 is
  begin
    return 'MIIBUwIBADANBgkqhkiG9w0BAQEFAASCAT0wggE5AgEAAkEAqPETAaRo1XVfBKubyS32ev3UDUKjpQdM9MY6AemuQaymcSaMrWB02SkMPHWInPj6koWI7GGp1DvNncxnaFA+/wIDAQABAkBJG/JWrphzb5SMB9ul5w8YUIoYpvL8crlZ4AKwWzj+0AnnLO+X39tJCml3hBRgxGB+w5YixJ9mf/P6z6uwpgAhAiEA/EBwiu3lBmrBQifscqB5Eyq0ZkJ5YcA1//fk1Nl3Bu8CIQCrc7mZ+OVBoj9KwNrnIZnFfeUcphwAc7WNtzPVK6jI8QIgJckdUqJKEUkCg/9o+s6w9D8MYNkKR6s8K4idnYipvL8CIHBlXhANNaWQSnOj+B07TsZEIPVmA8dcE3IC3szpYS3RAiBZNGiV+fbmCR0cGCAolUVuAo8JIfRVirANJdoy0H4KUQ==';
  end;

  ----------------------------------------------------------------------------------------------------    
  Function Rsa_Public_Key return varchar2 is
  begin
    return 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKjxEwGkaNV1XwSrm8kt9nr91A1Co6UHTPTGOgHprkGspnEmjK1gdNkpDDx1iJz4+pKFiOxhqdQ7zZ3MZ2hQPv8CAwEAAQ==';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Decode_Auth_Type(i_Auth_Type varchar2) return varchar2 is
  begin
    return case i_Auth_Type --
    when c_Route_Auth_Type_Session then 'Session' --
    when c_Route_Auth_Type_Token then 'Token' --
    when c_Route_Auth_Type_Bearer then 'Bearer' --
    when c_Route_Auth_Type_Basic then 'Basic' --
    else 'Unknown' end;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Dangerous_File_Extensions return Array_Varchar2 is
  begin
    return Array_Varchar2('asp',
                          'aspx',
                          'bak',
                          'bash',
                          'bat',
                          'cgi',
                          'class',
                          'conf',
                          'config',
                          'dll',
                          'docm',
                          'exe',
                          'htaccess',
                          'htgroup',
                          'htpasswd',
                          'ini',
                          'jar',
                          'js',
                          'jsp',
                          'lnk',
                          'log',
                          'mdb',
                          'msi',
                          'old',
                          'php',
                          'pl',
                          'pptm',
                          'sh',
                          'so',
                          'sql',
                          'sys',
                          'vbs',
                          'war',
                          'ws',
                          'wsh',
                          'xlsm');
  end;

end Biruni_Pref;
/
