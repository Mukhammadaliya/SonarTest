create or replace Noneditionable type Fazo_Schema.Glist Force authid current_user as object
(
  Val Json_Array_t,
----------------------------------------------------------------------------------------------------
  constructor Function Glist(self in out nocopy Glist) return self as result,
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    date
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    timestamp
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    timestamp with time zone
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    timestamp with local time zone
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Date
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Fazo_Schema.Array_Timestamp
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Glist
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Glist,
    v    Json_Object_t
  ),
------------------------------------------------------------------------------------------------------
  member Function count(self in Glist) return pls_integer,
----------------------------------------------------------------------------------------------------  
  member Function r_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return varchar2,
----------------------------------------------------------------------------------------------------  
  member Function r_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
----------------------------------------------------------------------------------------------------  
  member Function r_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
----------------------------------------------------------------------------------------------------  
  member Function r_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
----------------------------------------------------------------------------------------------------  
  member Function r_Array_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return Fazo_Schema.Array_Varchar2,
----------------------------------------------------------------------------------------------------  
  member Function r_Array_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
----------------------------------------------------------------------------------------------------  
  member Function r_Array_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
----------------------------------------------------------------------------------------------------  
  member Function r_Array_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
----------------------------------------------------------------------------------------------------  
  member Function r_Glist
  (
    self in Glist,
    i    pls_integer
  ) return Glist,
----------------------------------------------------------------------------------------------------  
  member Function r_Gmap
  (
    self in Glist,
    i    pls_integer
  ) return Json_Object_t,
---------------------------------------------------------------------------------------------------- 
  member Function o_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return varchar2,
----------------------------------------------------------------------------------------------------  
  member Function o_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
----------------------------------------------------------------------------------------------------  
  member Function o_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date,
----------------------------------------------------------------------------------------------------  
  member Function o_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp,
----------------------------------------------------------------------------------------------------  
  member Function o_Array_Varchar2
  (
    self in Glist,
    i    pls_integer
  ) return Fazo_Schema.Array_Varchar2,
----------------------------------------------------------------------------------------------------  
  member Function o_Array_Number
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number,
----------------------------------------------------------------------------------------------------  
  member Function o_Array_Date
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date,
----------------------------------------------------------------------------------------------------  
  member Function o_Array_Timestamp
  (
    self       in Glist,
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp,
----------------------------------------------------------------------------------------------------  
  member Function o_Glist
  (
    self in Glist,
    i    pls_integer
  ) return Glist,
----------------------------------------------------------------------------------------------------  
  member Function o_Gmap
  (
    self in Glist,
    i    pls_integer
  ) return Json_Object_t,
------------------------------------------------------------------------------------------------------
  member Procedure Print_Json
  (
    self in Glist,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  member Function Json(self in Glist) return varchar2
)
final not Persistable
/
