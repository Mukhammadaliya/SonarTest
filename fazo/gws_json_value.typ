create or replace type Fazo_Schema.Gws_Json_Value Force under Fazo_Schema.w_Wrapper
(
  Val Fazo_Schema.Array_Varchar2,

------------------------------------------------------------------------------------------------------
  constructor Function Gws_Json_Value
  (
    self in out nocopy Fazo_Schema.Gws_Json_Value,
    Val  Fazo_Schema.Array_Varchar2
  ) return self as result,
------------------------------------------------------------------------------------------------------
  constructor Function Gws_Json_Value
  (
    self in out nocopy Fazo_Schema.Gws_Json_Value,
    Val  Fazo_Schema.w_Wrapper
  ) return self as result,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Gws_Json_Value,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2
)
/
create or replace type body Fazo_Schema.Gws_Json_Value is

  ------------------------------------------------------------------------------------------------------
  constructor Function Gws_Json_Value
  (
    self in out nocopy Fazo_Schema.Gws_Json_Value,
    Val  Fazo_Schema.Array_Varchar2
  ) return self as result is
  begin
    Self.Type := 'J';
    Self.Val  := Val;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  constructor Function Gws_Json_Value
  (
    self in out nocopy Fazo_Schema.Gws_Json_Value,
    Val  Fazo_Schema.w_Wrapper
  ) return self as result is
    b Stream := Stream();
  begin
    Self.Type := 'J';
    Val.Print_Json(b);
    Self.Val := b.Val;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Gws_Json_Value,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print(Self.Val);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
  begin
    return Fazo.Gather(Self.Val, '');
  end;

end;
/
