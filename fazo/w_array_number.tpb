create or replace type body Fazo_Schema.w_Array_Number is

  ------------------------------------------------------------------------------------------------------
  constructor Function w_Array_Number
  (
    self in out nocopy Fazo_Schema.w_Array_Number,
    Val  Fazo_Schema.Array_Number
  ) return self as result is
  begin
    Self.Type := 'N';
    Self.Val  := Val;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    if Val.Count = 1 then
      return Fazo_Schema.Fazo.Format_Number(Val(1), i_Format, i_Nlsparam);
    elsif Val.Count = 0 then
      raise No_Data_Found;
    else
      raise Too_Many_Rows;
    end if;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    if Val.Count = 1 then
      return Val(1);
    elsif Val.Count = 0 then
      raise No_Data_Found;
    else
      raise Too_Many_Rows;
    end if;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    return Fazo_Schema.Fazo.To_Array_Varchar2(Val, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
  begin
    return Val;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Array_Number return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.w_Array_Number,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print('[');
    if Val is not null then
      for i in 1 .. Val.Count
      loop
        Out.Print('"' || Fazo_Schema.Fazo.Format_Number(Self.Val(i)) || '"');
        if i <> Val.Count then
          Out.Print(',');
        end if;
      end loop;
    end if;
    Out.Print(']');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
    result varchar2(32767);
  begin
    result := '[';
    if Val is not null then
      for i in 1 .. Val.Count
      loop
        result := result || '"' || Fazo_Schema.Fazo.Format_Number(Val(i)) || '"';
        if i <> Val.Count then
          result := result || ',';
        end if;
      end loop;
    end if;
    result := result || ']';
    return result;
  end;

end;
/
