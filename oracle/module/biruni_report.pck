create or replace package Biruni_Report is
  ----------------------------------------------------------------------------------------------------
  Rt_Html     constant varchar2(10) := 'html';
  Rt_Htmlm    constant varchar2(10) := 'htmlm';
  Rt_Htmls    constant varchar2(10) := 'htmls';
  Rt_Xlsx     constant varchar2(10) := 'xlsx';
  Rt_Imp_Xlsx constant varchar2(10) := 'imp_xlsx';
  Rt_Csv      constant varchar2(10) := 'csv';
  ----------------------------------------------------------------------------------------------------
  g_Replace_New_Line boolean := null;
  g_Max_Report_Size  number := 100 * 1024 * 1024; -- in bytes
  ----------------------------------------------------------------------------------------------------
  Procedure Flush
  (
    i_Table_Id number,
    p_Buf      in out nocopy varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Print
  (
    i_Table_Id number,
    p_Buf      in out nocopy varchar2,
    i_Line     varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Esc(i_Val varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Pair
  (
    i_Val1 varchar2,
    i_Val2 varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Report_Type return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book
  (
    i_Report_Type varchar2 := null,
    i_File_Name   varchar2 := null
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
    i_Table_Id          number,
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
    i_Wrap_Merged_Cells boolean := null -- this variable determines whether merged cells should be wrapped text or not
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Column_Width
  (
    p_Column_Widths in out nocopy Array_Number,
    i_Column_Index  number,
    i_Width         number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Column_Data_Source
  (
    p_Column_Data_Sources in out nocopy Array_Varchar2,
    i_Column_Index        number,
    i_Source              varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function New_Table_Id return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Close_Table
  (
    i_Table_Id            number,
    p_Buf                 in out nocopy varchar2,
    i_Row_No              number,
    i_Column_Widths       Array_Number,
    i_Column_Data_Sources Array_Varchar2,
    i_Groupings           Array_Varchar2,
    i_Grids               Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Get_Style_Index(i_Style_Name varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Function Get_Style_Index
  (
    i_Row_No          number,
    i_Cur_Style_Name  varchar2,
    i_Odd_Style_Name  varchar2,
    i_Even_Style_Name varchar2
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Print_Cell
  (
    i_Table_Id    number,
    p_Buf         in out nocopy varchar2,
    i_Cell_Type   varchar2,
    i_Val         varchar2,
    i_Style_Index number := null,
    i_Colspan     number := null,
    i_Rowspan     number := null,
    i_Param       varchar2 := null,
    i_Width       number := null,
    i_Height      number := null,
    i_Label       boolean := true,
    i_Menu_Ids    varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Menu
  (
    i_Id    number,
    i_Title varchar2
  );
end Biruni_Report;
/
create or replace package body Biruni_Report is
  ----------------------------------------------------------------------------------------------------
  type Style_Rt is record(
    Font_Size           number,
    Font_Color          varchar2(20),
    Font_Family         varchar2(100),
    Font_Bold           boolean,
    Font_Italic         boolean,
    Font_Underline      boolean,
    Horizontal_Align    Option_Number,
    Vertical_Align      Option_Number,
    Text_Rotate         number,
    Text_Wrap           boolean,
    Shrink_To_Fit       boolean,
    Indent              number,
    Background_Color    varchar2(20),
    Cell_Format         varchar2(20),
    Border_Top          Option_Varchar2,
    Border_Top_Color    varchar2(20),
    Border_Bottom       Option_Varchar2,
    Border_Bottom_Color varchar2(20),
    Border_Left         Option_Varchar2,
    Border_Left_Color   varchar2(20),
    Border_Right        Option_Varchar2,
    Border_Right_Color  varchar2(20));
  type Style_Aat is table of Style_Rt index by varchar2(100);

  ----------------------------------------------------------------------------------------------------
  g_Fonts            Array_Varchar2;
  g_Styles           Array_Varchar2;
  g_Cell_Metas       Array_Varchar2;
  g_Style_Names      Fazo.Number_Code_Aat;
  g_Style_Raws       Style_Aat;
  g_Cell_Metas_Index Fazo.Number_Code_Aat;
  g_Menus            Arraylist;

  g_Report_Type  varchar2(10);
  g_Book_Ready   boolean;
  g_Enable_Param boolean;

  g_Table_Id_Sq      number;
  g_Closed_Table_Ids Fazo.Boolean_Id_Aat;

  g_Line_Order_No number;
  g_Book_Buf      varchar2(4000);
  g_Report_Size   number;

  ----------------------------------------------------------------------------------------------------
  Procedure Init is
  begin
    g_Fonts      := Array_Varchar2();
    g_Styles     := Array_Varchar2();
    g_Cell_Metas := Array_Varchar2();
    g_Menus      := Arraylist();
    g_Style_Names.Delete;
    g_Style_Raws.Delete;
    g_Cell_Metas_Index.Delete;
  
    g_Report_Type  := null;
    g_Book_Ready   := false;
    g_Enable_Param := false;
  
    g_Table_Id_Sq := 0;
    g_Closed_Table_Ids.Delete;
  
    g_Line_Order_No := 0;
    g_Book_Buf      := null;
    g_Report_Size   := 0;
  
    delete from Biruni_Report_Lines;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Throw_Error(i_Message varchar2) is
  begin
    Init;
    Raise_Application_Error(-20999, 'Biruni Report: ' || i_Message);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Flush
  (
    i_Table_Id number,
    p_Buf      in out nocopy varchar2
  ) is
  begin
    if p_Buf is not null then
      insert into Biruni_Report_Lines
        (Table_Id, Order_No, Line)
      values
        (i_Table_Id, g_Line_Order_No, p_Buf);
    
      g_Closed_Table_Ids(i_Table_Id) := false;
    
      g_Line_Order_No := g_Line_Order_No + 1;
    
      g_Report_Size := g_Report_Size + Length(p_Buf);
      if g_Report_Size > g_Max_Report_Size then
        Raise_Application_Error(-20999, 'BIRUNI: report size too large');
      end if;
    
      p_Buf := null;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print
  (
    i_Table_Id number,
    p_Buf      in out nocopy varchar2,
    i_Line     varchar2
  ) is
  begin
    if g_Book_Ready then
      null;
    else
      Throw_Error('Book is not opened');
    end if;
  
    begin
      p_Buf := p_Buf || i_Line;
    exception
      when Value_Error then
        Flush(i_Table_Id, p_Buf);
        p_Buf := i_Line;
    end;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print(i_Line varchar2) is
  begin
    Print(0, g_Book_Buf, i_Line);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Esc(i_Val varchar2) return varchar2 is
    v varchar2(1) := Chr(0);
  begin
    return v || replace(i_Val, v, ' ') || v;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Pair
  (
    i_Val1 varchar2,
    i_Val2 varchar2
  ) return varchar2 is
  begin
    return '[' || Esc(i_Val1) || Esc(i_Val2) || ']';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Report_Type return varchar2 is
  begin
    return g_Report_Type;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Open_Book
  (
    i_Report_Type varchar2 := null,
    i_File_Name   varchar2 := null
  ) is
    v            varchar2(4000);
    v_Action_Out varchar2(2);
  begin
    if g_Book_Ready then
      Throw_Error('book is already opened');
    end if;
  
    v_Action_Out := Biruni_Route.Request_Route_Action_Out;
  
    if v_Action_Out = 'R' then
      v_Action_Out := Biruni_Route.Runtime_Response_Action_Out;
    end if;
  
    if v_Action_Out is not null and v_Action_Out not in ('Q', 'LR') then
      Throw_Error('route action must be procedure or fazo_query');
    end if;
  
    Init;
  
    g_Report_Type      := Nvl(i_Report_Type, Rt_Html);
    g_Book_Ready       := true;
    g_Enable_Param     := g_Report_Type = Rt_Html or i_Report_Type = Rt_Htmls;
    g_Replace_New_Line := g_Report_Type != Rt_Xlsx and g_Report_Type != Rt_Imp_Xlsx;
  
    v := Pair('file_name', i_File_Name);
    v := v || Pair('url', Biruni_Route.Request_Url);
    v := v || Pair('context_path', Biruni_Route.Request_Context_Path);
    v := v || Pair('report_type', i_Report_Type);
  
    Print('[');
    Print('[' || Esc('setting') || v || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Entities
  (
    i_Name varchar2,
    i_Val  Array_Varchar2
  ) is
  begin
    Print('[' || Esc(i_Name));
    for i in 1 .. i_Val.Count
    loop
      Print('[' || i_Val(i) || ']');
    end loop;
    Print(']');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Recycle_Table_If_Opened(i_Table_Id number) is
  begin
    if g_Closed_Table_Ids(i_Table_Id) = false then
      delete from Biruni_Report_Lines t
       where t.Table_Id = i_Table_Id;
    end if;
  exception
    when No_Data_Found then
      null;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Close_Book is
  begin
    if g_Book_Ready then
      null;
    else
      Throw_Error('book has not opened yet');
    end if;
  
    Print_Entities('font', g_Fonts);
    Print_Entities('style', g_Styles);
    Print_Entities('cell_meta', g_Cell_Metas);
    if g_Menus.Count > 0 then
      Print(Pair('menus', g_Menus.Json));
    end if;
    Flush(0, g_Book_Buf);
  
    for i in 1 .. g_Table_Id_Sq
    loop
      Recycle_Table_If_Opened(i);
    end loop;
  
    g_Book_Buf := ']';
    Flush(New_Table_Id, g_Book_Buf);
  
    Biruni_Route.Set_Report_Line_Count(g_Line_Order_No);
    g_Book_Ready := false;
  
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Sheet
  (
    i_Name              varchar2,
    i_Table_Id          number,
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
    v varchar2(4000);
  begin
    v := Pair('name', replace(i_Name, ':', ' '));
    v := v || Pair('table_id', i_Table_Id);
  
    if i_Param is not null then
      v := v || Pair('param', i_Param);
    end if;
    if i_Zoom is not null then
      v := v || Pair('zoom', i_Zoom);
    end if;
    if i_No_Gridlines then
      v := v || Pair('no_gridlines', 'Y');
    end if;
    if i_Split_Horizontal is not null then
      v := v || Pair('split_horizontal', i_Split_Horizontal);
    end if;
    if i_Split_Vertical is not null then
      v := v || Pair('split_vertical', i_Split_Vertical);
    end if;
    if i_Page_Header is not null then
      v := v || Pair('page_header', i_Page_Header);
    end if;
    if i_Page_Footer is not null then
      v := v || Pair('page_footer', i_Page_Footer);
    end if;
    if i_Page_Top is not null then
      v := v || Pair('page_top', i_Page_Top);
    end if;
    if i_Page_Bottom is not null then
      v := v || Pair('page_bottom', i_Page_Bottom);
    end if;
    if i_Page_Left is not null then
      v := v || Pair('page_left', i_Page_Left);
    end if;
    if i_Page_Right is not null then
      v := v || Pair('page_right', i_Page_Right);
    end if;
    if i_Fit_To_Page is not null then
      v := v || Pair('fit_to_page', 'Y');
    end if;
    if i_Landscape is not null then
      v := v || Pair('landscape', 'Y');
    end if;
    if i_Hidden is not null then
      v := v || Pair('hidden', 'Y');
    end if;
  
    if i_Wrap_Merged_Cells then
      v := v || Pair('wrap_merged_cells', 'Y');
    end if;
  
    Print('[' || Esc('sheet') || v || ']');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Column_Width
  (
    p_Column_Widths in out nocopy Array_Number,
    i_Column_Index  number,
    i_Width         number
  ) is
  begin
    if p_Column_Widths.Count < i_Column_Index then
      p_Column_Widths.Extend(i_Column_Index - p_Column_Widths.Count);
    end if;
  
    p_Column_Widths(i_Column_Index) := i_Width;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Column_Data_Source
  (
    p_Column_Data_Sources in out nocopy Array_Varchar2,
    i_Column_Index        number,
    i_Source              varchar2
  ) is
  begin
    if p_Column_Data_Sources.Count < i_Column_Index then
      p_Column_Data_Sources.Extend(i_Column_Index - p_Column_Data_Sources.Count);
    end if;
  
    p_Column_Data_Sources(i_Column_Index) := i_Source;
  end;

  ----------------------------------------------------------------------------------------------------
  Function New_Table_Id return number is
  begin
    g_Table_Id_Sq := g_Table_Id_Sq + 1;
    return g_Table_Id_Sq;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Column_Widths
  (
    i_Table_Id      number,
    p_Buf           in out nocopy varchar2,
    i_Column_Widths Array_Number
  ) is
  begin
    Print(i_Table_Id, p_Buf, '[');
    for i in 1 .. i_Column_Widths.Count
    loop
      Print(i_Table_Id, p_Buf, Esc(i_Column_Widths(i)));
    end loop;
    Print(i_Table_Id, p_Buf, ']');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Column_Data_Sources
  (
    i_Table_Id            number,
    p_Buf                 in out nocopy varchar2,
    i_Column_Data_Sources Array_Varchar2
  ) is
  begin
    Print(i_Table_Id, p_Buf, '[');
    for i in 1 .. i_Column_Data_Sources.Count
    loop
      Print(i_Table_Id, p_Buf, Esc(i_Column_Data_Sources(i)));
    end loop;
    Print(i_Table_Id, p_Buf, ']');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Groupings
  (
    i_Table_Id  number,
    p_Buf       in out nocopy varchar2,
    i_Groupings Array_Varchar2
  ) is
  begin
    Print(i_Table_Id, p_Buf, '[');
    for i in 1 .. i_Groupings.Count
    loop
      Print(i_Table_Id, p_Buf, i_Groupings(i));
    end loop;
    Print(i_Table_Id, p_Buf, ']');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Grid_Contents
  (
    i_Table_Id number,
    p_Buf      in out nocopy varchar2,
    i_Grids    Array_Varchar2
  ) is
  begin
    Print(i_Table_Id, p_Buf, '[');
    for i in 1 .. i_Grids.Count
    loop
      Print(i_Table_Id, p_Buf, i_Grids(i));
    end loop;
    Print(i_Table_Id, p_Buf, ']');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Is_Table_Closed(i_Table_Id number) return boolean is
  begin
    return g_Closed_Table_Ids(i_Table_Id);
  exception
    when No_Data_Found then
      return false;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Close_Table
  (
    i_Table_Id            number,
    p_Buf                 in out nocopy varchar2,
    i_Row_No              number,
    i_Column_Widths       Array_Number,
    i_Column_Data_Sources Array_Varchar2,
    i_Groupings           Array_Varchar2,
    i_Grids               Array_Varchar2
  ) is
  begin
    if i_Table_Id is null or Is_Table_Closed(i_Table_Id) then
      Throw_Error('Table is already closed');
    end if;
    if Nvl(i_Row_No, 0) = 0 then
      Throw_Error('Table must have at least one row');
    end if;
  
    Print(i_Table_Id, p_Buf, ']]');
    Print_Column_Widths(i_Table_Id, p_Buf, i_Column_Widths);
    Print_Column_Data_Sources(i_Table_Id, p_Buf, i_Column_Data_Sources);
    Print_Groupings(i_Table_Id, p_Buf, i_Groupings);
    Print_Grid_Contents(i_Table_Id, p_Buf, i_Grids);
    Print(i_Table_Id, p_Buf, ']');
  
    Flush(i_Table_Id, p_Buf);
  
    g_Closed_Table_Ids(i_Table_Id) := true;
  end;

  ----------------------------------------------------------------------------------------------------
  -- http://wwwyourhtmlsource..com/stylesheets/namedcolours.html
  Function Translate_Color_Names(i_Color_Name varchar2) return varchar2 is
  begin
    return case i_Color_Name --
    when 'maroon' then '#800000' --
    when 'red' then '#ff0000' --
    when 'orange' then '#ffA500' --
    when 'yellow' then '#ffff00' --
    when 'olive' then '#808000' --
    when 'purple' then '#800080' --
    when 'fuchsia' then '#ff00ff' --
    when 'white' then '#ffffff' --
    when 'lime' then '#00ff00' --
    when 'green' then '#008000' --
    when 'navy' then '#000080' --
    when 'blue' then '#0000ff' --
    when 'aqua' then '#00ffff' --
    when 'teal' then '#008080' --
    when 'black' then '#000000' --
    when 'silver' then '#c0c0c0' --
    when 'gray' then '#808080' --
    when 'magenta' then '#FF0080' --
    else i_Color_Name end;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Font
  (
    i_Size      number,
    i_Color     varchar2,
    i_Family    varchar2,
    i_Bold      boolean,
    i_Italic    boolean,
    i_Underline boolean
  ) return varchar2 is
    v varchar2(4000);
  begin
    if i_Size > 0 then
      v := v || Pair('size', i_Size);
    end if;
    if i_Color is not null then
      v := v || Pair('color', Translate_Color_Names(i_Color));
    end if;
    if i_Family is not null then
      v := v || Pair('family', i_Family);
    end if;
    if i_Bold then
      v := v || Pair('bold', 'Y');
    end if;
    if i_Italic then
      v := v || Pair('italic', 'Y');
    end if;
    if i_Underline then
      v := v || Pair('underline', 'Y');
    end if;
  
    return v;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Style
  (
    i_Font_Index          number,
    i_Align               number,
    i_Valign              number,
    i_Rotate              number,
    i_Indent              number,
    i_Bg_Color            varchar2,
    i_Format              varchar2,
    i_Wrap                boolean,
    i_Shrink_To_Fit       boolean,
    i_Border_Top          varchar2,
    i_Border_Top_Color    varchar2,
    i_Border_Bottom       varchar2,
    i_Border_Bottom_Color varchar2,
    i_Border_Left         varchar2,
    i_Border_Left_Color   varchar2,
    i_Border_Right        varchar2,
    i_Border_Right_Color  varchar2
  ) return varchar2 is
    v varchar2(4000);
  begin
    if i_Font_Index > 0 then
      v := v || Pair('font_index', i_Font_Index);
    end if;
    if i_Align in (1, 2, 3) then
      v := v || Pair('align', i_Align);
    end if;
    if i_Valign in (1, 2, 3) then
      v := v || Pair('valign', i_Valign);
    end if;
    if -180 <= i_Rotate and i_Rotate <= 180 then
      v := v || Pair('rotate', i_Rotate);
    end if;
    if i_Indent > 0 then
      v := v || Pair('indent', i_Indent);
    end if;
    if i_Bg_Color is not null then
      v := v || Pair('bg_color', Translate_Color_Names(i_Bg_Color));
    end if;
    if i_Format is not null then
      v := v || Pair('format', i_Format);
    end if;
    if i_Wrap then
      v := v || Pair('wrap', 'Y');
    end if;
    if i_Shrink_To_Fit then
      v := v || Pair('shrink_to_fit', 'Y');
    end if;
  
    if i_Border_Top is not null then
      v := v || Pair('b_top', i_Border_Top);
      if i_Border_Top_Color is not null then
        v := v || Pair('b_top_color', Translate_Color_Names(i_Border_Top_Color));
      end if;
    end if;
  
    if i_Border_Bottom is not null then
      v := v || Pair('b_bottom', i_Border_Bottom);
      if i_Border_Bottom_Color is not null then
        v := v || Pair('b_bottom_color', Translate_Color_Names(i_Border_Bottom_Color));
      end if;
    end if;
  
    if i_Border_Left is not null then
      v := v || Pair('b_left', i_Border_Left);
      if i_Border_Left_Color is not null then
        v := v || Pair('b_left_color', Translate_Color_Names(i_Border_Left_Color));
      end if;
    end if;
  
    if i_Border_Right is not null then
      v := v || Pair('b_right', i_Border_Right);
      if i_Border_Right_Color is not null then
        v := v || Pair('b_right_color', Translate_Color_Names(i_Border_Right_Color));
      end if;
    end if;
  
    return v;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Serial_Cell_Meta
  (
    i_Cell_Type   varchar2,
    i_Style_Index number,
    i_Colspan     number,
    i_Rowspan     number,
    i_Width       number,
    i_Height      number,
    i_Label       boolean,
    i_Menu_Ids    varchar2
  ) return varchar2 is
    v varchar2(4000);
  begin
    v := Pair('type', i_Cell_Type);
  
    if i_Style_Index >= 0 then
      v := v || Pair('style_index', i_Style_Index);
    end if;
  
    if i_Rowspan >= 1 then
      v := v || Pair('rowspan', i_Rowspan);
    end if;
  
    if i_Colspan >= 1 then
      v := v || Pair('colspan', i_Colspan);
    end if;
  
    if i_Width > 0 then
      v := v || Pair('width', i_Width);
    end if;
  
    if i_Height > 0 then
      v := v || Pair('height', i_Height);
    end if;
  
    if not i_Label then
      v := v || Pair('label', 'N');
    end if;
  
    if i_Menu_Ids is not null then
      v := v || Pair('menuIds', i_Menu_Ids);
    end if;
  
    return v;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure New_Style
  (
    i_Style_Name varchar2,
    i_Style      Style_Rt
  ) is
    v_Font        varchar2(4000);
    v_Style       varchar2(4000);
    v_Font_Index  pls_integer;
    v_Style_Index pls_integer;
  
    ----------------------------------------------------------------------
    Function Nval(i_Val Option_Number) return number is
    begin
      if i_Val is not null then
        return i_Val.Val;
      end if;
      return null;
    end;
  
    ----------------------------------------------------------------------
    Function Vval(i_Val Option_Varchar2) return varchar2 is
    begin
      if i_Val is not null then
        return i_Val.Val;
      else
        return null;
      end if;
    end;
  begin
    if i_Style_Name is null then
      Throw_Error('style name is missing');
    end if;
    if g_Style_Names.Exists(i_Style_Name) then
      Throw_Error('style name is duplicated [' || i_Style_Name || ']');
    end if;
  
    v_Font := Serial_Font(i_Size      => i_Style.Font_Size,
                          i_Color     => i_Style.Font_Color,
                          i_Family    => i_Style.Font_Family,
                          i_Bold      => i_Style.Font_Bold,
                          i_Italic    => i_Style.Font_Italic,
                          i_Underline => i_Style.Font_Underline);
  
    if v_Font is not null then
      v_Font_Index := Fazo.Index_Of(g_Fonts, v_Font);
      if v_Font_Index = 0 then
        g_Fonts.Extend;
        v_Font_Index := g_Fonts.Count;
        g_Fonts(v_Font_Index) := v_Font;
      end if;
    end if;
  
    v_Style := Serial_Style(i_Font_Index          => v_Font_Index,
                            i_Align               => Nval(i_Style.Horizontal_Align),
                            i_Valign              => Nval(i_Style.Vertical_Align),
                            i_Rotate              => i_Style.Text_Rotate,
                            i_Indent              => i_Style.Indent,
                            i_Bg_Color            => i_Style.Background_Color,
                            i_Format              => i_Style.Cell_Format,
                            i_Wrap                => i_Style.Text_Wrap,
                            i_Shrink_To_Fit       => i_Style.Shrink_To_Fit,
                            i_Border_Top          => Vval(i_Style.Border_Top),
                            i_Border_Top_Color    => i_Style.Border_Top_Color,
                            i_Border_Bottom       => Vval(i_Style.Border_Bottom),
                            i_Border_Bottom_Color => i_Style.Border_Bottom_Color,
                            i_Border_Left         => Vval(i_Style.Border_Left),
                            i_Border_Left_Color   => i_Style.Border_Left_Color,
                            i_Border_Right        => Vval(i_Style.Border_Right),
                            i_Border_Right_Color  => i_Style.Border_Right_Color);
  
    if v_Style is null then
      Throw_Error('empty style [' || i_Style_Name || ']');
    end if;
  
    v_Style_Index := Fazo.Index_Of(g_Styles, v_Style);
    if v_Style_Index = 0 then
      g_Styles.Extend;
      v_Style_Index := g_Styles.Count;
      g_Styles(v_Style_Index) := v_Style;
    end if;
  
    g_Style_Names(i_Style_Name) := v_Style_Index;
    g_Style_Raws(i_Style_Name) := i_Style;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Merge_Style
  (
    p_Style  in out Style_Rt,
    i_Parent Style_Rt
  ) is
  begin
    p_Style.Font_Size           := Nvl(p_Style.Font_Size, i_Parent.Font_Size);
    p_Style.Font_Color          := Nvl(p_Style.Font_Color, i_Parent.Font_Color);
    p_Style.Font_Family         := Nvl(p_Style.Font_Family, i_Parent.Font_Family);
    p_Style.Font_Bold           := Nvl(p_Style.Font_Bold, i_Parent.Font_Bold);
    p_Style.Font_Italic         := Nvl(p_Style.Font_Italic, i_Parent.Font_Italic);
    p_Style.Font_Underline      := Nvl(p_Style.Font_Underline, i_Parent.Font_Underline);
    p_Style.Horizontal_Align    := Nvl(p_Style.Horizontal_Align, i_Parent.Horizontal_Align);
    p_Style.Vertical_Align      := Nvl(p_Style.Vertical_Align, i_Parent.Vertical_Align);
    p_Style.Text_Rotate         := Nvl(p_Style.Text_Rotate, i_Parent.Text_Rotate);
    p_Style.Text_Wrap           := Nvl(p_Style.Text_Wrap, i_Parent.Text_Wrap);
    p_Style.Shrink_To_Fit       := Nvl(p_Style.Shrink_To_Fit, i_Parent.Shrink_To_Fit);
    p_Style.Indent              := Nvl(p_Style.Indent, i_Parent.Indent);
    p_Style.Background_Color    := Nvl(p_Style.Background_Color, i_Parent.Background_Color);
    p_Style.Cell_Format         := Nvl(p_Style.Cell_Format, i_Parent.Cell_Format);
    p_Style.Border_Top          := Nvl(p_Style.Border_Top, i_Parent.Border_Top);
    p_Style.Border_Top_Color    := Nvl(p_Style.Border_Top_Color, i_Parent.Border_Top_Color);
    p_Style.Border_Bottom       := Nvl(p_Style.Border_Bottom, i_Parent.Border_Bottom);
    p_Style.Border_Bottom_Color := Nvl(p_Style.Border_Bottom_Color, i_Parent.Border_Bottom_Color);
    p_Style.Border_Left         := Nvl(p_Style.Border_Left, i_Parent.Border_Left);
    p_Style.Border_Left_Color   := Nvl(p_Style.Border_Left_Color, i_Parent.Border_Left_Color);
    p_Style.Border_Right        := Nvl(p_Style.Border_Right, i_Parent.Border_Right);
    p_Style.Border_Right_Color  := Nvl(p_Style.Border_Right_Color, i_Parent.Border_Right_Color);
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
    r_Style  Style_Rt;
    r_Parent Style_Rt;
  begin
    if not Regexp_Like(i_Style_Name, '^[A-Za-z0-9_-]+$') then
      Throw_Error('style name does not conform to ^[A-Za-z0-9_-]+$');
    end if;
  
    r_Style.Font_Size           := i_Font_Size;
    r_Style.Font_Color          := i_Font_Color;
    r_Style.Font_Family         := i_Font_Family;
    r_Style.Font_Bold           := i_Font_Bold;
    r_Style.Font_Italic         := i_Font_Italic;
    r_Style.Font_Underline      := i_Font_Underline;
    r_Style.Horizontal_Align    := i_Horizontal_Align;
    r_Style.Vertical_Align      := i_Vertical_Align;
    r_Style.Text_Rotate         := i_Text_Rotate;
    r_Style.Text_Wrap           := i_Text_Wrap;
    r_Style.Shrink_To_Fit       := i_Shrink_To_Fit;
    r_Style.Indent              := i_Indent;
    r_Style.Background_Color    := i_Background_Color;
    r_Style.Cell_Format         := i_Cell_Format;
    r_Style.Border_Top          := Nvl(i_Border_Top, i_Border);
    r_Style.Border_Top_Color    := Nvl(i_Border_Top_Color, i_Border_Color);
    r_Style.Border_Bottom       := Nvl(i_Border_Bottom, i_Border);
    r_Style.Border_Bottom_Color := Nvl(i_Border_Bottom_Color, i_Border_Color);
    r_Style.Border_Left         := Nvl(i_Border_Left, i_Border);
    r_Style.Border_Left_Color   := Nvl(i_Border_Left_Color, i_Border_Color);
    r_Style.Border_Right        := Nvl(i_Border_Right, i_Border);
    r_Style.Border_Right_Color  := Nvl(i_Border_Right_Color, i_Border_Color);
  
    if i_Parent_Style_Name is not null then
      begin
        r_Parent := g_Style_Raws(i_Parent_Style_Name);
        Merge_Style(p_Style => r_Style, i_Parent => r_Parent);
      exception
        when No_Data_Found then
          Throw_Error('parent style is not found [' || i_Parent_Style_Name || ']');
      end;
    end if;
  
    New_Style(i_Style_Name, r_Style);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Create_Style(i_Style_Name varchar2) is
    r_Style  Style_Rt;
    r_Parent Style_Rt;
    v_Styles Array_Varchar2 := Fazo.Split(i_Style_Name, ' ');
  begin
    if v_Styles.Count <= 1 then
      Throw_Error('style is not found [' || i_Style_Name || ']');
    end if;
  
    for i in reverse 1 .. v_Styles.Count
    loop
      r_Parent := g_Style_Raws(v_Styles(i));
      Merge_Style(p_Style => r_Style, i_Parent => r_Parent);
    end loop;
  
    New_Style(i_Style_Name, r_Style);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Style_Index(i_Style_Name varchar2) return number is
  begin
    if i_Style_Name is null then
      return null;
    end if;
    return g_Style_Names(i_Style_Name);
  exception
    when No_Data_Found then
      begin
        Create_Style(i_Style_Name);
        return g_Style_Names(i_Style_Name);
      exception
        when No_Data_Found then
          Throw_Error('style is not created [' || i_Style_Name || ']');
      end;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Style_Index
  (
    i_Row_No          number,
    i_Cur_Style_Name  varchar2,
    i_Odd_Style_Name  varchar2,
    i_Even_Style_Name varchar2
  ) return number is
  begin
    if i_Odd_Style_Name is not null or i_Even_Style_Name is not null then
      if mod(i_Row_No, 2) = 0 then
        if i_Even_Style_Name is not null then
          return Get_Style_Index(i_Cur_Style_Name || ' ' || i_Even_Style_Name);
        end if;
      else
        if i_Odd_Style_Name is not null then
          return Get_Style_Index(i_Cur_Style_Name || ' ' || i_Odd_Style_Name);
        end if;
      end if;
    end if;
    return Get_Style_Index(i_Cur_Style_Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Cell
  (
    i_Table_Id    number,
    p_Buf         in out nocopy varchar2,
    i_Cell_Type   varchar2,
    i_Val         varchar2,
    i_Style_Index number := null,
    i_Colspan     number := null,
    i_Rowspan     number := null,
    i_Param       varchar2 := null,
    i_Width       number := null,
    i_Height      number := null,
    i_Label       boolean := true,
    i_Menu_Ids    varchar2 := null
  ) is
    v_Meta       varchar2(4000);
    v_Meta_Index number;
  begin
    if i_Table_Id is null then
      Throw_Error('table id is null');
    end if;
    v_Meta := Serial_Cell_Meta(i_Cell_Type   => i_Cell_Type,
                               i_Style_Index => i_Style_Index,
                               i_Rowspan     => i_Rowspan,
                               i_Colspan     => i_Colspan,
                               i_Width       => i_Width,
                               i_Height      => i_Height,
                               i_Label       => i_Label,
                               i_Menu_Ids    => i_Menu_Ids);
  
    begin
      v_Meta_Index := g_Cell_Metas_Index(v_Meta);
    exception
      when No_Data_Found then
        g_Cell_Metas.Extend;
        v_Meta_Index := g_Cell_Metas.Count;
        g_Cell_Metas(v_Meta_Index) := v_Meta;
        g_Cell_Metas_Index(v_Meta) := v_Meta_Index;
    end;
  
    if i_Param is not null and g_Enable_Param then
      Print(i_Table_Id, p_Buf, '[' || Esc(v_Meta_Index) || Esc(i_Val) || Esc(i_Param) || ']');
    else
      Print(i_Table_Id, p_Buf, '[' || Esc(v_Meta_Index) || Esc(i_Val) || ']');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Menu
  (
    i_Id    number,
    i_Title varchar2
  ) is
  begin
    g_Menus.Push(Array_Varchar2(i_Id, i_Title));
  end;

end Biruni_Report;
/
