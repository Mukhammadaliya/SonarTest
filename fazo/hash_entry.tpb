create or replace type body Fazo_Schema.Hash_Entry is

  ------------------------------------------------------------------------------------------------------
  constructor Function Hash_Entry
  (
    self in out nocopy Fazo_Schema.Hash_Entry,
    Key  varchar2,
    Val  Fazo_Schema.w_Wrapper
  ) return self as result is
  begin
    Self.Key := Key;
    Self.Val := Val;
    return;
  end Hash_Entry;

end;
/
