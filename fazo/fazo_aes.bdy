create package body Fazo_Schema.Fazo_Aes is
  ----------------------------------------------------------------------------------------------------
  Function Server_Code return varchar2 is
  begin
    Raise_Application_Error(-20999, 'Server code is not implemented');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Decrypt(i_Encrypted_Text varchar2) return varchar2 is
  begin
    Raise_Application_Error(-20999, 'Decryption algorithm is not implemented');
  end;

end Fazo_Aes;
/
