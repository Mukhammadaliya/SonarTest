create or replace type body Fazo_Schema.Option_Varchar2 is

  ------------------------------------------------------------------------------------------------------
  constructor Function Option_Varchar2
  (
    self in out nocopy Fazo_Schema.Option_Varchar2,
    Val  varchar2
  ) return self as result is
  begin
    Self.Type := 'v';
    Self.Val  := Val;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    return Val;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    return Fazo_Schema.Fazo.Format_Number(Val, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    return Fazo_Schema.Fazo.Format_Date(Val, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    return Fazo_Schema.Fazo.Format_Timestamp(Val, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    return Fazo_Schema.Array_Varchar2(Val);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
  begin
    return Fazo_Schema.Array_Number(Fazo_Schema.Fazo.Format_Number(Val, i_Format, i_Nlsparam));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
  begin
    return Fazo_Schema.Array_Date(Fazo_Schema.Fazo.Format_Date(Val, i_Format, i_Nlsparam));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
  begin
    return Fazo_Schema.Array_Timestamp(Fazo_Schema.Fazo.Format_Timestamp(Val, i_Format, i_Nlsparam));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Varchar2 return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Option_Varchar2,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print('"');
    Fazo_Schema.Fazo.Json_Escape_And_Print(out, Self.Val);
    Out.Print('"');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
  begin
    return '"' || Fazo_Schema.Fazo.Json_Escape(Val) || '"';
  end;

end;
/
