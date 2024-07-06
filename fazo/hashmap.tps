create or replace type Fazo_Schema.Hashmap Force under Fazo_Schema.w_Wrapper
(
  Keys    Fazo_Schema.Calc,
  Buckets Fazo_Schema.Hash_Bucket,

------------------------------------------------------------------------------------------------------
  constructor Function Hashmap(self in out nocopy Fazo_Schema.Hashmap) return self as result,
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.w_Wrapper
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    date
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    timestamp
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    timestamp with time zone
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    timestamp with local time zone
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Date
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Fazo_Schema.Hashmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Timestamp
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Put_All
  (
    self in out nocopy Fazo_Schema.Hashmap,
    That Fazo_Schema.Hashmap
  ),
------------------------------------------------------------------------------------------------------
  member Function count return binary_integer,
------------------------------------------------------------------------------------------------------
  member Function Has(Key varchar2) return boolean,
------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  member Function r_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
  member Function r_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
  member Function r_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
  member Function r_Array_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  member Function r_Array_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
  member Function r_Array_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
  member Function r_Array_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
  member Function r_Calc(Key varchar2) return Fazo_Schema.Calc,
  member Function r_Arraylist(Key varchar2) return Fazo_Schema.Arraylist,
  member Function r_Hashmap(Key varchar2) return Fazo_Schema.Hashmap,
------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
  member Function o_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
  member Function o_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
  member Function o_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
  member Function o_Array_Varchar2
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2,
  member Function o_Array_Number
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
  member Function o_Array_Date
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
  member Function o_Array_Timestamp
  (
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
  member Function o_Calc(Key varchar2) return Fazo_Schema.Calc,
  member Function o_Arraylist(Key varchar2) return Fazo_Schema.Arraylist,
  member Function o_Hashmap(Key varchar2) return Fazo_Schema.Hashmap,
------------------------------------------------------------------------------------------------------
  overriding member Function Is_Hashmap return boolean,
------------------------------------------------------------------------------------------------------
  member Function Is_Varchar2(Key varchar2) return boolean,
  member Function Is_Number(Key varchar2) return boolean,
  member Function Is_Date(Key varchar2) return boolean,
  member Function Is_Timestamp(Key varchar2) return boolean,
  member Function Is_Array_Varchar2(Key varchar2) return boolean,
  member Function Is_Array_Number(Key varchar2) return boolean,
  member Function Is_Array_Date(Key varchar2) return boolean,
  member Function Is_Array_Timestamp(Key varchar2) return boolean,
  member Function Is_Calc(Key varchar2) return boolean,
  member Function Is_Arraylist(Key varchar2) return boolean,
  member Function Is_Hashmap(Key varchar2) return boolean,
------------------------------------------------------------------------------------------------------
  member Function Keyset return Array_Varchar2,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Hashmap,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2
)
/
