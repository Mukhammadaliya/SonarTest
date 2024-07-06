create or replace type Fazo_Schema.Option_Timestamp Force under Fazo_Schema.w_Wrapper
(
  Val timestamp,
------------------------------------------------------------------------------------------------------
  constructor Function Option_Timestamp
  (
    self in out nocopy Fazo_Schema.Option_Timestamp,
    Val  timestamp
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
  overriding member Function Is_Timestamp return boolean,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Option_Timestamp,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2
)
/