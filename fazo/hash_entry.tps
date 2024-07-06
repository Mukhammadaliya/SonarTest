create or replace type Fazo_Schema.Hash_Entry Force as object
(

  Key varchar2(100),
  Val Fazo_Schema.w_Wrapper,

------------------------------------------------------------------------------------------------------
  constructor Function Hash_Entry
  (
    self in out nocopy Fazo_Schema.Hash_Entry,
    Key  varchar2,
    Val  Fazo_Schema.w_Wrapper
  ) return self as result
)
/
