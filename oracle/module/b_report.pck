create or replace package b_Report is
  ----------------------------------------------------------------------------------------------------
  a_Left   constant Option_Number := Option_Number(1);
  a_Center constant Option_Number := Option_Number(2);
  a_Right  constant Option_Number := Option_Number(3);
  a_Top    constant Option_Number := Option_Number(1);
  a_Middle constant Option_Number := Option_Number(2);
  a_Bottom constant Option_Number := Option_Number(3);
  ----------------------------------------------------------------------------------------------------
  b_Null                constant Option_Varchar2 := Option_Varchar2('none');
  b_Hair                constant Option_Varchar2 := Option_Varchar2('hair');
  b_Thin                constant Option_Varchar2 := Option_Varchar2('thin');
  b_Thick               constant Option_Varchar2 := Option_Varchar2('thick');
  b_Double              constant Option_Varchar2 := Option_Varchar2('double');
  b_Dotted              constant Option_Varchar2 := Option_Varchar2('dotted');
  b_Dashed              constant Option_Varchar2 := Option_Varchar2('dashed');
  b_Dash_Dot            constant Option_Varchar2 := Option_Varchar2('dash_dot');
  b_Dash_Dot_Dot        constant Option_Varchar2 := Option_Varchar2('dash_dot_dot');
  b_Medium              constant Option_Varchar2 := Option_Varchar2('medium');
  b_Medium_Dashed       constant Option_Varchar2 := Option_Varchar2('medium_dashed');
  b_Medium_Dash_Dot     constant Option_Varchar2 := Option_Varchar2('medium_dash_dot');
  b_Medium_Dash_Dot_Dot constant Option_Varchar2 := Option_Varchar2('medium_dash_dot_dot');
  ----------------------------------------------------------------------------------------------------
  Function Rt_Html return varchar2;
  Function Rt_Htmlm return varchar2;
  Function Rt_Htmls return varchar2;
  Function Rt_Xlsx return varchar2;
  Function Rt_Imp_Xlsx return varchar2;
  Function Rt_Csv return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book
  (
    i_Report_Type varchar2 := null,
    i_File_Name   varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book
  (
    p           Hashmap,
    i_File_Name varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book_With_Styles
  (
    i_Report_Type varchar2 := null,
    i_File_Name   varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book_With_Styles
  (
    p           Hashmap,
    i_File_Name varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Close_Book;
  ----------------------------------------------------------------------------------------------------
  Procedure New_Style
  (
    i_Style_Name          varchar2,
    i_Parent_Style_Name   varchar2 := null,
    i_Font_Size           number := null,
    i_Font_Color          varchar2 := null,
    i_Font_Family         varchar2 := null,
    i_Font_Bold           boolean := null,
    i_Font_Italic         boolean := null,
    i_Font_Underline      boolean := null,
    i_Horizontal_Align    Option_Number := null,
    i_Vertical_Align      Option_Number := null,
    i_Text_Rotate         number := null,
    i_Text_Wrap           boolean := null,
    i_Shrink_To_Fit       boolean := null,
    i_Indent              number := null,
    i_Background_Color    varchar2 := null,
    i_Cell_Format         varchar2 := null,
    i_Border              Option_Varchar2 := null,
    i_Border_Color        varchar2 := null,
    i_Border_Top          Option_Varchar2 := null,
    i_Border_Top_Color    varchar2 := null,
    i_Border_Bottom       Option_Varchar2 := null,
    i_Border_Bottom_Color varchar2 := null,
    i_Border_Left         Option_Varchar2 := null,
    i_Border_Left_Color   varchar2 := null,
    i_Border_Right        Option_Varchar2 := null,
    i_Border_Right_Color  varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Sheet
  (
    i_Name              varchar2,
    p_Table             in out nocopy b_Table,
    i_Param             varchar2 := null,
    i_Zoom              number := null,
    i_No_Gridlines      boolean := null,
    i_Split_Horizontal  number := null,
    i_Split_Vertical    number := null,
    i_Page_Header       number := null,
    i_Page_Footer       number := null,
    i_Page_Top          number := null,
    i_Page_Bottom       number := null,
    i_Page_Left         number := null,
    i_Page_Right        number := null,
    i_Fit_To_Page       boolean := null,
    i_Landscape         boolean := null,
    i_Hidden            boolean := null,
    i_Wrap_Merged_Cells boolean := null --this variable determines whether merged cells should be wrapped text or not
  );
  ----------------------------------------------------------------------------------------------------
  Function New_Table(i_Parent b_Table := null) return b_Table;
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Standart_Styles;
  ----------------------------------------------------------------------------------------------------
  Function Is_Redirect(p Hashmap) return boolean;
  ----------------------------------------------------------------------------------------------------
  Procedure Redirect_To_Report
  (
    i_Uri   varchar2,
    i_Param Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Redirect_To_Form
  (
    i_Uri       varchar2,
    i_Param     Hashmap,
    i_Filial_Id number := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Redirect_To_Window
  (
    i_Uri               varchar2,
    i_Param             Hashmap := null,
    i_With_Context_Path boolean := true
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Menu
  (
    i_Id    number,
    i_Title varchar2
  );
end b_Report;
/
create or replace package body b_Report is
  ----------------------------------------------------------------------------------------------------
  Function Rt_Html return varchar2 is
  begin
    return Biruni_Report.Rt_Html;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Rt_Htmlm return varchar2 is
  begin
    return Biruni_Report.Rt_Htmlm;
  end;

  ----------------------------------------------------------------------------------------------------      
  Function Rt_Htmls return varchar2 is
  begin
    return Biruni_Report.Rt_Htmls;
  end;

  ----------------------------------------------------------------------------------------------------      
  Function Rt_Xlsx return varchar2 is
  begin
    return Biruni_Report.Rt_Xlsx;
  end;

  ----------------------------------------------------------------------------------------------------      
  Function Rt_Imp_Xlsx return varchar2 is
  begin
    return Biruni_Report.Rt_Imp_Xlsx;
  end;

  ----------------------------------------------------------------------------------------------------      
  Function Rt_Csv return varchar2 is
  begin
    return Biruni_Report.Rt_Csv;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book
  (
    i_Report_Type varchar2 := null,
    i_File_Name   varchar2 := null
  ) is
  begin
    Biruni_Report.Open_Book(i_Report_Type => i_Report_Type, i_File_Name => i_File_Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book
  (
    p           Hashmap,
    i_File_Name varchar2
  ) is
    v_Rt varchar2(100) := p.o_Varchar2('rt');
  begin
    Biruni_Report.Open_Book(i_Report_Type => v_Rt, i_File_Name => i_File_Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book_With_Styles
  (
    i_Report_Type varchar2 := null,
    i_File_Name   varchar2 := null
  ) is
  begin
    Open_Book(i_Report_Type => i_Report_Type, i_File_Name => i_File_Name);
  
    New_Style(i_Style_Name     => 'root',
              i_Font_Size      => '8',
              i_Font_Color     => '#0C0C0C',
              i_Font_Family    => 'sans-serif',
              i_Border_Color   => '#7F7F7F',
              i_Vertical_Align => a_Top,
              i_Text_Wrap      => true);
  
    New_Style(i_Style_Name        => 'header',
              i_Parent_Style_Name => 'root',
              i_Font_Bold         => true,
              i_Horizontal_Align  => a_Center,
              i_Vertical_Align    => a_Middle,
              i_Background_Color  => '#D5D5D5',
              i_Border            => b_Thin);
  
    New_Style(i_Style_Name        => 'subtotal',
              i_Parent_Style_Name => 'root',
              i_Font_Bold         => true,
              i_Horizontal_Align  => a_Center,
              i_Vertical_Align    => a_Middle,
              i_Background_Color  => '#EAEAEA',
              i_Border            => b_Thin);
  
    New_Style(i_Style_Name        => 'body',
              i_Parent_Style_Name => 'root',
              i_Border            => b_Thin,
              i_Horizontal_Align  => a_Left);
  
    New_Style(i_Style_Name => 'footer', i_Parent_Style_Name => 'header');
  
    New_Style(i_Style_Name => 'bold', i_Font_Bold => true);
    New_Style(i_Style_Name => 'italic', i_Font_Italic => true);
    New_Style(i_Style_Name => 'underline', i_Font_Underline => true);
  
    New_Style(i_Style_Name => 'left', i_Horizontal_Align => a_Left);
    New_Style(i_Style_Name => 'center', i_Horizontal_Align => a_Center);
    New_Style(i_Style_Name => 'right', i_Horizontal_Align => a_Right);
  
    New_Style(i_Style_Name => 'top', i_Vertical_Align => a_Top);
    New_Style(i_Style_Name => 'middle', i_Vertical_Align => a_Middle);
    New_Style(i_Style_Name => 'bottom', i_Vertical_Align => a_Bottom);
  
    New_Style(i_Style_Name => 'text', i_Cell_Format => '@');
  
    New_Style(i_Style_Name => 'number', i_Horizontal_Align => a_Right, i_Cell_Format => '#,##0');
    New_Style(i_Style_Name => 'number1', i_Horizontal_Align => a_Right, i_Cell_Format => '#,##0.0');
    New_Style(i_Style_Name       => 'number2',
              i_Horizontal_Align => a_Right,
              i_Cell_Format      => '#,##0.00');
    New_Style(i_Style_Name       => 'number3',
              i_Horizontal_Align => a_Right,
              i_Cell_Format      => '#,##0.000');
    New_Style(i_Style_Name       => 'number4',
              i_Horizontal_Align => a_Right,
              i_Cell_Format      => '#,##0.0000');
    New_Style(i_Style_Name       => 'number5',
              i_Horizontal_Align => a_Right,
              i_Cell_Format      => '#,##0.00000');
    New_Style(i_Style_Name       => 'number6',
              i_Horizontal_Align => a_Right,
              i_Cell_Format      => '#,##0.000000');
  
    New_Style(i_Style_Name => 'down2up', i_Text_Rotate => -90);
    New_Style(i_Style_Name => 'up2down', i_Text_Rotate => 90);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book_With_Styles
  (
    p           Hashmap,
    i_File_Name varchar2
  ) is
    v_Rt varchar2(100) := p.o_Varchar2('rt');
  begin
    Open_Book_With_Styles(i_Report_Type => v_Rt, i_File_Name => i_File_Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Close_Book is
  begin
    Biruni_Report.Close_Book;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure New_Style
  (
    i_Style_Name          varchar2,
    i_Parent_Style_Name   varchar2 := null,
    i_Font_Size           number := null,
    i_Font_Color          varchar2 := null,
    i_Font_Family         varchar2 := null,
    i_Font_Bold           boolean := null,
    i_Font_Italic         boolean := null,
    i_Font_Underline      boolean := null,
    i_Horizontal_Align    Option_Number := null,
    i_Vertical_Align      Option_Number := null,
    i_Text_Rotate         number := null,
    i_Text_Wrap           boolean := null,
    i_Shrink_To_Fit       boolean := null,
    i_Indent              number := null,
    i_Background_Color    varchar2 := null,
    i_Cell_Format         varchar2 := null,
    i_Border              Option_Varchar2 := null,
    i_Border_Color        varchar2 := null,
    i_Border_Top          Option_Varchar2 := null,
    i_Border_Top_Color    varchar2 := null,
    i_Border_Bottom       Option_Varchar2 := null,
    i_Border_Bottom_Color varchar2 := null,
    i_Border_Left         Option_Varchar2 := null,
    i_Border_Left_Color   varchar2 := null,
    i_Border_Right        Option_Varchar2 := null,
    i_Border_Right_Color  varchar2 := null
  ) is
  begin
    Biruni_Report.New_Style(i_Style_Name          => i_Style_Name,
                            i_Parent_Style_Name   => i_Parent_Style_Name,
                            i_Font_Size           => i_Font_Size,
                            i_Font_Color          => i_Font_Color,
                            i_Font_Family         => i_Font_Family,
                            i_Font_Bold           => i_Font_Bold,
                            i_Font_Italic         => i_Font_Italic,
                            i_Font_Underline      => i_Font_Underline,
                            i_Horizontal_Align    => i_Horizontal_Align,
                            i_Vertical_Align      => i_Vertical_Align,
                            i_Text_Rotate         => i_Text_Rotate,
                            i_Text_Wrap           => i_Text_Wrap,
                            i_Shrink_To_Fit       => i_Shrink_To_Fit,
                            i_Indent              => i_Indent,
                            i_Background_Color    => i_Background_Color,
                            i_Cell_Format         => i_Cell_Format,
                            i_Border              => i_Border,
                            i_Border_Color        => i_Border_Color,
                            i_Border_Top          => i_Border_Top,
                            i_Border_Top_Color    => i_Border_Top_Color,
                            i_Border_Bottom       => i_Border_Bottom,
                            i_Border_Bottom_Color => i_Border_Bottom_Color,
                            i_Border_Left         => i_Border_Left,
                            i_Border_Left_Color   => i_Border_Left_Color,
                            i_Border_Right        => i_Border_Right,
                            i_Border_Right_Color  => i_Border_Right_Color);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Sheet
  (
    i_Name              varchar2,
    p_Table             in out nocopy b_Table,
    i_Param             varchar2 := null,
    i_Zoom              number := null,
    i_No_Gridlines      boolean := null,
    i_Split_Horizontal  number := null,
    i_Split_Vertical    number := null,
    i_Page_Header       number := null,
    i_Page_Footer       number := null,
    i_Page_Top          number := null,
    i_Page_Bottom       number := null,
    i_Page_Left         number := null,
    i_Page_Right        number := null,
    i_Fit_To_Page       boolean := null,
    i_Landscape         boolean := null,
    i_Hidden            boolean := null,
    i_Wrap_Merged_Cells boolean := null
  ) is
  begin
    Biruni_Report.Add_Sheet(i_Name              => i_Name,
                            i_Table_Id          => p_Table.z_Id,
                            i_Param             => i_Param,
                            i_Zoom              => i_Zoom,
                            i_No_Gridlines      => i_No_Gridlines,
                            i_Split_Horizontal  => i_Split_Horizontal,
                            i_Split_Vertical    => i_Split_Vertical,
                            i_Page_Header       => i_Page_Header,
                            i_Page_Footer       => i_Page_Footer,
                            i_Page_Top          => i_Page_Top,
                            i_Page_Bottom       => i_Page_Bottom,
                            i_Page_Left         => i_Page_Left,
                            i_Page_Right        => i_Page_Right,
                            i_Fit_To_Page       => i_Fit_To_Page,
                            i_Landscape         => i_Landscape,
                            i_Hidden            => i_Hidden,
                            i_Wrap_Merged_Cells => i_Wrap_Merged_Cells);
  
    Biruni_Report.Close_Table(p_Table.z_Id,
                              p_Table.z_Buf,
                              p_Table.z_Row_No,
                              p_Table.z_Column_Widths,
                              p_Table.z_Column_Data_Sources,
                              p_Table.z_Groupings,
                              p_Table.z_Grid_Contents);
    p_Table.z_Id := null;
  end;

  ----------------------------------------------------------------------------------------------------
  Function New_Table(i_Parent b_Table := null) return b_Table is
    v_Table b_Table := b_Table(Biruni_Report.New_Table_Id);
    v       varchar2(4000);
  begin
    v := '[' || Biruni_Report.Esc('table') || Biruni_Report.Esc(v_Table.z_Id) || '[';
  
    Biruni_Report.Print(v_Table.z_Id, v_Table.z_Buf, v);
  
    if i_Parent is not null then
      v_Table.z_Cur_Style_Name := i_Parent.z_Cur_Style_Name;
    end if;
  
    return v_Table;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Standart_Styles is
  begin
    Biruni_Report.New_Style(i_Style_Name     => 'root',
                            i_Font_Size      => '8',
                            i_Font_Color     => '#0C0C0C',
                            i_Font_Family    => 'sans-serif',
                            i_Border_Color   => '#7F7F7F',
                            i_Vertical_Align => a_Top,
                            i_Text_Wrap      => true);
  
    ---- info -----
    Biruni_Report.New_Style(i_Style_Name        => 'info',
                            i_Parent_Style_Name => 'root',
                            i_Horizontal_Align  => a_Left,
                            i_Font_Bold         => true);
  
    Biruni_Report.New_Style(i_Style_Name        => 'info_underline',
                            i_Parent_Style_Name => 'info',
                            i_Border_Bottom     => b_Thin);
  
    ---- header ----
    Biruni_Report.New_Style(i_Style_Name        => 'header',
                            i_Parent_Style_Name => 'root',
                            i_Font_Bold         => true,
                            i_Horizontal_Align  => a_Center,
                            i_Vertical_Align    => a_Middle,
                            i_Background_Color  => '#C4C4C4',
                            i_Border            => b_Thin);
  
    Biruni_Report.New_Style(i_Style_Name        => 'header_left',
                            i_Parent_Style_Name => 'header',
                            i_Horizontal_Align  => a_Left);
  
    Biruni_Report.New_Style(i_Style_Name        => 'header_right',
                            i_Parent_Style_Name => 'header',
                            i_Horizontal_Align  => a_Right);
  
    ------ body ----
    Biruni_Report.New_Style(i_Style_Name        => 'body',
                            i_Parent_Style_Name => 'root',
                            i_Border            => b_Thin,
                            i_Horizontal_Align  => a_Left);
  
    Biruni_Report.New_Style(i_Style_Name        => 'body_right',
                            i_Parent_Style_Name => 'body',
                            i_Horizontal_Align  => a_Right);
  
    Biruni_Report.New_Style(i_Style_Name        => 'body_center',
                            i_Parent_Style_Name => 'body',
                            i_Horizontal_Align  => a_Center);
  
    Biruni_Report.New_Style(i_Style_Name        => 'body_summ',
                            i_Parent_Style_Name => 'body_right',
                            i_Cell_Format       => '#,##0.00');
  
    ----- footer -----
    Biruni_Report.New_Style(i_Style_Name => 'footer', i_Parent_Style_Name => 'header');
  
    Biruni_Report.New_Style(i_Style_Name        => 'footer_left',
                            i_Parent_Style_Name => 'footer',
                            i_Horizontal_Align  => a_Left);
  
    Biruni_Report.New_Style(i_Style_Name        => 'footer_right',
                            i_Parent_Style_Name => 'footer',
                            i_Horizontal_Align  => a_Right);
  
    Biruni_Report.New_Style(i_Style_Name        => 'footer_summ',
                            i_Parent_Style_Name => 'footer_right',
                            i_Cell_Format       => '#,##0.00');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Redirect(p Hashmap) return boolean is
  begin
    return p.o_Varchar2('rt') = 'go';
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Redirect_To_Report
  (
    i_Uri   varchar2,
    i_Param Hashmap
  ) is
    result Hashmap := Hashmap();
  begin
    Result.Put('type', 'report');
    Result.Put('context_path', b_Session.Request_Context_Path);
    Result.Put('uri', i_Uri);
    Result.Put('param', i_Param);
    Biruni_Route.Set_Report_Redirect(result);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Redirect_To_Form
  (
    i_Uri       varchar2,
    i_Param     Hashmap,
    i_Filial_Id number := null
  ) is
    result Hashmap := Hashmap();
  begin
    Result.Put('type', 'form');
    Result.Put('context_path', b_Session.Request_Context_Path);
    Result.Put('uri', i_Uri);
    Result.Put('param', i_Param);
    Result.Put('filial_id', i_Filial_Id);
    Biruni_Route.Set_Report_Redirect(result);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Redirect_To_Window
  (
    i_Uri               varchar2,
    i_Param             Hashmap := null,
    i_With_Context_Path boolean := true
  ) is
    result Hashmap := Hashmap();
  begin
    Result.Put('type', 'window');
    Result.Put('uri', i_Uri);
  
    if i_Param is not null then
      Result.Put('param', i_Param);
    end if;
  
    if i_With_Context_Path then
      Result.Put('context_path', b_Session.Request_Context_Path);
    end if;
  
    Biruni_Route.Set_Report_Redirect(result);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Menu
  (
    i_Id    number,
    i_Title varchar2
  ) is
  begin
    Biruni_Report.Add_Menu(i_Id => i_Id, i_Title => i_Title);
  end;

end b_Report;
/
