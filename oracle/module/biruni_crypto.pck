create or replace package Biruni_Crypto is
  ----------------------------------------------------------------------------------------------------
  Function Aes_Encrypt
  (
    i_Src varchar2,
    i_Key varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Aes_Decrypt
  (
    i_Encrypted_Text varchar2,
    i_Key            varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Mac_Hash
  (
    i_Src  raw,
    i_Key  varchar2,
    i_Salt varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Base64_Encode(i_Clob clob) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Base64_Decode(i_Val Array_Varchar2) return clob;
end Biruni_Crypto;
/
create or replace package body Biruni_Crypto is
  ----------------------------------------------------------------------------------------------------  
  c_Aes_Crypto_Type constant pls_integer := Sys.Dbms_Crypto.Encrypt_Aes256 +
                                            Sys.Dbms_Crypto.Chain_Cbc + Sys.Dbms_Crypto.Pad_Pkcs5;
  ----------------------------------------------------------------------------------------------------
  Function Aes_Encrypt
  (
    i_Src varchar2,
    i_Key varchar2
  ) return varchar2 is
    v_Encrypted_Text raw(32767);
  begin
    v_Encrypted_Text := Sys.Dbms_Crypto.Encrypt(Src => Utl_Raw.Cast_To_Raw(Convert(i_Src, 'AL32UTF8')),
                                                Typ => c_Aes_Crypto_Type,
                                                Key => Hextoraw(i_Key));
  
    return Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Encode(v_Encrypted_Text));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Aes_Decrypt
  (
    i_Encrypted_Text varchar2,
    i_Key            varchar2
  ) return varchar2 is
    v_Decrypted_Text raw(32767);
  begin
    v_Decrypted_Text := Sys.Dbms_Crypto.Decrypt(Src => Utl_Encode.Base64_Decode(Utl_Raw.Cast_To_Raw(Convert(i_Encrypted_Text,
                                                                                                            'AL32UTF8'))),
                                                Typ => c_Aes_Crypto_Type,
                                                Key => Hextoraw(i_Key));
  
    return Utl_Raw.Cast_To_Varchar2(v_Decrypted_Text);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mac_Hash
  (
    i_Src  raw,
    i_Key  varchar2,
    i_Salt varchar2
  ) return varchar2 is
    v_Hash raw(1000);
  begin
    v_Hash := Sys.Dbms_Crypto.Mac(Src => i_Src || Utl_Raw.Cast_To_Raw(Convert(i_Salt, 'AL32UTF8')),
                                  Typ => Sys.Dbms_Crypto.Hash_Sh256,
                                  Key => i_Key);
  
    return Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Encode(v_Hash));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Base64_Encode(i_Clob clob) return Array_Varchar2 is
    c_Block_Size constant number := 12000; -- make sure you set a multiple of 3 not higher than 24573
    v_Len  number;
    v_Iter number;
    result Array_Varchar2;
  begin
    if i_Clob is null then
      return result;
    end if;
  
    v_Len  := Sys.Dbms_Lob.Getlength(i_Clob);
    v_Iter := Ceil(v_Len / c_Block_Size);
  
    result := Array_Varchar2();
    Result.Extend(v_Iter);
  
    for i in 1 .. v_Iter
    loop
      result(i) := Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Encode(Utl_Raw.Cast_To_Raw(Convert(Sys.Dbms_Lob.Substr(i_Clob,
                                                                                                                     c_Block_Size,
                                                                                                                     (i - 1) *
                                                                                                                     c_Block_Size + 1),
                                                                                                 'AL32UTF8'))));
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Base64_Decode(i_Val Array_Varchar2) return clob is
    result        clob;
    v_Buff        varchar2(32767);
    v_Curr        varchar2(32767);
    v_Curr_Length number;
    v_Per_Length  number := 10000;
    v_Rem_Length  number := 0;
    v_Length      number;
    v_Iter        number;
    v_Val         varchar2(32767);
  begin
    if i_Val is not null then
      Sys.Dbms_Lob.Createtemporary(result, false);
      Sys.Dbms_Lob.Open(result, Sys.Dbms_Lob.Lob_Readwrite);
    
      for i in 1 .. i_Val.Count
      loop
        v_Val := Regexp_Replace(i_Val(i), '\s');
      
        if v_Val is not null then
          v_Iter   := 0;
          v_Length := Length(v_Val);
        
          while v_Iter < v_Length
          loop
            v_Curr        := Substr(v_Val, v_Iter + 1, v_Per_Length - v_Rem_Length);
            v_Curr_Length := Length(v_Curr);
          
            v_Buff       := v_Buff || v_Curr;
            v_Rem_Length := v_Rem_Length + v_Curr_Length;
          
            if v_Rem_Length = v_Per_Length then
              v_Buff := Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Decode(Utl_Raw.Cast_To_Raw(Convert(v_Buff,
                                                                                                      'AL32UTF8'))));
            
              Sys.Dbms_Lob.Writeappend(result, Length(v_Buff), v_Buff);
            
              v_Buff       := '';
              v_Rem_Length := 0;
            end if;
          
            v_Iter := v_Iter + v_Curr_Length;
          end loop;
        end if;
      end loop;
    
      if v_Rem_Length != 0 then
        v_Buff := Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Decode(Utl_Raw.Cast_To_Raw(Convert(v_Buff,
                                                                                                'AL32UTF8'))));
      
        if v_Buff is not null then
          Sys.Dbms_Lob.Writeappend(result, Length(v_Buff), v_Buff);
        end if;
      end if;
    
      Sys.Dbms_Lob.Close(result);
    end if;
  
    return result;
  end;

end Biruni_Crypto;
/
