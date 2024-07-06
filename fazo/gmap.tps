create or replace Noneditionable type Fazo_Schema.Gmap Force authid current_user as object
(
  Val Json_Object_t,
----------------------------------------------------------------------------------------------------
  constructor Function Gmap(self in out nocopy Gmap) return self as result,
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    varchar2
  ),

----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    date
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    timestamp
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    timestamp with time zone
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    timestamp with local time zone
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Date
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Fazo_Schema.Array_Timestamp
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Glist
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    self in out nocopy Gmap,
    Key  varchar2,
    v    Gmap
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Put_All
  (
    self in out nocopy Gmap,
    That Gmap
  ),
----------------------------------------------------------------------------------------------------
  member Function count(self in Gmap) return pls_integer,
----------------------------------------------------------------------------------------------------
  member Function Has
  (
    self in Gmap,
    Key  varchar2
  ) return boolean,
------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return varchar2,
------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
----------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
----------------------------------------------------------------------------------------------------
  member Function r_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
------------------------------------------------------------------------------------------------------
  member Function r_Array_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return Fazo_Schema.Array_Varchar2,
------------------------------------------------------------------------------------------------------
  member Function r_Array_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
------------------------------------------------------------------------------------------------------
  member Function r_Array_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
------------------------------------------------------------------------------------------------------
  member Function r_Array_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
----------------------------------------------------------------------------------------------------
  member Function r_Glist
  (
    self in Gmap,
    Key  varchar2
  ) return Glist,
----------------------------------------------------------------------------------------------------
  member Function r_Gmap
  (
    self in Gmap,
    Key  varchar2
  ) return Gmap,
------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return varchar2,
------------------------------------------------------------------------------------------------------
  member Function o_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
----------------------------------------------------------------------------------------------------
  member Function o_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
----------------------------------------------------------------------------------------------------
  member Function o_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
------------------------------------------------------------------------------------------------------
  member Function o_Array_Varchar2
  (
    self in Gmap,
    Key  varchar2
  ) return Fazo_Schema.Array_Varchar2,
------------------------------------------------------------------------------------------------------
  member Function o_Array_Number
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
------------------------------------------------------------------------------------------------------
  member Function o_Array_Date
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
------------------------------------------------------------------------------------------------------
  member Function o_Array_Timestamp
  (
    self       in Gmap,
    Key        varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
----------------------------------------------------------------------------------------------------
  member Function o_Glist
  (
    self in Gmap,
    Key  varchar2
  ) return Glist,
----------------------------------------------------------------------------------------------------
  member Function o_Gmap
  (
    self in Gmap,
    Key  varchar2
  ) return Gmap,
------------------------------------------------------------------------------------------------------
  member Function Keyset(self in Gmap) return Fazo_Schema.Array_Varchar2,
----------------------------------------------------------------------------------------------------
  member Procedure Print_Json
  (
    self in Gmap,
    out  in out nocopy Fazo_Schema.Stream
  ),
----------------------------------------------------------------------------------------------------  
  member Function Json(self in Gmap) return varchar2
)
final not Persistable
/
