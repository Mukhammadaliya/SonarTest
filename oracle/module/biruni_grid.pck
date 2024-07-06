create or replace package Biruni_Grid is
  ----------------------------------------------------------------------------------------------------
  Procedure Build_Query
  (
    i_Query  Fazo_Query,
    i_Column Array_Varchar2,
    i_Filter Arraylist,
    i_Sort   Array_Varchar2,
    o_Query  out varchar2,
    o_Params out Hashmap
  );
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
  Procedure Execute_Query
  (
    i_Query  varchar2,
    i_Params Fazo_Schema.Hashmap,
    a        in out nocopy b_Table,
    i_Imgs   Matrix_Number := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Export
  (
    i_Query  Fazo_Query,
    i_Params Hashmap
  );
end Biruni_Grid;
/
create or replace package body Biruni_Grid is
  ----------------------------------------------------------------------------------------------------
  Procedure Build_Query
  (
    i_Query  Fazo_Query,
    i_Column Array_Varchar2,
    i_Filter Arraylist,
    i_Sort   Array_Varchar2,
    o_Query  out varchar2,
    o_Params out Hashmap
  ) is
    v_Sort Array_Varchar2 := i_Sort;
  begin
  
    if i_Sort is null then
      v_Sort := Array_Varchar2();
    end if;
  
    Fazo_Schema.Fazo_Util.Build_Query(i_Query                => i_Query.Query,
                                      i_Params               => i_Query.Params,
                                      i_Fields               => i_Query.Fields,
                                      i_Columns_After_Filter => i_Query.Columns_After_Filter,
                                      i_Column               => i_Column,
                                      i_Filter               => i_Filter,
                                      i_Sort                 => v_Sort,
                                      i_Namespace            => null,
                                      o_Query                => o_Query,
                                      o_Params               => o_Params);
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
    v_p_Array       Array_Varchar2;
    v_p_Timestamp   timestamp;
    v_Row_Processed number;
  begin
    o_Cursor := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(o_Cursor, i_Query, Dbms_Sql.Native);
  
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
        when Dbms_Sql.Char_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Varchar2, v_Col.Col_Max_Len);
          o_Col_Types(i) := 'V';
        when Dbms_Sql.User_Defined_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Array);
          o_Col_Types(i) := 'A';
        when Dbms_Sql.Timestamp_With_Local_Tz_Type then
          Dbms_Sql.Define_Column(o_Cursor, i, v_p_Timestamp);
          o_Col_Types(i) := 'T';
      end case;
    
    end loop;
  
    v_Row_Processed := Dbms_Sql.Execute(o_Cursor);
    if false then
      o_Cursor := v_Row_Processed;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Query
  (
    i_Query  varchar2,
    i_Params Fazo_Schema.Hashmap,
    a        in out nocopy b_Table,
    i_Imgs   Matrix_Number := null
  ) is
    v_Cursor      pls_integer;
    v_Count       pls_integer;
    v_Col_Types   Fazo_Schema.Array_Varchar2;
    v_p_Varchar2  varchar2(4000);
    v_p_Number    number;
    v_p_Date      date;
    v_p_Array     Array_Varchar2;
    v_p_Timestamp timestamp;
    v_Img_Exists  boolean := i_Imgs is not null and i_Imgs.Count > 0;
    v_Row_Height  number;
  begin
    if v_Img_Exists then
      v_Row_Height := 0;
      for i in 1 .. i_Imgs.Count
      loop
        if not Fazo.Is_Empty(i_Imgs(i)) and i_Imgs(i) (2) > v_Row_Height then
          v_Row_Height := i_Imgs(i) (2);
        end if;
      end loop;
    end if;
  
    Prepare_Cursor(i_Query     => i_Query,
                   i_Params    => i_Params,
                   o_Cursor    => v_Cursor,
                   o_Count     => v_Count,
                   o_Col_Types => v_Col_Types);
  
    loop
    
      if Dbms_Sql.Fetch_Rows(v_Cursor) = 0 then
        exit;
      end if;
    
      if v_Row_Height > 0 then
        a.New_Row(v_Row_Height);
      else
        a.New_Row;
      end if;
    
      for i in 1 .. v_Count
      loop
        case v_Col_Types(i)
        
          when 'V' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Varchar2);
            if v_Img_Exists and not Fazo.Is_Empty(i_Imgs(i)) then
              a.Image(i_Sha    => v_p_Varchar2, --
                      i_Width  => i_Imgs(i) (1),
                      i_Height => i_Imgs(i) (2));
            else
              a.Data(v_p_Varchar2);
            end if;
          
          when 'N' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Number);
            a.Data(v_p_Number, 'body right');
          
          when 'D' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Date);
            a.Data(v_p_Date, 'body center');
          
          when 'A' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Array);
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
          
            a.Data(v_p_Varchar2);
          
          when 'T' then
            Dbms_Sql.Column_Value(v_Cursor, i, v_p_Timestamp);
            a.Data(cast(v_p_Timestamp as date), 'body center');
          
        end case;
      
      end loop;
    end loop;
  
    Dbms_Sql.Close_Cursor(v_Cursor);
  exception
    when others then
      if Dbms_Sql.Is_Open(v_Cursor) then
        Dbms_Sql.Close_Cursor(v_Cursor);
      end if;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Export
  (
    i_Query  Fazo_Query,
    i_Params Hashmap
  ) is
    v_Labels    Array_Varchar2 := i_Params.r_Array_Varchar2('label');
    v_Sizes     Array_Number := i_Params.r_Array_Number('size');
    v_Imgs      Array_Varchar2 := i_Params.r_Array_Varchar2('img');
    v_Img_Sizes Matrix_Number := Matrix_Number();
    v_Query     varchar2(32767);
    v_Params    Hashmap;
    a           b_Table;
  begin
    v_Img_Sizes.Extend(v_Imgs.Count);
  
    for i in 1 .. v_Imgs.Count
    loop
      continue when v_Imgs(i) is null;
    
      v_Img_Sizes(i) := Fazo.To_Array_Number(Fazo.Split(v_Imgs(i), ';'));
    end loop;
  
    Build_Query(i_Query  => i_Query,
                i_Column => i_Params.r_Array_Varchar2('column'),
                i_Filter => i_Params.o_Arraylist('filter'),
                i_Sort   => i_Params.o_Array_Varchar2('sort'),
                o_Query  => v_Query,
                o_Params => v_Params);
  
    b_Report.Open_Book_With_Styles(i_Params.o_Varchar2('rt'));
  
    a := b_Report.New_Table;
  
    a.New_Row;
  
    a.Current_Style('header');
  
    for i in 1 .. v_Labels.Count
    loop
      if not Fazo.Is_Empty(v_Img_Sizes(i)) then
        a.Column_Width(i, v_Img_Sizes(i) (1));
      else
        a.Column_Width(i, Round(v_Sizes(i) * 70));
      end if;
    
      a.Data(v_Labels(i));
    end loop;
  
    a.Current_Style('body');
    Execute_Query(i_Query  => v_Query, --
                  i_Params => v_Params,
                  a        => a,
                  i_Imgs   => v_Img_Sizes);
  
    b_Report.Add_Sheet('Sheet', a);
    b_Report.Close_Book;
  end;

end Biruni_Grid;
/
