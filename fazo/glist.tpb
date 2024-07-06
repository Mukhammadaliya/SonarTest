create or replace Noneditionable type body Fazo_Schema.Glist is
  ----------------------------------------------------------------------------------------------------
  constructor Function Glist(self in out nocopy Glist) return self as result is
  begin
    Self.Val := Json_Array_t();
    return;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    varchar2
  ) is
  begin
    Self.Val.Append(v);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    number
  ) is
  begin
    Self.Val.Append(Fazo_Schema.Fazo.Format_Number(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    date
  ) is
  begin
    Self.Val.Append(Fazo_Schema.Fazo.Format_Date(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    timestamp
  ) is
  begin
    Self.Val.Append(Fazo_Schema.Fazo.Format_Timestamp(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    timestamp with time zone
  ) is
  begin
    Self.Val.Append(Fazo_Schema.Fazo.Format_Timestamp(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    timestamp with local time zone
  ) is
  begin
    Self.Val.Append(Fazo_Schema.Fazo.Format_Timestamp(v));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Varchar2
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(v(i));
    end loop;
  
    Self.Val.Append(Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Number
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(Fazo_Schema.Fazo.Format_Number(v(i)));
    end loop;
  
    Self.Val.Append(Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Date
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(Fazo_Schema.Fazo.Format_Date(v(i)));
    end loop;
  
    Self.Val.Append(Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Timestamp
  ) is
    Json_Arr Json_Array_t := Json_Array_t();
  begin
    for i in 1 .. v.Count
    loop
      Json_Arr.Append(Fazo_Schema.Fazo.Format_Timestamp(v(i)));
    end loop;
  
    Self.Val.Append(Json_Arr);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Glist
  ) is
  begin
    Self.Val.Append(v.Val);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Json_Object_t
  ) is
  begin
    Self.Val.Append(v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function count(self in Glist) return pls_integer is
  begin
    return Self.Val.Get_Size;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return varchar2 is
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Self.Val.Get_String(i - 1);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Number(Self.Val.Get_String(i - 1), i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(i - 1), i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(i - 1), i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return Fazo_Schema.Array_Varchar2 is
    Arr      Fazo_Schema.Array_Varchar2;
    Json_Arr Json_Array_t;
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Varchar2(Self.Val.Get_String(i - 1));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Varchar2();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
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
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
    Arr      Fazo_Schema.Array_Number;
    Json_Arr Json_Array_t;
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Number(Fazo_Schema.Fazo.Format_Number(Self.Val.Get_String(i - 1),
                                                                     i_Format,
                                                                     i_Nlsparam));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Number();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
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
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
    Arr      Fazo_Schema.Array_Date;
    Json_Arr Json_Array_t;
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Date(Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(i - 1),
                                                                 i_Format,
                                                                 i_Nlsparam));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Date();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
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
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
    Arr      Fazo_Schema.Array_Timestamp;
    Json_Arr Json_Array_t;
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Timestamp(Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(i - 1),
                                                                           i_Format,
                                                                           i_Nlsparam));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Timestamp();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
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
    self in Glist,
    i    pls_integer
  ) return Glist is
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Glist(Treat(Self.Val.Get(i - 1) as Json_Array_t));
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function r_Gmap
  (
    self in Glist,
    i    pls_integer
  ) return Json_Object_t is
  begin
    if Self.Val.Get_Size < i then
      Raise_Application_Error(-20999, 'Glist:' || i || ' index not found');
    elsif Self.Val.Get_Type(i - 1) <> 'OBJECT' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Treat(Self.Val.Get(i - 1) as Json_Object_t);
  end;

  ---------------------------------------------------------------------------------------------------- 
  member Function o_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return varchar2 is
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist: index ' || i || ' type does not match');
    end if;
  
    return Self.Val.Get_String(i - 1);
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist: index ' || i || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Number(Self.Val.Get_Number(i - 1), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist: index ' || i || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Date(Self.Val.Get_String(i - 1), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) <> 'SCALAR' then
      Raise_Application_Error(-20999, 'Glist: index ' || i || ' type does not match');
    end if;
  
    return Fazo_Schema.Fazo.Format_Timestamp(Self.Val.Get_String(i - 1), i_Format, i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Array_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return Fazo_Schema.Array_Varchar2 is
    Arr      Fazo_Schema.Array_Varchar2;
    Json_Arr Json_Array_t;
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Varchar2(Self.Val.Get_String(i - 1));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Varchar2();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Json_Arr.Get_String(i - 1);
    end loop;
  
    return Arr;
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Array_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
    Arr      Fazo_Schema.Array_Number;
    Json_Arr Json_Array_t;
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Number(Self.Val.Get_String(i - 1));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Number();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Number(Json_Arr.Get_Number(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Array_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
    Arr      Fazo_Schema.Array_Date := Fazo_Schema.Array_Date();
    Json_Arr Json_Array_t := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Date(Self.Val.Get_String(i - 1));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Date();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
    Arr.Extend(Json_Arr.Get_Size);
  
    for i in 1 .. Arr.Count
    loop
      Arr(i) := Fazo_Schema.Fazo.Format_Date(Json_Arr.Get_String(i - 1), i_Format, i_Nlsparam);
    end loop;
  
    return Arr;
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Array_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
    Arr      Fazo_Schema.Array_Timestamp := Fazo_Schema.Array_Timestamp();
    Json_Arr Json_Array_t := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) = 'SCALAR' then
      return Fazo_Schema.Array_Timestamp(Self.Val.Get_String(i - 1));
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    Arr      := Fazo_Schema.Array_Timestamp();
    Json_Arr := Treat(Self.Val.Get(i - 1) as Json_Array_t);
  
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
    self in Glist,
    i    pls_integer
  ) return Glist is
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) <> 'ARRAY' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Glist(Treat(Self.Val.Get(i - 1) as Json_Array_t));
  end;

  ----------------------------------------------------------------------------------------------------  
  member Function o_Gmap
  (
    self in Glist,
    i    pls_integer
  ) return Json_Object_t is
  begin
    if Self.Val.Get_Size < i then
      return null;
    elsif Self.Val.Get_Type(i - 1) <> 'OBJECT' then
      Raise_Application_Error(-20999, 'Glist:index ' || i || ' type does not match');
    end if;
  
    return Treat(Self.Val.Get(i - 1) as Json_Object_t);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Print_Json
  (
    self in Glist,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print(v => Fazo_Schema.Fazo.Read_Clob(Self.Val.To_Clob));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Json(self in Glist) return varchar2 is
  begin
    return Self.Val.To_String;
  end;

end;
/
