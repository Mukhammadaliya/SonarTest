create or replace package Biruni_Report_Test is

  ----------------------------------------------------------------------------------------------------
  Procedure Test1;
  ----------------------------------------------------------------------------------------------------
  Procedure Run(p Hashmap);
  ----------------------------------------------------------------------------------------------------
  Procedure Install;

end Biruni_Report_Test;
/
create or replace package body Biruni_Report_Test is

  ----------------------------------------------------------------------------------------------------
  Procedure Test1 is
    a b_Table := b_Report.New_Table;
    b b_Table;
  begin
    a.Current_Style('body');
  
    a.New_Row;
    b := b_Report.New_Table(a);
    b.New_Row;
    b.Data('1.1');
    b.New_Row;
    b.Data('2.1');
    a.Data(b);
  
    a.New_Row;
    a.Data('3.1');
    a.Data('3.2');
  
    b_Report.Add_Sheet('test 1', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test2 is
    a b_Table := b_Report.New_Table;
    b b_Table;
  begin
    a.Current_Style('body');
  
    a.New_Row;
    a.Data('1.1');
    a.Data('1.2', i_Rowspan => 2);
  
    a.New_Row;
    a.Data('2.1');
  
    a.New_Row;
    b := b_Report.New_Table(a);
    b.New_Row;
    b.Data('2.2.a');
    b.New_Row;
    b.Data('2.2.b');
    a.Data(b);
    a.Data;
  
    a.New_Row;
    a.Data('3.1');
  
    b_Report.Add_Sheet('test 2', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_Grouping is
    a b_Table;
    b b_Table;
    c b_Table;
  begin
    a := b_Report.New_Table();
  
    a.Current_Style('body');
  
    a.New_Row;
    a.Data('Total', 'root center middle', i_Rowspan => 2);
  
    a.New_Row;
    a.Data('A', 'header');
  
    b := b_Report.New_Table(i_Parent => b);
    b.Start_Row_Group(); --start 2 row grouping
    b.New_Row;
    b.Data('A1');
  
    b.Data('B', 'header');
    b.Start_Column_Group(); --start 1 column grouping
    b.Data('B11');
    b.Data('B12');
    b.Data('B13');
  
    b.Start_Column_Group(); --start 2 column grouping
    b.Data('B14');
    b.Data('B15');
    b.Stop_Column_Group(); --stop 2 column grouping
    b.Stop_Column_Group(); --stop 1 column grouping
  
    b.New_Row;
    b.Data('A2');
  
    b.Data('B', 'header');
    b.Data('B11');
    b.Data('B12');
    b.Data('B13');
    b.Data('B14');
    b.Data('B15');
  
    b.New_Row;
    b.Data('A3');
  
    b.Data('B', 'header');
    b.Data('B11');
    b.Data('B12');
    b.Data('B13');
    b.Data('B14');
    b.Data('B15');
  
    c := b_Report.New_Table(i_Parent => b);
    c.New_Row;
    c.Data('C', 'header');
  
    c.Start_Row_Group(); --start 3 row grouping
    c.New_Row;
    c.Data('C1');
  
    c.Data('C', 'header');
    c.Start_Column_Group(); --start 3 column grouping
    c.Data('C11');
    c.Data('C12');
    c.Data('C13');
    c.Data('C14');
    c.Data('C15');
    c.Stop_Column_Group(); --stop 3 column grouping
  
    c.New_Row;
    c.Data('C2');
  
    c.Data('C', 'header');
    c.Data('C11');
    c.Data('C12');
    c.Data('C13');
    c.Data('C14');
    c.Data('C15');
  
    c.New_Row;
    c.Data('C3');
  
    c.Data('C', 'header');
    c.Data('C11');
    c.Data('C12');
    c.Data('C13');
    c.Data('C14');
    c.Data('C15');
    c.Stop_Row_Group(); --stop 3 row grouping
  
    b.New_Row;
    b.Data(c);
    b.Stop_Row_Group(); --stop 2 row grouping
  
    b.New_Row;
    b.Data('A4');
  
    b.Data('B', 'header');
    b.Data('B11');
    b.Data('B12');
    b.Data('B13');
    b.Data('B14');
    b.Data('B15');
  
    a.Start_Row_Group(); --start 1 row grouping
    a.New_Row;
    a.Data(b);
    a.Stop_Row_Group(); --stop 1 row grouping
  
    b_Report.Add_Sheet('test', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_Row_Height is
    a b_Table := b_Report.New_Table;
    c b_Table;
  begin
    a.Current_Style('body');
    c := b_Report.New_Table(a);
  
    c.New_Row;
    c.Data('C1');
    c.New_Row;
    c.Data('C2');
  
    a.New_Row;
    a.New_Row(30);
    a.Data('A');
    a.Data(c);
  
    b_Report.Add_Sheet('row_height', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_Col_Width is
    a b_Table := b_Report.New_Table;
    c b_Table;
  begin
    a.Column_Width(1, 50);
  
    a.Current_Style('body');
    c := b_Report.New_Table(a);
  
    c.Column_Width(1, 20);
    c.Column_Width(2, 30);
  
    c.New_Row;
    c.Data('C1');
    c.Data('C2');
  
    a.New_Row;
    a.New_Row;
    a.Data('A');
    a.New_Row;
    a.Data(c);
  
    b_Report.Add_Sheet('col_width', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_Style is
    a b_Table := b_Report.New_Table();
  begin
    a.Column_Width(1, 100);
    a.Column_Width(2, 200);
    a.Column_Width(3, 100);
    a.Column_Width(4, 300);
  
    a.Current_Style('root');
  
    a.New_Row;
    a.Data('Info.........', i_Colspan => 4);
  
    a.New_Row;
    a.Data('Other info.........', i_Colspan => 4);
  
    a.New_Row;
    a.New_Row;
  
    a.Current_Style('header');
  
    a.Open_Table();
    a.Open_Thead();
  
    a.New_Row;
    a.Data('1');
    a.Data('2');
    a.Data('3');
    a.Data('4');
  
    a.New_Row;
    /*a.Data('Name');
    a.Data('Surname');
    a.Data('Salary');
    a.Data('Note');*/
    a.Data('Name', i_Colspan => 2);
    a.Data('Salary', i_Rowspan => 2);
    a.Data('Note', i_Rowspan => 2);
  
    a.New_Row;
    a.Data('First name');
    a.Data('Last name');
  
    a.New_Row;
    a.Data('1');
    a.Data('2');
    a.Data('3');
    a.Data('4');
  
    a.Close_Thead();
  
    a.Open_Tbody();
    a.Current_Style('body');
    for i in 1 .. 5
    loop
      a.New_Row;
      a.Data('Name' || i);
      a.Data('Surname' || i);
      a.Data(i * 1000, 'body number2');
      a.Data('Note' || i);
    end loop;
  
    a.New_Row;
    a.Data('Andy Abel', 'body center', i_Colspan => 2);
    a.Data('10000', 'body number2', i_Rowspan => 2);
    a.Data('Note', i_Rowspan => 2);
  
    a.New_Row;
    a.Data('Andy');
    a.Data('Abel');
  
    a.New_Row;
    a.Data(1);
    a.Data(2);
    a.Data(3);
    a.Data(4);
  
    a.Close_Tbody();
  
    a.Open_Tfoot();
    a.Current_Style('footer');
    a.New_Row;
    a.Data('Total');
    a.Data();
    a.Data();
    a.Data();
    a.Close_Tfoot();
    a.Close_Table();
  
    a.Current_Style('root');
  
    a.New_Row;
    a.New_Row;
  
    a.New_Row;
    a.Data('Footer info.........', i_Colspan => 4);
  
    a.New_Row;
    a.Data('Other footer info.........', i_Colspan => 4);
  
    b_Report.Add_Sheet('report styling', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_Without_Style is
    a b_Table := b_Report.New_Table();
  begin
    a.Column_Width(1, 100);
    a.Column_Width(2, 200);
    a.Column_Width(3, 100);
    a.Column_Width(4, 300);
  
    a.Current_Style('root');
  
    a.New_Row;
    a.Data('Info.........', i_Colspan => 4);
  
    a.New_Row;
    a.Data('Other info.........', i_Colspan => 4);
  
    a.New_Row;
    a.New_Row;
  
    a.Current_Style('header');
  
    a.New_Row;
    a.Data('1');
    a.Data('2');
    a.Data('3');
    a.Data('4');
  
    a.New_Row;
    /*a.Data('Name');
    a.Data('Surname');
    a.Data('Salary');
    a.Data('Note');*/
    a.Data('Name', i_Colspan => 2);
    a.Data('Salary', i_Rowspan => 2);
    a.Data('Note', i_Rowspan => 2);
  
    a.New_Row;
    a.Data('First name');
    a.Data('Last name');
  
    a.New_Row;
    a.Data('1');
    a.Data('2');
    a.Data('3');
    a.Data('4');
  
    a.Current_Style('body');
    for i in 1 .. 5
    loop
      a.New_Row;
      a.Data('Name' || i);
      a.Data('Surname' || i);
      a.Data(i * 1000, 'body number2');
      a.Data('Note' || i);
    end loop;
  
    a.New_Row;
    a.Data('Andy Abel', 'body center', i_Colspan => 2);
    a.Data('10000', 'body number2', i_Rowspan => 2);
    a.Data('Note', i_Rowspan => 2);
  
    a.New_Row;
    a.Data('Andy');
    a.Data('Abel');
  
    a.New_Row;
    a.Data(1);
    a.Data(2);
    a.Data(3);
    a.Data(4);
  
    a.Current_Style('footer');
    a.New_Row;
    a.Data('Total');
    a.Data();
    a.Data();
    a.Data();
  
    a.Current_Style('root');
  
    a.New_Row;
    a.New_Row;
  
    a.New_Row;
    a.Data('Footer info.........', i_Colspan => 4);
  
    a.New_Row;
    a.Data('Other footer info.........', i_Colspan => 4);
  
    b_Report.Add_Sheet('report without styling', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_Style_Nested_Tables is
    a b_Table := b_Report.New_Table();
    c b_Table;
  begin
    a.Column_Width(1, 200);
    a.Column_Width(2, 200);
  
    a.Current_Style('header');
  
    a.Open_Table();
    a.Open_Thead();
  
    a.New_Row;
    a.Data('head');
    a.Data('head');
  
    a.New_Row;
  
    c := b_Report.New_Table(a);
    c.New_Row;
    c.Data('nested 0');
    c.New_Row;
    c.Data('nested 1');
    c.New_Row;
    c.Data('nested 2');
    c.New_Row;
    c.Data('nested 3');
    c.New_Row;
    c.Data('nested 4');
    c.New_Row;
    c.Data('nested 4');
  
    a.Data('left');
    a.Data(c);
  
    a.New_Row;
    a.Data('1');
    a.Data('2');
    a.Close_Thead();
  
    a.Open_Tbody();
    a.Current_Style('body');
    for i in 1 .. 5
    loop
      a.New_Row;
      a.Data('body ' || i);
      a.Data('body ' || i);
    end loop;
  
    a.Close_Tbody();
    a.Close_Table();
  
    b_Report.Add_Sheet('report nested tables styling', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test_No_Style_Nested_Tables is
    a b_Table := b_Report.New_Table();
    b b_Table;
  begin
    a.Column_Width(1, 200);
    a.Column_Width(2, 200);
  
    a.Current_Style('header');
    a.New_Row;
    a.Data('head');
    a.Data('head');
  
    b := b_Report.New_Table(a);
  
    b.New_Row;
    b.Data('nested 0');
    b.New_Row;
    b.Data('nested 1');
    b.New_Row;
    b.Data('nested 2');
    b.New_Row;
    b.Data('nested 3');
    b.New_Row;
    b.Data('nested 4');
  
    a.New_Row;
    a.Data('left');
    a.Data(b);
  
    a.New_Row;
    a.Data('1');
    a.Data('2');
  
    a.Current_Style('body');
    for i in 1 .. 5
    loop
      a.New_Row;
      a.Data('body ' || i);
      a.Data('body ' || i);
    end loop;
  
    b_Report.Add_Sheet('report nested tables without styling', a);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run(p Hashmap) is
  begin
    b_Report.Open_Book_With_Styles(p.o_Varchar2('rt'));
  
    Test1;
  
    Test2;
  
    Test_Grouping;
  
    Test_Row_Height;
    Test_Col_Width;
  
    Test_Style;
  
    Test_Without_Style;
  
    Test_Style_Nested_Tables;
  
    Test_No_Style_Nested_Tables;
  
    b_Report.Close_Book;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Install is
  begin
    z_Biruni_Routes.Save_One(i_Uri         => '/anor/z/report_test',
                             i_Action_Name => 'Biruni_Report_Test.Run',
                             i_Action_In   => 'M',
                             i_Action_Out  => '',
                             i_Access_Type => 'P');
    commit;
  end;

end Biruni_Report_Test;
/
