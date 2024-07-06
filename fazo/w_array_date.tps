create or replace type Fazo_Schema.w_Array_Date Force under Fazo_Schema.w_Wrapper
(
  Val Fazo_Schema.Array_Date,
------------------------------------------------------------------------------------------------------
  constructor Function w_Array_Date
  (
    self in out nocopy Fazo_Schema.w_Array_Date,
    Val  Fazo_Schema.Array_Date
  ) return self as result,
------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  overriding member Function As_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
  overriding member Function As_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  overriding member Function As_Array_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
  overriding member Function As_Array_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
------------------------------------------------------------------------------------------------------
  overriding member Function Is_Array_Date return boolean,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.w_Array_Date,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2
)
/
