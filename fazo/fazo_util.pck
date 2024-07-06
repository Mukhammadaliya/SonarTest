create or replace package Fazo_Schema.Fazo_Util authid current_user is

  ----------------------------------------------------------------------------------------------------
  c_f_Varchar2 constant varchar2(1) := 'V';
  c_f_Number   constant varchar2(1) := 'N';
  c_f_Date     constant varchar2(1) := 'D';
  c_f_Option   constant varchar2(1) := 'O';
  c_f_Refer    constant varchar2(1) := 'R';
  c_f_Map      constant varchar2(1) := 'M';
  c_f_Multi    constant varchar2(1) := 'K';
  ----------------------------------------------------------------------------------------------------
  c_Ct_Forward_File constant varchar2(1) := 'F';
  c_Ct_Forward_Size constant varchar2(1) := 'S';
  ----------------------------------------------------------------------------------------------------
  Procedure Prepare_Cursor
  (
    i_Query     varchar2,
    i_Params    Fazo_Schema.Hashmap,
    o_Cursor    out pls_integer,
    o_Count     out pls_integer,
    o_Col_Types out Fazo_Schema.Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Execute_Count
  (
    i_Query  varchar,
    i_Params Fazo_Schema.Hashmap
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Function Execute_Count
  (
    i_Query         varchar2,
    i_Filter_Clause varchar2,
    i_Params        Hashmap
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Query
  (
    i_Query  varchar2,
    i_Params Fazo_Schema.Hashmap,
    Writer   in out nocopy Fazo_Schema.Stream
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Build_Query
  (
    i_Query                varchar2,
    i_Params               Fazo_Schema.Hashmap,
    i_Fields               Fazo_Schema.Hashmap,
    i_Columns_After_Filter Fazo_Schema.Array_Varchar2 := null,
    i_Column               Fazo_Schema.Array_Varchar2,
    i_Filter               Fazo_Schema.Arraylist,
    i_Sort                 Fazo_Schema.Array_Varchar2,
    i_Namespace            varchar2,
    o_Query                out varchar2,
    o_Params               out Fazo_Schema.Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Function Serial_Query
  (
    i_Query  varchar2,
    i_Params Hashmap
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Build_Query_Page
  (
    i_Query                varchar2,
    i_Params               Fazo_Schema.Hashmap,
    i_Fields               Fazo_Schema.Hashmap,
    i_Columns_After_Filter Fazo_Schema.Array_Varchar2 := null,
    i_Column               Fazo_Schema.Array_Varchar2,
    i_Filter               Fazo_Schema.Arraylist,
    i_Sort                 Fazo_Schema.Array_Varchar2,
    i_Rownum_Start         number,
    i_Rownum_End           number,
    i_Namespace            varchar2,
    o_Query                out varchar2,
    o_Params               out Fazo_Schema.Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Query_Page
  (
    i_Query                varchar2,
    i_Params               Fazo_Schema.Hashmap,
    i_Fields               Fazo_Schema.Hashmap,
    i_Columns_After_Filter Fazo_Schema.Array_Varchar2 := null,
    i_Column               Fazo_Schema.Array_Varchar2,
    i_Filter               Fazo_Schema.Arraylist,
    i_Sort                 Fazo_Schema.Array_Varchar2,
    i_Rownum_Start         number,
    i_Rownum_End           number,
    i_Namespace            varchar2,
    Writer                 in out nocopy Stream,
    i_Metadata             Arraylist := null
  );
  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Info_Refer
  (
    Writer   in out nocopy Stream,
    i_Search varchar2,
    i_Field  Fazo_Schema.Arraylist
  );
  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Info
  (
    Writer   in out nocopy Stream,
    i_Fields Fazo_Schema.Hashmap,
    i_Names  Fazo_Schema.Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Data
  (
    i_Fields Fazo_Schema.Hashmap,
    i_Names  Array_Varchar2,
    Writer   in out nocopy Stream
  );
  ----------------------------------------------------------------------------------------------------
  Function Check_Version_Compatibility(i_Version varchar2) return boolean;
end Fazo_Util;
/
create or replace package body Fazo_Schema.Fazo_Util is

  ----------------------------------------------------------------------------------------------------
  Function Escape_Sql_Value(i_Value varchar2) return varchar2 is
  begin
    return replace(i_Value, '''', '''''');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Prepare_Cursor
  (
    i_Query     varchar2,
    i_Params    Fazo_Schema.Hashmap,
    o_Cursor    out pls_integer,
    o_Count     out pls_integer,
    o_Col_Types out Fazo_Schema.Array_Varchar2
  ) is
    v_Col           Dbms_Sql.Desc_Rec2;
    v_Cols          Dbms_Sql.Desc_Tab2;
    v_Param         Fazo_Schema.Hash_Entry;
    v_p_Varchar2    varchar2(4000);
    v_p_Number      number;
    v_p_Date        date;
    v_p_Tltz        timestamp with local time zone;
    v_p_Array       Array_Varchar2;
    v_Row_Processed number;
  begin
    o_Cursor := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(o_Cursor, '/*' || user || '*/' || i_Query, Dbms_Sql.Native);
  
    if i_Params is not null then
      for i in 1 .. i_Params.Buckets.Count
      loop
        v_Param := i_Params.Buckets(i);
      
        continue when not Regexp_Like(i_Query, ':' || v_Param.Key || '(\W|$)', 'i');
      
        case
          when v_Param.Val.Is_Varchar2 then
            Dbms_Sql.Bind_Variable(o_Cursor, v_Param.Key, v_Param.Val.As_Varchar2);
          
          when v_Param.Val.Is_Array_Varchar2 then
            Dbms_Sql.Bind_Variable(o_Cursor, v_Param.Key, v_Param.Val.As_Array_Varchar2);
          
          when v_Param.Val.Is_Number then
            Dbms_Sql.Bind_Variable(o_Cursor, v_Param.Key, v_Param.Val.As_Number);
          
          when v_Param.Val.Is_Array_Number then
            Dbms_Sql.Bind_Variable(o_Cursor, v_Param.Key, v_Param.Val.As_Array_Number);
          
          when v_Param.Val.Is_Date then
            Dbms_Sql.Bind_Variable(o_Cursor, v_Param.Key, v_Param.Val.As_Date);
          
          when v_Param.Val.Is_Array_Date then
            Dbms_Sql.Bind_Variable(o_Cursor, v_Param.Key, v_Param.Val.As_Array_Date);
          
          else
            Raise_Application_Error(-20999,
                                    'Fazo query params value`s type must be in (varchar2, number, date, or these arrays key=' ||
                                    v_Param.Key);
        end case;
      end loop;
    end if;
  
    Dbms_Sql.Describe_Columns2(o_Cursor, o_Count, v_Cols);
  
    o_Col_Types := Array_Varchar2();
    o_Col_Types.Extend(o_Count);
  
    for i in 1 .. o_Count
    loop
      v_Col := v_Cols(i);
    
      case v_Col.Col_Type
        when Dbms_Sql.Varchar2_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Varchar2, v_Col.Col_Max_Len);
          o_Col_Types(i) := 'V';
        when Dbms_Sql.Number_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Number);
          o_Col_Types(i) := 'N';
        when Dbms_Sql.Date_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Date);
          o_Col_Types(i) := 'D';
        when Dbms_Sql.Timestamp_With_Local_Tz_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Tltz);
          o_Col_Types(i) := 'TLTZ';
        when Dbms_Sql.Char_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Varchar2, v_Col.Col_Max_Len);
          o_Col_Types(i) := 'V';
        when Dbms_Sql.User_Defined_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Array);
          o_Col_Types(i) := 'A';
        else
          Raise_Application_Error(-20999, 'Prepare cursor: Invalid col type ' || v_Col.Col_Type);
      end case;
    
    end loop;
  
    v_Row_Processed := Dbms_Sql.Execute(o_Cursor);
    if false then
      o_Cursor := v_Row_Processed;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Execute_Count
  (
    i_Query  varchar,
    i_Params Fazo_Schema.Hashmap
  ) return number is
    v_Cursor pls_integer;
    v_Count  pls_integer;
    v_Cts    Fazo_Schema.Array_Varchar2;
    result   number;
  begin
  
    Fazo_Schema.Fazo_Util.Prepare_Cursor(i_Query     => i_Query,
                                         i_Params    => i_Params,
                                         o_Cursor    => v_Cursor,
                                         o_Count     => v_Count,
                                         o_Col_Types => v_Cts);
  
    if Dbms_Sql.Fetch_Rows(v_Cursor) <> 0 and v_Cts.Count = 1 and v_Cts(1) = 'N' then
      Dbms_Sql.Column_Value(v_Cursor, 1, result);
    end if;
  
    if Dbms_Sql.Fetch_Rows(v_Cursor) <> 0 then
      result := null;
    end if;
  
    Dbms_Sql.Close_Cursor(v_Cursor);
  
    if result is null then
      Raise_Application_Error(-20999, 'Query: not count clause');
    end if;
  
    return result;
  exception
    when others then
      if Dbms_Sql.Is_Open(v_Cursor) then
        Dbms_Sql.Close_Cursor(v_Cursor);
      end if;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Execute_Count
  (
    i_Query         varchar2,
    i_Filter_Clause varchar2,
    i_Params        Hashmap
  ) return number is
  begin
    return Execute_Count('SELECT count(1) cnt$ FROM (' || i_Query || ') t ' || i_Filter_Clause,
                         i_Params);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Query
  (
    i_Query  varchar2,
    i_Params Fazo_Schema.Hashmap,
    Writer   in out nocopy Fazo_Schema.Stream
  ) is
    v_Cursor      pls_integer;
    v_Count       pls_integer;
    v_Col_Types   Fazo_Schema.Array_Varchar2;
    v_p_Varchar2  varchar2(4000);
    v_p_Number    number;
    v_p_Date      date;
    v_p_Tltz      timestamp with local time zone;
    v_p_Array     Array_Varchar2;
    v_First_Enter boolean := true;
  begin
  
    Prepare_Cursor(i_Query     => i_Query,
                   i_Params    => i_Params,
                   o_Cursor    => v_Cursor,
                   o_Count     => v_Count,
                   o_Col_Types => v_Col_Types);
  
    Writer.Print('[');
  
    loop
    
      if Dbms_Sql.Fetch_Rows(v_Cursor) = 0 then
        exit;
      end if;
    
      if v_First_Enter then
        v_First_Enter := false;
      else
        Writer.Print(',');
      end if;
    
      Writer.Print('[');
      for i in 1 .. v_Count
      loop
        case v_Col_Types(i)
        
          when 'V' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Varchar2);
            Writer.Print('"' || Fazo.Json_Escape(v_p_Varchar2) || '"');
          
          when 'N' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Number);
            Writer.Print('"' || v_p_Number || '"');
          
          when 'D' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Date);
            Writer.Print('"' || Fazo.Format_Date(v_p_Date) || '"');
          
          when 'TLTZ' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Tltz);
            Writer.Print('"' || Fazo.Format_Timestamp(cast(v_p_Tltz as timestamp)) || '"');
          
          when 'A' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Array);
            Writer.Print('"');
            v_p_Varchar2 := '';
            v_p_Array    := Fazo_Schema.Fazo.Sort(v_p_Array);
            if v_p_Array is not null then
              for j in 1 .. v_p_Array.Count
              loop
                if j <> 1 then
                  v_p_Varchar2 := v_p_Varchar2 || ', ';
                end if;
                v_p_Varchar2 := v_p_Varchar2 || v_p_Array(j);
                if Nvl(Length(v_p_Varchar2), 0) > 301 then
                  v_p_Varchar2 := Substr(v_p_Varchar2, 1, 300) || '...';
                  exit;
                end if;
              end loop;
            end if;
          
            Writer.Print(Fazo.Json_Escape(v_p_Varchar2));
            Writer.Print('"');
          
          else
            Raise_Application_Error(-20999, 'Invalid query column type=' || v_Col_Types(i));
        end case;
      
        if i <> v_Count then
          Writer.Print(',');
        end if;
      
      end loop;
      Writer.Print(']');
    
    end loop;
  
    Writer.Print(']');
  
    Dbms_Sql.Close_Cursor(v_Cursor);
  
  exception
    when others then
      if Dbms_Sql.Is_Open(v_Cursor) then
        Dbms_Sql.Close_Cursor(v_Cursor);
      end if;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Fazo_Query(i_Msg varchar2) is
  begin
    Raise_Application_Error(-20999, 'FAZO_QUERY:' || i_Msg);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Fq_Filter_Clause
  (
    i_Fields      Fazo_Schema.Hashmap,
    i_Filter_Expr Fazo_Schema.Arraylist,
    i_Namespace   varchar2,
    p_Params      in out nocopy Fazo_Schema.Hashmap
  ) return varchar2 is
    c_Inlist_Count constant number := 7;
    v_Namespace varchar2(30) := Nvl(i_Namespace, 'n');
    v_Nc        pls_integer := 0;
  
    ----------------------------------------------------------------------
    Function Next_Key return varchar2 is
      result varchar2(100);
    begin
      v_Nc   := v_Nc + 1;
      result := v_Namespace || v_Nc;
    
      if p_Params.Has(result) then
        Raise_Fazo_Query('Use another namespace, params contain given key [' || result || ']');
      end if;
    
      return result;
    end;
  
    ----------------------------------------------------------------------
    Function Convert_Key
    (
      i_Data_Type varchar2,
      i_Key       varchar2
    ) return varchar2 is
    begin
      return case i_Data_Type --
      when 'V' then i_Key --
      when 'N' then 'to_number(' || i_Key || ')' --
      when 'D' then 'to_date(' || i_Key || ', ''yyyymmddhh24miss'')' --
      end;
    end;
  
    ----------------------------------------------------------------------
    Function Convert_Value
    (
      i_Data_Type varchar2,
      i_Value     varchar2
    ) return varchar2 is
    begin
      return case i_Data_Type --
      when 'V' then i_Value --
      when 'N' then to_char(Fazo.Format_Number(i_Value)) --
      when 'D' then to_char(Fazo.Format_Date(i_Value), 'yyyymmddhh24miss') --
      end;
    end;
  
    ----------------------------------------------------------------------
    Function Put_Value(i_Value varchar2) return varchar2 is
      v_Key varchar2(100) := Next_Key;
    begin
      p_Params.Put(v_Key, i_Value);
      return ':' || v_Key;
    end;
  
    ----------------------------------------------------------------------
    Function Put_Value(i_Value Array_Varchar2) return varchar2 is
      v_Key varchar2(100) := Next_Key;
    begin
      p_Params.Put(v_Key, i_Value);
      return ':' || v_Key;
    end;
  
    ----------------------------------------------------------------------
    Function Put_Value
    (
      i_Data_Type varchar2,
      i_Value     varchar2
    ) return varchar2 is
    begin
      return Convert_Key(i_Data_Type, Put_Value(Convert_Value(i_Data_Type, i_Value)));
    end;
  
    ----------------------------------------------------------------------
    Function Pred_One
    (
      i_Data_Type varchar2,
      i_Name      varchar2,
      i_Op        varchar2,
      i_Val       varchar2
    ) return varchar2 is
      v_Suff_Escape varchar2(4000);
    begin
      if i_Op in ('elike', 'esearch') then
        v_Suff_Escape := ' escape ''\''';
      end if;
    
      if i_Data_Type = 'V' then
        if i_Op in ('like', 'elike') then
          return i_Name || ' like ' || Put_Value(i_Val) || v_Suff_Escape;
        elsif i_Op in ('search', 'esearch') then
          return 'lower(' || i_Name || ') like ' || Put_Value(Lower(i_Val)) || v_Suff_Escape;
        end if;
      end if;
    
      if i_Val is null then
        case i_Op
          when '=' then
            return i_Name || ' is null';
          when '<>' then
            return i_Name || ' is not null';
          else
            Raise_Fazo_Query('inequality predicate value is empty');
        end case;
      
      elsif i_Op in ('=', '<>', '<', '<=', '>', '>=') then
        return i_Name || ' ' || i_Op || ' ' || Put_Value(i_Data_Type, i_Val);
      
      elsif i_Op in ('like', 'elike', 'search', 'esearch') then
        if i_Op in ('like', 'elike') then
          return i_Name || ' like ' || Put_Value(i_Val) || v_Suff_Escape;
        elsif i_Op in ('search', 'esearch') then
          return 'lower(' || i_Name || ') like ' || Put_Value(Lower(i_Val)) || v_Suff_Escape;
        end if;
      end if;
    
      Raise_Fazo_Query('not one operator [' || i_Op || ']');
    end;
  
    ----------------------------------------------------------------------
    Function Pred_Set
    (
      i_Data_Type varchar2,
      i_Name      varchar2,
      i_Op        varchar2,
      i_Val       Fazo_Schema.Array_Varchar2
    ) return varchar2 is
      r     varchar2(32767);
      v_Op  varchar2(30);
      v_Val Fazo_Schema.Array_Varchar2;
    begin
      case i_Op
        when '=' then
          v_Op := 'in';
        when '<>' then
          v_Op := 'not in';
        else
          Raise_Fazo_Query('not set operator [' || i_Op || ']');
      end case;
    
      if i_Val.Count <= c_Inlist_Count then
      
        r := i_Name || ' ' || v_Op || ' (';
        for i in 1 .. i_Val.Count
        loop
          r := r || Put_Value(i_Data_Type, i_Val(i));
          if i <> i_Val.Count then
            r := r || ',';
          end if;
        end loop;
        return r || ')';
      
      else
        v_Val := Fazo_Schema.Array_Varchar2();
        v_Val.Extend(i_Val.Count);
        for i in 1 .. i_Val.Count
        loop
          v_Val(i) := Convert_Value(i_Data_Type, i_Val(i));
        end loop;
      
        return i_Name || ' ' || v_Op || ' (SELECT ' || Convert_Key(i_Data_Type, 'column_value') || --
         ' FROM TABLE(cast(' || Put_Value(v_Val) || ' as array_varchar2)))';
      
      end if;
    
    end;
  
    ----------------------------------------------------------------------
    Function Pred
    (
      i_Data_Type varchar2,
      i_Name      varchar2,
      i_Op        varchar2,
      i_Val       Fazo_Schema.Array_Varchar2
    ) return varchar2 is
    begin
      case i_Val.Count
        when 0 then
          Raise_Fazo_Query('value not found for field');
        when 1 then
          return Pred_One(i_Data_Type, i_Name, i_Op, i_Val(1));
        else
          return Pred_Set(i_Data_Type, i_Name, i_Op, i_Val);
      end case;
    end;
  
    ----------------------------------------------------------------------
    Function Option_Pred
    (
      i_Name varchar2,
      i_Op   varchar2,
      i_Val  varchar2
    ) return varchar2 is
      v_Field      Arraylist := i_Fields.r_Arraylist(i_Name);
      v_For        varchar2(100) := v_Field.r_Varchar2(2);
      v_Codes      Array_Varchar2 := v_Field.r_Array_Varchar2(3);
      v_Names      Array_Varchar2 := v_Field.r_Array_Varchar2(4);
      v_For_Field  Arraylist := i_Fields.r_Arraylist(v_For);
      v            Array_Varchar2 := Array_Varchar2();
      v_Op         varchar2(10) := '=';
      v_Name       varchar2(4000);
      v_Val        varchar2(4000) := i_Val;
      v_Is_Search  boolean := false;
      v_Is_Escaped boolean := false;
      v_Else_Found boolean := false;
    begin
      if i_Op in ('elike', 'esearch') then
        v_Is_Escaped := true;
      end if;
    
      if i_Op in ('search', 'esearch') then
        v_Is_Search := true;
        v_Val       := Lower(i_Val);
      end if;
    
      if i_Op not in ('like', 'elike', 'search', 'esearch') then
        Raise_Fazo_Query('Not text filter operator');
      end if;
    
      for i in 1 .. v_Names.Count
      loop
        v_Name := v_Names(i);
      
        if v_Is_Search then
          v_Name := Lower(v_Name);
        end if;
      
        if not v_Is_Escaped and v_Name like v_Val or v_Is_Escaped and v_Name like v_Val escape '\' then
          if i <= v_Codes.Count then
            v.Extend;
            v(v.Count) := v_Codes(i);
          else
            v_Else_Found := true;
          end if;
        end if;
      end loop;
    
      if v_Else_Found then
        v_Op := '<>';
        v    := v_Codes multiset Except v;
        if v.Count = 0 then
          return '';
        end if;
      elsif v.Count = 0 then
        return '1=2/*' || i_Name || ' ' || i_Op || ' ' || i_Val || '*/';
      end if;
    
      case v_For_Field.r_Varchar2(1)
        when c_f_Varchar2 then
          return Pred(i_Data_Type => 'V', i_Name => 't.' || v_For, i_Op => v_Op, i_Val => v);
        when c_f_Number then
          return Pred(i_Data_Type => 'N', i_Name => 't.' || v_For, i_Op => v_Op, i_Val => v);
        else
          Raise_Fazo_Query('for field of option is not varchar2 or number field');
      end case;
    
    end;
  
    ----------------------------------------------------------------------
    Function Refer_Pred
    (
      i_Name varchar2,
      i_Op   varchar2,
      i_Val  Array_Varchar2
    ) return varchar2 is
      v_Field      Arraylist := i_Fields.r_Arraylist(i_Name);
      v_For        varchar2(100) := v_Field.r_Varchar2(2);
      v_Table_Name varchar2(4000) := v_Field.r_Varchar2(3);
      v_Code_Field varchar2(100) := v_Field.r_Varchar2(4);
      v_Name_Field varchar2(100) := v_Field.r_Varchar2(5);
      v_Pred       varchar2(4000);
    
      v_For_Field Arraylist := i_Fields.r_Arraylist(v_For);
      Function Multi_Column return varchar2 is
        m_For         varchar2(100) := v_For_Field.r_Varchar2(2);
        m_Table_Name  varchar2(4000) := v_For_Field.r_Varchar2(3);
        m_Join_Clause varchar2(4000) := v_For_Field.r_Varchar2(4);
      begin
        return ' exists(select * from ' || --
        m_Table_Name || ' s JOIN ' || v_Table_Name || ' ss ' || --
         ' ON (s.' || m_For || '=ss.' || v_Code_Field || ') WHERE ' || --
        replace(replace(m_Join_Clause, '$', 't.'), '@', 's.') || --
         ' and ' || v_Pred || ')';
      end;
    
    begin
    
      v_Pred := Pred(i_Data_Type => 'V',
                     i_Name      => 'ss.' || v_Name_Field,
                     i_Op        => i_Op,
                     i_Val       => i_Val);
    
      if v_For_Field.r_Varchar2(1) = Fazo_Util.c_f_Multi then
        return Multi_Column;
      end if;
    
      return ' exists(select * from ' || v_Table_Name || --
       ' ss where ss.' || v_Code_Field || '=' || 't.' || v_For || ' and ' || v_Pred || ')';
    end;
  
    ----------------------------------------------------------------------
    Function Multi_Pred
    (
      i_Name varchar2,
      i_Op   varchar2,
      i_Val  Array_Varchar2
    ) return varchar2 is
      v_Field       Arraylist := i_Fields.r_Arraylist(i_Name);
      v_For         varchar2(100) := v_Field.r_Varchar2(2);
      v_Table_Name  varchar2(4000) := v_Field.r_Varchar2(3);
      v_Join_Clause varchar2(4000) := v_Field.r_Varchar2(4);
      v_Data_Type   varchar2(1) := v_Field.r_Varchar2(5);
      v_Pred        varchar2(4000);
    begin
      v_Pred := Pred(i_Data_Type => v_Data_Type,
                     i_Name      => 'p.' || v_For,
                     i_Op        => i_Op,
                     i_Val       => i_Val);
    
      return ' exists(select * from ' || v_Table_Name || ' p where ' || --
      replace(replace(v_Join_Clause, '$', 't.'), '@', 'p.') || ' and ' || v_Pred || ')';
    end;
  
    ----------------------------------------------------------------------
    Function Map_Pred
    (
      i_Name varchar2,
      i_Op   varchar2,
      i_Val  Array_Varchar2
    ) return varchar2 is
      v_Field  Arraylist := i_Fields.r_Arraylist(i_Name);
      v_Map_Fn varchar2(4000) := v_Field.r_Varchar2(2);
    begin
      return Pred(i_Data_Type => 'V',
                  i_Name      => replace(v_Map_Fn, '$', 't.'),
                  i_Op        => i_Op,
                  i_Val       => i_Val);
    end;
  
    ----------------------------------------------------------------------
    Function b_Predicate(i_Filter Fazo_Schema.Arraylist) return varchar2 is
      v_Name  varchar2(100);
      v_Field Fazo_Schema.Arraylist;
    begin
      if i_Filter.Val.Count <> 3 then
        Raise_Fazo_Query('predicate filter must contain 3 elements');
      end if;
    
      v_Name  := i_Filter.r_Varchar2(1);
      v_Field := i_Fields.o_Arraylist(v_Name);
    
      if v_Field is null then
        Raise_Fazo_Query('Field not found [' || v_Name || ']');
      end if;
    
      case v_Field.r_Varchar2(1)
        when c_f_Varchar2 then
          return Pred(i_Data_Type => 'V',
                      i_Name      => 't.' || v_Name,
                      i_Op        => i_Filter.r_Varchar2(2),
                      i_Val       => i_Filter.r_Array_Varchar2(3));
        when c_f_Number then
          return Pred(i_Data_Type => 'N',
                      i_Name      => 't.' || v_Name,
                      i_Op        => i_Filter.r_Varchar2(2),
                      i_Val       => i_Filter.r_Array_Varchar2(3));
        when c_f_Date then
          return Pred(i_Data_Type => 'D',
                      i_Name      => 't.' || v_Name,
                      i_Op        => i_Filter.r_Varchar2(2),
                      i_Val       => i_Filter.r_Array_Varchar2(3));
        when c_f_Option then
          return Option_Pred(i_Name => v_Name,
                             i_Op   => i_Filter.r_Varchar2(2),
                             i_Val  => i_Filter.r_Varchar2(3));
        
        when c_f_Refer then
          return Refer_Pred(i_Name => v_Name,
                            i_Op   => i_Filter.r_Varchar2(2),
                            i_Val  => i_Filter.r_Array_Varchar2(3));
        
        when c_f_Multi then
          return Multi_Pred(i_Name => v_Name,
                            i_Op   => i_Filter.r_Varchar2(2),
                            i_Val  => i_Filter.r_Array_Varchar2(3));
        when c_f_Map then
          return Map_Pred(i_Name => v_Name,
                          i_Op   => i_Filter.r_Varchar2(2),
                          i_Val  => i_Filter.r_Array_Varchar2(3));
        
      end case;
    end;
  
    ----------------------------------------------------------------------
    Function b_Filter(i_Filter Fazo_Schema.Arraylist) return varchar2;
  
    ----------------------------------------------------------------------
    Function b_Binary
    (
      i_Op     varchar2,
      i_Filter Fazo_Schema.Arraylist
    ) return varchar2 is
      v_Op varchar2(4000);
      k    number;
      r    varchar2(4000) := '';
    begin
      if i_Filter.Count < 2 then
        Raise_Fazo_Query('binary filter must contain at least 2 element');
      end if;
    
      v_Op := ' ' || i_Op || ' ';
      k    := i_Filter.Count;
    
      for i in 1 .. k
      loop
        r := r || b_Filter(i_Filter.r_Arraylist(i));
        if i <> k then
          r := r || v_Op;
        end if;
      end loop;
    
      return r;
    end;
  
    ----------------------------------------------------------------------
    Function b_Compound
    (
      i_Op     varchar2,
      i_Filter Fazo_Schema.Arraylist
    ) return varchar2 is
    begin
      if i_Op = 'not' then
        return 'not ' || b_Filter(i_Filter);
      elsif i_Op in ('and', 'or') then
        return '(' || b_Binary(i_Op, i_Filter) || ')';
      else
        Raise_Fazo_Query('not compound operator [' || i_Op || ']');
      end if;
    end;
  
    ----------------------------------------------------------------------
    Function b_Filter(i_Filter Fazo_Schema.Arraylist) return varchar2 is
    begin
      case i_Filter.Count
        when 2 then
          return b_Compound(i_Filter.r_Varchar2(1), i_Filter.r_Arraylist(2));
        when 3 then
          return b_Predicate(i_Filter);
        else
          Raise_Fazo_Query('filter definition not found');
      end case;
    end;
  
    ----------------------------------------------------------------------
  begin
    return b_Filter(i_Filter_Expr);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Fq_Column_Clause
  (
    i_Fields  Fazo_Schema.Hashmap,
    i_Columns Fazo_Schema.Array_Varchar2
  ) return Fazo_Schema.Array_Varchar2 is
    v_Name  varchar2(100);
    v_Field Fazo_Schema.Arraylist;
    result  Array_Varchar2;
    ----------------------------------------------------------------------
    Function Format_Option_Column
    (
      i_Name  varchar2,
      i_Field Arraylist
    ) return varchar2 is
      v_For       varchar2(100) := i_Field.r_Varchar2(2);
      v_Codes     Array_Varchar2 := i_Field.r_Array_Varchar2(3);
      v_Names     Array_Varchar2 := i_Field.r_Array_Varchar2(4);
      v_For_Field Arraylist := i_Fields.r_Arraylist(v_For);
      r           varchar2(4000);
      -------------------------------
      Function Option_Column
      (
        i_For        varchar2,
        i_Field_Type varchar2
      ) return varchar2 is
        v_Res varchar2(4000);
      begin
        v_Res := 'DECODE(' || i_For;
        case i_Field_Type
          when c_f_Varchar2 then
            for i in 1 .. v_Codes.Count
            loop
              v_Res := v_Res || ',''' || Escape_Sql_Value(v_Codes(i)) || ''',''' ||
                       Escape_Sql_Value(v_Names(i)) || '''';
            end loop;
          
          when c_f_Number then
            for i in 1 .. v_Codes.Count
            loop
              v_Res := v_Res || ',' || v_Codes(i) || ',''' || Escape_Sql_Value(v_Names(i)) || '''';
            end loop;
          
          else
            Raise_Fazo_Query('for field of option column is not varchar2 or number field');
        end case;
      
        if v_Codes.Count < v_Names.Count then
          v_Res := v_Res || ',''' || v_Names(v_Codes.Count + 1) || '''';
        end if;
      
        return v_Res || ') ';
      end;
    begin
      if v_For_Field.r_Varchar2(1) in (c_f_Varchar2, c_f_Number) then
        r := Option_Column(v_For, v_For_Field.r_Varchar2(1));
      elsif v_For_Field.r_Varchar2(1) = c_f_Multi then
        r := '(SELECT cast(collect(' ||
             Option_Column('s.' || v_For_Field.r_Varchar2(2), v_For_Field.r_Varchar2(5)) || --
             ') as array_varchar2)' || --
             ' FROM ' || v_For_Field.r_Varchar2(3) || ' s WHERE ' || --
             replace(replace(v_For_Field.r_Varchar2(4), '$', 't.'), '@', 's.') || ') ';
      else
        Raise_Fazo_Query('for field of option is not varchar2 or number field or multi field');
      end if;
    
      return r || ' ' || i_Name;
    end;
  
    ----------------------------------------------------------------------
    Function Format_Refer_Column
    (
      i_Name  varchar2,
      i_Field Arraylist
    ) return varchar2 is
      v_For        varchar2(100) := i_Field.r_Varchar2(2);
      v_Table_Name varchar2(4000) := i_Field.r_Varchar2(3);
      v_Code_Field varchar2(100) := i_Field.r_Varchar2(4);
      v_Name_Field varchar2(100) := i_Field.r_Varchar2(5);
      v_For_Field  Arraylist := i_Fields.r_Arraylist(v_For);
      r            varchar2(4000);
      Procedure Multi_Column is
        m_For         varchar2(100) := v_For_Field.r_Varchar2(2);
        m_Table_Name  varchar2(4000) := v_For_Field.r_Varchar2(3);
        m_Join_Clause varchar2(4000) := v_For_Field.r_Varchar2(4);
      begin
        r := '(SELECT cast(collect(to_char(ss.' || v_Name_Field || ') order by lower(ss.' ||
             v_Name_Field || ')) as array_varchar2) x$' || --
             ' FROM ' || m_Table_Name || ' s JOIN ' || v_Table_Name || ' ss ' || --
             ' ON (s.' || m_For || '=ss.' || v_Code_Field || ') WHERE ' || --
             replace(replace(m_Join_Clause, '$', 't.'), '@', 's.') || ') ' || i_Name;
      end;
    begin
      if v_For_Field.r_Varchar2(1) = Fazo_Util.c_f_Multi then
        Multi_Column;
      else
        r := '(SELECT w.' || v_Name_Field || ' FROM ' || v_Table_Name || ' w WHERE w.' ||
             v_Code_Field || '=t.' || v_For || ') ' || i_Name;
      end if;
      return r;
    end;
  
    ----------------------------------------------------------------------
    Function Format_Map_Column
    (
      i_Name   varchar2,
      i_Map_Fn varchar2
    ) return varchar2 is
    begin
      return replace(i_Map_Fn, '$', 't.') || ' ' || i_Name;
    end;
  
    ----------------------------------------------------------------------
    Function Format_Multi_Column
    (
      i_Name  varchar2,
      i_Field Arraylist
    ) return varchar2 is
      v_For         varchar2(100) := i_Field.r_Varchar2(2);
      v_Table_Name  varchar2(4000) := i_Field.r_Varchar2(3);
      v_Join_Clause varchar2(4000) := i_Field.r_Varchar2(4);
    begin
      return '(SELECT cast(collect(to_char(s.' || v_For || --
       ')) as array_varchar2)' || --
       ' FROM ' || v_Table_Name || ' s WHERE ' || --
      replace(replace(v_Join_Clause, '$', 't.'), '@', 's.') || ') ' || i_Name;
    end;
  
    ----------------------------------------------------------------------
  begin
    if i_Columns.Count = 0 then
      Raise_Application_Error(-20999, 'Query: column is empty');
    end if;
  
    result := Array_Varchar2();
    Result.Extend(i_Columns.Count);
  
    for i in 1 .. i_Columns.Count
    loop
      v_Name  := i_Columns(i);
      v_Field := i_Fields.o_Arraylist(v_Name);
      if v_Field is null then
        Raise_Fazo_Query('Field not found [' || v_Name || ']');
      end if;
    
      case v_Field.r_Varchar2(1)
        when c_f_Varchar2 then
          result(i) := v_Name;
        when c_f_Number then
          result(i) := v_Name;
        when c_f_Date then
          result(i) := v_Name;
        when c_f_Option then
          result(i) := Format_Option_Column(v_Name, v_Field);
        when c_f_Refer then
          result(i) := Format_Refer_Column(v_Name, v_Field);
        when c_f_Map then
          result(i) := Format_Map_Column(v_Name, v_Field.r_Varchar2(2));
        when c_f_Multi then
          result(i) := Format_Multi_Column(v_Name, v_Field);
      end case;
    
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Fq_Sort_Clause
  (
    i_Fields Fazo_Schema.Hashmap,
    i_Sort   Fazo_Schema.Array_Varchar2
  ) return varchar2 is
    v_Field_Type  varchar2(1);
    v_Name        varchar2(4000);
    v_Asc         varchar2(10);
    v_Field       Fazo_Schema.Arraylist;
    v_Field_Multi Fazo_Schema.Arraylist;
    r             varchar2(4000);
  begin
    for i in 1 .. i_Sort.Count
    loop
      v_Name := i_Sort(i);
      v_Asc  := Substr(v_Name, 1, 1);
      if v_Asc in ('+', '-') then
        v_Name := Substr(v_Name, 2);
        v_Asc  := case v_Asc
                    when '-' then
                     ' desc'
                    else
                     ''
                  end;
      else
        v_Asc := '';
      end if;
    
      v_Field := i_Fields.o_Arraylist(v_Name);
      if v_Field is null then
        Raise_Fazo_Query('Field not found [' || v_Name || ']');
      end if;
    
      v_Field_Type := v_Field.r_Varchar2(1);
    
      if v_Field_Type = c_f_Refer then
        v_Field_Multi := i_Fields.o_Arraylist(v_Field.r_Varchar2(2));
        if v_Field_Multi.r_Varchar2(1) = c_f_Multi then
          v_Name := 'Lower((select Listagg(Substr(to_char(Column_Value), 1, 100), '','') Within group(order by Lower(Column_Value))
                                  from table(' || v_Name ||
                    ') Ss
                                 where Rownum < 10))';
        elsif v_Field.r_Varchar2(7) = c_f_Varchar2 then
          v_Name := 'lower(' || v_Name || ')';
        end if;
      elsif v_Field_Type = c_f_Map then
        if v_Field.r_Varchar2(3) = c_f_Varchar2 then
          v_Name := 'lower(' || v_Name || ')';
        end if;
      elsif v_Field_Type = c_f_Varchar2 then
        v_Name := 'lower(' || v_Name || ')';
      elsif v_Field_Type = c_f_Option then
        v_Field_Multi := i_Fields.o_Arraylist(v_Field.r_Varchar2(2));
        if v_Field_Multi.r_Varchar2(1) = c_f_Multi then
          v_Name := 'Lower((select Listagg(Substr(to_char(Column_Value), 1, 100), '','') Within group(order by Lower(Column_Value))
                                  from table(' || v_Name ||
                    ') Ss
                                 where Rownum < 10))';
        else
          v_Name := 'lower(' || v_Name || ')';
        end if;
      end if;
    
      r := r || v_Name || v_Asc;
    
      if i <> i_Sort.Count then
        r := r || ',';
      end if;
    end loop;
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Fq_Clauses
  (
    i_Fields        Fazo_Schema.Hashmap,
    i_Column        Fazo_Schema.Array_Varchar2,
    i_Filter        Fazo_Schema.Arraylist,
    i_Sort          Fazo_Schema.Array_Varchar2,
    i_Namespace     varchar2,
    p_Query         in out nocopy varchar2,
    p_Params        in out nocopy Fazo_Schema.Hashmap,
    o_Column_Clause out varchar2,
    o_Filter_Clause out varchar2,
    o_Sort_Clause   out varchar2
  ) is
    v_Column          Array_Varchar2;
    v_Sort_Cols       Array_Varchar2 := i_Sort;
    v_Sort_Col_Clause Array_Varchar2;
  begin
    v_Column := Fq_Column_Clause(i_Fields, i_Column);
  
    if i_Filter is not null and i_Filter.Val.Count > 0 then
      o_Filter_Clause := 'WHERE ' || Fq_Filter_Clause(i_Fields, i_Filter, i_Namespace, p_Params);
    end if;
  
    if i_Sort is not null and i_Sort.Count > 0 then
      o_Sort_Clause := ' ORDER BY ' || Fq_Sort_Clause(i_Fields, i_Sort);
    end if;
  
    for i in 1 .. i_Sort.Count
    loop
      if Substr(i_Sort(i), 1, 1) in ('+', '-') then
        v_Sort_Cols(i) := Substr(i_Sort(i), 2);
      else
        v_Sort_Cols(i) := i_Sort(i);
      end if;
    end loop;
  
    if v_Sort_Cols.Count > 0 then
      v_Sort_Col_Clause := Fq_Column_Clause(i_Fields, v_Sort_Cols);
    
      v_Sort_Col_Clause := v_Sort_Col_Clause multiset Except v_Sort_Cols;
    
      if v_Sort_Col_Clause.Count > 0 then
        p_Query := 'SELECT t.*,' || Fazo.Gather(v_Sort_Col_Clause, ',') || ' FROM (' || p_Query ||
                   ') t';
      
        for i in 1 .. v_Sort_Col_Clause.Count
        loop
          for j in 1 .. v_Column.Count
          loop
            if v_Sort_Col_Clause(i) = v_Column(j) then
              v_Column(j) := i_Column(j);
            end if;
          end loop;
        end loop;
      
      end if;
    end if;
  
    o_Column_Clause := Fazo.Gather(v_Column, ',');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Build_Query
  (
    i_Query                varchar2,
    i_Params               Fazo_Schema.Hashmap,
    i_Fields               Fazo_Schema.Hashmap,
    i_Columns_After_Filter Fazo_Schema.Array_Varchar2,
    i_Column               Fazo_Schema.Array_Varchar2,
    i_Filter               Fazo_Schema.Arraylist,
    i_Sort                 Fazo_Schema.Array_Varchar2,
    i_Namespace            varchar2,
    o_Query                out varchar2,
    o_Params               out Fazo_Schema.Hashmap
  ) is
    v_Query         varchar2(32767) := i_Query;
    v_Column_Clause varchar2(32767);
    v_Filter_Clause varchar2(32767);
    v_Sort_Clause   varchar2(32767);
  begin
  
    o_Params := Fazo_Schema.Hashmap();
    o_Params.Put_All(i_Params);
  
    Fq_Clauses(i_Fields        => i_Fields,
               i_Column        => i_Column,
               i_Filter        => i_Filter,
               i_Sort          => i_Sort,
               i_Namespace     => i_Namespace,
               p_Query         => v_Query,
               p_Params        => o_Params,
               o_Column_Clause => v_Column_Clause,
               o_Filter_Clause => v_Filter_Clause,
               o_Sort_Clause   => v_Sort_Clause);
  
    if i_Columns_After_Filter is null then
      o_Query := 'SELECT ' || v_Column_Clause || --
                 ' FROM (' || v_Query || ') t ' || v_Filter_Clause || v_Sort_Clause;
    else
      o_Query := 'SELECT t.*,' || Fazo.Gather(i_Columns_After_Filter, ',') || --
                 ' FROM (' || v_Query || ') t ' || v_Filter_Clause;
      o_Query := 'SELECT ' || v_Column_Clause || --
                 ' FROM (' || o_Query || ') t ' || v_Sort_Clause;
    end if;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Query
  (
    i_Query  varchar2,
    i_Params Hashmap
  ) return varchar2 is
    v_Param Fazo_Schema.Hash_Entry;
    v       Array_Varchar2;
    v_Val   varchar2(32767);
    r       varchar2(32767) := i_Query;
  begin
    if i_Params is not null then
      for i in 1 .. i_Params.Buckets.Count
      loop
        v_Param := i_Params.Buckets(i);
        case
        
          when v_Param.Val.Is_Varchar2 then
            v_Val := '''' || Escape_Sql_Value(v_Param.Val.As_Varchar2) || '''';
          
          when v_Param.Val.Is_Array_Varchar2 then
            v := v_Param.Val.As_Array_Varchar2;
            if v is null then
              v_Val := 'null';
            else
              for i in 1 .. v.Count
              loop
                v(i) := '''' || Escape_Sql_Value(v(i)) || '''';
              end loop;
              v_Val := 'array_varchar2(' || Fazo_Schema.Fazo.Gather(v, ',') || ')';
            end if;
          when v_Param.Val.Is_Number then
            v_Val := 'to_number(''' || v_Param.Val.As_Number || ''')';
          
          when v_Param.Val.Is_Array_Number then
            v := Fazo.To_Array_Varchar2(v_Param.Val.As_Array_Number);
            if v is null then
              v_Val := 'null';
            else
              for i in 1 .. v.Count
              loop
                v(i) := 'to_number(''' || Escape_Sql_Value(v(i)) || ''')';
              end loop;
              v_Val := 'array_number(' || Fazo_Schema.Fazo.Gather(v, ',') || ')';
            end if;
          when v_Param.Val.Is_Date then
            v_Val := 'to_date(''' || to_char(v_Param.Val.As_Date, 'yyyymmddhh24miss') ||
                     ''',''yyyymmddhh24miss'')';
          
          when v_Param.Val.Is_Array_Date then
            v := Fazo.To_Array_Varchar2(v_Param.Val.As_Array_Date, 'yyyymmddhh24miss');
            if v is null then
              v_Val := 'null';
            else
              for i in 1 .. v.Count
              loop
                v(i) := 'to_date(''' || Escape_Sql_Value(v(i)) || ''',''yyyymmddhh24miss'')';
              end loop;
              v_Val := 'array_date(' || Fazo_Schema.Fazo.Gather(v, ',') || ')';
            end if;
          else
            Raise_Application_Error(-20999,
                                    'Fazo query params value`s type must be varchar2 or array_varchar2 key=' ||
                                    v_Param.Key);
        end case;
      
        r := Regexp_Replace(r, ':' || v_Param.Key || '(\W|$)', v_Val || '\1');
      
      end loop;
    end if;
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Build_Query_Page
  (
    i_Query                varchar2,
    i_Params               Fazo_Schema.Hashmap,
    i_Fields               Fazo_Schema.Hashmap,
    i_Columns_After_Filter Fazo_Schema.Array_Varchar2,
    i_Column               Fazo_Schema.Array_Varchar2,
    i_Filter               Fazo_Schema.Arraylist,
    i_Sort                 Fazo_Schema.Array_Varchar2,
    i_Rownum_Start         number,
    i_Rownum_End           number,
    i_Namespace            varchar2,
    o_Query                out varchar2,
    o_Params               out Fazo_Schema.Hashmap
  ) is
    v_Query            varchar2(32767) := i_Query;
    v_Params           Fazo_Schema.Hashmap;
    v_Column_Clause    varchar2(32767);
    v_Filter_Clause    varchar2(32767);
    v_Sort_Clause      varchar2(32767);
    v_Rownum_Start     number := Nvl(i_Rownum_Start, 0);
    v_Rownum_End       number := Nvl(i_Rownum_End, 0);
    v_Rownum_Start_Key varchar2(30) := Nvl(i_Namespace, 'n') || 'rn_start';
    v_Rownum_End_Key   varchar2(30) := Nvl(i_Namespace, 'n') || 'rn_end';
  begin
    v_Params := Fazo_Schema.Hashmap();
    v_Params.Put_All(i_Params);
  
    Fq_Clauses(i_Fields        => i_Fields,
               i_Column        => i_Column,
               i_Filter        => i_Filter,
               i_Sort          => i_Sort,
               i_Namespace     => i_Namespace,
               p_Query         => v_Query,
               p_Params        => v_Params,
               o_Column_Clause => v_Column_Clause,
               o_Filter_Clause => v_Filter_Clause,
               o_Sort_Clause   => v_Sort_Clause);
  
    if i_Columns_After_Filter is null then
      v_Query := 'SELECT * FROM (' || v_Query || ') t ' || v_Filter_Clause || v_Sort_Clause;
    else
      v_Query := 'SELECT t.*, ' || Fazo.Gather(i_Columns_After_Filter, ',') || --
                 ' FROM (' || v_Query || ') t ' || v_Filter_Clause || v_Sort_Clause;
    end if;
  
    v_Query := 'SELECT ' || v_Column_Clause || ' FROM (SELECT a.*, ROWNUM row_num FROM (' ||
               v_Query || ') a WHERE ROWNUM < to_number(:' || v_Rownum_End_Key ||
               ')) t WHERE row_num  > to_number(:' || v_Rownum_Start_Key || ')';
  
    v_Params.Put(v_Rownum_Start_Key, to_char(v_Rownum_Start));
    v_Params.Put(v_Rownum_End_Key, to_char(v_Rownum_End));
  
    o_Query  := v_Query;
    o_Params := v_Params;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Query_Page
  (
    i_Query                varchar2,
    i_Params               Fazo_Schema.Hashmap,
    i_Fields               Fazo_Schema.Hashmap,
    i_Columns_After_Filter Fazo_Schema.Array_Varchar2,
    i_Column               Fazo_Schema.Array_Varchar2,
    i_Filter               Fazo_Schema.Arraylist,
    i_Sort                 Fazo_Schema.Array_Varchar2,
    i_Rownum_Start         number,
    i_Rownum_End           number,
    i_Namespace            varchar2,
    Writer                 in out nocopy Stream,
    i_Metadata             Arraylist := null
  ) is
    v_Query            varchar2(32767) := i_Query;
    v_Params           Fazo_Schema.Hashmap;
    v_Count            number;
    v_Column_Clause    varchar2(32767);
    v_Filter_Clause    varchar2(32767);
    v_Sort_Clause      varchar2(32767);
    v_Rownum_Start     number := Nvl(i_Rownum_Start, 0);
    v_Rownum_End       number := Nvl(i_Rownum_End, 0);
    v_Rownum_Start_Key varchar2(30) := Nvl(i_Namespace, 'n') || 'rn_start';
    v_Rownum_End_Key   varchar2(30) := Nvl(i_Namespace, 'n') || 'rn_end';
  begin
  
    v_Params := Fazo_Schema.Hashmap();
    v_Params.Put_All(i_Params);
  
    Fq_Clauses(i_Fields        => i_Fields,
               i_Column        => i_Column,
               i_Filter        => i_Filter,
               i_Sort          => i_Sort,
               i_Namespace     => i_Namespace,
               p_Query         => v_Query,
               p_Params        => v_Params,
               o_Column_Clause => v_Column_Clause,
               o_Filter_Clause => v_Filter_Clause,
               o_Sort_Clause   => v_Sort_Clause);
  
    v_Count := Execute_Count(i_Query, v_Filter_Clause, v_Params);
  
    if v_Count = 0 then
      Writer.Print('{"count":0,"data":[]');
    else
      Writer.Print('{"count":' || v_Count || ',"data":');
    
      if i_Columns_After_Filter is null then
        v_Query := 'SELECT * FROM (' || v_Query || ') t ' || v_Filter_Clause || v_Sort_Clause;
      else
        v_Query := 'SELECT t.*, ' || Fazo.Gather(i_Columns_After_Filter, ',') || --
                   ' FROM (' || v_Query || ') t ' || v_Filter_Clause || v_Sort_Clause;
      end if;
      v_Query := 'SELECT ' || v_Column_Clause || ' FROM (SELECT a.*, ROWNUM row_num FROM (' ||
                 v_Query || ') a WHERE ROWNUM < to_number(:' || v_Rownum_End_Key ||
                 ')) t WHERE row_num  > to_number(:' || v_Rownum_Start_Key || ')';
    
      v_Params.Put(v_Rownum_Start_Key, to_char(v_Rownum_Start));
      v_Params.Put(v_Rownum_End_Key, to_char(v_Rownum_End));
    
      Execute_Query(v_Query, v_Params, Writer);
    
    end if;
    if i_Metadata is not null then
      Writer.Print(',"meta":');
      i_Metadata.Print_Json(Writer);
    end if;
    Writer.Print('}');
  end;

  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Function Fields_Info_Refer
  (
    i_Field       Fazo_Schema.Arraylist,
    i_Number_Type boolean,
    i_Values      Array_Varchar2
  ) return Hashmap is
    v_Table_Name varchar2(4000) := Nvl(i_Field.r_Varchar2(6), i_Field.r_Varchar2(3));
    v_Code_Field varchar2(100) := i_Field.r_Varchar2(4);
    v_Name_Field varchar2(100) := i_Field.r_Varchar2(5);
    v_Count      number;
    v_Query      varchar2(4000);
    v_Elems      Array_Varchar2;
    v_Param      Hashmap;
    Writer       Stream := Stream();
    result       Hashmap := Hashmap();
  begin
  
    v_Query := 'SELECT count(*) FROM ' || v_Table_Name;
    v_Count := Execute_Count(v_Query, null);
    Result.Put('count', v_Count);
  
    if v_Count <= 50 then
      v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ' FROM ' || v_Table_Name ||
                 ' ORDER BY ' || v_Name_Field;
      Execute_Query(v_Query, null, Writer);
      Result.Put('data', Fazo_Schema.Gws_Json_Value(Writer.Val));
    
    elsif i_Values.Count > 0 then
      v_Elems := Array_Varchar2();
      v_Param := Hashmap();
      for i in 1 .. i_Values.Count
      loop
        v_Param.Put('iv' || i, i_Values(i));
        if i_Number_Type then
          Fazo.Push(v_Elems, 'to_number(:iv' || i || ')');
        else
          Fazo.Push(v_Elems, ':iv' || i);
        end if;
      end loop;
    
      v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ' FROM ' || v_Table_Name ||
                 ' WHERE ' || v_Code_Field || ' in (' || Fazo.Gather(v_Elems, ',') || ')' || --
                 ' ORDER BY ' || v_Name_Field;
      Execute_Query(v_Query, v_Param, Writer);
      Result.Put('vals', Fazo_Schema.Gws_Json_Value(Writer.Val));
    
    end if;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Info_Refer
  (
    Writer   in out nocopy Stream,
    i_Search varchar2,
    i_Field  Fazo_Schema.Arraylist
  ) is
    v_Table_Name varchar2(4000) := Nvl(i_Field.r_Varchar2(6), i_Field.r_Varchar2(3));
    v_Code_Field varchar2(100) := i_Field.r_Varchar2(4);
    v_Name_Field varchar2(100) := i_Field.r_Varchar2(5);
    v_Query      varchar2(4000);
  begin
    v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ' FROM ' || v_Table_Name ||
               ' WHERE rownum < 100 AND lower(' || v_Name_Field || ') like :search' || --
               ' ORDER BY ' || v_Name_Field;
    Execute_Query(v_Query, Fazo.Zip_Map('search', '%' || Lower(i_Search) || '%'), Writer);
  end;

  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Info
  (
    Writer   in out nocopy Stream,
    i_Fields Fazo_Schema.Hashmap,
    i_Names  Fazo_Schema.Hashmap
  ) is
    v_Name        varchar2(100);
    v_Field       Arraylist;
    v_Number_Type boolean;
    v_Refers      Hashmap := Hashmap();
    v_Data        Hashmap := Hashmap();
  begin
  
    for i in 1 .. i_Names.Buckets.Count
    loop
      v_Name  := i_Names.Buckets(i).Key;
      v_Field := i_Fields.r_Arraylist(v_Name);
      if v_Field.r_Varchar2(1) = c_f_Refer then
        v_Number_Type := i_Fields.r_Arraylist(v_Field.r_Varchar2(2)).r_Varchar2(1) = c_f_Number;
        v_Refers.Put(v_Name,
                     Fields_Info_Refer(v_Field,
                                       v_Number_Type,
                                       i_Names.Buckets(i).Val.As_Array_Varchar2));
      end if;
    end loop;
  
    v_Data.Put('fields', i_Fields);
    v_Data.Put('refers', v_Refers);
  
    v_Data.Print_Json(Writer);
  end;

  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Function Fields_Data_Option(i_Field Fazo_Schema.Arraylist) return Hashmap is
    v_Codes Array_Varchar2 := i_Field.r_Array_Varchar2(3);
    v_Names Array_Varchar2 := i_Field.r_Array_Varchar2(4);
    v_Items Arraylist := Arraylist();
    result  Hashmap := Hashmap();
  begin
    for i in 1 .. v_Codes.Count
    loop
      v_Items.Push(Array_Varchar2(v_Codes(i), v_Names(i)));
    end loop;
  
    Result.Put('count', v_Codes.Count);
    Result.Put('data', v_Items);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Function Fields_Data_Refer(i_Field Fazo_Schema.Arraylist) return Hashmap is
    v_Table_Name varchar2(4000) := i_Field.r_Varchar2(3);
    v_Code_Field varchar2(100) := i_Field.r_Varchar2(4);
    v_Name_Field varchar2(100) := i_Field.r_Varchar2(5);
    v_Query      varchar2(4000);
    Writer       Stream := Stream();
    result       Hashmap := Hashmap();
  begin
  
    v_Query := 'SELECT count(*) FROM ' || v_Table_Name;
    Result.Put('count', Execute_Count(v_Query, null));
  
    v_Query := 'SELECT ' || v_Code_Field || ',' || v_Name_Field || ' FROM ' || v_Table_Name;
    Execute_Query(v_Query, null, Writer);
    Result.Put('data', Fazo_Schema.Gws_Json_Value(Writer.Val));
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  -- deprecated
  ----------------------------------------------------------------------------------------------------
  Procedure Fields_Data
  (
    i_Fields Fazo_Schema.Hashmap,
    i_Names  Array_Varchar2,
    Writer   in out nocopy Stream
  ) is
    v_Name  varchar2(100);
    v_Field Arraylist;
    v_Data  Hashmap := Hashmap();
  begin
    for i in 1 .. i_Names.Count
    loop
      v_Name  := i_Names(i);
      v_Field := i_Fields.r_Arraylist(v_Name);
    
      case v_Field.r_Varchar2(1)
        when c_f_Option then
          v_Data.Put(v_Name, Fields_Data_Option(v_Field));
        when c_f_Refer then
          v_Data.Put(v_Name, Fields_Data_Refer(v_Field));
      end case;
    
    end loop;
  
    v_Data.Print_Json(Writer);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Check_Version_Compatibility(i_Version varchar2) return boolean is
    v_Version varchar2(100);
    v_Cur     Array_Number;
    v_Comp    Array_Number;
    --------------------------------------------------
    Function Get_Version return varchar2 is
      result varchar2(100);
    begin
      execute immediate 'alter package biruni compile';
      execute immediate 'alter package biruni compile body';
    
      execute immediate 'begin :c := Biruni.c_Version; end;'
        using out result;
    
      return result;
    exception
      when others then
        Dbms_Output.Put_Line('fazo_util.get_version: ' || sqlerrm);
        return null;
    end;
  
    --------------------------------------------------
    Function Get_Version_Depricated return varchar2 is
      result varchar2(100);
    begin
      execute immediate 'alter package biruni_version compile';
      execute immediate 'alter package biruni_version compile body';
    
      execute immediate 'begin :c := Biruni_Version.c_Version; end;'
        using out result;
    
      return result;
    exception
      when others then
        Dbms_Output.Put_Line('fazo_util.get_version_depricated: ' || sqlerrm);
        return null;
    end;
  
  begin
    v_Version := Get_Version;
  
    if v_Version is null then
      v_Version := Get_Version_Depricated;
    end if;
  
    Dbms_Output.Put_Line(v_Version);
  
    v_Cur  := Fazo.To_Array_Number(Fazo.Split(v_Version, '.'));
    v_Comp := Fazo.To_Array_Number(Fazo.Split(i_Version, '.'));
  
    if v_Cur.Count = 3 and v_Comp.Count = 3 then
      for i in 1 .. v_Cur.Count
      loop
        if v_Cur(i) > v_Comp(i) then
          return true;
        elsif v_Cur(i) < v_Comp(i) then
          return false;
        end if;
      end loop;
    
      return true;
    end if;
  
    return false;
  exception
    when others then
      return false;
  end;

end Fazo_Util;
/
