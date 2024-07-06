create or replace type Fazo_Schema.Excel_Sheet Force as object
(
  name    varchar2(4000),
  z_Table Fazo_Schema.Matrix_Varchar2,

------------------------------------------------------------------------------------------------------
  constructor Function Excel_Sheet
  (
    self    in out nocopy Fazo_Schema.Excel_Sheet,
    i_Sheet Fazo_Schema.w_Wrapper
  ) return self as result,
------------------------------------------------------------------------------------------------------
  member Function Count_Row return pls_integer,
------------------------------------------------------------------------------------------------------
  member Function Count_Cell(i pls_integer) return pls_integer,
------------------------------------------------------------------------------------------------------
  member Function Is_Empty_Row(i pls_integer) return boolean,
------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    i pls_integer,
    j pls_integer
  ) return varchar2,
------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    i pls_integer,
    j pls_integer
  ) return number,
------------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    i pls_integer,
    j pls_integer
  ) return date,
------------------------------------------------------------------------------------------------------
  member Function Has
  (
    i pls_integer,
    j pls_integer
  ) return boolean,
------------------------------------------------------------------------------------------------------
  member Function Get
  (
    i pls_integer,
    j pls_integer
  ) return varchar2,
------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    i pls_integer,
    j pls_integer
  ) return varchar2,
------------------------------------------------------------------------------------------------------
  member Function o_Number
  (
    i pls_integer,
    j pls_integer
  ) return number,
------------------------------------------------------------------------------------------------------
  member Function o_Date
  (
    i pls_integer,
    j pls_integer
  ) return date

)
/
create or replace type body Fazo_Schema.Excel_Sheet is

  ------------------------------------------------------------------------------------------------------
  constructor Function Excel_Sheet
  (
    self    in out nocopy Fazo_Schema.Excel_Sheet,
    i_Sheet Fazo_Schema.w_Wrapper
  ) return self as result is
    v Fazo_Schema.Hashmap := Treat(i_Sheet as Hashmap);
  begin
    Self.Name := v.r_Varchar2('name');
    z_Table   := Fazo.Split(v.r_Array_Varchar2('table'), Chr(1));
  
    for i in 1 .. z_Table.Count
    loop
      z_Table(i) := Fazo.Split(Fazo.Gather(z_Table(i), ''), Chr(2));
      for j in 1 .. z_Table(i).Count
      loop
        z_Table(i)(j) := trim(z_Table(i) (j));
      end loop;
    end loop;
  
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Count_Row return pls_integer is
  begin
    return z_Table.Count;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Count_Cell(i pls_integer) return pls_integer is
  begin
    if 0 < i and i <= z_Table.Count then
      return z_Table(i).Count;
    else
      return 0;
    end if;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Empty_Row(i pls_integer) return boolean is
  begin
    if 0 < i and i <= z_Table.Count then
      for j in 1 .. z_Table(i).Count
      loop
        if z_Table(i) (j) is not null then
          return false;
        end if;
      end loop;
    end if;
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    i pls_integer,
    j pls_integer
  ) return varchar2 is
  begin
    return trim(z_Table(i) (j));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    i pls_integer,
    j pls_integer
  ) return number is
  begin
    return Fazo_Schema.Fazo.Format_Number(trim(z_Table(i) (j)));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    i pls_integer,
    j pls_integer
  ) return date is
  begin
    return Fazo_Schema.Fazo.Format_Date(trim(z_Table(i) (j)));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Has
  (
    i pls_integer,
    j pls_integer
  ) return boolean is
  begin
    return 0 < i and i <= z_Table.Count and 0 < j and j <= z_Table(i).Count;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Get
  (
    i pls_integer,
    j pls_integer
  ) return varchar2 is
  begin
    return z_Table(i)(j);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    i pls_integer,
    j pls_integer
  ) return varchar2 is
  begin
    if Has(i, j) then
      return r_Varchar2(i, j);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Number
  (
    i pls_integer,
    j pls_integer
  ) return number is
  begin
    if Has(i, j) then
      return r_Number(i, j);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Date
  (
    i pls_integer,
    j pls_integer
  ) return date is
  begin
    if Has(i, j) then
      return r_Date(i, j);
    end if;
    return null;
  end;

end;
/
