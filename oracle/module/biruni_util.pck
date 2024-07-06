create or replace package Biruni_Util is
  ----------------------------------------------------------------------------------------------------
  Function Millis_To_Timestamp(i_Millis number) return timestamp
    with time zone;
  ----------------------------------------------------------------------------------------------------  
  Function Timestamp_To_Millis(i_Timestamp timestamp with time zone) return number;
  ----------------------------------------------------------------------------------------------------
  Function Equal_Ignore_Case
  (
    i_Val1 varchar2,
    i_Val2 varchar2
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Extract_Ora_Error_Message(i_Sqlerrm varchar2) return varchar2;
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
  Function Take_Custom_Translation
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2;
  ---------------------------------------------------------------------------------------------------- 
  Function Is_Generated_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Prepare_Url
  (
    i_Uri    varchar2,
    i_Params Hashmap
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gen_Oneid_Url(i_Redirect_Params Hashmap) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gen_Lazy_Report_Output
  (
    i_Register_Id number,
    i_Lang_Code   varchar2
  ) return Array_Varchar2;
end Biruni_Util;
/
create or replace package body Biruni_Util is
  ----------------------------------------------------------------------------------------------------
  Function Millis_To_Timestamp(i_Millis number) return timestamp
    with time zone is
  begin
    return To_Timestamp_Tz('01.01.1970 00:00', 'dd.mm.yyyy TZH:TZM') + Numtodsinterval(i_Millis / 1000,
                                                                                       'second');
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Timestamp_To_Millis(i_Timestamp timestamp with time zone) return number is
    v_Millis number;
  begin
    if i_Timestamp is null then
      return 0;
    end if;
  
    with Interval_Difference as
     (select cast(i_Timestamp At time zone 'UTC' as timestamp with time zone) -
             To_Timestamp_Tz('01.01.1970 00:00', 'dd.mm.yyyy TZH:TZM') Diff
        from Dual)
    select Extract(second from Diff) + --
           Extract(Minute from Diff) * 60 + -- 
           Extract(Hour from Diff) * 3600 + --
           Extract(day from Diff) * 86400
      into v_Millis
      from Interval_Difference;
  
    return Trunc(v_Millis * 1000);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Equal_Ignore_Case
  (
    i_Val1 varchar2,
    i_Val2 varchar2
  ) return boolean is
  begin
    return Fazo.Equal(i_Val1 => Lower(i_Val1), i_Val2 => Lower(i_Val2));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Extract_Ora_Error_Message(i_Sqlerrm varchar2) return varchar2 is
  begin
    return Regexp_Replace(i_Sqlerrm,
                          'ORA-\d+:\s(line\s\d+,\scolumn\s\d+:\s)?(.+?)(ORA-\d+:.*)',
                          '\2',
                          1,
                          1,
                          'n');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Take_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2,
    o_Text      out varchar2,
    o_Custom    out varchar2
  ) is
  begin
    if Regexp_Like(i_Lang_Code, '^[a-z]+$') then
    
      execute immediate 'BEGIN SELECT t.text_' || i_Lang_Code || ', t.custom' ||
                        ' INTO :a,:b FROM biruni_translations t WHERE t.message = :m;END;'
        using out o_Text, out o_Custom, in i_Message;
    end if;
  
    o_Custom := Nvl(o_Custom, 'N');
  exception
    when others then
      o_Text   := null;
      o_Custom := 'N';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Take_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2 is
    v_Text varchar2(4000);
  begin
    if Regexp_Like(i_Lang_Code, '^[a-z]+$') then
    
      execute immediate 'BEGIN SELECT t.text_' || i_Lang_Code ||
                        ' INTO :a FROM biruni_translations t WHERE t.message = :m;END;'
        using out v_Text, in i_Message;
    end if;
  
    return v_Text;
  exception
    when others then
      return null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Take_Custom_Translation
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2 is
    v_Text varchar2(4000);
  begin
    if Regexp_Like(i_Lang_Code, '^[a-z]+$') then
    
      execute immediate 'BEGIN SELECT t.text_' || i_Lang_Code ||
                        ' INTO :a FROM biruni_custom_translations t WHERE t.code =:c AND t.message = :m;END;'
        using out v_Text, in i_Code, i_Message;
    end if;
  
    return v_Text;
  exception
    when others then
      return null;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Is_Generated_Translation
  (
    i_Message   varchar2,
    i_Lang_Code varchar2
  ) return varchar2 is
  begin
    if z_Biruni_Generated_Translations.Exist(i_Message => i_Message, i_Lang_Code => i_Lang_Code) then
      return 'Y';
    end if;
  
    return 'N';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Encode_Base64(i_Val varchar2) return varchar2 is
  begin
    return Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Encode(Utl_Raw.Cast_To_Raw(i_Val)));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Prepare_Url
  (
    i_Uri    varchar2,
    i_Params Hashmap
  ) return varchar2 is
    v_Keys       Array_Varchar2 := i_Params.Keyset();
    v_Uri_Params Array_Varchar2 := Array_Varchar2();
  begin
    for i in 1 .. v_Keys.Count
    loop
      Fazo.Push(v_Uri_Params,
                v_Keys(i) || '=' || Utl_Url.Escape(i_Params.r_Varchar2(v_Keys(i)), true, 'UTF8'));
    end loop;
  
    if v_Uri_Params.Count > 0 then
      return i_Uri || '?' || Fazo.Gather(v_Uri_Params, Chr(38));
    end if;
  
    return i_Uri;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Oneid_Url(i_Redirect_Params Hashmap) return varchar2 is
    r_Server Biruni_Oauth2_Servers%rowtype;
    v_Params Array_Varchar2 := Array_Varchar2();
  
    --------------------------------------------
    Procedure Push_Param
    (
      i_Key varchar2,
      i_Val varchar2
    ) is
    begin
      Fazo.Push(v_Params, i_Key || '=' || Utl_Url.Escape(i_Val, true, 'UTF8'));
    end;
  begin
    r_Server := z_Biruni_Oauth2_Servers.Load(Biruni_Pref.c_Oauth2_Oneid);
  
    Push_Param('response_type', 'one_code');
    Push_Param('client_id', r_Server.Client_Id);
    Push_Param('redirect_uri', r_Server.Redirect_Uri);
    Push_Param('scope', r_Server.Scope);
    Push_Param('state', Encode_Base64(i_Redirect_Params.Json));
  
    return r_Server.Authorize_Url || '?' || Fazo.Gather(v_Params, Chr(38));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Lazy_Report_Output
  (
    i_Register_Id number,
    i_Lang_Code   varchar2
  ) return Array_Varchar2 is
    v_Obj Json_Object_t := Json_Object_t;
  begin
    v_Obj.Put('register_id', i_Register_Id);
    v_Obj.Put('wait_time', Biruni_Pref.c_Lazy_Report_Request_Wait_Time);
    v_Obj.Put('generating_message',
              Take_Translation(i_Message => '#b:lr_generating', i_Lang_Code => i_Lang_Code));
  
    return Fazo.Read_Clob(v_Obj.To_Clob);
  end;

end Biruni_Util;
/
