create package Fazo_Schema.Fazo_Aes authid current_user is
  ----------------------------------------------------------------------------------------------------
  Function Server_Code return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Decrypt(i_Encrypted_Text varchar2) return varchar2;
end Fazo_Aes;
