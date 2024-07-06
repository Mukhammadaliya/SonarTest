create or replace type body Fazo_Schema.Option_Date is

  ------------------------------------------------------------------------------------------------------
  constructor Function Option_Date
  (
    self in out nocopy Fazo_Schema.Option_Date,
    Val  date
  ) return self as result is
  begin
    Self.Type := 'd';
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
    return Fazo_Schema.Fazo.Format_Date(Val, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    return Val;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    return cast(Val as timestamp);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    return Fazo_Schema.Array_Varchar2(Fazo_Schema.Fazo.Format_Date(Val, i_Format, i_Nlsparam));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
  begin
    return Fazo_Schema.Array_Date(Val);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
  begin
    return Fazo_Schema.Array_Timestamp(cast(Val as timestamp));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Date return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Option_Date,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print('"' || Fazo_Schema.Fazo.Format_Date(Self.Val) || '"');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
  begin
    return '"' || Fazo_Schema.Fazo.Format_Date(Self.Val) || '"';
  end Json;

end;
/
