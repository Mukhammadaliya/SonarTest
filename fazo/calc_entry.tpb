create or replace type body Fazo_Schema.Calc_Entry is

  ------------------------------------------------------------------------------------------------------
  constructor Function Calc_Entry
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    Key  varchar2
  ) return self as result is
  begin
    Self.Key := Key;
    Self.Val := 0;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ) is
  begin
    if v is not null then
      Self.Val := Val + v;
    end if;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Subtract
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ) is
  begin
    if v is not null then
      Self.Val := Val - v;
    end if;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Multiply
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ) is
  begin
    if v is not null then
      Self.Val := Val * v;
    end if;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Divide
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ) is
  begin
    if v is not null then
      Self.Val := Val / v;
    end if;
  end;

end;
/
