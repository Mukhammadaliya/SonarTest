create or replace type Runtime_Service force as object
(
  Class_Name         varchar2(1000),
  Detail             Hashmap,
  Data               Array_Varchar2,
  Review_Procedure   varchar2(120),
  Response_Procedure varchar2(120),
  Action_In          varchar2(1), -- (V)archar2, (A)rray_varchar2, (H)ashmap, Array(L)ist
  Action_Out         varchar2(1), -- (V)archar2, (A)rray_varchar2, (H)ashmap, Array(L)ist
----------------------------------------------------------------------------------------------------  
  constructor Function Runtime_Service(Class_Name varchar2) return self as result,
----------------------------------------------------------------------------------------------------
  member Procedure Set_Detail
  (
    self   in out nocopy Runtime_Service,
    Detail Hashmap
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Set_Data
  (
    self in out nocopy Runtime_Service,
    Data varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Set_Data
  (
    self in out nocopy Runtime_Service,
    Data Array_Varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Set_Data
  (
    self in out nocopy Runtime_Service,
    Data Fazo_Schema.w_Wrapper
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Set_Response_Procedure
  (
    self               in out nocopy Runtime_Service,
    Response_Procedure varchar2 := null,
    Action_In          varchar2 := null,
    Action_Out         varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Set_Review_Procedure
  (
    self             in out nocopy Runtime_Service,
    Review_Procedure varchar2
  )
)
/
create or replace type body Runtime_Service is
  ----------------------------------------------------------------------------------------------------  
  constructor Function Runtime_Service(Class_Name varchar2) return self as result is
  begin
    Self.Class_Name := Class_Name;
    Self.Detail     := Hashmap();
    Self.Action_In  := Biruni_Pref.c_Rs_Action_In_Out_Array_Varchar2;
    return;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Detail
  (
    self   in out nocopy Runtime_Service,
    Detail Hashmap
  ) is
  begin
    Self.Detail := Detail;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Data
  (
    self in out nocopy Runtime_Service,
    Data varchar2
  ) is
  begin
    Self.Data := Array_Varchar2(Data);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Data
  (
    self in out nocopy Runtime_Service,
    Data Array_Varchar2
  ) is
  begin
    Self.Data := Data;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Data
  (
    self in out nocopy Runtime_Service,
    Data Fazo_Schema.w_Wrapper
  ) is
  begin
    Self.Data := Fazo.To_Json(Data).Val;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Response_Procedure
  (
    self               in out nocopy Runtime_Service,
    Response_Procedure varchar2,
    Action_In          varchar2,
    Action_Out         varchar2
  ) is
  begin
    Self.Response_Procedure := Response_Procedure;
  
    if Action_In is null or
       Action_In in (Biruni_Pref.c_Rs_Action_In_Out_Varchar2,
                     Biruni_Pref.c_Rs_Action_In_Out_Array_Varchar2,
                     Biruni_Pref.c_Rs_Action_In_Out_Hashmap,
                     Biruni_Pref.c_Rs_Action_In_Out_Arraylist) then
      Self.Action_In := Action_In;
    else
      Raise_Application_Error('-20999', 'Type ' || Action_In || ' is not supported.');
    end if;
  
    if Action_Out is null or
       Action_Out in (Biruni_Pref.c_Rs_Action_In_Out_Varchar2,
                      Biruni_Pref.c_Rs_Action_In_Out_Array_Varchar2,
                      Biruni_Pref.c_Rs_Action_In_Out_Hashmap,
                      Biruni_Pref.c_Rs_Action_In_Out_Arraylist) then
      Self.Action_Out := Action_Out;
    else
      Raise_Application_Error('-20999', 'Type ' || Action_Out || ' is not supported.');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Review_Procedure
  (
    self             in out nocopy Runtime_Service,
    Review_Procedure varchar2
  ) is
  begin
    Self.Review_Procedure := Review_Procedure;
  end;

end;
/
