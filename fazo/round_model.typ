create or replace type Fazo_Schema.Round_Model Force as object
(
  z_Scale number,
  z_Half  number,
  z_Type  varchar2(1),

------------------------------------------------------------------------------------------------------
  constructor Function Round_Model
  (
    self    in out nocopy Fazo_Schema.Round_Model,
    i_Model varchar2
  ) return self as result,
------------------------------------------------------------------------------------------------------
  member Function z_Eval
  (
    i_Val   number,
    i_Scale number
  ) return number,
------------------------------------------------------------------------------------------------------
  member Function Eval(i_Val number) return number

)
/
create or replace type body Fazo_Schema.Round_Model is

  ------------------------------------------------------------------------------------------------------
  constructor Function Round_Model
  (
    self    in out nocopy Fazo_Schema.Round_Model,
    i_Model varchar2
  ) return self as result is
  begin
    if i_Model is null then
      Raise_Application_Error(-20999, 'Round model is null');
    end if;
  
    Self.z_Scale := to_number(Substr(i_Model, 1, 4), 'S9D9', 'NLS_NUMERIC_CHARACTERS=''. ''');
    if Substr(i_Model, 4, 1) = '5' then
      Self.z_Scale := Self.z_Scale - 0.5;
      Self.z_Half  := 1;
    else
      Self.z_Half := 0;
    end if;
    Self.z_Type := Substr(i_Model, 5, 1);
  
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function z_Eval
  (
    i_Val   number,
    i_Scale number
  ) return number is
    v_Ten number := Power(10, i_Scale);
  begin
    case Self.z_Type
      when 'C' then
        return Ceil(i_Val * v_Ten) / v_Ten;
      when 'R' then
        return Round(i_Val * v_Ten) / v_Ten;
      when 'F' then
        return Floor(i_Val * v_Ten) / v_Ten;
    end case;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Eval(i_Val number) return number is
  begin
    if i_Val is null then
      return null;
    end if;
    if i_Val = 0 then
      return 0;
    end if;
    /*if i_Val < 0 then
      Raise_Application_Error(-20999, 'ROUND_MODEL: value is negative');
    end if;*/
    if z_Half = 1 then
      return z_Eval(i_Val * 2, z_Scale) / 2;
    else
      return z_Eval(i_Val, z_Scale);
    end if;
  end;

end;
/
