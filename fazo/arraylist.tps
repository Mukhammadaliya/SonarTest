create or replace type Fazo_Schema.Arraylist Force under Fazo_Schema.w_Wrapper
(
  Val Fazo_Schema.w_Array_Wrapper,
------------------------------------------------------------------------------------------------------
  constructor Function Arraylist(self in out nocopy Fazo_Schema.Arraylist) return self as result,
------------------------------------------------------------------------------------------------------
  constructor Function Arraylist
  (
    self in out nocopy Fazo_Schema.Arraylist,
    Val  Fazo_Schema.w_Array_Wrapper
  ) return self as result,
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.w_Wrapper
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    date
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    timestamp
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    timestamp with time zone
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    timestamp with local time zone
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Date
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Timestamp
  ),
------------------------------------------------------------------------------------------------------
  member Function count return pls_integer,
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
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
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
  member Function r_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  member Function r_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
  member Function r_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
  member Function r_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
  member Function r_Array_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  member Function r_Array_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
  member Function r_Array_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
  member Function r_Array_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
  member Function r_Calc(i pls_integer) return Fazo_Schema.Calc,
  member Function r_Arraylist(i pls_integer) return Fazo_Schema.Arraylist,
  member Function r_Hashmap(i pls_integer) return Fazo_Schema.w_Wrapper,
------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  member Function o_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
  member Function o_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
  member Function o_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
  member Function o_Array_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  member Function o_Array_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
  member Function o_Array_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
  member Function o_Array_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
  member Function o_Calc(i pls_integer) return Fazo_Schema.Calc,
  member Function o_Arraylist(i pls_integer) return Fazo_Schema.Arraylist,
  member Function o_Hashmap(i pls_integer) return Fazo_Schema.w_Wrapper,
------------------------------------------------------------------------------------------------------
  overriding member Function Is_Arraylist return boolean,
------------------------------------------------------------------------------------------------------
  member Function Is_Varchar2(i pls_integer) return boolean,
  member Function Is_Number(i pls_integer) return boolean,
  member Function Is_Date(i pls_integer) return boolean,
  member Function Is_Timestamp(i pls_integer) return boolean,
  member Function Is_Array_Varchar2(i pls_integer) return boolean,
  member Function Is_Array_Number(i pls_integer) return boolean,
  member Function Is_Array_Date(i pls_integer) return boolean,
  member Function Is_Array_Timestamp(i pls_integer) return boolean,
  member Function Is_Arraylist(i pls_integer) return boolean,
  member Function Is_Calc(i pls_integer) return boolean,
  member Function Is_Hashmap(i pls_integer) return boolean,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Arraylist,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2,
------------------------------------------------------------------------------------------------------
  static Function As_Arraylist(v Fazo_Schema.w_Wrapper) return Arraylist
)
/
