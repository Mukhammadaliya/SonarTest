create or replace type Fazo_Schema.Calc Force under Fazo_Schema.w_Wrapper
(
  Buckets Fazo_Schema.w_Calc_Bucket_Array,
  Sep     varchar2(1),
------------------------------------------------------------------------------------------------------
  constructor Function Calc(self in out nocopy Fazo_Schema.Calc) return self as result,
------------------------------------------------------------------------------------------------------
  constructor Function Calc
  (
    self      in out nocopy Fazo_Schema.Calc,
    Separator varchar2
  ) return self as result,
------------------------------------------------------------------------------------------------------
  member Procedure Find_Or_Create
  (
    self  in out nocopy Fazo_Schema.Calc,
    i_Key varchar2,
    i     out pls_integer,
    j     out pls_integer
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key  varchar2,
    v    number
  ),
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    v    number
  ),
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    v    number
  ),
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    v    number
  ),
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    Key5 varchar2,
    v    number
  ),

------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    That in Fazo_Schema.Calc
  ),
------------------------------------------------------------------------------------------------------
  member Function count return binary_integer,
------------------------------------------------------------------------------------------------------
  member Function Get_Value(Key varchar2) return number,
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2
  ) return number,
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2
  ) return number,
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2
  ) return number,
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    Key5 varchar2
  ) return number,
------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key  varchar2,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    Key5 varchar2,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Function Sum_By_Prefix(Prefix varchar2) return number,
------------------------------------------------------------------------------------------------------
  member Function Sum_By_Like(Expr varchar2) return number,
------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key(Key1 varchar2) return number,
------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key
  (
    Key1 varchar2,
    Key2 varchar2
  ) return number,
------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2
  ) return number,
------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2
  ) return number,
------------------------------------------------------------------------------------------------------
  member Function Get_Bucket return Fazo_Schema.Calc_Bucket,
------------------------------------------------------------------------------------------------------
  member Function Keyset return Fazo_Schema.Array_Varchar2,
------------------------------------------------------------------------------------------------------
  overriding member Function Is_Calc return boolean,
------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Calc,
    out  in out nocopy Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2
)
/
