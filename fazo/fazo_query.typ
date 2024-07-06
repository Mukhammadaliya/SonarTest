create or replace type Fazo_Schema.Fazo_Query Force authid current_user as object
(
  Query                varchar2(32767),
  Params               Fazo_Schema.Hashmap,
  Fields               Fazo_Schema.Hashmap,
  Columns_After_Filter Fazo_Schema.Array_Varchar2,
  Metadata             Fazo_Schema.Arraylist,
------------------------------------------------------------------------------------------------------
  constructor Function Fazo_Query
  (
    self  in out nocopy Fazo_Schema.Fazo_Query,
    Query varchar2
  ) return self as result,

------------------------------------------------------------------------------------------------------
  constructor Function Fazo_Query
  (
    self                  in out nocopy Fazo_Schema.Fazo_Query,
    Query                 varchar2,
    Params                Hashmap,
    Generate_Where_Clause boolean := false
  ) return self as result,

------------------------------------------------------------------------------------------------------
  member Function Execute_Page
  (
    i_Column    Array_Varchar2,
    i_Filter    Arraylist := null,
    i_Sort      Array_Varchar2 := null,
    i_Offset    number := null,
    i_Limit     number := null,
    i_Namespace varchar2 := null
  ) return Stream,
------------------------------------------------------------------------------------------------------
  member Procedure Varchar2_Field
  (
    self     in out nocopy Fazo_Schema.Fazo_Query,
    i_Name1  varchar2,
    i_Name2  varchar2 := null,
    i_Name3  varchar2 := null,
    i_Name4  varchar2 := null,
    i_Name5  varchar2 := null,
    i_Name6  varchar2 := null,
    i_Name7  varchar2 := null,
    i_Name8  varchar2 := null,
    i_Name9  varchar2 := null,
    i_Name10 varchar2 := null
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Number_Field
  (
    self     in out nocopy Fazo_Schema.Fazo_Query,
    i_Name1  varchar2,
    i_Name2  varchar2 := null,
    i_Name3  varchar2 := null,
    i_Name4  varchar2 := null,
    i_Name5  varchar2 := null,
    i_Name6  varchar2 := null,
    i_Name7  varchar2 := null,
    i_Name8  varchar2 := null,
    i_Name9  varchar2 := null,
    i_Name10 varchar2 := null
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Date_Field
  (
    self     in out nocopy Fazo_Schema.Fazo_Query,
    i_Name1  varchar2,
    i_Name2  varchar2 := null,
    i_Name3  varchar2 := null,
    i_Name4  varchar2 := null,
    i_Name5  varchar2 := null,
    i_Name6  varchar2 := null,
    i_Name7  varchar2 := null,
    i_Name8  varchar2 := null,
    i_Name9  varchar2 := null,
    i_Name10 varchar2 := null
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Option_Field
  
  (
    self    in out nocopy Fazo_Query,
    i_Name  varchar2,
    i_For   varchar2,
    i_Codes Array_Varchar2,
    i_Names Array_Varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Option_Field
  (
    self    in out nocopy Fazo_Query,
    i_Name  varchar2,
    i_For   varchar2,
    i_Codes Array_Number,
    i_Names Array_Varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Refer_Field
  (
    self               in out nocopy Fazo_Query,
    i_Name             varchar2,
    i_For              varchar2,
    i_Table_Name       varchar2,
    i_Code_Field       varchar2,
    i_Name_Field       varchar2,
    i_Table_For_Select varchar2 := null,
    i_Field_Type       varchar2 := null,
    i_Manual_Sort      boolean := false
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Map_Field
  (
    self         in out nocopy Fazo_Query,
    i_Name       varchar2,
    i_Map_Fn     varchar2,
    i_Field_Type varchar2 := null
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Multi_Varchar2_Field
  (
    self          in out nocopy Fazo_Query,
    i_Name        varchar2,
    i_Table_Name  varchar2,
    i_Join_Clause varchar2,
    i_For         varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Multi_Number_Field
  (
    self          in out nocopy Fazo_Query,
    i_Name        varchar2,
    i_Table_Name  varchar2,
    i_Join_Clause varchar2,
    i_For         varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Add_Column_After_Filter
  (
    self            in out nocopy Fazo_Query,
    i_Column_Clause varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Grid_Column_Label
  (
    self    in out nocopy Fazo_Query,
    i_Name  varchar2,
    i_Label varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Function Ft_Date return varchar2,
----------------------------------------------------------------------------------------------------
  member Function Ft_Number return varchar2
)
/
create or replace type body Fazo_Schema.Fazo_Query is

  ------------------------------------------------------------------------------------------------------
  constructor Function Fazo_Query
  (
    self  in out nocopy Fazo_Schema.Fazo_Query,
    Query varchar2
  ) return self as result is
  begin
    Self.Query  := Query;
    Self.Fields := Hashmap();
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  constructor Function Fazo_Query
  (
    self                  in out nocopy Fazo_Schema.Fazo_Query,
    Query                 varchar2,
    Params                Hashmap,
    Generate_Where_Clause boolean := false
  ) return self as result is
    v_Keys  Array_Varchar2 := Params.Keyset;
    v_Query varchar2(32767) := Query;
  begin
    if Generate_Where_Clause then
      v_Keys := Params.Keyset;
      if v_Keys.Count > 0 then
        for i in 1 .. v_Keys.Count
        loop
          v_Keys(i) := 'w.' || v_Keys(i) || '=:' || v_Keys(i);
        end loop;
        v_Query := 'SELECT * FROM ' || v_Query || ' w WHERE ' || Fazo.Gather(v_Keys, ' AND ');
      end if;
    end if;
  
    Self.Query  := v_Query;
    Self.Params := Params;
    Self.Fields := Hashmap();
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Execute_Page
  (
    i_Column    Array_Varchar2,
    i_Filter    Arraylist := null,
    i_Sort      Array_Varchar2 := null,
    i_Offset    number := null,
    i_Limit     number := null,
    i_Namespace varchar2 := null
  ) return Stream is
    v_Rownum_Start number := Nvl(i_Offset, 0);
    v_Rownum_End   number := v_Rownum_Start + Nvl(i_Limit, 20) + 1;
    Writer         Stream := Stream();
  begin
    Fazo_Schema.Fazo_Util.Execute_Query_Page(i_Query        => Self.Query,
                                             i_Params       => Self.Params,
                                             i_Fields       => Fields,
                                             i_Column       => i_Column,
                                             i_Filter       => i_Filter,
                                             i_Sort         => i_Sort,
                                             i_Rownum_Start => v_Rownum_Start,
                                             i_Rownum_End   => v_Rownum_End,
                                             i_Namespace    => i_Namespace,
                                             Writer         => Writer);
  
    return Writer;
  
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Varchar2_Field
  (
    self     in out nocopy Fazo_Schema.Fazo_Query,
    i_Name1  varchar2,
    i_Name2  varchar2 := null,
    i_Name3  varchar2 := null,
    i_Name4  varchar2 := null,
    i_Name5  varchar2 := null,
    i_Name6  varchar2 := null,
    i_Name7  varchar2 := null,
    i_Name8  varchar2 := null,
    i_Name9  varchar2 := null,
    i_Name10 varchar2 := null
  ) is
    v Arraylist := Arraylist();
    Procedure Put(i_Name varchar2) is
    begin
      if i_Name is not null then
        Self.Fields.Put(i_Name, v);
      end if;
    end;
  begin
    v.Push(Fazo_Util.c_f_Varchar2);
    Put(i_Name1);
    Put(i_Name2);
    Put(i_Name3);
    Put(i_Name4);
    Put(i_Name5);
    Put(i_Name6);
    Put(i_Name7);
    Put(i_Name8);
    Put(i_Name9);
    Put(i_Name10);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Number_Field
  (
    self     in out nocopy Fazo_Schema.Fazo_Query,
    i_Name1  varchar2,
    i_Name2  varchar2 := null,
    i_Name3  varchar2 := null,
    i_Name4  varchar2 := null,
    i_Name5  varchar2 := null,
    i_Name6  varchar2 := null,
    i_Name7  varchar2 := null,
    i_Name8  varchar2 := null,
    i_Name9  varchar2 := null,
    i_Name10 varchar2 := null
  ) is
    v Arraylist := Arraylist();
    Procedure Put(i_Name varchar2) is
    begin
      if i_Name is not null then
        Self.Fields.Put(i_Name, v);
      end if;
    end;
  begin
    v.Push(Fazo_Util.c_f_Number);
    Put(i_Name1);
    Put(i_Name2);
    Put(i_Name3);
    Put(i_Name4);
    Put(i_Name5);
    Put(i_Name6);
    Put(i_Name7);
    Put(i_Name8);
    Put(i_Name9);
    Put(i_Name10);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Date_Field
  (
    self     in out nocopy Fazo_Schema.Fazo_Query,
    i_Name1  varchar2,
    i_Name2  varchar2 := null,
    i_Name3  varchar2 := null,
    i_Name4  varchar2 := null,
    i_Name5  varchar2 := null,
    i_Name6  varchar2 := null,
    i_Name7  varchar2 := null,
    i_Name8  varchar2 := null,
    i_Name9  varchar2 := null,
    i_Name10 varchar2 := null
  ) is
    v Arraylist := Arraylist();
    Procedure Put(i_Name varchar2) is
    begin
      if i_Name is not null then
        Self.Fields.Put(i_Name, v);
      end if;
    end;
  begin
    v.Push(Fazo_Util.c_f_Date);
    Put(i_Name1);
    Put(i_Name2);
    Put(i_Name3);
    Put(i_Name4);
    Put(i_Name5);
    Put(i_Name6);
    Put(i_Name7);
    Put(i_Name8);
    Put(i_Name9);
    Put(i_Name10);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Option_Field
  (
    self    in out nocopy Fazo_Query,
    i_Name  varchar2,
    i_For   varchar2,
    i_Codes Array_Varchar2,
    i_Names Array_Varchar2
  ) is
    v Arraylist := Arraylist();
  begin
    if i_Name is null then
      Raise_Application_Error(-20999, 'refer field name is empty');
    end if;
    if i_For is null then
      Raise_Application_Error(-20999, 'refer for name is empty');
    end if;
    v.Push(Fazo_Util.c_f_Option);
    v.Push(i_For);
    v.Push(i_Codes);
    v.Push(i_Names);
    Self.Fields.Put(i_Name, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Option_Field
  (
    self    in out nocopy Fazo_Query,
    i_Name  varchar2,
    i_For   varchar2,
    i_Codes Array_Number,
    i_Names Array_Varchar2
  ) is
    v Arraylist := Arraylist();
  begin
    if i_Name is null then
      Raise_Application_Error(-20999, 'refer field name is empty');
    end if;
    if i_For is null then
      Raise_Application_Error(-20999, 'refer for name is empty');
    end if;
    v.Push(Fazo_Util.c_f_Option);
    v.Push(i_For);
    v.Push(Fazo_Schema.Fazo.To_Array_Varchar2(i_Codes));
    v.Push(i_Names);
    Self.Fields.Put(i_Name, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Refer_Field
  (
    self               in out nocopy Fazo_Query,
    i_Name             varchar2,
    i_For              varchar2,
    i_Table_Name       varchar2,
    i_Code_Field       varchar2,
    i_Name_Field       varchar2,
    i_Table_For_Select varchar2 := null,
    i_Field_Type       varchar2 := null,
    i_Manual_Sort      boolean := false
  ) is
    v Arraylist := Arraylist();
  begin
    if i_Name is null then
      Raise_Application_Error(-20999, 'refer field name is empty');
    end if;
    if i_For is null then
      Raise_Application_Error(-20999, 'refer for name is empty');
    end if;
    v.Push(Fazo_Util.c_f_Refer);
    v.Push(i_For);
    v.Push('(' || i_Table_Name || ')');
    v.Push(i_Code_Field);
    v.Push(i_Name_Field);
  
    if i_Table_For_Select is not null then
      v.Push('(' || i_Table_For_Select || ')');
    else
      v.Push(i_Table_For_Select);
    end if;
  
    if i_Field_Type in (Fazo_Util.c_f_Number, Fazo_Util.c_f_Date) then
      v.Push(i_Field_Type);
    else
      v.Push(Fazo_Util.c_f_Varchar2);
    end if;
  
    v.Push(case when i_Manual_Sort then 'Y' else 'N' end);
  
    Self.Fields.Put(i_Name, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Map_Field
  (
    self         in out nocopy Fazo_Query,
    i_Name       varchar2,
    i_Map_Fn     varchar2,
    i_Field_Type varchar2 := null
  ) is
    v Arraylist := Arraylist();
  begin
    if i_Name is null then
      Raise_Application_Error(-20999, 'map field name is empty');
    end if;
    if i_Map_Fn is null then
      Raise_Application_Error(-20999, 'map map_fn name is empty');
    end if;
    v.Push(Fazo_Util.c_f_Map);
    v.Push('(' || i_Map_Fn || ')');
    if i_Field_Type in (Fazo_Util.c_f_Number, Fazo_Util.c_f_Date) then
      v.Push(i_Field_Type);
    else
      v.Push(Fazo_Util.c_f_Varchar2);
    end if;
    Self.Fields.Put(i_Name, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Multi_Varchar2_Field
  (
    self          in out nocopy Fazo_Query,
    i_Name        varchar2,
    i_Table_Name  varchar2,
    i_Join_Clause varchar2,
    i_For         varchar2
  ) is
    v Arraylist := Arraylist();
  begin
    if i_Name is null then
      Raise_Application_Error(-20999, 'multi field name is empty');
    end if;
    v.Push(Fazo_Util.c_f_Multi);
    v.Push(i_For);
    v.Push('(' || i_Table_Name || ')');
    v.Push(i_Join_Clause);
    v.Push(Fazo_Util.c_f_Varchar2);
    Self.Fields.Put(i_Name, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Multi_Number_Field
  (
    self          in out nocopy Fazo_Query,
    i_Name        varchar2,
    i_Table_Name  varchar2,
    i_Join_Clause varchar2,
    i_For         varchar2
  ) is
    v Arraylist := Arraylist();
  begin
    if i_Name is null then
      Raise_Application_Error(-20999, 'multi field name is empty');
    end if;
    v.Push(Fazo_Util.c_f_Multi);
    v.Push(i_For);
    v.Push('(' || i_Table_Name || ')');
    v.Push(i_Join_Clause);
    v.Push(Fazo_Util.c_f_Number);
    Self.Fields.Put(i_Name, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Add_Column_After_Filter
  (
    self            in out nocopy Fazo_Query,
    i_Column_Clause varchar2
  ) is
  begin
    if trim(i_Column_Clause) is null then
      Raise_Application_Error(-20999, 'field_clause in add_field_after_clause is empty');
    end if;
    if Self.Columns_After_Filter is null then
      Self.Columns_After_Filter := Array_Varchar2();
    end if;
    Fazo.Push(Self.Columns_After_Filter, i_Column_Clause);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Grid_Column_Label
  (
    self    in out nocopy Fazo_Query,
    i_Name  varchar2,
    i_Label varchar2
  ) is
  begin
    if Self.Metadata is null then
      Self.Metadata := Arraylist();
    end if;
    Self.Metadata.Push(Array_Varchar2('column', i_Name, i_Label));
  end;

  ----------------------------------------------------------------------------------------------------
  member Function Ft_Date return varchar2 is
  begin
    return Fazo_Util.c_f_Date;
  end;

  ----------------------------------------------------------------------------------------------------
  member Function Ft_Number return varchar2 is
  begin
    return Fazo_Util.c_f_Number;
  end;

end;
/
