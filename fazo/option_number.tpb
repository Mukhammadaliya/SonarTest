create or replace type body Fazo_Schema.Option_Number is

  ------------------------------------------------------------------------------------------------------
  constructor Function Option_Number
  (
    self in out nocopy Fazo_Schema.Option_Number,
    Val  number
  ) return self as result is
  begin
    Self.Type := 'n';
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
    return Fazo_Schema.Fazo.Format_Number(Val, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    return Val;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    return Fazo_Schema.Array_Varchar2(Fazo_Schema.Fazo.Format_Number(Val, i_Format, i_Nlsparam));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
  begin
    return Fazo_Schema.Array_Number(Val);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Number return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Option_Number,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print('"' || Fazo_Schema.Fazo.Format_Number(Self.Val) || '"');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
  begin
    return '"' || Fazo_Schema.Fazo.Format_Number(Val) || '"';
  end;

end;
/
