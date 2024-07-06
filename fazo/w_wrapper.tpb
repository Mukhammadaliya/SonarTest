create or replace type body Fazo_Schema.w_Wrapper is

  ------------------------------------------------------------------------------------------------------
  member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Array_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Array_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
  begin
    raise Value_Error;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Varchar2 return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Number return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Date return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Timestamp return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Varchar2 return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Number return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Date return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Timestamp return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Arraylist return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Calc return boolean is
  begin
    return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Hashmap return boolean is
  begin
    return false;
  end;

end;
/
