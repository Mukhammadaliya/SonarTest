create or replace package Fazo_Schema.Fazo_z authid current_user is

  ----------------------------------------------------------------------------------------------------
  Function Count_Table_Records(i_Table_Name varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Clob(i_Query clob);
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Stream(i_Query Fazo_Schema.Stream);
  ----------------------------------------------------------------------------------------------------
  Function Serial_Table(i_Table_Name varchar2) return Fazo_Schema.Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Serial_All(Request Fazo_Schema.Hashmap := null) return Fazo_Schema.Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Table_Sha1(i_Table_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Is_Correct_Table_Checksum
  (
    i_Table_Name varchar2,
    i_Checksum   varchar2
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Procedure Run(i_Table_Prefix varchar2 := null);
  ----------------------------------------------------------------------------------------------------
  Procedure Run_Force
  (
    i_Table_Prefix varchar2 := null,
    i_With_Dml     boolean := true
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Compile_Invalid_Objects;
  ----------------------------------------------------------------------------------------------------
  Procedure Drop_Object_If_Exists(i_Object_Name varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Wrap_Package(i_Package_Name varchar2);

end Fazo_z;
/
create or replace package body Fazo_Schema.Fazo_z is
  ----------------------------------------------------------------------------------------------------
  g_Not_Updated_Column_Names Array_Varchar2 := Array_Varchar2();
  ----------------------------------------------------------------------------------------------------
  g_Def_Column_Names Array_Varchar2 := Array_Varchar2();
  ----------------------------------------------------------------------------------------------------
  g_Def_Column_Values Array_Varchar2 := Array_Varchar2();
  ----------------------------------------------------------------------------------------------------
  g_r_Constraint_Indexs Fazo.Number_Code_Aat;
  g_r_Constraints       Matrix_Varchar2;
  g_z_By_Wrapper        boolean := false;
  g_Zt_By_Wrapper       boolean := false;
  ----------------------------------------------------------------------------------------------------
  type Column_Rt is record(
    name         varchar2(128),
    Virtual      varchar2(3),
    Data_Type    varchar2(130),
    Data_Type2   varchar2(30),
    Data_Size    number,
    Data_Scale   number,
    Nullable     varchar2(3),
    Char_Used    varchar2(1),
    Data_Default varchar2(4000));
  ----------------------------------------------------------------------------------------------------
  type Column_Nt is table of Column_Rt;
  ----------------------------------------------------------------------------------------------------
  type Constraint_Rt is record(
    name                varchar2(128),
    Constraint_Type     varchar2(1),
    Enabled             varchar2(1),
    Deferrable          varchar2(1),
    Deferred            varchar2(1),
    Validated           varchar2(1),
    Generated           varchar2(1),
    Ref_Constraint_Name varchar2(128),
    Ref_Table_Name      varchar2(128),
    Ref_Column_Names    Array_Varchar2,
    Delete_Rule         varchar2(30),
    Search_Condition    varchar2(4000),
    Index_Name          varchar2(128),
    Column_Names        Array_Varchar2,
    Child_Constraints   Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  type Constraint_Nt is table of Constraint_Rt;
  ----------------------------------------------------------------------------------------------------
  type Index_Rt is record(
    name         varchar2(128),
    Index_Type   varchar2(30),
    Uniqueness   varchar2(9),
    Tablespace   varchar2(30),
    Generated    varchar2(1),
    Column_Names Array_Varchar2,
    Expr         Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  type Index_Nt is table of Index_Rt;
  ----------------------------------------------------------------------------------------------------
  type Table_Rt is record(
    name                 varchar2(128),
    Tablespace           varchar2(30),
    Column_List          Column_Nt,
    Constraint_List      Constraint_Nt,
    Index_List           Index_Nt,
    Real_Column_List     Column_Nt,
    Update_Column_List   Column_Nt,
    Standart_Column_List Column_Nt);

  ----------------------------------------------------------------------------------------------------
  type Context_Rt is record(
    out          Stream,
    Errors       Array_Varchar2,
    Tbl          Table_Rt,
    Package_Name varchar2(128),
    Is_Body      boolean,
    With_Dml     boolean);

  ----------------------------------------------------------------------------------------------------
  Function Count_Table_Records(i_Table_Name varchar2) return number is
    result number;
  begin
    execute immediate 'DECLARE s number; BEGIN SELECT count(*) into s FROM ' || i_Table_Name ||
                      ';:a:=s;END;'
      using out result;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Error(i_Message varchar2) is
  begin
    Raise_Application_Error(-20999, i_Message);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Fix_Hidden_Columns
  (
    i_Table_Name   varchar2,
    i_Column_Names Array_Varchar2
  ) return Array_Varchar2 is
    v_Data_Default varchar2(32767);
    v_Temp         Array_Varchar2;
    result         Array_Varchar2 := Array_Varchar2();
  begin
    for i in 1 .. i_Column_Names.Count
    loop
      begin
      
        select t.Data_Default
          into v_Data_Default
          from User_Tab_Cols t
         where t.Table_Name = i_Table_Name
           and t.Column_Name = i_Column_Names(i)
           and t.Hidden_Column = 'YES';
      
        select t.Column_Name
          bulk collect
          into v_Temp
          from User_Tab_Columns t
         where t.Table_Name = i_Table_Name
           and v_Data_Default like '%"' || t.Column_Name || '"%'
         order by t.Column_Name;
      
        result := result multiset union v_Temp;
      exception
        when No_Data_Found then
          Result.Extend;
          result(Result.Count) := i_Column_Names(i);
      end;
    
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Indexes(i_Table_Name varchar2) return Index_Nt is
    v_Expr    Array_Varchar2;
    v_Descend varchar2(10);
    result    Index_Nt;
  begin
  
    select t.Index_Name,
           t.Index_Type,
           t.Uniqueness,
           t.Tablespace_Name,
           t.Generated,
           (select cast(collect(c.Column_Name order by c.Column_Position) as
                        Fazo_Schema.Array_Varchar2)
              from User_Ind_Columns c
             where c.Index_Name = t.Index_Name) Column_Names,
           cast(null as Fazo_Schema.Array_Varchar2)
      bulk collect
      into result
      from User_Indexes t
     where t.Table_Name = i_Table_Name;
  
    for i in 1 .. Result.Count
    loop
      result(i).Column_Names := Fix_Hidden_Columns(i_Table_Name, result(i).Column_Names);
    
      v_Expr := Array_Varchar2();
      for r in (select c.Column_Name, c.Data_Default, c.Hidden_Column, t.Descend
                  from User_Tab_Cols c
                  join User_Ind_Columns t
                    on (c.Table_Name = t.Table_Name and c.Column_Name = t.Column_Name)
                 where t.Index_Name = result(i).Name
                 order by t.Column_Position)
      loop
        v_Expr.Extend;
      
        if r.Descend = 'ASC' then
          v_Descend := '';
        else
          v_Descend := ' ' || r.Descend;
        end if;
      
        if r.Hidden_Column = 'YES' then
          v_Expr(v_Expr.Count) := r.Data_Default || v_Descend;
        else
          v_Expr(v_Expr.Count) := r.Column_Name || v_Descend;
        end if;
      end loop;
    
      result(i).Expr := v_Expr;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Constraints(i_Table_Name varchar2) return Constraint_Nt is
    result Constraint_Nt;
  begin
  
    select t.Constraint_Name,
           t.Constraint_Type,
           Decode(t.Status, 'ENABLED', 'Y', 'N') Enabled,
           Decode(t.Deferrable, 'DEFERRABLE', 'Y', 'N') Deferrable,
           Decode(t.Deferred, 'DEFERRED', 'Y', 'N') Deferred,
           Decode(t.Validated, 'VALIDATED', 'Y', 'N') Validated,
           Decode(t.Generated, 'GENERATED NAME', 'Y', 'N') Generated,
           t.r_Constraint_Name,
           (select w.Table_Name
              from User_Constraints w
             where w.Constraint_Name = t.r_Constraint_Name) r_Table_Name,
           (select cast(collect(Rc.Column_Name order by Rc.Position) as Fazo_Schema.Array_Varchar2)
              from User_Cons_Columns Rc
             where Rc.Constraint_Name = t.r_Constraint_Name) r_Field_Names,
           t.Delete_Rule,
           t.Search_Condition,
           t.Index_Name,
           (select cast(collect(Column_Name order by c.Position) as Fazo_Schema.Array_Varchar2)
              from User_Cons_Columns c
             where c.Constraint_Name = t.Constraint_Name) Field_Names,
           cast(null as Array_Varchar2) Child_Constraints
      bulk collect
      into result
      from User_Constraints t
     where t.Table_Name = i_Table_Name;
  
    for i in 1 .. Result.Count
    loop
      if g_r_Constraint_Indexs.Exists(result(i).Name) then
        result(i).Child_Constraints := g_r_Constraints(g_r_Constraint_Indexs(result(i).Name));
      else
        result(i).Child_Constraints := Array_Varchar2();
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Columns(i_Table_Name varchar2) return Column_Nt is
    r_Column Column_Rt;
    result   Column_Nt := Column_Nt();
  begin
  
    for r in (select *
                from User_Tab_Cols t
               where t.Table_Name = i_Table_Name
                 and t.Hidden_Column = 'NO'
               order by t.Column_Id)
    loop
      r_Column         := null;
      r_Column.Name    := r.Column_Name;
      r_Column.Virtual := r.Virtual_Column;
    
      r_Column.Data_Type := r.Data_Type;
    
      case r.Data_Type
        when 'VARCHAR2' then
          r_Column.Data_Size  := r.Char_Length;
          r_Column.Data_Type2 := 'VARCHAR2';
        when 'NUMBER' then
          r_Column.Data_Size  := r.Data_Precision;
          r_Column.Data_Scale := r.Data_Scale;
          r_Column.Data_Type2 := 'NUMBER';
        when 'DATE' then
          r_Column.Data_Type2 := 'DATE';
        when 'CLOB' then
          r_Column.Data_Type2 := 'VARCHAR2';
        else
          if r.Data_Type like 'TIMESTAMP%' then
            r_Column.Data_Type2 := 'TIMESTAMP';
          else
            null;
          end if;
      end case;
    
      r_Column.Nullable     := r.Nullable;
      r_Column.Char_Used    := r.Char_Used;
      r_Column.Data_Default := r.Data_Default;
    
      Result.Extend;
      result(Result.Count) := r_Column;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Extract_Column_Names(i_Columns Column_Nt) return Array_Varchar2 is
    result Array_Varchar2 := Array_Varchar2();
  begin
    for i in 1 .. i_Columns.Count
    loop
      Result.Extend;
      result(Result.Count) := i_Columns(i).Name;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Non_Standard_Column_Names(i_Columns Column_Nt) return Array_Varchar2 is
    result Array_Varchar2 := Array_Varchar2();
  begin
    for i in 1 .. i_Columns.Count
    loop
      continue when i_Columns(i).Data_Type2 in('VARCHAR2', 'NUMBER', 'DATE', 'TIMESTAMP');
      Fazo.Push(result, i_Columns(i).Name);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Except_Columns
  (
    i_Columns             Column_Nt,
    i_Except_Column_Names Array_Varchar2
  ) return Column_Nt is
    result Column_Nt := Column_Nt();
  begin
  
    for i in 1 .. i_Columns.Count
    loop
      if not i_Columns(i).Name member of i_Except_Column_Names then
        Result.Extend;
        result(Result.Count) := i_Columns(i);
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Except_Non_Standard_Columns(i_Columns Column_Nt) return Column_Nt is
  begin
    return Except_Columns(i_Columns, Non_Standard_Column_Names(i_Columns));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Filter_Real_Columns(i_Column_List Column_Nt) return Column_Nt is
    result Column_Nt := Column_Nt();
  begin
  
    for i in 1 .. i_Column_List.Count
    loop
      if i_Column_List(i).Virtual = 'NO' then
        Result.Extend;
        result(Result.Count) := i_Column_List(i);
      end if;
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Filter_Update_Columns
  (
    i_Column_List     Column_Nt,
    i_Constraint_List Constraint_Nt
  ) return Column_Nt is
    v_Except_Column_Names Array_Varchar2;
  begin
    v_Except_Column_Names := Non_Standard_Column_Names(i_Column_List);
  
    for i in 1 .. i_Constraint_List.Count
    loop
      if i_Constraint_List(i).Constraint_Type = 'P' then
        v_Except_Column_Names := v_Except_Column_Names multiset union i_Constraint_List(i).Column_Names;
        exit;
      end if;
    end loop;
  
    return Except_Columns(i_Column_List, v_Except_Column_Names);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Table(i_Table_Name varchar2) return Table_Rt is
    v_Table_Name varchar2(128) := Upper(trim(i_Table_Name));
    v_Tablespace varchar2(30);
    r_Table      Table_Rt;
  begin
    select t.Tablespace_Name
      into v_Tablespace
      from User_Tables t
     where t.Table_Name = v_Table_Name;
  
    r_Table.Name       := v_Table_Name;
    r_Table.Tablespace := v_Tablespace;
  
    r_Table.Column_List     := Load_Columns(v_Table_Name);
    r_Table.Constraint_List := Load_Constraints(v_Table_Name);
    r_Table.Index_List      := Load_Indexes(v_Table_Name);
  
    r_Table.Real_Column_List     := Filter_Real_Columns(r_Table.Column_List);
    r_Table.Update_Column_List   := Except_Columns(Filter_Update_Columns(r_Table.Real_Column_List,
                                                                         r_Table.Constraint_List),
                                                   g_Not_Updated_Column_Names);
    r_Table.Standart_Column_List := Except_Columns(r_Table.Update_Column_List, g_Def_Column_Names);
    return r_Table;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Indexes(i_Indexes Index_Nt) return Arraylist is
    r_Index Index_Rt;
    v_Index Hashmap;
    result  Arraylist := Arraylist();
  begin
  
    for i in 1 .. i_Indexes.Count
    loop
      r_Index := i_Indexes(i);
      v_Index := Hashmap();
    
      if r_Index.Generated = 'N' then
        v_Index.Put('name', r_Index.Name);
      else
        v_Index.Put('name', '');
      end if;
      v_Index.Put('index_type', r_Index.Index_Type);
      v_Index.Put('uniqueness', r_Index.Uniqueness);
      v_Index.Put('tablespace', r_Index.Tablespace);
      v_Index.Put('generated', r_Index.Generated);
      v_Index.Put('column_names', r_Index.Column_Names);
      v_Index.Put('expr', r_Index.Expr);
    
      Result.Push(v_Index);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Constraints(i_Constraints Constraint_Nt) return Arraylist is
    r_Key  Constraint_Rt;
    v_Key  Hashmap;
    result Arraylist := Arraylist();
  begin
  
    for i in 1 .. i_Constraints.Count
    loop
      r_Key := i_Constraints(i);
      v_Key := Hashmap();
    
      if r_Key.Generated = 'N' then
        v_Key.Put('name', r_Key.Name);
      else
        v_Key.Put('name', '');
      end if;
      v_Key.Put('type', r_Key.Constraint_Type);
      v_Key.Put('enabled', r_Key.Enabled);
      v_Key.Put('deferrable', r_Key.Deferrable);
      v_Key.Put('deferred', r_Key.Deferred);
      v_Key.Put('validated', r_Key.Validated);
      v_Key.Put('generated', r_Key.Generated);
      v_Key.Put('ref_constraint', r_Key.Ref_Constraint_Name);
      v_Key.Put('ref_table', r_Key.Ref_Table_Name);
      v_Key.Put('ref_column_names', r_Key.Ref_Column_Names);
      v_Key.Put('delete_rule', r_Key.Delete_Rule);
      v_Key.Put('search_condition', r_Key.Search_Condition);
      v_Key.Put('index_name', r_Key.Index_Name);
      v_Key.Put('column_names', r_Key.Column_Names);
      v_Key.Put('child_constraints', r_Key.Child_Constraints);
    
      Result.Push(v_Key);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Columns(i_Columns Column_Nt) return Arraylist is
    r_Column Column_Rt;
    v_Column Hashmap;
    result   Arraylist := Arraylist();
  begin
  
    for i in 1 .. i_Columns.Count
    loop
      r_Column := i_Columns(i);
      v_Column := Hashmap();
    
      v_Column.Put('name', r_Column.Name);
      v_Column.Put('virtual', r_Column.Virtual);
      v_Column.Put('data_type', r_Column.Data_Type);
      v_Column.Put('data_size', r_Column.Data_Size);
      v_Column.Put('data_scale', r_Column.Data_Scale);
      v_Column.Put('nullable', r_Column.Nullable);
      v_Column.Put('char_used', r_Column.Char_Used);
      v_Column.Put('data_default', trim(r_Column.Data_Default));
    
      Result.Push(v_Column);
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Table(i_Table Table_Rt) return Fazo_Schema.Hashmap is
    v_Table Hashmap := Hashmap();
  begin
    v_Table.Put('fv', '2017-03-16');
    v_Table.Put('name', i_Table.Name);
    v_Table.Put('tablespace', i_Table.Tablespace);
    v_Table.Put('columns', Serial_Columns(i_Table.Column_List));
    v_Table.Put('constraints', Serial_Constraints(i_Table.Constraint_List));
    v_Table.Put('indexes', Serial_Indexes(i_Table.Index_List));
    return v_Table;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Table(i_Table_Name varchar2) return Fazo_Schema.Hashmap is
  begin
    return Serial_Table(Load_Table(i_Table_Name));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_User_Objects(i_Object_Type varchar2) return Array_Varchar2 is
    result Array_Varchar2;
  begin
    select t.Object_Name
      bulk collect
      into result
      from User_Objects t
     where t.Object_Type = i_Object_Type
       and Object_Name not like 'Z\_%' escape '\';
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_All(Request Fazo_Schema.Hashmap := null) return Fazo_Schema.Hashmap is
    result        Hashmap := Hashmap();
    v_Tables      Arraylist := Arraylist();
    v_Table_Names Array_Varchar2;
  begin
    -- just hack not to warn
    if false then
      result := Request;
    end if;
  
    select t.Table_Name
      bulk collect
      into v_Table_Names
      from User_Tables t
     where t.Table_Name not like 'X\_%' escape '\'
     order by t.Table_Name;
  
    for i in 1 .. v_Table_Names.Count
    loop
      Dbms_Application_Info.Set_Module('FAZO SERIAL TABLE',
                                       i || '/' || v_Table_Names.Count || ' ' || v_Table_Names(i));
      v_Tables.Push(Fazo_Schema.Gws_Json_Value(Serial_Table(v_Table_Names(i))));
    end loop;
  
    Dbms_Application_Info.Set_Module('FAZO SERIAL TABLE', 'OTHER OBJECTS');
    Result.Put('tables', v_Tables);
    Result.Put('sequences', Load_User_Objects('SEQUENCE'));
    Result.Put('packages', Load_User_Objects('PACKAGE'));
    Result.Put('package_bodies', Load_User_Objects('PACKAGE BODY'));
    Result.Put('procedures', Load_User_Objects('PROCEDURE'));
    Result.Put('functions', Load_User_Objects('FUNCTION'));
    Result.Put('views', Load_User_Objects('VIEW'));
  
    Dbms_Application_Info.Set_Module('FAZO SERIAL TABLE', 'FINISH');
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Clob(i_Query clob) is
    v_Dynsql pls_integer;
    v_Ignore pls_integer;
  begin
  
    v_Dynsql := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(c => v_Dynsql, statement => i_Query, Language_Flag => Dbms_Sql.Native);
    v_Ignore := Dbms_Sql.Execute(c => v_Dynsql);
    Dbms_Sql.Close_Cursor(c => v_Dynsql);
  
    v_Dynsql := v_Ignore; -- hack not to warning
  
  exception
    when others then
      if Dbms_Sql.Is_Open(c => v_Dynsql) then
        Dbms_Sql.Close_Cursor(c => v_Dynsql);
      end if;
      Dbms_Output.Put_Line('execute_clob: ' || sqlerrm);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Stream(i_Query Fazo_Schema.Stream) is
  begin
    Execute_Clob(i_Query.Get_Clob);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Zmake_Message_Procedure is
    Writer Stream := Stream();
  begin
    Writer.Println('create function zmake_message(');
    Writer.Println('i_message varchar2,');
    Writer.Println('i_params array_varchar2');
    Writer.Println(') return varchar2 is begin');
    Writer.Println('return fazo.mk_message(i_message, i_params);');
    Writer.Println('end;');
  
    begin
      Execute_Stream(Writer);
    exception
      when others then
        null;
    end;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Column_Names return Array_Varchar2 is
    result Array_Varchar2;
  begin
    select distinct t.Column_Name
      bulk collect
      into result
      from User_Tab_Columns t
     where exists (select *
              from User_Tables k
             where k.Temporary = 'N'
               and k.Table_Name = t.Table_Name)
     order by t.Column_Name;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Table_Names return Array_Varchar2 is
    result Array_Varchar2;
  begin
    select t.Table_Name
      bulk collect
      into result
      from User_Tables t
     order by t.Table_Name;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Zt_Table_Names return Array_Varchar2 is
    v_All_Table_Names Array_Varchar2;
    v_Zt_Table_Names  Array_Varchar2;
  begin
    v_All_Table_Names := Get_Table_Names;
    v_Zt_Table_Names  := Array_Varchar2();
  
    for i in 1 .. v_All_Table_Names.Count
    loop
      -- ignore x_ tables
      if not Regexp_Like(v_All_Table_Names(i), '^(?[Xx]_)[a-zA-Z_][a-zA-Z0-9_]*$') and
         not Regexp_Like(v_All_Table_Names(i), '^(UI_)[a-zA-Z_][a-zA-Z0-9_]*$') then
        Fazo.Push(v_Zt_Table_Names, v_All_Table_Names(i));
      end if;
    end loop;
  
    return v_Zt_Table_Names;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Names_Sha1(i_Names Array_Varchar2) return varchar2 is
    Writer Stream := Stream();
  begin
    for i in 1 .. i_Names.Count
    loop
      Writer.Println(i_Names(i));
    end loop;
    return Fazo.Hash_Sha1(Writer.Get_Clob());
  end;

  ----------------------------------------------------------------------------------------------------
  Function Table_Sha1(i_Table Table_Rt) return varchar2 is
    v_Serial Stream;
  begin
    v_Serial := Stream();
    Serial_Table(i_Table).Print_Json(v_Serial);
    return Fazo_Schema.Fazo.Hash_Sha1(v_Serial.Get_Clob());
  end;

  ----------------------------------------------------------------------------------------------------
  Function Table_Sha1(i_Table_Name varchar2) return varchar2 is
  begin
    return Table_Sha1(Load_Table(i_Table_Name));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Correct_Table_Checksum
  (
    i_Table_Name varchar2,
    i_Checksum   varchar2
  ) return boolean is
  begin
    return Fazo.Equal(Table_Sha1(Load_Table(i_Table_Name)), i_Checksum);
  exception
    when others then
      return false;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_z(Writer in out nocopy Stream) is
    v_Column_Names Array_Varchar2;
  begin
  
    v_Column_Names := Get_Column_Names;
  
    Writer.Println('CREATE OR REPLACE PACKAGE z IS');
  
    if g_z_By_Wrapper then
      for i in 1 .. v_Column_Names.Count
      loop
        Writer.Println(v_Column_Names(i) ||
                       ' CONSTANT fazo_schema.w_column_name:=fazo_schema.w_column_name(''' ||
                       v_Column_Names(i) || ''');');
      end loop;
    else
      for i in 1 .. v_Column_Names.Count
      loop
        Writer.Println(v_Column_Names(i) || ' CONSTANT varchar2(128):=''' || v_Column_Names(i) ||
                       ''';');
      end loop;
    end if;
  
    Writer.Println('c_column_names_sha1_checksum_x constant varchar2(40):=''' ||
                   Names_Sha1(v_Column_Names) || ''';');
  
    Writer.Println('END z;');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_z is
    Writer Stream;
  begin
    Dbms_Output.Put_Line('package Z');
    Writer := Stream();
    Gen_z(Writer);
    Execute_Stream(Writer);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Correct_z_Package return boolean is
    v_Cur_Sha1 varchar2(40);
    v_f_Sha1   varchar2(40);
  begin
    v_Cur_Sha1 := Names_Sha1(Get_Column_Names);
  
    begin
      execute immediate 'BEGIN :R:=z.c_column_names_sha1_checksum_x; END;'
        using out v_f_Sha1;
    exception
      when others then
        return false;
    end;
  
    return v_Cur_Sha1 = v_f_Sha1;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Zt(Writer in out nocopy Stream) is
    v_Zt_Table_Names Array_Varchar2;
  begin
    v_Zt_Table_Names := Get_Zt_Table_Names;
  
    Writer.Println('CREATE OR REPLACE PACKAGE zt IS');
  
    if g_Zt_By_Wrapper then
      for i in 1 .. v_Zt_Table_Names.Count
      loop
        Writer.Println(v_Zt_Table_Names(i) ||
                       ' CONSTANT fazo_schema.w_table_name:=fazo_schema.w_table_name(''' ||
                       v_Zt_Table_Names(i) || ''');');
      end loop;
    else
      for i in 1 .. v_Zt_Table_Names.Count
      loop
        Writer.Println(v_Zt_Table_Names(i) || ' CONSTANT varchar2(128):= ''' ||
                       v_Zt_Table_Names(i) || ''';');
      end loop;
    end if;
    Writer.Println('c_table_names_sha1_checksum_x constant varchar2(40):=''' ||
                   Names_Sha1(v_Zt_Table_Names) || ''';');
  
    Writer.Println('END zt;');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Zt is
    Writer Stream;
  begin
    Dbms_Output.Put_Line('package Zt');
    Writer := Stream();
    Gen_Zt(Writer);
    Execute_Stream(Writer);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Correct_Zt_Package return boolean is
    v_Cur_Sha1 varchar2(40);
    v_f_Sha1   varchar2(40);
  begin
    v_Cur_Sha1 := Names_Sha1(Get_Zt_Table_Names);
  
    begin
      execute immediate 'BEGIN :R:=zt.c_table_names_sha1_checksum_x; END;'
        using out v_f_Sha1;
    exception
      when others then
        return false;
    end;
  
    return v_Cur_Sha1 = v_f_Sha1;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Find_Column
  (
    i_Table       Table_Rt,
    i_Column_Name varchar2
  ) return Column_Rt is
  begin
    for i in 1 .. i_Table.Column_List.Count
    loop
      if i_Table.Column_List(i).Name = i_Column_Name then
        return i_Table.Column_List(i);
      end if;
    end loop;
    raise No_Data_Found;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Find_Columns
  (
    i_Table        Table_Rt,
    i_Column_Names Array_Varchar2
  ) return Column_Nt is
    result Column_Nt := Column_Nt();
  begin
  
    for i in 1 .. i_Column_Names.Count
    loop
      Result.Extend;
      result(Result.Count) := Find_Column(i_Table, i_Column_Names(i));
    end loop;
  
    return result;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mapped_Error_Message
  (
    Io_Error_Messages in out nocopy Array_Varchar2,
    i_Message         varchar2
  ) return varchar2 is
  begin
    for i in 1 .. Io_Error_Messages.Count
    loop
      if Io_Error_Messages(i) = i_Message then
        return 'c_error(' || i || ')';
      end if;
    end loop;
  
    Io_Error_Messages.Extend;
    Io_Error_Messages(Io_Error_Messages.Count) := i_Message;
    return 'c_error(' || Io_Error_Messages.Count || ')';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Column
  (
    i_Columns     Column_Nt,
    i_Item        varchar2,
    i_Infix       varchar2 := null,
    i_Prefix      varchar2 := null,
    i_Suffix      varchar2 := null,
    i_Raise_Error boolean := false
  ) return varchar2 is
    r_Col   Column_Rt;
    v       varchar2(32767);
    r       varchar2(32767) := i_Prefix;
    v_Infix varchar2(100) := i_Infix || Chr(10);
    v_To    varchar2(32767);
  begin
  
    for i in 1 .. i_Columns.Count
    loop
      r_Col := i_Columns(i);
    
      v_To := '\1' || r_Col.Name;
    
      v := Regexp_Replace(i_Item, '[$]([A-Za-z0-9_.]*)name', v_To);
    
      if i_Raise_Error then
        if r_Col.Data_Type = 'DATE' then
          v := 'case ' || v || ' when trunc(' || v || ') then  to_char(' || v ||
               ', ''dd.mm.yyyy'') else to_char(' || v || ', ''dd.mm.yyyy hh24:mi:ss'') end';
        end if;
      end if;
    
      for k in 1 .. g_Def_Column_Names.Count
      loop
        if r_Col.Name = g_Def_Column_Names(k) then
          v_To := g_Def_Column_Values(k);
        end if;
      end loop;
    
      v := Regexp_Replace(v, '[$][@]([A-Za-z0-9_.]*)name', v_To);
    
      v_To := '\1' || r_Col.Name;
    
      if r_Col.Data_Type2 = 'TIMESTAMP' then
        v_To := 'to_timestamp(' || v_To || ')';
      end if;
    
      v := Regexp_Replace(v, '[$][#]([A-Za-z0-9_.]*)name', v_To);
    
      v := replace(v, '$type', r_Col.Data_Type2);
    
      if r_Col.Nullable = 'Y' then
        v := replace(v, '$null', ':=NULL');
      else
        v := replace(v, '$null', '');
      end if;
    
      r := r || v;
    
      if i <> i_Columns.Count then
        r := r || v_Infix;
      end if;
    end loop;
  
    return r || i_Suffix;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Column
  (
    i_Table        Table_Rt,
    i_Column_Names Array_Varchar2,
    i_Item         varchar2,
    i_Infix        varchar2 := null,
    i_Prefix       varchar2 := null,
    i_Suffix       varchar2 := null
  ) return varchar2 is
  begin
    return Mk_Column(i_Columns => Find_Columns(i_Table, i_Column_Names),
                     i_Item    => i_Item,
                     i_Infix   => i_Infix,
                     i_Prefix  => i_Prefix,
                     i_Suffix  => i_Suffix);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Check_Date
  (
    Io_Error_Messages in out nocopy Array_Varchar2,
    i_Table           Table_Rt,
    i_Prefix          varchar2
  ) return varchar2 is
    v_Columns Column_Nt;
    r_Column  Column_Rt;
    r         varchar2(32767);
  begin
    v_Columns := Except_Columns(i_Table.Real_Column_List, g_Def_Column_Names);
  
    for i in 1 .. v_Columns.Count
    loop
      r_Column := v_Columns(i);
      if r_Column.Data_Type2 in ('DATE', 'TIMESTAMP') then
        r := r || 'check_date(' || i_Prefix || r_Column.Name || ',';
        r := r ||
             Mapped_Error_Message(Io_Error_Messages,
                                  i_Table.Name || ' NOT IN 1900-2100 ' || r_Column.Name || '=$1');
        r := r || ');' || Chr(10);
      end if;
    end loop;
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Raise_Error
  (
    Io_Error_Messages in out nocopy Array_Varchar2,
    i_Message         varchar2,
    i_Table_Name      varchar2,
    i_Columns         Column_Nt,
    i_Prefix          varchar2
  ) return varchar2 is
    r varchar2(4000);
  begin
    r := i_Table_Name || ' ' || i_Message;
    for i in 1 .. i_Columns.Count
    loop
      r := r || ' ' || i_Columns(i).Name || '=$' || i;
    end loop;
  
    r := 'raise_application_error(-20999, zmake_message(' --
         || Mapped_Error_Message(Io_Error_Messages, r) || ',';
  
    if i_Columns.Count > 0 then
      r := r || Mk_Column(i_Columns     => i_Columns,
                          i_Prefix      => 'array_varchar2(',
                          i_Item        => '$' || i_Prefix || 'name',
                          i_Infix       => ',',
                          i_Suffix      => ')',
                          i_Raise_Error => true);
    else
      r := r || 'null';
    end if;
  
    r := r || '));';
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Insert_Clause
  (
    i_Table  Table_Rt,
    i_Prefix varchar2
  ) return varchar2 is
    r varchar2(32767);
  begin
  
    r := Mk_Column(i_Columns => i_Table.Real_Column_List,
                   i_Prefix  => 'INSERT INTO ' || i_Table.Name || '(',
                   i_Item    => '$name',
                   i_Infix   => ',',
                   i_Suffix  => ')');
  
    r := r || Mk_Column(i_Columns => i_Table.Real_Column_List,
                        i_Prefix  => ' VALUES(',
                        i_Item    => '$@' || i_Prefix || 'name',
                        i_Infix   => ',',
                        i_Suffix  => ');');
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Update_Clause
  (
    i_Table         Table_Rt,
    i_Prefix        varchar2,
    i_Where_Columns Column_Nt
  ) return varchar2 is
    r varchar2(32767);
  begin
  
    r := Mk_Column(i_Columns => i_Table.Update_Column_List,
                   i_Prefix  => 'UPDATE ' || i_Table.Name || ' t SET ',
                   i_Item    => '$t.name=$@' || i_Prefix || 'name',
                   i_Infix   => ',');
  
    r := r || Mk_Column(i_Columns => i_Where_Columns,
                        i_Prefix  => ' WHERE ',
                        i_Item    => '$t.name=$' || i_Prefix || 'name',
                        i_Infix   => ' AND ',
                        i_Suffix  => ';');
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Load_Function
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION load(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN ' || Ctx.Tbl.Name || '%ROWTYPE'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS r ' || Ctx.Tbl.Name || '%ROWTYPE;BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT * INTO r FROM ' || Ctx.Tbl.Name || ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ';'));
    
      Ctx.Out.Println('RETURN r;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN');
      Ctx.Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'NO_DATA_FOUND',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => i_Columns,
                                     i_Prefix          => 'i_'));
    
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Take_Function
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION take(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN ' || Ctx.Tbl.Name || '%ROWTYPE'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS r ' || Ctx.Tbl.Name || '%ROWTYPE;BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT * INTO r FROM ' || Ctx.Tbl.Name || ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ';'));
    
      Ctx.Out.Println('RETURN r;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL; END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Lock_Load_Function
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION lock_load(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN ' || Ctx.Tbl.Name || '%ROWTYPE'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS r ' || Ctx.Tbl.Name || '%ROWTYPE;BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT * INTO r FROM ' || Ctx.Tbl.Name || ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ' FOR UPDATE;'));
    
      Ctx.Out.Println('RETURN r;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN');
      Ctx.Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'NO_DATA_FOUND',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => i_Columns,
                                     i_Prefix          => 'i_'));
    
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Lock_Load_Function2
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION lock_load(p hashmap,',
                              i_Item    => '$i_name varchar2:=null',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN ' || Ctx.Tbl.Name || '%ROWTYPE'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS r ' || Ctx.Tbl.Name || '%ROWTYPE;BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Item    => '$r.name:=p.r_$type(nvl($i_name,''$name''));'));
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT * INTO r FROM ' || Ctx.Tbl.Name || ' t WHERE ',
                                i_Item    => '$t.name=$r.name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ' FOR UPDATE;'));
    
      Ctx.Out.Println('RETURN r;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN');
      Ctx.Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'NO_DATA_FOUND',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => i_Columns,
                                     i_Prefix          => 'i_'));
    
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Lock_Only_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'PROCEDURE lock_only(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS x varchar2(1);BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT ''x'' INTO x FROM ' || Ctx.Tbl.Name ||
                                             ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ' FOR UPDATE;'));
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN');
      Ctx.Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'NO_DATA_FOUND',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => i_Columns,
                                     i_Prefix          => 'i_'));
    
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Exist_Function
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION exist(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN BOOLEAN'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS x number;BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT 1 INTO x FROM ' || Ctx.Tbl.Name || ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ';'));
    
      Ctx.Out.Println('RETURN TRUE;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;');
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Exist_Function2
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION exist(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ',o_row IN OUT NOCOPY ' || Ctx.Tbl.Name ||
                                           '%ROWTYPE) RETURN BOOLEAN'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT * INTO o_row FROM ' || Ctx.Tbl.Name ||
                                             ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ';'));
    
      Ctx.Out.Println('RETURN TRUE;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;');
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Exist_Lock_Function
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION exist_lock(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN BOOLEAN'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS x number;BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT 1 INTO x FROM ' || Ctx.Tbl.Name || ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ' FOR UPDATE;'));
    
      Ctx.Out.Println('RETURN TRUE;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;');
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Exist_Lock_Function2
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'FUNCTION exist_lock(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ',o_row IN OUT NOCOPY ' || Ctx.Tbl.Name ||
                                           '%ROWTYPE) RETURN BOOLEAN'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'SELECT * INTO o_row FROM ' || Ctx.Tbl.Name ||
                                             ' t WHERE ',
                                i_Item    => '$t.name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ' FOR UPDATE;'));
    
      Ctx.Out.Println('RETURN TRUE;');
    
      Ctx.Out.Println('EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;');
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Update_One_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
    if Ctx.Tbl.Standart_Column_List.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'PROCEDURE update_one(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ','));
  
    Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Standart_Column_List,
                              i_Prefix  => ',',
                              i_Item    => '$i_name option_$type:=null',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS r_row ' || Ctx.Tbl.Name || '%ROWTYPE; BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'r_row:=lock_load(',
                                i_Item    => '$i_name=>$i_name',
                                i_Infix   => ',',
                                i_Suffix  => ');'));
    
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Standart_Column_List,
                                i_Item    => 'IF $i_name IS NOT NULL THEN $r_row.name:=$i_name.val;END IF;'));
    
      Ctx.Out.Println('update_row(r_row);END');
    end if;
  
    Ctx.Out.Println(';');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Update_Row_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
    if Ctx.Tbl.Standart_Column_List.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println('PROCEDURE update_row(i_row ' || Ctx.Tbl.Name || '%ROWTYPE)');
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println(Mk_Check_Date(Ctx.Errors, Ctx.Tbl, 'i_row.'));
    
      Ctx.Out.Println('BEGIN');
      Ctx.Out.Println(Mk_Update_Clause(Ctx.Tbl, 'i_row.', i_Columns));
      Ctx.Out.Println('EXCEPTION WHEN OTHERS THEN');
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Real_Column_List,
                                i_Prefix  => 'raise_user_error(',
                                i_Item    => '$i_name=>$@i_row.name',
                                i_Infix   => ',',
                                i_Suffix  => '); RAISE;END;'));
    
      Ctx.Out.Println('IF SQL%NOTFOUND THEN');
      Ctx.Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'NO_DATA_FOUND',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => i_Columns,
                                     i_Prefix          => 'i_row.'));
      Ctx.Out.Println('raise no_data_found;');
      Ctx.Out.Println('END IF;');
    
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Save_Row_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
    if Ctx.Tbl.Standart_Column_List.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println('PROCEDURE save_row(i_row ' || Ctx.Tbl.Name || '%ROWTYPE)');
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println(Mk_Check_Date(Ctx.Errors, Ctx.Tbl, 'i_row.'));
    
      Ctx.Out.Println('BEGIN');
      Ctx.Out.Println(Mk_Update_Clause(Ctx.Tbl, 'i_row.', i_Columns));
    
      Ctx.Out.Println('IF SQL%NOTFOUND THEN');
      Ctx.Out.Println(Mk_Insert_Clause(Ctx.Tbl, 'i_row.'));
      Ctx.Out.Println('END IF;');
      Ctx.Out.Println('EXCEPTION WHEN OTHERS THEN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Real_Column_List,
                                i_Prefix  => 'raise_user_error(',
                                i_Item    => '$i_name=>$@i_row.name',
                                i_Infix   => ',',
                                i_Suffix  => '); RAISE;END;'));
    
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Save_One_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
    if Ctx.Tbl.Standart_Column_List.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'PROCEDURE save_one(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ','));
  
    if Ctx.Tbl.Update_Column_List.Count > 0 then
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Standart_Column_List,
                                i_Prefix  => ',',
                                i_Item    => '$i_name $type $null',
                                i_Infix   => ','));
    end if;
  
    Ctx.Out.Println(')');
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS r_row ' || Ctx.Tbl.Name || '%ROWTYPE; BEGIN');
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns, i_Item => '$r_row.name:=$i_name;'));
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Standart_Column_List,
                                i_Item    => '$r_row.name:=$i_name;'));
      Ctx.Out.Println('save_row(r_row);');
      Ctx.Out.Println('END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Delete_One_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
    Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                              i_Prefix  => 'PROCEDURE delete_one(',
                              i_Item    => '$i_name $type',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'DELETE FROM ' || Ctx.Tbl.Name || ' WHERE ',
                                i_Item    => '$name=$i_name',
                                i_Infix   => ' AND ',
                                i_Suffix  => ';'));
    
      Ctx.Out.Println('EXCEPTION WHEN OTHERS THEN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'raise_user_error(',
                                i_Item    => '$i_name=>$i_name',
                                i_Infix   => ',',
                                i_Suffix  => ');'));
    
      Ctx.Out.Println('RAISE;END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Insert_Try_Procedure
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
    v_Columns Column_Nt := Except_Columns(Ctx.Tbl.Real_Column_List, g_Def_Column_Names);
  begin
    if v_Columns.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                              i_Prefix  => 'PROCEDURE insert_try(',
                              i_Item    => '$i_name $type $null',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println(Mk_Check_Date(Ctx.Errors, Ctx.Tbl, 'i_'));
      Ctx.Out.Println('BEGIN');
      Ctx.Out.Println(Mk_Column(i_Columns => i_Columns,
                                i_Prefix  => 'IF NOT exist(',
                                i_Item    => '$i_name',
                                i_Infix   => ',',
                                i_Suffix  => ') THEN'));
    
      Ctx.Out.Println(Mk_Insert_Clause(Ctx.Tbl, 'i_'));
    
      Ctx.Out.Println('END IF;');
    
      Ctx.Out.Println('EXCEPTION WHEN OTHERS THEN');
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Real_Column_List,
                                i_Prefix  => 'raise_user_error(',
                                i_Item    => '$i_name=>$@i_name',
                                i_Infix   => ',',
                                i_Suffix  => '); RAISE;END;'));
    
      Ctx.Out.Println('END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Column_Actions
  (
    Ctx       in out nocopy Context_Rt,
    i_Columns Column_Nt
  ) is
  begin
    Gen_Load_Function(Ctx, i_Columns);
    Gen_Take_Function(Ctx, i_Columns);
    Gen_Lock_Load_Function(Ctx, i_Columns);
    Gen_Lock_Load_Function2(Ctx, i_Columns);
    Gen_Lock_Only_Procedure(Ctx, i_Columns);
    Gen_Exist_Function(Ctx, i_Columns);
    Gen_Exist_Function2(Ctx, i_Columns);
    Gen_Exist_Lock_Function(Ctx, i_Columns);
    Gen_Exist_Lock_Function2(Ctx, i_Columns);
  
    if Ctx.With_Dml then
      Gen_Update_Row_Procedure(Ctx, i_Columns);
      Gen_Update_One_Procedure(Ctx, i_Columns);
      Gen_Save_Row_Procedure(Ctx, i_Columns);
      Gen_Save_One_Procedure(Ctx, i_Columns);
      Gen_Delete_One_Procedure(Ctx, i_Columns);
    
      Gen_Insert_Try_Procedure(Ctx, i_Columns);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Primary_Key_Actions(Ctx in out nocopy Context_Rt) is
    r_Constraint Constraint_Rt;
  begin
    for i in 1 .. Ctx.Tbl.Constraint_List.Count
    loop
      r_Constraint := Ctx.Tbl.Constraint_List(i);
    
      if r_Constraint.Constraint_Type = 'P' then
        Gen_Column_Actions(Ctx, Find_Columns(Ctx.Tbl, r_Constraint.Column_Names));
        exit;
      end if;
    
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Insert_Row_Procedure(Ctx in out nocopy Context_Rt) is
  begin
    Ctx.Out.Println('PROCEDURE insert_row(i_row ' || Ctx.Tbl.Name || '%ROWTYPE)');
  
    if Ctx.Is_Body then
    
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println(Mk_Check_Date(Ctx.Errors, Ctx.Tbl, 'i_row.'));
    
      Ctx.Out.Println('BEGIN');
      Ctx.Out.Println(Mk_Insert_Clause(Ctx.Tbl, 'i_row.'));
    
      Ctx.Out.Println('EXCEPTION WHEN OTHERS THEN ');
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Real_Column_List,
                                i_Prefix  => 'raise_user_error(',
                                i_Item    => '$i_name=>$@i_row.name',
                                i_Infix   => ',',
                                i_Suffix  => '); RAISE;END;'));
      Ctx.Out.Println('END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Insert_One_Procedure(Ctx in out nocopy Context_Rt) is
    v_Columns Column_Nt := Except_Columns(Ctx.Tbl.Real_Column_List, g_Def_Column_Names);
  begin
  
    if v_Columns.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                              i_Prefix  => 'PROCEDURE insert_one(',
                              i_Item    => '$i_name $type $null',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println(Mk_Check_Date(Ctx.Errors, Ctx.Tbl, 'i_'));
    
      Ctx.Out.Println('BEGIN');
      Ctx.Out.Println(Mk_Insert_Clause(Ctx.Tbl, 'i_'));
    
      Ctx.Out.Println('EXCEPTION WHEN OTHERS THEN');
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Real_Column_List,
                                i_Prefix  => 'raise_user_error(',
                                i_Item    => '$i_name=>$@i_name',
                                i_Infix   => ',',
                                i_Suffix  => '); RAISE;END;'));
      Ctx.Out.Println('END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mk_Object_Name_Params(i_Count pls_integer) return varchar2 is
    r varchar2(32767);
  begin
    if g_z_By_Wrapper then
      for i in 1 .. i_Count
      loop
        r := r || 'i_f' || i || ' fazo_schema.w_column_name:=null,' || Chr(10);
      end loop;
    else
      for i in 1 .. i_Count
      loop
        r := r || 'i_f' || i || ' varchar2:=null,' || Chr(10);
      end loop;
    end if;
  
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Init_Procedure(Ctx in out nocopy Context_Rt) is
    v_Columns Column_Nt := Except_Non_Standard_Columns(Ctx.Tbl.Column_List);
  begin
    v_Columns := Except_Columns(v_Columns, g_Def_Column_Names);
  
    Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                              i_Prefix  => 'PROCEDURE init(p_row out nocopy ' || Ctx.Tbl.Name ||
                                           '%ROWTYPE,',
                              i_Item    => '$i_name $type:=null',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => v_Columns, i_Item => 'p_row.$name := $i_name;'));
    
      Ctx.Out.Println('END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_To_Map_Function(Ctx in out nocopy Context_Rt) is
    v_Columns Column_Nt := Except_Non_Standard_Columns(Ctx.Tbl.Column_List);
  begin
    Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                              i_Prefix  => 'FUNCTION to_map(i_row ' || Ctx.Tbl.Name || '%ROWTYPE,' ||
                                           Mk_Object_Name_Params(v_Columns.Count),
                              i_Item    => '$i_name varchar2:=null',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN hashmap'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS v_cols fazo.number_code_aat;r hashmap:=hashmap();');
    
      if g_z_By_Wrapper then
        Ctx.Out.Println('PROCEDURE put_col(v fazo_schema.w_column_name) IS BEGIN');
        Ctx.Out.Println('IF v IS NOT NULL THEN v_cols(v.name):=1;END IF;END;');
      else
        Ctx.Out.Println('PROCEDURE put_col(v varchar2) IS BEGIN');
        Ctx.Out.Println('IF v IS NOT NULL THEN v_cols(v):=1;END IF;END;');
      end if;
    
      Ctx.Out.Println('BEGIN');
    
      for i in 1 .. v_Columns.Count
      loop
        Ctx.Out.Println('put_col(i_f' || i || ');');
      end loop;
    
      Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                                i_Item    => 'IF v_cols.exists(''$name'') THEN r.put(nvl($i_name,''$name''),$#i_row.name);END IF;'));
    
      Ctx.Out.Println('return r;END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_To_Row_Function(Ctx in out nocopy Context_Rt) is
    v_Func_Name varchar2(128);
    v_Columns   Column_Nt := Except_Non_Standard_Columns(Ctx.Tbl.Column_List);
  begin
    v_Columns   := Except_Columns(v_Columns, g_Def_Column_Names);
    v_Func_Name := 'FUNCTION to_row(i_map hashmap,';
  
    Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                              i_Prefix  => v_Func_Name || Mk_Object_Name_Params(v_Columns.Count),
                              i_Item    => '$i_name varchar2:=null',
                              i_Infix   => ',',
                              i_Suffix  => ') RETURN ' || Ctx.Tbl.Name || '%ROWTYPE'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS v_cols fazo.number_code_aat;r ' || Ctx.Tbl.Name || '%ROWTYPE;');
    
      if g_z_By_Wrapper then
        Ctx.Out.Println('PROCEDURE put_col(v fazo_schema.w_column_name) IS BEGIN');
        Ctx.Out.Println('IF v IS NOT NULL THEN v_cols(v.name):=1;END IF;END;');
      else
        Ctx.Out.Println('PROCEDURE put_col(v varchar2) IS BEGIN');
        Ctx.Out.Println('IF v IS NOT NULL THEN v_cols(v):=1;END IF;END;');
      end if;
    
      Ctx.Out.Println('BEGIN');
    
      for i in 1 .. v_Columns.Count
      loop
        Ctx.Out.Println('put_col(i_f' || i || ');');
      end loop;
    
      Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                                i_Item    => 'IF v_cols.exists(''$name'') THEN $r.name:=i_map.o_' ||
                                             '$type(nvl($i_name,''$name''));END IF;'));
    
      Ctx.Out.Println('return r;END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_To_Row_Procedure(Ctx in out nocopy Context_Rt) is
    v_Func_Name varchar2(128);
    v_Columns   Column_Nt := Except_Non_Standard_Columns(Ctx.Tbl.Column_List);
  begin
    v_Columns   := Except_Columns(v_Columns, g_Def_Column_Names);
    v_Func_Name := 'PROCEDURE to_row(p_row in out ' || Ctx.Tbl.Name || '%ROWTYPE,i_map hashmap,';
  
    Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                              i_Prefix  => v_Func_Name || Mk_Object_Name_Params(v_Columns.Count),
                              i_Item    => '$i_name varchar2:=null',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS v_cols fazo.number_code_aat;');
    
      if g_z_By_Wrapper then
        Ctx.Out.Println('PROCEDURE put_col(v fazo_schema.w_column_name) IS BEGIN');
        Ctx.Out.Println('IF v IS NOT NULL THEN v_cols(v.name):=1;END IF;END;');
      else
        Ctx.Out.Println('PROCEDURE put_col(v varchar2) IS BEGIN');
        Ctx.Out.Println('IF v IS NOT NULL THEN v_cols(v):=1;END IF;END;');
      end if;
    
      Ctx.Out.Println('BEGIN');
    
      for i in 1 .. v_Columns.Count
      loop
        Ctx.Out.Println('put_col(i_f' || i || ');');
      end loop;
    
      Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                                i_Item    => 'IF v_cols.exists(''$name'') THEN $p_row.name:=i_map.o_' ||
                                             '$type(nvl($i_name,''$name''));END IF;'));
    
      Ctx.Out.Println('END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_To_Map_All_Function(Ctx in out nocopy Context_Rt) is
  begin
    Ctx.Out.Println('FUNCTION to_map_all(i_row ' || Ctx.Tbl.Name || '%ROWTYPE) RETURN hashmap');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS r hashmap:=hashmap();BEGIN');
      Ctx.Out.Println(Mk_Column(i_Columns => Except_Non_Standard_Columns(Ctx.Tbl.Column_List),
                                i_Item    => 'r.put(''$name'',$#i_row.name);'));
      Ctx.Out.Println('return r;END');
    
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_To_Row_All_Function(Ctx in out nocopy Context_Rt) is
    v_Columns Column_Nt := Except_Non_Standard_Columns(Ctx.Tbl.Column_List);
  begin
    v_Columns := Except_Columns(v_Columns, g_Def_Column_Names);
    Ctx.Out.Println('FUNCTION to_row_all(i_map hashmap) return ' || Ctx.Tbl.Name || '%ROWTYPE');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS r ' || Ctx.Tbl.Name || '%ROWTYPE;BEGIN');
      Ctx.Out.Println(Mk_Column(i_Columns => v_Columns,
                                i_Item    => '$r.name:=i_map.o_$type(''$name'');'));
      Ctx.Out.Println('return r;END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Difference_Function(Ctx in out nocopy Context_Rt) is
  begin
    if Non_Standard_Column_Names(Ctx.Tbl.Column_List).Count > 0 then
      return;
    end if;
    Ctx.Out.Println('FUNCTION difference(i_row1 ' || Ctx.Tbl.Name || '%ROWTYPE,i_row2 ' ||
                    Ctx.Tbl.Name || '%ROWTYPE) return array_varchar2');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS r array_varchar2:=array_varchar2();BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Column_List,
                                i_Item    => 'IF not fazo_schema.fazo.equal($#i_row1.name,$#i_row2.name)' ||
                                             ' THEN r.extend;r(r.count):=''$name'';END IF;'));
      Ctx.Out.Println('return r;END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Equal_Function(Ctx in out nocopy Context_Rt) is
  begin
    if Non_Standard_Column_Names(Ctx.Tbl.Column_List).Count > 0 then
      return;
    end if;
    Ctx.Out.Println('FUNCTION equal(i_row1 ' || Ctx.Tbl.Name || '%ROWTYPE,i_row2 ' || Ctx.Tbl.Name ||
                    '%ROWTYPE) return boolean');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Column_List,
                                i_Item    => 'IF not fazo_schema.fazo.equal($#i_row1.name,$#i_row2.name)' ||
                                             ' THEN return false;END IF;'));
      Ctx.Out.Println('return true;END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Trim_Texts_Actions(Ctx in out nocopy Context_Rt) is
    v_Cols Column_Nt := Column_Nt();
    v_Col  Column_Rt;
  begin
    for i in 1 .. Ctx.Tbl.Real_Column_List.Count
    loop
      v_Col := Ctx.Tbl.Real_Column_List(i);
      if v_Col.Data_Type2 = 'VARCHAR2' then
        v_Cols.Extend;
        v_Cols(v_Cols.Count) := v_Col;
      end if;
    end loop;
  
    if v_Cols.Count = 0 then
      return;
    end if;
  
    Ctx.Out.Println('PROCEDURE trim_texts(p_row in out nocopy ' || Ctx.Tbl.Name || '%ROWTYPE)');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println(Mk_Column(i_Columns => v_Cols, --
                                i_Item    => '$p_row.name:=trim($p_row.name);'));
      Ctx.Out.Println('END');
    end if;
  
    Ctx.Out.Println(';');
  
    Ctx.Out.Println('FUNCTION trim_texts(i_row ' || Ctx.Tbl.Name || '%ROWTYPE) return ' ||
                    Ctx.Tbl.Name || '%ROWTYPE');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS r ' || Ctx.Tbl.Name || '%ROWTYPE:=i_row;BEGIN');
      Ctx.Out.Println('trim_texts(r); return r; END');
    end if;
  
    Ctx.Out.Println(';');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_All_Columns_Actions(Ctx in out nocopy Context_Rt) is
  begin
    if Ctx.With_Dml then
      Gen_Insert_Row_Procedure(Ctx);
      Gen_Insert_One_Procedure(Ctx);
    end if;
  
    Gen_Init_Procedure(Ctx);
  
    Gen_To_Map_Function(Ctx);
    Gen_To_Row_Function(Ctx);
    Gen_To_Row_Procedure(Ctx);
  
    Gen_To_Map_All_Function(Ctx);
    Gen_To_Row_All_Function(Ctx);
  
    Gen_Difference_Function(Ctx);
    Gen_Equal_Function(Ctx);
  
    Gen_Trim_Texts_Actions(Ctx);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Error_Dup_Val_On_Index(Ctx in out nocopy Context_Rt) is
    v_Key         Constraint_Rt;
    v_Index       Index_Rt;
    v_Index_Names Fazo_Schema.Array_Varchar2 := Fazo_Schema.Array_Varchar2();
    v_Out         Stream := Stream;
  begin
  
    for i in 1 .. Ctx.Tbl.Constraint_List.Count
    loop
      v_Key := Ctx.Tbl.Constraint_List(i);
    
      if v_Key.Constraint_Type in ('P', 'U') then
      
        if v_Key.Index_Name is not null then
          v_Index_Names.Extend;
          v_Index_Names(v_Index_Names.Count) := v_Key.Index_Name;
        end if;
      
        v_Out.Println('IF v_error like ''%(' || user || '.' || v_Key.Name || ')%'' THEN');
      
        v_Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'DUP VAL ON INDEX',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => Find_Columns(Ctx.Tbl, v_Key.Column_Names),
                                     i_Prefix          => 'i_row.'));
        v_Out.Println('END IF;');
      
      end if;
    
    end loop;
  
    for i in 1 .. Ctx.Tbl.Index_List.Count
    loop
      v_Index := Ctx.Tbl.Index_List(i);
    
      if v_Index.Uniqueness = 'UNIQUE' and v_Index.Name not member of v_Index_Names then
        v_Out.Println('IF v_error like ''%(' || user || '.' || v_Index.Name || ')%'' THEN');
      
        v_Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'DUP_VAL_ON_INDEX',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => Find_Columns(Ctx.Tbl, v_Index.Column_Names),
                                     i_Prefix          => 'i_row.'));
        v_Out.Println('END IF;');
      end if;
    end loop;
  
    if v_Out.Non_Empty then
      Ctx.Out.Println('IF v_code = -1  THEN');
      Ctx.Out.Print(v_Out);
      Ctx.Out.Println('END IF;');
    end if;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Error_Null_Column(Ctx in out nocopy Context_Rt) is
    v_Out Stream := Stream();
    v_Col Column_Rt;
  begin
  
    for i in 1 .. Ctx.Tbl.Column_List.Count
    loop
      v_Col := Ctx.Tbl.Column_List(i);
      if v_Col.Nullable = 'N' then
        v_Out.Println('IF i_row.' || v_Col.Name || ' IS NULL THEN');
        v_Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'NULL VALUE ' || v_Col.Name,
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => Column_Nt(),
                                     i_Prefix          => null));
        v_Out.Println('END IF;');
      end if;
    end loop;
  
    if v_Out.Non_Empty then
      Ctx.Out.Println('IF v_code in (-1400,-1407) THEN');
      Ctx.Out.Print(v_Out);
      Ctx.Out.Println('END IF;');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Error_Check_Violated(Ctx in out nocopy Context_Rt) is
    v_Out   Stream := Stream();
    v_Check Constraint_Rt;
  begin
    for i in 1 .. Ctx.Tbl.Constraint_List.Count
    loop
    
      v_Check := Ctx.Tbl.Constraint_List(i);
      if v_Check.Constraint_Type = 'C' and v_Check.Generated = 'N' then
        v_Out.Println('IF v_error like ''%(' || user || '.' || v_Check.Name || ')%'' THEN');
      
        v_Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'CHECK VIOLATED[' ||
                                                          replace(v_Check.Search_Condition,
                                                                  '''',
                                                                  '''''') || ']',
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => Find_Columns(Ctx.Tbl, v_Check.Column_Names),
                                     i_Prefix          => 'i_row.'));
        v_Out.Println('END IF;');
      end if;
    
    end loop;
  
    if v_Out.Non_Empty then
      Ctx.Out.Println('IF v_code = -2290 THEN');
      Ctx.Out.Print(v_Out);
      Ctx.Out.Println('END IF;');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Error_Parent_Key_Not_Found(Ctx in out nocopy Context_Rt) is
    v_Key Constraint_Rt;
    v_Out Stream := Stream();
  begin
    for i in 1 .. Ctx.Tbl.Constraint_List.Count
    loop
      v_Key := Ctx.Tbl.Constraint_List(i);
    
      if v_Key.Constraint_Type = 'R' then
        v_Out.Println('IF v_error like''%(' || user || '.' || v_Key.Name || ')%'' THEN');
        v_Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                     i_Message         => 'PARENT KEY NOT FOUND ' ||
                                                          v_Key.Ref_Constraint_Name,
                                     i_Table_Name      => Ctx.Tbl.Name,
                                     i_Columns         => Find_Columns(Ctx.Tbl, v_Key.Column_Names),
                                     i_Prefix          => 'i_row.'));
        v_Out.Println('END IF;');
      end if;
    
    end loop;
  
    if v_Out.Non_Empty then
      Ctx.Out.Println('IF v_code = -2291 THEN');
      Ctx.Out.Print(v_Out);
      Ctx.Out.Println('END IF;');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Error_Child_Record_Found(Ctx in out nocopy Context_Rt) is
    v_Key          Constraint_Rt;
    v_Cons_Columns varchar2(4000);
    v_Out          Stream := Stream();
  begin
    for i in 1 .. Ctx.Tbl.Constraint_List.Count
    loop
      v_Key := Ctx.Tbl.Constraint_List(i);
    
      if v_Key.Constraint_Type in ('P', 'U') then
      
        for j in 1 .. v_Key.Child_Constraints.Count
        loop
          v_Out.Println('IF v_error like ''%(' || user || '.' || v_Key.Child_Constraints(j) ||
                        ')%'' THEN');
        
          select '(' || Listagg(c.Column_Name, ', ') Within group(order by c.Position) || ')'
            into v_Cons_Columns
            from User_Cons_Columns c
           where c.Constraint_Name = v_Key.Child_Constraints(j);
        
          v_Out.Println(Mk_Raise_Error(Io_Error_Messages => Ctx.Errors,
                                       i_Message         => v_Key.Child_Constraints(j) || ' ' ||
                                                            v_Cons_Columns,
                                       i_Table_Name      => Ctx.Tbl.Name || ' CHILD RECORD FOUND',
                                       i_Columns         => Find_Columns(Ctx.Tbl, v_Key.Column_Names),
                                       i_Prefix          => 'i_row.'));
          v_Out.Println('END IF;');
        end loop;
      
      end if;
    
    end loop;
  
    if v_Out.Non_Empty then
      Ctx.Out.Println('IF v_code = -2292 THEN');
      Ctx.Out.Print(v_Out);
      Ctx.Out.Println('END IF;');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Get_Error_Messages(Ctx in out nocopy Context_Rt) is
  begin
    Ctx.Out.Println('FUNCTION get_error_messages RETURN fazo_schema.array_varchar2');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN return c_error; END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Raise_User_Error_Private(Ctx in out nocopy Context_Rt) is
  begin
    if Ctx.Is_Body then
      Ctx.Out.Println('PROCEDURE raise_user_error_private(i_row ' || Ctx.Tbl.Name || '%ROWTYPE)');
    
      Ctx.Out.Println('IS v_code number := sqlcode; v_error varchar2(4000):=sqlerrm; BEGIN');
    
      Gen_Error_Null_Column(Ctx);
      Gen_Error_Check_Violated(Ctx);
      Gen_Error_Dup_Val_On_Index(Ctx);
      Gen_Error_Child_Record_Found(Ctx);
      Gen_Error_Parent_Key_Not_Found(Ctx);
    
      Ctx.Out.Println('NULL;END;');
    end if;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Raise_User_Error(Ctx in out nocopy Context_Rt) is
  begin
    Ctx.Out.Println('PROCEDURE raise_user_error(i_row ' || Ctx.Tbl.Name || '%ROWTYPE)');
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS BEGIN');
      Ctx.Out.Println('raise_user_error_private(i_row);');
      Ctx.Out.Println('raise_application_error(-20999, sqlerrm);END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Raise_User_Error2(Ctx in out nocopy Context_Rt) is
  begin
    Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Column_List,
                              i_Prefix  => 'PROCEDURE raise_user_error(',
                              i_Item    => '$i_name $type:=NULL',
                              i_Infix   => ',',
                              i_Suffix  => ')'));
  
    if Ctx.Is_Body then
      Ctx.Out.Println('IS v_row ' || Ctx.Tbl.Name || '%rowtype; BEGIN');
    
      Ctx.Out.Println(Mk_Column(i_Columns => Ctx.Tbl.Column_List,
                                i_Item    => '$v_row.name:=$i_name;'));
    
      Ctx.Out.Println('raise_user_error_private(v_row);');
      Ctx.Out.Println('raise_application_error(-20999, sqlerrm);END');
    end if;
  
    Ctx.Out.Println(';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Error_Actions(Ctx in out nocopy Context_Rt) is
  begin
    Gen_Get_Error_Messages(Ctx);
    Gen_Raise_User_Error_Private(Ctx);
    Gen_Raise_User_Error(Ctx);
    Gen_Raise_User_Error2(Ctx);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Util_Actions(Ctx in out nocopy Context_Rt) is
  begin
    Ctx.Out.Println('c_age_start_date CONSTANT DATE := TO_DATE(''01.01.1900'', ''dd.mm.yyyy'');');
    Ctx.Out.Println('c_age_end_date   CONSTANT DATE := TO_DATE(''01.01.2100'', ''dd.mm.yyyy'');');
  
    Ctx.Out.Println('PROCEDURE check_date(i_date DATE, i_msg VARCHAR2) IS BEGIN');
    Ctx.Out.Println('IF i_date is not null AND i_date NOT BETWEEN c_age_start_date AND c_age_end_date THEN');
    Ctx.Out.Println('raise_application_error(-20999, zmake_message(i_msg,array_varchar2(i_date)));');
    Ctx.Out.Println('END IF;');
    Ctx.Out.Println('END;');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Spec(Ctx in out nocopy Context_Rt) is
  begin
  
    Ctx.Out.Println('create or replace package ' || Ctx.Package_Name || ' is');
  
    Gen_Error_Actions(Ctx);
  
    Gen_Primary_Key_Actions(Ctx);
    Gen_All_Columns_Actions(Ctx);
  
    Ctx.Out.Println('c_table_sha1 constant varchar2(40):=''' || Table_Sha1(Ctx.Tbl) || ''';');
    Ctx.Out.Println('end ' || Ctx.Package_Name || ';');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Gen_Body(Ctx in out nocopy Context_Rt) is
    v_Ctx        Context_Rt;
    v_Error_Text varchar2(32767);
  begin
  
    v_Ctx     := Ctx;
    v_Ctx.Out := Stream();
  
    Gen_Util_Actions(v_Ctx);
    Gen_Error_Actions(v_Ctx);
    Gen_Primary_Key_Actions(v_Ctx);
    Gen_All_Columns_Actions(v_Ctx);
  
    Ctx.Errors := v_Ctx.Errors;
  
    Ctx.Out.Println('create or replace package body ' || Ctx.Package_Name || ' is');
  
    Ctx.Out.Print('c_error constant array_varchar2 :=');
    if Ctx.Errors.Count > 0 then
      Ctx.Out.Print(' array_varchar2(''');
      -- FAZO_SCHEMA.GATHER not supported large string
      for i in 1 .. Ctx.Errors.Count
      loop
        v_Error_Text := Ctx.Errors(i);
        if i <> Ctx.Errors.Count then
          v_Error_Text := v_Error_Text || ''',' || Chr(10) || '''';
        end if;
        Ctx.Out.Print(v_Error_Text);
      end loop;
    
      Ctx.Out.Println(''');');
    else
      Ctx.Out.Println(' array_varchar2();');
    end if;
  
    Ctx.Out.Print(v_Ctx.Out);
  
    Ctx.Out.Println('end ' || Ctx.Package_Name || ';');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Package_Name(i_Table_Name varchar2) return varchar2 is
  begin
  
    return 'Z_' || i_Table_Name;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Table_Package
  (
    i_Table    Table_Rt,
    i_With_Dml boolean := true
  ) is
    v_Package_Name varchar2(128);
    Ctx            Context_Rt;
  begin
  
    v_Package_Name := Gen_Package_Name(i_Table.Name);
  
    Dbms_Output.Put_Line('package spec ' || v_Package_Name);
  
    Ctx              := null;
    Ctx.Out          := Stream();
    Ctx.Errors       := null;
    Ctx.Tbl          := i_Table;
    Ctx.Package_Name := v_Package_Name;
    Ctx.Is_Body      := false;
    Ctx.With_Dml     := i_With_Dml;
  
    Gen_Spec(Ctx);
    Execute_Stream(Ctx.Out);
  
    Dbms_Output.Put_Line('package body ' || v_Package_Name);
  
    Ctx              := null;
    Ctx.Out          := Stream();
    Ctx.Errors       := Array_Varchar2();
    Ctx.Tbl          := i_Table;
    Ctx.Package_Name := v_Package_Name;
    Ctx.Is_Body      := true;
    Ctx.With_Dml     := i_With_Dml;
  
    Gen_Body(Ctx);
    Execute_Stream(Ctx.Out);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Prepare_Table_Package(i_Table_Name varchar2) is
    r_Table        Table_Rt;
    v_Package_Name varchar2(128);
    v_New_Sha      varchar2(40);
    v_Old_Sha      varchar2(40);
  begin
    r_Table := Load_Table(i_Table_Name);
  
    v_Package_Name := Gen_Package_Name(r_Table.Name);
  
    begin
      execute immediate 'BEGIN :R:=' || v_Package_Name || '.c_table_sha1;END;'
        using out v_Old_Sha;
    
      v_New_Sha := Table_Sha1(r_Table);
      if not Fazo_Schema.Fazo.Equal(v_Old_Sha, v_New_Sha) then
        raise No_Data_Found;
      end if;
    exception
      when others then
        if sqlerrm not like '%C_TABLE_SHA1%' then
          Dbms_Output.Put_Line(sqlerrm);
        end if;
        Run_Table_Package(r_Table);
    end;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Drop_z_Package_Without_Tables(i_Table_Names Array_Varchar2) is
    v_Old_z Array_Varchar2;
    v_New_z Array_Varchar2 := Array_Varchar2();
  begin
    select t.Object_Name
      bulk collect
      into v_Old_z
      from User_Objects t
     where t.Object_Type = 'PACKAGE'
       and t.Object_Name like 'Z\_%' escape '\';
  
    v_New_z.Extend(i_Table_Names.Count);
    for i in 1 .. i_Table_Names.Count
    loop
      v_New_z(i) := Gen_Package_Name(i_Table_Names(i));
    end loop;
  
    v_Old_z := v_Old_z multiset Except v_New_z;
  
    for i in 1 .. v_Old_z.Count
    loop
      Dbms_Output.Put_Line('drop old ' || v_Old_z(i));
      execute immediate 'drop package ' || v_Old_z(i);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Fill_r_Constraints is
    v_Index         number;
    v_r_Constraint  varchar2(120);
    v_Constraints   Array_Varchar2;
    v_r_Constraints Array_Varchar2;
  begin
    g_r_Constraint_Indexs.Delete;
    g_r_Constraints := Matrix_Varchar2();
  
    select q.Constraint_Name, q.r_Constraint_Name
      bulk collect
      into v_Constraints, v_r_Constraints
      from User_Constraints q
     where q.r_Constraint_Name is not null;
  
    for i in 1 .. v_Constraints.Count
    loop
      v_r_Constraint := v_r_Constraints(i);
    
      if g_r_Constraint_Indexs.Exists(v_r_Constraint) then
        v_Index := g_r_Constraint_Indexs(v_r_Constraint);
      else
        Fazo.Push(g_r_Constraints, Array_Varchar2());
        v_Index := g_r_Constraints.Count;
        g_r_Constraint_Indexs(v_r_Constraint) := v_Index;
      end if;
    
      Fazo.Push(g_r_Constraints(v_Index), v_Constraints(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Init is
  begin
    Dbms_Application_Info.Set_Module('FAZO_Z', 'START');
    Dbms_Output.Enable(null);
  
    g_z_By_Wrapper  := not Fazo_Util.Check_Version_Compatibility('6.16.0');
    g_Zt_By_Wrapper := not Fazo_Util.Check_Version_Compatibility('7.15.0');
  
    g_Not_Updated_Column_Names := Array_Varchar2('CREATED_BY', 'CREATED_ON');
  
    g_Def_Column_Names := Array_Varchar2('CREATED_ON',
                                         'CREATED_BY',
                                         'MODIFIED_ON',
                                         'MODIFIED_BY',
                                         'MODIFIED_ID');
  
    g_Def_Column_Values := Array_Varchar2('CURRENT_TIMESTAMP',
                                          'FAZO_ENV.GET_USER_ID',
                                          'CURRENT_TIMESTAMP',
                                          'FAZO_ENV.GET_USER_ID',
                                          'BIRUNI_MODIFIED_SQ.NEXTVAL');
  
    Fill_r_Constraints;
  
    Run_Zmake_Message_Procedure;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run(i_Table_Prefix varchar2) is
    v_Table_Names Fazo_Schema.Array_Varchar2;
  begin
    Init;
  
    select t.Table_Name
      bulk collect
      into v_Table_Names
      from User_Tables t
     where t.Temporary <> 'Y'
       and not exists (select 1
              from User_Tab_Columns k
             where k.Data_Type = 'BLOB'
               and k.Table_Name = t.Table_Name);
  
    Drop_z_Package_Without_Tables(v_Table_Names);
  
    select t.Table_Name
      bulk collect
      into v_Table_Names
      from User_Tables t
     where t.Temporary <> 'Y'
       and t.Table_Name like Upper(i_Table_Prefix) || '%'
       and not exists (select 1
              from User_Tab_Columns k
             where k.Data_Type = 'BLOB'
               and k.Table_Name = t.Table_Name);
  
    if not Is_Correct_z_Package then
      Run_z;
    end if;
  
    if not Is_Correct_Zt_Package then
      Run_Zt;
    end if;
  
    for i in 1 .. v_Table_Names.Count
    loop
      Dbms_Application_Info.Set_Module('FAZO_GEN',
                                       i || '/' || v_Table_Names.Count || ' ' || v_Table_Names(i));
      Prepare_Table_Package(v_Table_Names(i));
    end loop;
  
    Dbms_Application_Info.Set_Module('FAZO_GEN', 'FINISH');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Force
  (
    i_Table_Prefix varchar2,
    i_With_Dml     boolean
  ) is
    v_Table_Names Array_Varchar2;
  begin
    Init;
  
    select t.Table_Name
      bulk collect
      into v_Table_Names
      from User_Tables t
     where t.Temporary <> 'Y'
       and not exists (select 1
              from User_Tab_Columns k
             where k.Data_Type = 'BLOB'
               and k.Table_Name = t.Table_Name);
  
    Drop_z_Package_Without_Tables(v_Table_Names);
  
    select t.Table_Name
      bulk collect
      into v_Table_Names
      from User_Tables t
     where t.Temporary <> 'Y'
       and t.Table_Name like Upper(i_Table_Prefix) || '%'
       and not exists (select 1
              from User_Tab_Columns k
             where k.Data_Type = 'BLOB'
               and k.Table_Name = t.Table_Name);
  
    Run_z;
    Run_Zt;
  
    for i in 1 .. v_Table_Names.Count
    loop
      Dbms_Application_Info.Set_Module('FAZO_GEN',
                                       i || '/' || v_Table_Names.Count || ' ' || v_Table_Names(i));
      Run_Table_Package(Load_Table(v_Table_Names(i)), i_With_Dml);
    end loop;
  
    Dbms_Application_Info.Set_Module('FAZO_GEN', 'FINISH');
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Compile_Invalid_Objects is
    v_Position number := 0;
    v_Count    number;
  begin
    select count(*)
      into v_Count
      from User_Objects
     where Object_Type in ('PACKAGE', 'PACKAGE BODY', 'VIEW')
       and Status != 'VALID';
  
    for r in (select Object_Name,
                     Object_Type,
                     Decode(Object_Type, 'PACKAGE', 1, 'PACKAGE BODY', 2, 'VIEW', 3, 4) as Recompile_Order
                from User_Objects
               where Object_Type in ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER')
                 and Status != 'VALID'
               order by 3)
    loop
      begin
        if r.Object_Type = 'PACKAGE' then
          execute immediate 'ALTER PACKAGE "' || r.Object_Name || '" COMPILE';
        elsif r.Object_Type = 'VIEW' then
          execute immediate 'ALTER VIEW "' || r.Object_Name || '" COMPILE';
        elsif r.Object_Type = 'PACKAGE BODY' then
          execute immediate 'ALTER PACKAGE "' || r.Object_Name || '" COMPILE BODY';
        else
          execute immediate 'ALTER TRIGGER "' || r.Object_Name || '" COMPILE';
        end if;
      exception
        when others then
          Dbms_Output.Put_Line(r.Object_Type || ' : ' || r.Object_Name);
      end;
    
      v_Position := v_Position + 1;
      Dbms_Application_Info.Set_Action('COMPILE ' || v_Position || '/' || v_Count || ' ' ||
                                       r.Object_Name);
    end loop;
  
    Dbms_Application_Info.Set_Action('FINISH');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Drop_Object_If_Exists(i_Object_Name varchar2) is
  begin
    for r in (select 'DROP ' || Object_Type || ' ' || Object_Name Ddl
                from User_Objects t
               where t.Object_Name = Upper(i_Object_Name)
               order by t.Object_Id desc)
    loop
      execute immediate r.Ddl;
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Wrap_Package(i_Package_Name varchar2) is
    a Dbms_Sql.Varchar2a;
    Procedure Load_Source(i_Type varchar2) is
    begin
      select Text
        bulk collect
        into a
        from (select 'create or replace ' Text, 0 Line
                from Dual
              union
              select t.Text, t.Line
                from User_Source t
               where t.Type = i_Type
                 and t.Name = Upper(i_Package_Name)
               order by 2);
    end;
  begin
    Load_Source('PACKAGE');
    Dbms_Ddl.Create_Wrapped(a, 1, a.Count);
  
    Load_Source('PACKAGE BODY');
    Dbms_Ddl.Create_Wrapped(a, 1, a.Count);
  end;

end Fazo_z;
/
