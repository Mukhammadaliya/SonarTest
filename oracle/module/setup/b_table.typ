create or replace type b_Table as object
(
  z_Id                  number,
  z_Buf                 varchar2(4000),
  z_Cur_Style_Name      varchar2(100),
  z_Odd_Style_Name      varchar2(100),
  z_Even_Style_Name     varchar2(100),
  z_Row_No              number,
  z_Column_No           number,
  z_Column_Widths       Array_Number,
  z_Column_Data_Sources Array_Varchar2,
  z_Groupings           Array_Varchar2,
  z_Grid_Contents       Array_Varchar2,
  constructor Function b_Table(i_Table_Id number) return self as result,
----------------------------------------------------------------------------------------------------
  member Procedure Column_Width
  (
    self           in out nocopy b_Table,
    i_Column_Index number,
    i_Width        number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Column_Data_Source
  (
    self            in out nocopy b_Table,
    i_Column_Index  number,
    i_First_Row     number,
    i_Last_Row      number,
    i_Source_Sheet  varchar2,
    i_Source_Column number,
    i_Source_Count  number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Current_Style
  (
    self         in out nocopy b_Table,
    i_Style_Name varchar2
  ),
----------------------------------------------------------------------------------------------------
  member Procedure New_Row
  (
    self     in out nocopy b_Table,
    i_Height number := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Data(self in out nocopy b_Table),
----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        number,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        date,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        timestamp,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self  in out nocopy b_Table,
    p_Val in out nocopy b_Table
  ),
----------------------------------------------------------------------------------------------------  
  member Procedure Page_Break
  
  (
    self               in out nocopy b_Table,
    i_Row_Break        boolean := null,
    i_Column_Break     boolean := null,
    i_Row_Breakable    boolean := null, -- Row breakable automatically breaks row if data from this row till the next row breakable doesn't fit the page.
    i_Column_Breakable boolean := null -- Column breakable automatically breaks column if data from this column till the next column breakable doesn't fit the page.
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Add_Data
  (
    self    in out nocopy b_Table,
    i_Count number
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Image
  (
    self         in out nocopy b_Table,
    i_Sha        varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Add_Image
  (
    i_Cell_Type  varchar2,
    i_Val        varchar2,
    i_Style_Name varchar2,
    i_Colspan    number,
    i_Rowspan    number,
    i_Width      number,
    i_Height     number,
    i_Label      boolean := true
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Barcode
  (
    i_Text       varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null,
    i_Label      boolean := true
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Qrcode
  (
    i_Text       varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Gs1_Data_Matrix
  (
    i_Text       varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null
  ),
----------------------------------------------------------------------------------------------------
  member Function Is_Empty return boolean,
----------------------------------------------------------------------------------------------------
  member Procedure Start_Row_Group(i_Show boolean := null),
----------------------------------------------------------------------------------------------------
  member Procedure Stop_Row_Group,
----------------------------------------------------------------------------------------------------
  member Procedure Start_Column_Group(i_Show boolean := null),
----------------------------------------------------------------------------------------------------
  member Procedure Stop_Column_Group,
----------------------------------------------------------------------------------------------------
  member Procedure Set_Odd_Style
  (
    self         in out nocopy b_Table,
    i_Style_Name varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Set_Even_Style
  (
    self         in out nocopy b_Table,
    i_Style_Name varchar2 := null
  ),
----------------------------------------------------------------------------------------------------
  member Procedure Open_Table,
----------------------------------------------------------------------------------------------------
  member Procedure Close_Table,
----------------------------------------------------------------------------------------------------
  member Procedure Open_Thead,
----------------------------------------------------------------------------------------------------
  member Procedure Close_Thead,
----------------------------------------------------------------------------------------------------
  member Procedure Open_Tbody,
----------------------------------------------------------------------------------------------------
  member Procedure Close_Tbody,
----------------------------------------------------------------------------------------------------
  member Procedure Open_Tfoot,
----------------------------------------------------------------------------------------------------
  member Procedure Close_Tfoot
)
/
create or replace type body b_Table is
  ----------------------------------------------------------------------------------------------------
  constructor Function b_Table
  (
    self       in out nocopy b_Table,
    i_Table_Id number
  ) return self as result is
  begin
    z_Id                  := i_Table_Id;
    z_Buf                 := null;
    z_Cur_Style_Name      := null;
    z_Odd_Style_Name      := null;
    z_Even_Style_Name     := null;
    z_Row_No              := 0;
    z_Column_No           := 0;
    z_Column_Widths       := Array_Number();
    z_Column_Data_Sources := Array_Varchar2();
    z_Groupings           := Array_Varchar2();
    z_Grid_Contents       := Array_Varchar2();
    return;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Column_Width
  (
    self           in out nocopy b_Table,
    i_Column_Index number,
    i_Width        number
  ) is
  begin
    Biruni_Report.Column_Width(p_Column_Widths => Self.z_Column_Widths,
                               i_Column_Index  => i_Column_Index,
                               i_Width         => i_Width);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Column_Data_Source
  (
    self            in out nocopy b_Table,
    i_Column_Index  number,
    i_First_Row     number,
    i_Last_Row      number,
    i_Source_Sheet  varchar2,
    i_Source_Column number,
    i_Source_Count  number
  ) is
  begin
    -- Check if the source count is zero. If it is, return immediately to prevent
    -- the generation of an unsupported format by the POI library.
    -- The Nvl function ensures that a null value for i_Source_Count is treated as zero.
    if Nvl(i_Source_Count, 0) = 0 then
      return;
    end if;
  
    Biruni_Report.Column_Data_Source(p_Column_Data_Sources => Self.z_Column_Data_Sources,
                                     i_Column_Index        => i_Column_Index,
                                     i_Source              => Fazo.Gather(Array_Varchar2(i_First_Row,
                                                                                         i_Last_Row,
                                                                                         i_Source_Sheet,
                                                                                         i_Source_Column,
                                                                                         i_Source_Count),
                                                                          ':'));
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Current_Style
  (
    self         in out nocopy b_Table,
    i_Style_Name varchar2
  ) is
  begin
    Self.z_Cur_Style_Name := i_Style_Name;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure New_Row
  (
    self     in out nocopy b_Table,
    i_Height number := null
  ) is
    v varchar2(4000);
  begin
    if i_Height is not null then
      v := v || Biruni_Report.Pair('h', i_Height);
    end if;
  
    if Self.z_Row_No > 0 then
      Biruni_Report.Print(z_Id, z_Buf, '][[' || v || ']');
    else
      Biruni_Report.Print(z_Id, z_Buf, '[[' || v || ']');
    end if;
  
    z_Row_No    := z_Row_No + 1;
    z_Column_No := 0;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Data(self in out nocopy b_Table) is
  begin
    Biruni_Report.Print_Cell(i_Table_Id    => z_Id,
                             p_Buf         => z_Buf,
                             i_Cell_Type   => 'V',
                             i_Val         => null,
                             i_Style_Index => Biruni_Report.Get_Style_Index(z_Row_No,
                                                                            Self.z_Cur_Style_Name,
                                                                            Self.z_Odd_Style_Name,
                                                                            Self.z_Even_Style_Name));
  
    z_Column_No := z_Column_No + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ) is
    v_Style_Index number;
  
    Function Formatted_Val return varchar2 is
    begin
      if Biruni_Report.g_Replace_New_Line then
        return replace(i_Val, Chr(10), '<br>');
      end if;
      return i_Val;
    end;
  
  begin
    if i_Style_Name is not null then
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     i_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    else
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     Self.z_Cur_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    end if;
  
    Biruni_Report.Print_Cell(i_Table_Id    => z_Id,
                             p_Buf         => z_Buf,
                             i_Cell_Type   => 'V',
                             i_Val         => Formatted_Val,
                             i_Style_Index => v_Style_Index,
                             i_Colspan     => i_Colspan,
                             i_Rowspan     => i_Rowspan,
                             i_Param       => i_Param,
                             i_Menu_Ids    => i_Menu_Ids);
  
    z_Column_No := z_Column_No + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        number,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ) is
    v_Style_Index number;
    v_Style_Name  varchar2(50) := i_Style_Name;
    v_Val         varchar2(200);
  
  begin
    if i_Style_Name is null then
      v_Style_Name := Self.z_Cur_Style_Name;
    end if;
  
    -- auto number style for decimal part
    if v_Style_Name like '%number0%' then
      v_Style_Name := replace(v_Style_Name,
                              'number0',
                              'number' ||
                              Least(Length(Regexp_Substr(Rtrim(i_Val, '0'), '\.[0-9]+')) - 1, 6));
    end if;
  
    v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                   v_Style_Name,
                                                   Self.z_Odd_Style_Name,
                                                   Self.z_Even_Style_Name);
  
    if Biruni_Report.Report_Type = b_Report.Rt_Html or
       Biruni_Report.Report_Type = b_Report.Rt_Htmls then
      if i_Val = Trunc(i_Val) then
        v_Val := to_char(i_Val, 'FM999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''');
      else
        v_Val := to_char(i_Val, 'FM999G999G999G999G990D999999', 'NLS_NUMERIC_CHARACTERS=''. ''');
      end if;
    else
      v_Val := to_char(i_Val, 'TM9', 'NLS_NUMERIC_CHARACTERS=''. ''');
    end if;
  
    Biruni_Report.Print_Cell(i_Table_Id    => z_Id,
                             p_Buf         => z_Buf,
                             i_Cell_Type   => 'N',
                             i_Val         => v_Val,
                             i_Style_Index => v_Style_Index,
                             i_Colspan     => i_Colspan,
                             i_Rowspan     => i_Rowspan,
                             i_Param       => i_Param,
                             i_Menu_Ids    => i_Menu_Ids);
  
    z_Column_No := z_Column_No + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        date,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ) is
    v             varchar2(20);
    v_Style_Index number;
  begin
    if i_Style_Name is not null then
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     i_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    else
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     Self.z_Cur_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    end if;
  
    if i_Val = Trunc(i_Val) then
      v := to_char(i_Val, 'dd.mm.yyyy');
    else
      v := to_char(i_Val, 'dd.mm.yyyy hh24:mi:ss');
    end if;
  
    Biruni_Report.Print_Cell(i_Table_Id    => z_Id,
                             p_Buf         => z_Buf,
                             i_Cell_Type   => 'D',
                             i_Val         => v,
                             i_Style_Index => v_Style_Index,
                             i_Colspan     => i_Colspan,
                             i_Rowspan     => i_Rowspan,
                             i_Param       => i_Param,
                             i_Menu_Ids    => i_Menu_Ids);
  
    z_Column_No := z_Column_No + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self         in out nocopy b_Table,
    i_Val        timestamp,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Param      varchar2 := null,
    i_Menu_Ids   varchar2 := null
  ) is
    v             varchar2(20);
    v_Style_Index number;
  begin
    if i_Style_Name is not null then
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     i_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    else
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     Self.z_Cur_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    end if;
  
    if i_Val = Trunc(i_Val) then
      v := to_char(i_Val, 'dd.mm.yyyy');
    else
      v := to_char(i_Val, 'dd.mm.yyyy hh24:mi:ss');
    end if;
  
    Biruni_Report.Print_Cell(i_Table_Id    => z_Id,
                             p_Buf         => z_Buf,
                             i_Cell_Type   => 'D',
                             i_Val         => v,
                             i_Style_Index => v_Style_Index,
                             i_Colspan     => i_Colspan,
                             i_Rowspan     => i_Rowspan,
                             i_Param       => i_Param,
                             i_Menu_Ids    => i_Menu_Ids);
  
    z_Column_No := z_Column_No + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Data
  (
    self  in out nocopy b_Table,
    p_Val in out nocopy b_Table
  ) is
  begin
    Biruni_Report.Print_Cell(i_Table_Id  => Self.z_Id,
                             p_Buf       => z_Buf,
                             i_Cell_Type => 'T',
                             i_Val       => p_Val.z_Id);
  
    z_Column_No := z_Column_No + 1;
  
    Biruni_Report.Close_Table(p_Val.z_Id,
                              p_Val.z_Buf,
                              p_Val.z_Row_No,
                              p_Val.z_Column_Widths,
                              p_Val.z_Column_Data_Sources,
                              p_Val.z_Groupings,
                              p_Val.z_Grid_Contents);
    p_Val.z_Id := null;
  end;

  ----------------------------------------------------------------------------------------------------  
  member Procedure Page_Break
  (
    self               in out nocopy b_Table,
    i_Row_Break        boolean := null,
    i_Column_Break     boolean := null,
    i_Row_Breakable    boolean := null,
    i_Column_Breakable boolean := null
  ) is
    v varchar2(4000);
  begin
    if Is_Empty then
      return;
    end if;
  
    if i_Row_Break then
      v := v || Biruni_Report.Pair('pbr', 'Y');
    end if;
  
    if i_Column_Break and Self.z_Column_No > 0 then
      v := v || Biruni_Report.Pair('pbc', z_Column_No - 1);
    end if;
  
    if i_Row_Breakable then
      v := v || Biruni_Report.Pair('pbar', 'Y');
    end if;
  
    if i_Column_Breakable and Self.z_Column_No > 0 then
      v := v || Biruni_Report.Pair('pbac', z_Column_No - 1);
    end if;
  
    if v is not null then
      Biruni_Report.Print(z_Id, z_Buf, '[' || v || ']');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Add_Data
  (
    self    in out nocopy b_Table,
    i_Count number
  ) is
  begin
    for i in 1 .. i_Count
    loop
      Self.Data;
    end loop;
  
    z_Column_No := z_Column_No + i_Count + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Add_Image
  (
    self         in out nocopy b_Table,
    i_Cell_Type  varchar2,
    i_Val        varchar2,
    i_Style_Name varchar2,
    i_Colspan    number,
    i_Rowspan    number,
    i_Width      number,
    i_Height     number,
    i_Label      boolean := true
  ) is
    v_Style_Index number;
  begin
    if i_Style_Name is not null then
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     i_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    else
      v_Style_Index := Biruni_Report.Get_Style_Index(z_Row_No,
                                                     Self.z_Cur_Style_Name,
                                                     Self.z_Odd_Style_Name,
                                                     Self.z_Even_Style_Name);
    end if;
  
    Biruni_Report.Print_Cell(i_Table_Id    => z_Id,
                             p_Buf         => z_Buf,
                             i_Cell_Type   => i_Cell_Type,
                             i_Val         => i_Val,
                             i_Style_Index => v_Style_Index,
                             i_Colspan     => i_Colspan,
                             i_Rowspan     => i_Rowspan,
                             i_Width       => i_Width,
                             i_Height      => i_Height,
                             i_Label       => i_Label);
  
    z_Column_No := z_Column_No + 1;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Image
  (
    i_Sha        varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null
  ) is
  begin
    Add_Image(i_Cell_Type  => 'I',
              i_Val        => i_Sha,
              i_Style_Name => i_Style_Name,
              i_Colspan    => i_Colspan,
              i_Rowspan    => i_Rowspan,
              i_Width      => i_Width,
              i_Height     => i_Height);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Barcode
  (
    i_Text       varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null,
    i_Label      boolean := true
  ) is
  begin
    Add_Image(i_Cell_Type  => 'B',
              i_Val        => i_Text,
              i_Style_Name => i_Style_Name,
              i_Colspan    => i_Colspan,
              i_Rowspan    => i_Rowspan,
              i_Width      => i_Width,
              i_Height     => i_Height,
              i_Label      => i_Label);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Qrcode
  (
    i_Text       varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null
  ) is
  begin
    Add_Image(i_Cell_Type  => 'Q',
              i_Val        => i_Text,
              i_Style_Name => i_Style_Name,
              i_Colspan    => i_Colspan,
              i_Rowspan    => i_Rowspan,
              i_Width      => i_Width,
              i_Height     => i_Height);
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Gs1_Data_Matrix
  (
    i_Text       varchar2,
    i_Style_Name varchar2 := null,
    i_Colspan    number := null,
    i_Rowspan    number := null,
    i_Width      number := null,
    i_Height     number := null
  ) is
  begin
    Add_Image(i_Cell_Type  => 'M',
              i_Val        => i_Text,
              i_Style_Name => i_Style_Name,
              i_Colspan    => i_Colspan,
              i_Rowspan    => i_Rowspan,
              i_Width      => i_Width,
              i_Height     => i_Height);
  end;

  ----------------------------------------------------------------------------------------------------
  member Function Is_Empty return boolean is
  begin
    return z_Row_No = 0;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Start_Row_Group(i_Show boolean := null) is
  begin
    Fazo.Push(z_Groupings,
              '[' || Biruni_Report.Esc('s') || Biruni_Report.Esc('r') ||
              Biruni_Report.Esc(z_Row_No) ||
              Biruni_Report.Esc(case i_Show when true then 'Y' else 'N' end) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Stop_Row_Group is
  begin
    Fazo.Push(z_Groupings,
              '[' || Biruni_Report.Esc('e') || Biruni_Report.Esc('r') ||
              Biruni_Report.Esc(z_Row_No - 1) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Start_Column_Group(i_Show boolean := null) is
  begin
    Fazo.Push(z_Groupings,
              '[' || Biruni_Report.Esc('s') || Biruni_Report.Esc('c') ||
              Biruni_Report.Esc(z_Column_No) ||
              Biruni_Report.Esc(case i_Show when true then 'Y' else 'N' end) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Stop_Column_Group is
  begin
    Fazo.Push(z_Groupings,
              '[' || Biruni_Report.Esc('e') || Biruni_Report.Esc('c') ||
              Biruni_Report.Esc(z_Column_No - 1) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Odd_Style
  (
    self         in out nocopy b_Table,
    i_Style_Name varchar2 := null
  ) is
  begin
    Self.z_Odd_Style_Name := i_Style_Name;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Set_Even_Style
  (
    self         in out nocopy b_Table,
    i_Style_Name varchar2 := null
  ) is
  begin
    Self.z_Even_Style_Name := i_Style_Name;
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Open_Table is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('tb') || Biruni_Report.Esc(z_Row_No) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Close_Table is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('te') || Biruni_Report.Esc(z_Row_No - 1) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Open_Thead is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('hb') || Biruni_Report.Esc(z_Row_No) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Close_Thead is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('he') || Biruni_Report.Esc(z_Row_No - 1) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Open_Tbody is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('bb') || Biruni_Report.Esc(z_Row_No) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Close_Tbody is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('be') || Biruni_Report.Esc(z_Row_No - 1) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Open_Tfoot is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('fb') || Biruni_Report.Esc(z_Row_No) || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  member Procedure Close_Tfoot is
  begin
    Fazo.Push(z_Grid_Contents,
              '[' || Biruni_Report.Esc('fe') || Biruni_Report.Esc(z_Row_No - 1) || ']');
  end;

end;
/
