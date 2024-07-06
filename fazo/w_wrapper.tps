create or replace type Fazo_Schema.w_Wrapper Force as object
(
  type char(1),
------------------------------------------------------------------------------------------------------
  member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
  member Function As_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
  member Function As_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
  member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
  member Function As_Array_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
  member Function As_Array_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
------------------------------------------------------------------------------------------------------
  member Function Is_Varchar2 return boolean,
  member Function Is_Number return boolean,
  member Function Is_Date return boolean,
  member Function Is_Timestamp return boolean,
  member Function Is_Array_Varchar2 return boolean,
  member Function Is_Array_Number return boolean,
  member Function Is_Array_Date return boolean,
  member Function Is_Array_Timestamp return boolean,
  member Function Is_Arraylist return boolean,
  member Function Is_Calc return boolean,
  member Function Is_Hashmap return boolean,
------------------------------------------------------------------------------------------------------
  not instantiable member Procedure Print_Json
  (
    self in Fazo_Schema.w_Wrapper,
    out  in out nocopy Fazo_Schema.Stream
  ),
  not instantiable member Function Json return varchar2
)
not instantiable not final;
/
