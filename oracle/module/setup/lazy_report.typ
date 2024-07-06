create or replace type Lazy_Report as object
(
  Report_Type varchar2(10),
----------------------------------------------------------------------------------------------------
  constructor Function Lazy_Report(self in out nocopy Lazy_Report) return self as result,
---------------------------------------------------------------------------------------------------- 
  member Function Get_Value(self Lazy_Report) return varchar2
)
/
create or replace type body Lazy_Report is
  ----------------------------------------------------------------------------------------------------
  constructor Function Lazy_Report(self in out nocopy Lazy_Report) return self as result is
  begin
    return;
  end;

  ---------------------------------------------------------------------------------------------------- 
  member Function Get_Value(self Lazy_Report) return varchar2 is
  begin
    return Self.Report_Type;
  end;

end;
/
