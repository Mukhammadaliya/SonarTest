create or replace type body Fazo_Schema.Hashmap is

  ------------------------------------------------------------------------------------------------------
  constructor Function Hashmap(self in out nocopy Fazo_Schema.Hashmap) return self as result is
  begin
    Self.Type    := 'H';
    Self.Keys    := Fazo_Schema.Calc();
    Self.Buckets := Fazo_Schema.Hash_Bucket();
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.w_Wrapper
  ) is
    Pos   pls_integer;
    v_Key varchar2(100) := Lower(Key);
  begin
    if Key is null then
      Raise_Application_Error(-20999, 'Hashmap is put null key');
    end if;
  
    if v is null then
      Raise_Application_Error(-20999, 'Hashmap is put null object');
    end if;
  
    Pos := Keys.Get_Value(v_Key);
  
    if Pos = 0 then
      Buckets.Extend;
      Pos := Self.Buckets.Count;
      Keys.Set_Value(v_Key, Pos);
      Buckets(Pos) := Fazo_Schema.Hash_Entry(v_Key, v);
    else
      Buckets(Pos).Val := v;
    end if;
  
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    varchar2
  ) is
  begin
    Self.Put(Key, Option_Varchar2(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    number
  ) is
  begin
    Self.Put(Key, Fazo_Schema.Option_Number(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    date
  ) is
  begin
    Self.Put(Key, Fazo_Schema.Option_Date(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    timestamp
  ) is
  begin
    Self.Put(Key, Fazo_Schema.Option_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    timestamp with time zone
  ) is
  begin
    Self.Put(Key, Fazo_Schema.Option_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    timestamp with local time zone
  ) is
  begin
    Self.Put(Key, Fazo_Schema.Option_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Varchar2
  ) is
  begin
    Self.Put(Key, Fazo_Schema.w_Array_Varchar2(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Number
  ) is
  begin
    Self.Put(Key, Fazo_Schema.w_Array_Number(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Date
  ) is
  begin
    Self.Put(Key, Fazo_Schema.w_Array_Date(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Timestamp
  ) is
  begin
    Self.Put(Key, Fazo_Schema.w_Array_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Put_All
  (
    self in out nocopy Fazo_Schema.Hashmap,
    That Fazo_Schema.Hashmap
  ) is
  begin
    if That is null then
      return;
    end if;
    for i in 1 .. That.Buckets.Count
    loop
      Self.Put(That.Buckets(i).Key, That.Buckets(i).Val);
    end loop;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function count return binary_integer is
  begin
    return Keys.Count;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Has(Key varchar2) return boolean is
  begin
    return Keys.Get_Value(Key) != 0;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Varchar2(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Number(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Date(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Timestamp(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Varchar2(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Number(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Date(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Timestamp(i_Format, i_Nlsparam);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Calc(Key varchar2) return Fazo_Schema.Calc is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Treat(Buckets(p).Val as Calc);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Arraylist(Key varchar2) return Fazo_Schema.Arraylist is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Fazo_Schema.Arraylist.As_Arraylist(Buckets(p).Val);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Hashmap(Key varchar2) return Fazo_Schema.Hashmap is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Treat(Buckets(p).Val as Hashmap);
    end if;
    Raise_Application_Error(-20999, 'Hashmap:' || Key || ' not found');
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Varchar2(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Number(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Date(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Timestamp(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Varchar2(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Number(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Date(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.As_Array_Timestamp(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Calc(Key varchar2) return Fazo_Schema.Calc is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Treat(Buckets(p).Val as Calc);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Arraylist(Key varchar2) return Fazo_Schema.Arraylist is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Fazo_Schema.Arraylist.As_Arraylist(Buckets(p).Val);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Hashmap(Key varchar2) return Fazo_Schema.Hashmap is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Treat(Buckets(p).Val as Hashmap);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Varchar2(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Varchar2;
    end if;
    return null;
  end;

  member Function Is_Number(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Number;
    end if;
    return null;
  end;

  member Function Is_Date(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Date;
    end if;
    return null;
  end;

  member Function Is_Timestamp(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Timestamp;
    end if;
    return null;
  end;

  member Function Is_Array_Varchar2(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Array_Varchar2;
    end if;
    return null;
  end;

  member Function Is_Array_Number(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Array_Number;
    end if;
    return null;
  end;

  member Function Is_Array_Date(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Array_Date;
    end if;
    return null;
  end;

  member Function Is_Array_Timestamp(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Array_Timestamp;
    end if;
    return null;
  end;

  member Function Is_Calc(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Calc;
    end if;
    return null;
  end;

  member Function Is_Arraylist(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Arraylist;
    end if;
    return null;
  end;

  member Function Is_Hashmap(Key varchar2) return boolean is
    p number;
  begin
    p := Keys.Get_Value(Key);
    if 0 < p then
      return Buckets(p).Val.Is_Hashmap;
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Hashmap return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Keyset return Array_Varchar2 is
  begin
    return Keys.Keyset;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Hashmap,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print('{');
  
    for i in 1 .. Self.Buckets.Count
    loop
    
      Out.Print('"' || Fazo.Json_Escape(Buckets(i).Key) || '":');
    
      Self.Buckets(i).Val.Print_Json(out);
    
      if i <> Buckets.Count then
        Out.Print(',');
      end if;
    
    end loop;
  
    Out.Print('}');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
    result varchar2(32767);
  begin
    result := '{';
  
    for i in 1 .. Self.Buckets.Count
    loop
    
      result := result || '"' || Fazo.Json_Escape(Buckets(i).Key) || '":' || Buckets(i).Val.Json;
    
      if i <> Buckets.Count then
        result := result || ',';
      end if;
    
    end loop;
  
    return result || '}';
  end Json;

end;
/
