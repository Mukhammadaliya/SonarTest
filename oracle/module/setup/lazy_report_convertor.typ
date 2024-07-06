create or replace type Lazy_Report_Convertor as object
(
  Register_Id number,
----------------------------------------------------------------------------------------------------
  constructor Function Lazy_Report_Convertor(Register_Id number) return self as result,
----------------------------------------------------------------------------------------------------  
  member Function Get_Value(self Lazy_Report_Convertor) return number
)
/
create or replace type body Lazy_Report_Convertor is
  ----------------------------------------------------------------------------------------------------
  constructor Function Lazy_Report_Convertor(Register_Id number) return self as result is
  begin
    Self.Register_Id := Register_Id;
    return;
  end;

  ---------------------------------------------------------------------------------------------------- 
  member Function Get_Value(self Lazy_Report_Convertor) return number is
  begin
    return Self.Register_Id;
  end;

end;
/
