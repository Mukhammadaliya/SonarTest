create or replace Noneditionable type body Fazo_Schema.Gmap is
  ----------------------------------------------------------------------------------------------------
  constructor Function Gmap(self in out nocopy Gmap) return self as result is
  begin
    Val := Json_Object_t();
    return;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    varchar2
  ) is
  begin
    Self.Val.Put(Key, v);
  end;

  ----------------------------------------------------------------------------------------------------
  --TODO review format number
  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    number
  ) is
  begin
    Self.Val.Put(Key, Fazo_Schema.Fazo.Format_Number(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    date
  ) is
  begin
    Self.Val.Put(Key, Fazo_Schema.Fazo.Format_Date(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    timestamp
  ) is
  begin
    Self.Val.Put(Key, Fazo_Schema.Fazo.Format_Timestamp(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    timestamp with time zone
  ) is
  begin
    Self.Val.Put(Key, Fazo_Schema.Fazo.Format_Timestamp(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    timestamp with local time zone
  ) is
  begin
    Self.Val.Put(Key, Fazo_Schema.Fazo.Format_Timestamp(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Varchar2
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(v(i));
    end loop;
  
    Self.Val.Put(Key, Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Number
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(Fazo_Schema.Fazo.Format_Number(v(i)));
    end loop;
  
    Self.Val.Put(Key, Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Date
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(Fazo_Schema.Fazo.Format_Date(v(i)));
    end loop;
  
    Self.Val.Put(Key, Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Timestamp
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(Fazo_Schema.Fazo.Format_Timestamp(v(i)));
    end loop;
  
    Self.Val.Put(Key, Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Glist
  ) is
  begin
    Self.Val.Put(Key, v.Val);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Gmap
  ) is
  begin
    Self.Val.Put(Key, v.Val);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Put_All
  (
    self in out nocopy Gmap,
    That Gmap
  ) is
  begin
    if That is null then
      return;
    end if;
  
    Self.Val.Mergepatch(That.Val.To_String);
  end;

  ----------------------------------------------------------------------------------------------------
  member Function count(self in Gmap) return pls_integer is
  begin
    return Self.Val.Get_Size;
  end;

  ----------------------------------------------------------------------------------------------------
  member Function Has
  (
    self in Gmap,
    Key  varchar2
  ) return boolean is
  begin
    return Self.Val.Has(Key);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return varchar2 is
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Self.Val.Get_String(Key);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return number is
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Number(Self.Val.Get_String(Key), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return date is
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(Key), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------
  member Function r_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return timestamp is
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(Key), i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return Fazo_Schema.Array_Varchar2 is
    Arr      Fazo_Schema.Array_Varchar2;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Varchar2(Self.Val.Get_String(Key));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Varchar2();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Json_Arr.Get_String(i - 1);
    end loop;
  
    return Arr;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return Fazo_Schema.Array_Number is
    Arr      Fazo_Schema.Array_Number;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Number(Fazo_Schema.Fazo.Format_Number(Self.Val.Get_String(Key),
                                                                     i_Format,
                                                                     i_Nlsparam));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Number();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Number(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return Fazo_Schema.Array_Date is
    Arr      Fazo_Schema.Array_Date;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Date(Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(Key),
                                                                 i_Format,
                                                                 i_Nlsparam));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Date();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Date(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return Fazo_Schema.Array_Timestamp is
    Arr      Fazo_Schema.Array_Timestamp;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Timestamp(Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(Key),
                                                                           i_Format,
                                                                           i_Nlsparam));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Timestamp();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Timestamp(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ----------------------------------------------------------------------------------------------------
  member Function r_Glist
  (
    self in Gmap,
    Key  varchar2
  ) return Glist is
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Glist(Self.Val.Get_Array(Key));
  end;

  ----------------------------------------------------------------------------------------------------
  member Function r_Gmap
  (
    self in Gmap,
    Key  varchar2
  ) return Gmap is
  begin
    if not Self.Has(Key) then
      Raise_Application_Error(-20999, 'Gmap:' || Key || ' not found');
    elsif Self.Val.Get_Type(Key) <> 'OBJECT' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Gmap(Self.Val.Get_Object(Key));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return varchar2 is
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Self.Val.Get_String(Key);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return number is
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Number(Self.Val.Get_String(Key), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------
  member Function o_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return date is
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(Key), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------
  member Function o_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return timestamp is
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(Key), i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return Fazo_Schema.Array_Varchar2 is
    Arr      Fazo_Schema.Array_Varchar2;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Varchar2(Self.Val.Get_String(Key));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Varchar2();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Json_Arr.Get_String(i - 1);
    end loop;
  
    return Arr;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return Fazo_Schema.Array_Number is
    Arr      Fazo_Schema.Array_Number;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Number(Fazo_Schema.Fazo.Format_Number(Self.Val.Get_String(Key),
                                                                     i_Format,
                                                                     i_Nlsparam));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Number();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Number(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return Fazo_Schema.Array_Date is
    Arr      Fazo_Schema.Array_Date;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Date(Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(Key),
                                                                 i_Format,
                                                                 i_Nlsparam));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Date();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Date(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2,
    i_Nlsparam varchar2
  ) return Fazo_Schema.Array_Timestamp is
    Arr      Fazo_Schema.Array_Timestamp;
    Json_Arr Json_Array_t;
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) = 'SCALAR' then
      return Fazo_Schema.Array_Timestamp(Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(Key),
                                                                           i_Format,
                                                                           i_Nlsparam));
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Timestamp();
    Json_Arr := Self.Val.Get_Array(Key);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Timestamp(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ----------------------------------------------------------------------------------------------------
  member Function o_Glist
  (
    self in Gmap,
    Key  varchar2
  ) return Glist is
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Glist(Self.Val.Get_Array(Key));
  end;

  ----------------------------------------------------------------------------------------------------
  member Function o_Gmap
  (
    self in Gmap,
    Key  varchar2
  ) return Gmap is
  begin
    if not Self.Has(Key) then
      return null;
    elsif Self.Val.Get_Type(Key) <> 'OBJECT' then
      Raise_Application_Error(-20999, 'Gmap:key ' || Key || ' type does not match');
    end if;
  
    return Gmap(Self.Val.Get_Object(Key));
  end;

  ------------------------------------------------------------------------------------------------------
  -- TODO depricated
  -- use json_key_list
  ------------------------------------------------------------------------------------------------------  
  member Function Keyset(self in Gmap) return Fazo_Schema.Array_Varchar2 is
    Arr  Fazo_Schema.Array_Varchar2 := Fazo_Schema.Array_Varchar2();
    Keys Json_Key_List := Self.Val.Get_Keys;
  begin
    if Keys is not null then
      Arr.Extend(Keys.Count);
    
      for i in 1 .. Arr.Count
      loop
        Arr(i) := Keys(i);
      end loop;
    end if;
  
    return Arr;
  end;

  ----------------------------------------------------------------------------------------------------      
  --TODO add print(clob) to stream
  ----------------------------------------------------------------------------------------------------      
  member Procedure Print_Json
  (
    self in Gmap,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print(Fazo_Schema.Fazo.Read_Clob(Self.Val.To_Clob));
  end;

  ----------------------------------------------------------------------------------------------------
  member Function Json(self in Gmap) return varchar2 is
  begin
    return Self.Val.To_String;
  end;

end;
/
