create or replace package Fazo_Schema.Fazo authid current_user is

  -- json stringify for array_varchar2, matrix_varchar2 and other primitive types

  c_Whitespace constant varchar2(4) := ' ' || Chr(10) || Chr(9) || Chr(13);
  ----------------------------------------------------------------------------------------------------
  type Varchar2_Code_Aat is table of varchar2(4000) index by varchar2(100);
  type Varchar2_Id_Aat is table of varchar2(4000) index by binary_integer;
  type Number_Code_Aat is table of number index by varchar2(100);
  type Number_Id_Aat is table of number index by binary_integer;
  type Date_Code_Aat is table of date index by varchar2(100);
  type Date_Id_Aat is table of date index by binary_integer;
  type Boolean_Code_Aat is table of boolean index by varchar2(100);
  type Boolean_Id_Aat is table of boolean index by binary_integer;
  ----------------------------------------------------------------------------------------------------
  subtype Rowid_t is rowid;
  type Array_Rowid is table of rowid;
  ------------------------------------------------------------------------------------------------------
  Function Version return number;
  ------------------------------------------------------------------------------------------------------
  Function Json_Escape(v varchar2) return varchar2;
  ------------------------------------------------------------------------------------------------------
  Procedure Json_Escape_And_Print
  (
    out in out nocopy Stream,
    v   varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Format_Number
  (
    i_Val      number,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Format_Number
  (
    i_Val      varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Function Format_Date
  (
    i_Val      date,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Format_Date
  (
    i_Val      varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date;
  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      timestamp,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      timestamp with time zone,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      timestamp with local time zone,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp;
  ----------------------------------------------------------------------------------------------------
  Function Is_Number(i_Val varchar2) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Varchar2
  (
    i_Val      Array_Number,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Varchar2
  (
    i_Val      Array_Date,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Varchar2
  (
    i_Val      Array_Timestamp,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Number
  (
    i_Val      Array_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Number;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Date
  (
    i_Val      Array_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Date;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Date(i_Val Array_Timestamp) return Array_Date;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Timestamp
  (
    i_Val      Array_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Function To_Array_Timestamp(i_Val Array_Date) return Array_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Varchar2
  (
    i_Val      Matrix_Number,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Varchar2
  (
    i_Val      Matrix_Date,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Varchar2
  (
    i_Val      Matrix_Timestamp,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Number
  (
    i_Val      Matrix_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Number;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Date
  (
    i_Val      Matrix_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Date;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Date(i_Val Matrix_Timestamp) return Matrix_Date;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Timestamp
  (
    i_Val      Matrix_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Timestamp(i_Val Matrix_Date) return Matrix_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Function Column_Varchar2
  (
    i_Array Array_Varchar2,
    i_Index number
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Column_Number
  (
    i_Array Array_Number,
    i_Index number
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Function Column_Date
  (
    i_Array Array_Date,
    i_Index number
  ) return date;
  ----------------------------------------------------------------------------------------------------
  Function Column_Timestamp
  (
    i_Array Array_Timestamp,
    i_Index number
  ) return timestamp;
  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Varchar2,
    i_Col_Index pls_integer
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Number,
    i_Col_Index pls_integer
  ) return Array_Number;
  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Date,
    i_Col_Index pls_integer
  ) return Array_Date;
  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Timestamp,
    i_Col_Index pls_integer
  ) return Array_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Varchar2) return Matrix_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Number) return Matrix_Number;
  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Date) return Matrix_Date;
  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Timestamp) return Matrix_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Varchar2) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Number) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Date) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Timestamp) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Varchar2) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Varchar2) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Number) return Array_Number;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Number);
  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Number) return Array_Number;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Number);
  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Date) return Array_Date;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Date);
  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Date) return Array_Date;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Date);
  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Timestamp) return Array_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Timestamp);
  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Timestamp) return Array_Timestamp;
  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Timestamp);
  ----------------------------------------------------------------------------------------------------
  Function Zip_Map
  (
    i_Name1 varchar2,
    i_Val1  varchar2,
    i_Name2 varchar2 := null,
    i_Val2  varchar2 := null,
    i_Name3 varchar2 := null,
    i_Val3  varchar2 := null,
    i_Name4 varchar2 := null,
    i_Val4  varchar2 := null,
    i_Name5 varchar2 := null,
    i_Val5  varchar2 := null,
    i_Name6 varchar2 := null,
    i_Val6  varchar2 := null
  ) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Zip_Array_Map
  (
    i_Name1 varchar2,
    i_Val1  Array_Varchar2,
    i_Name2 varchar2 := null,
    i_Val2  Array_Varchar2 := null,
    i_Name3 varchar2 := null,
    i_Val3  Array_Varchar2 := null,
    i_Name4 varchar2 := null,
    i_Val4  Array_Varchar2 := null,
    i_Name5 varchar2 := null,
    i_Val5  Array_Varchar2 := null,
    i_Name6 varchar2 := null,
    i_Val6  Array_Varchar2 := null
  ) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Zip_Matrix(i_Val Matrix_Varchar2) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Zip_Matrix
  (
    i_Val1 Array_Varchar2,
    i_Val2 Array_Varchar2 := null,
    i_Val3 Array_Varchar2 := null,
    i_Val4 Array_Varchar2 := null
  ) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Zip_Matrix_Transposed(i_Val Matrix_Varchar2) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Varchar2,
    i_Val   varchar2
  ) return pls_integer;
  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Number,
    i_Val   number
  ) return pls_integer;
  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Date,
    i_Val   date
  ) return pls_integer;
  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Timestamp,
    i_Val   timestamp
  ) return pls_integer;
  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Varchar2,
    i_Val   varchar2
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Number,
    i_Val   number
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Date,
    i_Val   date
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Timestamp,
    i_Val   timestamp
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Varchar2,
    i_Val   varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Number,
    i_Val   number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Date,
    i_Val   date
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Timestamp,
    i_Val   timestamp
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Varchar2,
    i_Val    Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Number,
    i_Val    Array_Number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Date,
    i_Val    Array_Date
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Timestamp,
    i_Val    Array_Timestamp
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Varchar2,
    i_Val1   varchar2,
    i_Val2   varchar2 := null,
    i_Val3   varchar2 := null,
    i_Val4   varchar2 := null,
    i_Val5   varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Number,
    i_Val1   number,
    i_Val2   number := null,
    i_Val3   number := null,
    i_Val4   number := null,
    i_Val5   number := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Date,
    i_Val1   date,
    i_Val2   date := null,
    i_Val3   date := null,
    i_Val4   date := null,
    i_Val5   date := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Timestamp,
    i_Val1   timestamp,
    i_Val2   timestamp := null,
    i_Val3   timestamp := null,
    i_Val4   timestamp := null,
    i_Val5   timestamp := null
  );
  ----------------------------------------------------------------------------------------------------
  Function Parse_Json(i_Src varchar2) return w_Wrapper;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Json(i_Src Array_Varchar2) return w_Wrapper;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Json(i_Src clob) return w_Wrapper;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Array(i_Src varchar2) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Array(i_Src Array_Varchar2) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Array(i_Src clob) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Map(i_Src varchar2) return Fazo_Schema.Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Map(i_Src Array_Varchar2) return Fazo_Schema.Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Parse_Map(i_Src clob) return Fazo_Schema.Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.w_Wrapper) return Stream;
  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Varchar2) return Stream;
  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Number) return Stream;
  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Date) return Stream;
  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Timestamp) return Stream;
  ----------------------------------------------------------------------------------------------------
  Function Split
  (
    i_Val       varchar2,
    i_Delimiter varchar2
  ) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Split
  (
    i_Val       Array_Varchar2,
    i_Delimiter varchar2
  ) return Matrix_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Varchar2,
    i_Delimiter varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Number,
    i_Delimiter varchar2,
    i_Format    varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Date,
    i_Delimiter varchar2,
    i_Format    varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Timestamp,
    i_Delimiter varchar2,
    i_Format    varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 varchar2,
    i_Val2 varchar2
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 number,
    i_Val2 number
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 date,
    i_Val2 date
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 timestamp,
    i_Val2 timestamp
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Week_Day(i_Date date) return pls_integer;
  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha1(i_Value varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha1(i_Value Array_Varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha1(i_Value clob) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Read_Clob(i_Clob clob) return Array_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Make_Clob(i_Val Array_Varchar2) return clob;
  ----------------------------------------------------------------------------------------------------
  Function Length_Text(i_Val Array_Varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Function Lengthb_Text(i_Val Array_Varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Function Empty_Text(i_Val Array_Varchar2) return boolean;
  ----------------------------------------------------------------------------------------------------
  Function Dump(i_Val varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Mk_Message
  (
    i_Template varchar2,
    i_Params   Fazo_Schema.Array_Varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Trim_Ora_Error(i_Error varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Trimmed_Sqlerrm return varchar2;

end Fazo;
/
create or replace package body Fazo_Schema.Fazo is

  ------------------------------------------------------------------------------------------------------
  Function Version return number is
  begin
    return 20140524;
  end;

  ------------------------------------------------------------------------------------------------------
  Function Json_Escape(v varchar2) return varchar2 is
    c varchar2(3);
    r varchar2(32767);
  begin
    if v is null then
      return r;
    end if;
    for i in 1 .. Length(v)
    loop
      c := Substr(v, i, 1);
      if c < ' ' then
        case c
          when Chr(8) then
            r := r || '\b';
          when Chr(9) then
            r := r || '\t';
          when Chr(10) then
            r := r || '\r';
          when Chr(12) then
            r := r || '\f';
          when Chr(13) then
            r := r || '\n';
          else
            r := r || Lpad(Rawtohex(Utl_Raw.Cast_To_Raw(c)), 4, '0');
        end case;
      
      else
        case c
          when '"' then
            r := r || '\"';
          when '\' then
            r := r || '\\';
            -- not required to escape only for </script>
        --when '/' then r := r || '\/';
          when Chr(127) then
            r := r || '\u007f';
          else
            r := r || c;
        end case;
      
      end if;
    
    end loop;
    return r;
  end;

  ------------------------------------------------------------------------------------------------------
  Procedure Json_Escape_And_Print
  (
    out in out nocopy Stream,
    v   varchar2
  ) is
  
  begin
  
    Out.Print(Json_Escape(v));
  
  exception
    when Value_Error then
    
      Out.Print(Json_Escape(Substr(v, 1, 10000)));
      Out.Print(Json_Escape(Substr(v, 10001, 10000)));
      Out.Print(Json_Escape(Substr(v, 20001, 10000)));
      Out.Print(Json_Escape(Substr(v, 30001)));
    
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Number
  (
    i_Val      number,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    if i_Format is not null then
      if i_Nlsparam is not null then
        return to_char(i_Val, i_Format, i_Nlsparam);
      else
        return to_char(i_Val, i_Format);
      end if;
    else
      if i_Nlsparam is not null then
        raise Value_Error;
      elsif -1 < i_Val and i_Val < 0 then
        return '-0' || to_char(-i_Val, 'TM9', 'NLS_NUMERIC_CHARACTERS=''. ''');
      elsif 0 < i_Val and i_Val < 1 then
        return '0' || to_char(i_Val, 'TM9', 'NLS_NUMERIC_CHARACTERS=''. ''');
      else
        return to_char(i_Val, 'TM9', 'NLS_NUMERIC_CHARACTERS=''. ''');
      end if;
    
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Number
  (
    i_Val      varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    if i_Format is not null then
      if i_Nlsparam is not null then
        return to_number(i_Val, i_Format, i_Nlsparam);
      else
        return to_number(i_Val, i_Format);
      end if;
    else
      if i_Nlsparam is not null then
        raise Value_Error;
      else
        return to_number(i_Val, '99999999999999999999D99999999', 'NLS_NUMERIC_CHARACTERS=''. ''');
      end if;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Date
  (
    i_Val      date,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    if i_Format is not null then
      if i_Nlsparam is not null then
        return to_char(i_Val, i_Format, i_Nlsparam);
      else
        return to_char(i_Val, i_Format);
      end if;
    else
      if i_Nlsparam is not null then
        raise Value_Error;
      else
        if Trunc(i_Val) = i_Val then
          return to_char(i_Val, 'dd.mm.yyyy');
        else
          return to_char(i_Val, 'dd.mm.yyyy hh24:mi:ss');
        end if;
      end if;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Date
  (
    i_Val      varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    if i_Format is not null then
      if i_Nlsparam is not null then
        return to_date(i_Val, i_Format, i_Nlsparam);
      else
        return to_date(i_Val, i_Format);
      end if;
    else
      if i_Nlsparam is not null then
        raise Value_Error;
      else
        if Length(i_Val) = 10 then
          return to_date(i_Val, 'dd.mm.yyyy');
        else
          return to_date(i_Val, 'dd.mm.yyyy hh24:mi:ss');
        end if;
      end if;
    end if;
  exception
    when others then
      if sqlcode = -01861 then
        Raise_Application_Error(-20999, 'Invalid date format[' || i_Val || ']');
      else
        raise;
      end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      timestamp,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    if i_Format is not null then
      if i_Nlsparam is not null then
        return to_char(i_Val, i_Format, i_Nlsparam);
      else
        return to_char(i_Val, i_Format);
      end if;
    else
      if i_Nlsparam is not null then
        raise Value_Error;
      else
        return to_char(i_Val, 'dd.mm.yyyy hh24:mi:ss');
      end if;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      timestamp with time zone,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    return Format_Timestamp(i_Val      => cast(i_Val as timestamp),
                            i_Format   => i_Format,
                            i_Nlsparam => i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      timestamp with local time zone,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    return Format_Timestamp(i_Val      => cast(i_Val as timestamp),
                            i_Format   => i_Format,
                            i_Nlsparam => i_Nlsparam);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Format_Timestamp
  (
    i_Val      varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    if i_Format is not null then
      if i_Nlsparam is not null then
        return To_Timestamp(i_Val, i_Format, i_Nlsparam);
      else
        return To_Timestamp(i_Val, i_Format);
      end if;
    else
      if i_Nlsparam is not null then
        raise Value_Error;
      else
        return To_Timestamp(i_Val, 'dd.mm.yyyy hh24:mi:ss');
      end if;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Number(i_Val varchar2) return boolean is
    v_Dummy number;
  begin
    v_Dummy := to_number(i_Val);
    return true or v_Dummy > 0;
  exception
    when others then
      return false;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Varchar2
  (
    i_Val      Array_Number,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Varchar2();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := Format_Number(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Varchar2
  (
    i_Val      Array_Date,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Varchar2();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := Format_Date(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Varchar2
  (
    i_Val      Array_Timestamp,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Varchar2();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := Format_Timestamp(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Number
  (
    i_Val      Array_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Number is
    result Array_Number;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Number();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := Format_Number(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Date
  (
    i_Val      Array_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Date is
    result Array_Date;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Date();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := Format_Date(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Date(i_Val Array_Timestamp) return Array_Date is
    result Array_Date;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Date();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := cast(i_Val(i) as date);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Timestamp
  (
    i_Val      Array_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Timestamp is
    result Array_Timestamp;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Timestamp();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := Format_Timestamp(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array_Timestamp(i_Val Array_Date) return Array_Timestamp is
    result Array_Timestamp;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Timestamp();
    Result.Extend(i_Val.Count);
    for i in 1 .. i_Val.Count
    loop
      result(i) := cast(i_Val(i) as timestamp);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Varchar2
  (
    i_Val      Matrix_Number,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Varchar2 is
    result Matrix_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Varchar2();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Varchar2(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Varchar2
  (
    i_Val      Matrix_Date,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Varchar2 is
    result Matrix_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Varchar2();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Varchar2(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Varchar2
  (
    i_Val      Matrix_Timestamp,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Varchar2 is
    result Matrix_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Varchar2();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Varchar2(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Number
  (
    i_Val      Matrix_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Number is
    result Matrix_Number;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Number();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Number(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Date
  (
    i_Val      Matrix_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Date is
    result Matrix_Date;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Date();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Date(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Date(i_Val Matrix_Timestamp) return Matrix_Date is
    result Matrix_Date;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Date();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Date(i_Val(i));
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Timestamp
  (
    i_Val      Matrix_Varchar2,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Matrix_Timestamp is
    result Matrix_Timestamp;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Timestamp();
    Result.Extend(i_Val.Count);
  
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Timestamp(i_Val(i), i_Format, i_Nlsparam);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Matrix_Timestamp(i_Val Matrix_Date) return Matrix_Timestamp is
    result Matrix_Timestamp;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Matrix_Timestamp();
    Result.Extend(i_Val.Count);
    for i in 1 .. i_Val.Count
    loop
      result(i) := To_Array_Timestamp(i_Val(i));
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column_Varchar2
  (
    i_Array Array_Varchar2,
    i_Index number
  ) return varchar2 is
  begin
    return i_Array(i_Index);
  exception
    when Subscript_Beyond_Count then
      return null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column_Number
  (
    i_Array Array_Number,
    i_Index number
  ) return number is
  begin
    return i_Array(i_Index);
  exception
    when Subscript_Beyond_Count then
      return null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column_Date
  (
    i_Array Array_Date,
    i_Index number
  ) return date is
  begin
    return i_Array(i_Index);
  exception
    when Subscript_Beyond_Count then
      return null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column_Timestamp
  (
    i_Array Array_Timestamp,
    i_Index number
  ) return timestamp is
  begin
    return i_Array(i_Index);
  exception
    when Subscript_Beyond_Count then
      return null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Varchar2,
    i_Col_Index pls_integer
  ) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Varchar2();
    Result.Extend(i_Val.Count);
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count >= i_Col_Index then
        result(i) := i_Val(i) (i_Col_Index);
      end if;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Number,
    i_Col_Index pls_integer
  ) return Array_Number is
    result Array_Number;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Number();
    Result.Extend(i_Val.Count);
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count >= i_Col_Index then
        result(i) := i_Val(i) (i_Col_Index);
      end if;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Date,
    i_Col_Index pls_integer
  ) return Array_Date is
    result Array_Date;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Date();
    Result.Extend(i_Val.Count);
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count >= i_Col_Index then
        result(i) := i_Val(i) (i_Col_Index);
      end if;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Column
  (
    i_Val       Matrix_Timestamp,
    i_Col_Index pls_integer
  ) return Array_Timestamp is
    result Array_Timestamp;
  begin
    if i_Val is null then
      return result;
    end if;
  
    result := Array_Timestamp();
    Result.Extend(i_Val.Count);
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count >= i_Col_Index then
        result(i) := i_Val(i) (i_Col_Index);
      end if;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Varchar2) return Matrix_Varchar2 is
    v_Max_Col pls_integer := 0;
    result    Matrix_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count > v_Max_Col then
        v_Max_Col := i_Val(i).Count;
      end if;
    end loop;
    if v_Max_Col = 0 then
      return Matrix_Varchar2();
    end if;
  
    result := Matrix_Varchar2();
    Result.Extend(v_Max_Col);
    for i in 1 .. v_Max_Col
    loop
      result(i) := Column(i_Val, i);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Number) return Matrix_Number is
    v_Max_Col pls_integer := 0;
    result    Matrix_Number;
  begin
    if i_Val is null then
      return result;
    end if;
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count > v_Max_Col then
        v_Max_Col := i_Val(i).Count;
      end if;
    end loop;
    if v_Max_Col = 0 then
      return Matrix_Number();
    end if;
  
    result := Matrix_Number();
    Result.Extend(v_Max_Col);
    for i in 1 .. v_Max_Col
    loop
      result(i) := Column(i_Val, i);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Date) return Matrix_Date is
    v_Max_Col pls_integer := 0;
    result    Matrix_Date;
  begin
    if i_Val is null then
      return result;
    end if;
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count > v_Max_Col then
        v_Max_Col := i_Val(i).Count;
      end if;
    end loop;
    if v_Max_Col = 0 then
      return Matrix_Date();
    end if;
  
    result := Matrix_Date();
    Result.Extend(v_Max_Col);
    for i in 1 .. v_Max_Col
    loop
      result(i) := Column(i_Val, i);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Transpose(i_Val Matrix_Timestamp) return Matrix_Timestamp is
    v_Max_Col pls_integer := 0;
    result    Matrix_Timestamp;
  begin
    if i_Val is null then
      return result;
    end if;
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i).Count > v_Max_Col then
        v_Max_Col := i_Val(i).Count;
      end if;
    end loop;
    if v_Max_Col = 0 then
      return Matrix_Timestamp();
    end if;
  
    result := Matrix_Timestamp();
    Result.Extend(v_Max_Col);
    for i in 1 .. v_Max_Col
    loop
      result(i) := Column(i_Val, i);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Varchar2) return boolean is
  begin
    return i_Val is null or i_Val.Count = 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Number) return boolean is
  begin
    return i_Val is null or i_Val.Count = 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Date) return boolean is
  begin
    return i_Val is null or i_Val.Count = 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Empty(i_Val Array_Timestamp) return boolean is
  begin
    return i_Val is null or i_Val.Count = 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Varchar2) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Varchar2) is
  begin
    p_Val := Sort(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Varchar2) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value desc;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Varchar2) is
  begin
    p_Val := Sort_Desc(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Number) return Array_Number is
    result Array_Number;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Number) is
  begin
    p_Val := Sort(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Number) return Array_Number is
    result Array_Number;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value desc;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Number) is
  begin
    p_Val := Sort_Desc(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Date) return Array_Date is
    result Array_Date;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Date) is
  begin
    p_Val := Sort(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Date) return Array_Date is
    result Array_Date;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value desc;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Date) is
  begin
    p_Val := Sort_Desc(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort(i_Val Array_Timestamp) return Array_Timestamp is
    result Array_Timestamp;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort(p_Val in out nocopy Array_Timestamp) is
  begin
    p_Val := Sort(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sort_Desc(i_Val Array_Timestamp) return Array_Timestamp is
    result Array_Timestamp;
  begin
    if i_Val is null then
      return i_Val;
    end if;
  
    select Column_Value
      bulk collect
      into result
      from table(i_Val)
     order by Column_Value desc;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sort_Desc(p_Val in out nocopy Array_Timestamp) is
  begin
    p_Val := Sort_Desc(p_Val);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Zip_Map
  (
    i_Name1 varchar2,
    i_Val1  varchar2,
    i_Name2 varchar2 := null,
    i_Val2  varchar2 := null,
    i_Name3 varchar2 := null,
    i_Val3  varchar2 := null,
    i_Name4 varchar2 := null,
    i_Val4  varchar2 := null,
    i_Name5 varchar2 := null,
    i_Val5  varchar2 := null,
    i_Name6 varchar2 := null,
    i_Val6  varchar2 := null
  ) return Hashmap is
    result Hashmap := Hashmap();
  begin
    if i_Name1 is not null then
      Result.Put(i_Name1, i_Val1);
    end if;
  
    if i_Name2 is not null then
      Result.Put(i_Name2, i_Val2);
    end if;
  
    if i_Name3 is not null then
      Result.Put(i_Name3, i_Val3);
    end if;
  
    if i_Name4 is not null then
      Result.Put(i_Name4, i_Val4);
    end if;
  
    if i_Name5 is not null then
      Result.Put(i_Name5, i_Val5);
    end if;
  
    if i_Name6 is not null then
      Result.Put(i_Name6, i_Val6);
    end if;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Zip_Array_Map
  (
    i_Name1 varchar2,
    i_Val1  Array_Varchar2,
    i_Name2 varchar2 := null,
    i_Val2  Array_Varchar2 := null,
    i_Name3 varchar2 := null,
    i_Val3  Array_Varchar2 := null,
    i_Name4 varchar2 := null,
    i_Val4  Array_Varchar2 := null,
    i_Name5 varchar2 := null,
    i_Val5  Array_Varchar2 := null,
    i_Name6 varchar2 := null,
    i_Val6  Array_Varchar2 := null
  ) return Arraylist is
    result Arraylist := Arraylist();
  
    Function Get
    (
      v Array_Varchar2,
      i pls_integer
    ) return varchar2 is
    begin
      if v is not null then
        return v(i);
      end if;
      return null;
    end;
  
  begin
    if i_Name1 is not null and i_Val1 is not null then
      for i in 1 .. i_Val1.Count
      loop
        Result.Push(Zip_Map(i_Name1,
                            Get(i_Val1, i),
                            i_Name2,
                            Get(i_Val2, i),
                            i_Name3,
                            Get(i_Val3, i),
                            i_Name4,
                            Get(i_Val4, i),
                            i_Name5,
                            Get(i_Val5, i),
                            i_Name6,
                            Get(i_Val6, i)));
      end loop;
    end if;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Zip_Matrix(i_Val Matrix_Varchar2) return Arraylist is
    result Arraylist := Arraylist();
  begin
    if i_Val is null then
      return null;
    end if;
    for i in 1 .. i_Val.Count
    loop
      Result.Push(i_Val(i));
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Zip_Matrix
  (
    i_Val1 Array_Varchar2,
    i_Val2 Array_Varchar2 := null,
    i_Val3 Array_Varchar2 := null,
    i_Val4 Array_Varchar2 := null
  ) return Arraylist is
  begin
    if i_Val4 is not null then
      return Zip_Matrix(Matrix_Varchar2(i_Val1, i_Val2, i_Val3, i_Val4));
    elsif i_Val3 is not null then
      return Zip_Matrix(Matrix_Varchar2(i_Val1, i_Val2, i_Val3));
    elsif i_Val2 is not null then
      return Zip_Matrix(Matrix_Varchar2(i_Val1, i_Val2));
    else
      return Zip_Matrix(Matrix_Varchar2(i_Val1));
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Zip_Matrix_Transposed(i_Val Matrix_Varchar2) return Arraylist is
  begin
    return Zip_Matrix(Transpose(i_Val));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Varchar2,
    i_Val   varchar2
  ) return pls_integer is
  begin
    for i in 1 .. i_Array.Count
    loop
      if i_Array(i) = i_Val then
        return i;
      end if;
    end loop;
    return 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Number,
    i_Val   number
  ) return pls_integer is
  begin
    for i in 1 .. i_Array.Count
    loop
      if i_Array(i) = i_Val then
        return i;
      end if;
    end loop;
    return 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Date,
    i_Val   date
  ) return pls_integer is
  begin
    for i in 1 .. i_Array.Count
    loop
      if i_Array(i) = i_Val then
        return i;
      end if;
    end loop;
    return 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Index_Of
  (
    i_Array Array_Timestamp,
    i_Val   timestamp
  ) return pls_integer is
  begin
    for i in 1 .. i_Array.Count
    loop
      if i_Array(i) = i_Val then
        return i;
      end if;
    end loop;
    return 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Varchar2,
    i_Val   varchar2
  ) return boolean is
  begin
    return Index_Of(i_Array, i_Val) > 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Number,
    i_Val   number
  ) return boolean is
  begin
    return Index_Of(i_Array, i_Val) > 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Date,
    i_Val   date
  ) return boolean is
  begin
    return Index_Of(i_Array, i_Val) > 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Contains
  (
    i_Array Array_Timestamp,
    i_Val   timestamp
  ) return boolean is
  begin
    return Index_Of(i_Array, i_Val) > 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Varchar2,
    i_Val   varchar2
  ) is
  begin
    p_Array.Extend;
    p_Array(p_Array.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Number,
    i_Val   number
  ) is
  begin
    p_Array.Extend;
    p_Array(p_Array.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Date,
    i_Val   date
  ) is
  begin
    p_Array.Extend;
    p_Array(p_Array.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Array in out nocopy Array_Timestamp,
    i_Val   timestamp
  ) is
  begin
    p_Array.Extend;
    p_Array(p_Array.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Varchar2,
    i_Val    Array_Varchar2
  ) is
  begin
    p_Matrix.Extend;
    p_Matrix(p_Matrix.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Number,
    i_Val    Array_Number
  ) is
  begin
    p_Matrix.Extend;
    p_Matrix(p_Matrix.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Date,
    i_Val    Array_Date
  ) is
  begin
    p_Matrix.Extend;
    p_Matrix(p_Matrix.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Timestamp,
    i_Val    Array_Timestamp
  ) is
  begin
    p_Matrix.Extend;
    p_Matrix(p_Matrix.Count) := i_Val;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Varchar2,
    i_Val1   varchar2,
    i_Val2   varchar2 := null,
    i_Val3   varchar2 := null,
    i_Val4   varchar2 := null,
    i_Val5   varchar2 := null
  ) is
  begin
    if i_Val5 is not null then
      Push(p_Matrix, Array_Varchar2(i_Val1, i_Val2, i_Val3, i_Val4, i_Val5));
    elsif i_Val4 is not null then
      Push(p_Matrix, Array_Varchar2(i_Val1, i_Val2, i_Val3, i_Val4));
    elsif i_Val3 is not null then
      Push(p_Matrix, Array_Varchar2(i_Val1, i_Val2, i_Val3));
    elsif i_Val2 is not null then
      Push(p_Matrix, Array_Varchar2(i_Val1, i_Val2));
    else
      Push(p_Matrix, Array_Varchar2(i_Val1));
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Number,
    i_Val1   number,
    i_Val2   number := null,
    i_Val3   number := null,
    i_Val4   number := null,
    i_Val5   number := null
  ) is
  begin
    if i_Val5 is not null then
      Push(p_Matrix, Array_Number(i_Val1, i_Val2, i_Val3, i_Val4, i_Val5));
    elsif i_Val4 is not null then
      Push(p_Matrix, Array_Number(i_Val1, i_Val2, i_Val3, i_Val4));
    elsif i_Val3 is not null then
      Push(p_Matrix, Array_Number(i_Val1, i_Val2, i_Val3));
    elsif i_Val2 is not null then
      Push(p_Matrix, Array_Number(i_Val1, i_Val2));
    else
      Push(p_Matrix, Array_Number(i_Val1));
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Date,
    i_Val1   date,
    i_Val2   date := null,
    i_Val3   date := null,
    i_Val4   date := null,
    i_Val5   date := null
  ) is
  begin
    if i_Val5 is not null then
      Push(p_Matrix, Array_Date(i_Val1, i_Val2, i_Val3, i_Val4, i_Val5));
    elsif i_Val4 is not null then
      Push(p_Matrix, Array_Date(i_Val1, i_Val2, i_Val3, i_Val4));
    elsif i_Val3 is not null then
      Push(p_Matrix, Array_Date(i_Val1, i_Val2, i_Val3));
    elsif i_Val2 is not null then
      Push(p_Matrix, Array_Date(i_Val1, i_Val2));
    else
      Push(p_Matrix, Array_Date(i_Val1));
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Push
  (
    p_Matrix in out nocopy Matrix_Timestamp,
    i_Val1   timestamp,
    i_Val2   timestamp := null,
    i_Val3   timestamp := null,
    i_Val4   timestamp := null,
    i_Val5   timestamp := null
  ) is
  begin
    if i_Val5 is not null then
      Push(p_Matrix, Array_Timestamp(i_Val1, i_Val2, i_Val3, i_Val4, i_Val5));
    elsif i_Val4 is not null then
      Push(p_Matrix, Array_Timestamp(i_Val1, i_Val2, i_Val3, i_Val4));
    elsif i_Val3 is not null then
      Push(p_Matrix, Array_Timestamp(i_Val1, i_Val2, i_Val3));
    elsif i_Val2 is not null then
      Push(p_Matrix, Array_Timestamp(i_Val1, i_Val2));
    else
      Push(p_Matrix, Array_Timestamp(i_Val1));
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Json(i_Src Array_Varchar2) return w_Wrapper is
    Src_Index  binary_integer := 1;
    Cur        varchar2(32767);
    Len        binary_integer;
    Pos        binary_integer := 0;
    Token_Type varchar2(1);
    Token      varchar2(32767);
    e_Json exception;
  
    --------------------------------------------------
    Function Peek_Char return varchar2 is
      Ln binary_integer := Len;
      p  binary_integer := Pos;
      Cc varchar2(32767) := Cur;
    begin
      p := p + 1;
      if p > Ln then
        Cc := null;
        p  := 1;
        for i in Src_Index + 1 .. i_Src.Count
        loop
          Cc := i_Src(i);
          if Cc is not null then
            exit;
          end if;
        end loop;
      end if;
    
      return Substr(Cc, p, 1);
    end;
  
    --------------------------------------------------
    Function Next_Char return varchar2 is
    begin
      Pos := Pos + 1;
    
      if Pos > Len then
        Cur := null;
        Len := 0;
        Pos := 1;
        for i in Src_Index + 1 .. i_Src.Count
        loop
          Src_Index := i;
          Cur       := i_Src(Src_Index);
          Len       := Nvl(Length(Cur), 0);
          if Cur is not null then
            exit;
          end if;
        end loop;
      end if;
    
      return Substr(Cur, Pos, 1);
    end Next_Char;
  
    --------------------------------------------------
    Procedure Read_String is
      c varchar2(3);
    begin
      Token_Type := '"';
      Token      := null;
    
      loop
        c := Next_Char;
        if c = '"' then
          exit;
        
        elsif c = '\' then
          c := Next_Char;
          case c
            when '"' then
              Token := Token || c;
            when '''' then
              -- not in specs
              Token := Token || c;
            when '\' then
              Token := Token || c;
            when '/' then
              Token := Token || c;
            when 'b' then
              Token := Token || Chr(8);
            when 't' then
              Token := Token || Chr(9);
            when 'r' then
              Token := Token || Chr(10);
            when 'f' then
              Token := Token || Chr(12);
            when 'n' then
              Token := Token || Chr(13);
            when 'u' then
              Token := Token ||
                       Nchr(to_number(Next_Char || Next_Char || Next_Char || Next_Char, 'XXXX'));
          end case;
        
        else
          Token := Token || c;
        
        end if;
      end loop;
    end;
  
    --------------------------------------------------
    Procedure Read_Literal(c varchar2) is
    begin
      case c
        when 't' then
          Token_Type := '"';
          Token      := c || Next_Char || Next_Char || Next_Char;
          if Token = 'true' then
            null;
          else
            raise e_Json;
          end if;
        
        when 'f' then
          Token_Type := '"';
          Token      := c || Next_Char || Next_Char || Next_Char || Next_Char;
          if Token = 'false' then
            null;
          else
            raise e_Json;
          end if;
        
        when 'n' then
          Token_Type := '"';
          Token      := c || Next_Char || Next_Char || Next_Char;
          if Token = 'null' then
            Token := '';
          else
            raise e_Json;
          end if;
        
      end case;
    end;
  
    --------------------------------------------------
    Procedure Read_Number(c varchar2) is
    begin
      Token_Type := '"';
      Token      := c;
      loop
        if Peek_Char in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', 'e', 'E', '+', '-') then
          Token := Token || Next_Char;
        else
          exit;
        end if;
      end loop;
    end;
  
    --------------------------------------------------
    Procedure Next_Token is
      c varchar2(3); -- unicode fix
    begin
    
      loop
        c := Next_Char;
        if c is null then
          raise e_Json;
        end if;
        exit when c not in(' ', Chr(9), Chr(10), Chr(13));
      end loop;
    
      if c = '"' then
        Read_String;
      
      elsif c in ('t', 'f', 'n') then
        Read_Literal(c);
      
      elsif c in ('-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9') then
        Read_Number(c);
      
      else
        Token_Type := c;
        Token      := null;
      end if;
    
    end;
  
    --------------------------------------------------
    Function Parse_Token return w_Wrapper;
  
    --------------------------------------------------
    Function Parse_Array return Arraylist is
      w               Arraylist := Arraylist();
      v_Required_Next boolean := false;
    begin
      loop
      
        Next_Token;
      
        case Token_Type
          when ']' then
            if v_Required_Next then
              raise e_Json;
            end if;
            return w;
          else
            w.Push(Parse_Token);
        end case;
      
        Next_Token;
        case Token_Type
          when ']' then
            return w;
          when ',' then
            v_Required_Next := true;
        end case;
      
      end loop;
    end;
  
    --------------------------------------------------
    Function Parse_Map return Hashmap is
      v_Required_Next boolean := false;
      Key             varchar2(100);
      w               Hashmap := Hashmap();
    begin
      loop
      
        Next_Token;
        case Token_Type
          when '}' then
            if v_Required_Next then
              raise e_Json;
            end if;
            return w;
          when '"' then
            Key := Token;
        end case;
      
        Next_Token;
        if Token_Type = ':' then
          null;
        else
          raise e_Json;
        end if;
      
        Next_Token;
        w.Put(Key, Parse_Token);
      
        Next_Token;
        case Token_Type
          when '}' then
            return w;
          when ',' then
            v_Required_Next := true;
        end case;
      
      end loop;
    end;
  
    --------------------------------------------------
    Function Parse_Token return w_Wrapper is
    begin
      case Token_Type
        when '"' then
          return Fazo_Schema.Option_Varchar2(Token);
        when '[' then
          return Parse_Array;
        when '{' then
          return Parse_Map;
      end case;
    end;
  
  begin
    if Empty_Text(i_Src) then
      return null;
    end if;
  
    Cur := i_Src(Src_Index);
    Len := Nvl(Length(Cur), 0);
  
    Next_Token;
    return Parse_Token;
  exception
    when e_Json then
      Raise_Application_Error(-20384,
                              'json error at pos=' || Pos || Chr(10) ||
                              Dbms_Utility.Format_Error_Backtrace);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Json(i_Src varchar2) return w_Wrapper is
  begin
    return Parse_Json(Array_Varchar2(i_Src));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Json(i_Src clob) return w_Wrapper is
  begin
    return Parse_Json(Read_Clob(i_Src));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Array(i_Src varchar2) return Arraylist is
  begin
    return Treat(Parse_Json(i_Src) as Arraylist);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Array(i_Src Array_Varchar2) return Arraylist is
  begin
    return Treat(Parse_Json(i_Src) as Arraylist);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Array(i_Src clob) return Arraylist is
  begin
    return Treat(Parse_Json(Read_Clob(i_Src)) as Arraylist);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Map(i_Src varchar2) return Fazo_Schema.Hashmap is
  begin
    return Treat(Parse_Json(i_Src) as Fazo_Schema.Hashmap);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Map(i_Src Array_Varchar2) return Fazo_Schema.Hashmap is
  begin
    return Treat(Parse_Json(i_Src) as Fazo_Schema.Hashmap);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Parse_Map(i_Src clob) return Fazo_Schema.Hashmap is
  begin
    return Treat(Parse_Json(Read_Clob(i_Src)) as Fazo_Schema.Hashmap);
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.w_Wrapper) return Stream is
    result Stream := Stream();
  begin
    i_Value.Print_Json(result);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Varchar2) return Stream is
    result Stream := Stream();
  begin
    Fazo_Schema.w_Array_Varchar2(i_Value).Print_Json(result);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Number) return Stream is
    result Stream := Stream();
  begin
    Fazo_Schema.w_Array_Number(i_Value).Print_Json(result);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Date) return Stream is
    result Stream := Stream();
  begin
    Fazo_Schema.w_Array_Date(i_Value).Print_Json(result);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Json(i_Value Fazo_Schema.Array_Timestamp) return Stream is
    result Stream := Stream();
  begin
    Fazo_Schema.w_Array_Timestamp(i_Value).Print_Json(result);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Split
  (
    i_Val       varchar2,
    i_Delimiter varchar2
  ) return Array_Varchar2 is
    v_Pos      pls_integer := 1;
    v_Last_Pos pls_integer := 1;
    result     Array_Varchar2;
  begin
    if i_Val is null then
      return Array_Varchar2('');
    end if;
  
    result := Array_Varchar2();
    loop
      v_Pos := Instr(i_Val, i_Delimiter, v_Last_Pos);
    
      Result.Extend;
    
      if v_Pos > 0 then
        result(Result.Count) := Substr(i_Val, v_Last_Pos, v_Pos - v_Last_Pos);
      else
        result(Result.Count) := Substr(i_Val, v_Last_Pos);
        exit;
      end if;
    
      v_Last_Pos := v_Pos + Length(i_Delimiter);
    
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Split
  (
    i_Val       Array_Varchar2,
    i_Delimiter varchar2
  ) return Matrix_Varchar2 is
    v_Dlen pls_integer := Length(i_Delimiter);
    v_Size pls_integer;
    v      Array_Varchar2;
    result Matrix_Varchar2;
  begin
    if i_Val is null then
      return result;
    end if;
  
    if i_Delimiter is null then
      return Matrix_Varchar2(i_Val);
    end if;
  
    if v_Dlen > 1 then
      Raise_Application_Error(-20990, 'Length of delimiter must be 1');
    end if;
  
    for i in 1 .. i_Val.Count
    loop
      v := Split(i_Val(i), i_Delimiter);
      if result is null then
        result := Matrix_Varchar2(Array_Varchar2(v(1)));
      elsif v(1) is not null then
        v_Size := result(Result.Count).Count;
        if result(Result.Count) (v_Size) is not null then
          result(Result.Count).Extend;
        end if;
        v_Size := result(Result.Count).Count;
        result(Result.Count)(v_Size) := v(1);
      end if;
    
      for k in 2 .. v.Count
      loop
        Result.Extend;
        result(Result.Count) := Array_Varchar2(v(k));
      end loop;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Varchar2,
    i_Delimiter varchar2
  ) return varchar2 is
    result varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count
    loop
      result := result || i_Val(i);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Number,
    i_Delimiter varchar2,
    i_Format    varchar2 := null
  ) return varchar2 is
    v_Format varchar2(50) := Nvl(i_Format, 'TM9');
    result   varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count
    loop
      result := result || to_char(i_Val(i), v_Format);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Date,
    i_Delimiter varchar2,
    i_Format    varchar2 := null
  ) return varchar2 is
    v_Format varchar2(50) := Nvl(i_Format, 'dd.mm.yyyy');
    result   varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count
    loop
      result := result || to_char(i_Val(i), v_Format);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gather
  (
    i_Val       Array_Timestamp,
    i_Delimiter varchar2,
    i_Format    varchar2 := null
  ) return varchar2 is
    v_Format varchar2(50) := Nvl(i_Format, 'dd.mm.yyyy hh24:mi:ss.ff');
    result   varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count
    loop
      result := result || to_char(i_Val(i), v_Format);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 varchar2,
    i_Val2 varchar2
  ) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 number,
    i_Val2 number
  ) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 date,
    i_Val2 date
  ) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Equal
  (
    i_Val1 timestamp,
    i_Val2 timestamp
  ) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Week_Day(i_Date date) return pls_integer is
  begin
    return Trunc(i_Date) - Trunc(i_Date, 'IW');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha1(i_Value varchar2) return varchar2 is
  begin
    return Sys.Dbms_Crypto.Hash(Utl_I18n.String_To_Raw(i_Value, 'AL32UTF8'),
                                Sys.Dbms_Crypto.Hash_Sh1);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha1(i_Value Array_Varchar2) return varchar2 is
  begin
    return Hash_Sha1(Make_Clob(i_Value));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha1(i_Value clob) return varchar2 is
  begin
    return Sys.Dbms_Crypto.Hash(i_Value, Sys.Dbms_Crypto.Hash_Sh1);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Read_Clob(i_Clob clob) return Array_Varchar2 is
    c_Block_Size constant number := 16000;
    v_Len  number;
    v_Iter number;
    result Array_Varchar2;
  begin
    if i_Clob is null then
      return result;
    end if;
  
    v_Len  := Dbms_Lob.Getlength(i_Clob);
    v_Iter := Ceil(v_Len / c_Block_Size);
  
    result := Array_Varchar2();
    Result.Extend(v_Iter);
    for i in 1 .. v_Iter
    loop
      result(i) := Dbms_Lob.Substr(i_Clob, c_Block_Size, (i - 1) * c_Block_Size + 1);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Make_Clob(i_Val Array_Varchar2) return clob is
    result clob;
  begin
    if i_Val is not null then
      Dbms_Lob.Createtemporary(result, false);
      Dbms_Lob.Open(result, Dbms_Lob.Lob_Readwrite);
      for i in 1 .. i_Val.Count
      loop
        if i_Val(i) is not null then
          Dbms_Lob.Writeappend(result, Length(i_Val(i)), i_Val(i));
        end if;
      end loop;
      Dbms_Lob.Close(result);
    end if;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Length_Text(i_Val Array_Varchar2) return number is
    result number := 0;
  begin
    if i_Val is not null then
      for i in 1 .. i_Val.Count
      loop
        result := result + Nvl(Length(i_Val(i)), 0);
      end loop;
    end if;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Lengthb_Text(i_Val Array_Varchar2) return number is
    result number := 0;
  begin
    if i_Val is not null then
      for i in 1 .. i_Val.Count
      loop
        result := result + Nvl(Lengthb(i_Val(i)), 0);
      end loop;
    end if;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Empty_Text(i_Val Array_Varchar2) return boolean is
  begin
    if i_Val is null then
      return true;
    end if;
    for i in 1 .. i_Val.Count
    loop
      if i_Val(i) is not null then
        return false;
      end if;
    end loop;
    return true;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Dump(i_Val varchar2) return varchar2 is
    result varchar2(32767);
  begin
    select Dump(i_Val)
      into result
      from Dual;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Message
  (
    i_Template varchar2,
    i_Params   Fazo_Schema.Array_Varchar2 := null
  ) return varchar2 is
    r varchar2(32767) := i_Template;
  begin
    if i_Params is not null then
      for i in 1 .. i_Params.Count
      loop
        r := replace(r, '$' || i, i_Params(i));
      end loop;
    end if;
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Trim_Ora_Error(i_Error varchar2) return varchar2 is
  begin
    return Regexp_Replace(i_Error, 'ORA-[0-9]+: ', '');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Trimmed_Sqlerrm return varchar2 is
  begin
    return Trim_Ora_Error(sqlerrm);
  end;

end Fazo;
/
