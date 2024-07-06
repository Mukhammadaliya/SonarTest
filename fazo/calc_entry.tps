create or replace type Fazo_Schema.Calc_Entry Force as object
(

  Key varchar2(100),
  Val number,

------------------------------------------------------------------------------------------------------
  constructor Function Calc_Entry
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    Key  varchar2
  ) return self as result,

------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Subtract
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Multiply
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Divide
  (
    self in out nocopy Fazo_Schema.Calc_Entry,
    v    number
  )

)
/
