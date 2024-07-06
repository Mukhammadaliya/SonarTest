create or replace type Fazo_Schema.w_Array_Number Force under Fazo_Schema.w_Wrapper
(
  Val Fazo_Schema.Array_Number,
------------------------------------------------------------------------------------------------------
  constructor Function w_Array_Number
  (
    self in out nocopy Fazo_Schema.w_Array_Number,
    Val  Fazo_Schema.Array_Number
  ) return self as result,
------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
------------------------------------------------------------------------------------------------------
  overriding member Function Is_Array_Number return boolean,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.w_Array_Number,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2
)
/
