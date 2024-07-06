create or replace package Biruni_Easy_Report is
  c_Version constant varchar2(10) := '1.1';
  ----------------------------------------------------------------------------------------------------
  Procedure Build_Easy_Report
  (
    i_Sha             varchar2,
    i_File_Name       varchar2,
    i_Data            Json_Object_t,
    i_View_Properties Json_Object_t := null
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Validate_Definition
  (
    i_Sha  varchar2,
    i_Data Json_Object_t
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Easy_Report_Properties
  (
    i_Sha          varchar2,
    i_File_Size    number,
    i_File_Name    varchar2,
    i_Content_Type varchar2,
    i_Store_Kind   varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Delete_Easy_Report(i_Sha varchar2);
  ----------------------------------------------------------------------------------------------------
  -- called by job to delete old easy report files
  ----------------------------------------------------------------------------------------------------
  Procedure Clean_Easy_Reports;
end Biruni_Easy_Report;
/
create or replace package body Biruni_Easy_Report is
  g_Easy_Report Json_Object_t;
  ----------------------------------------------------------------------------------------------------
  Procedure Build_Easy_Report
  (
    i_Sha             varchar2,
    i_File_Name       varchar2,
    i_Data            Json_Object_t,
    i_View_Properties Json_Object_t := null
  ) is
  begin
    Validate_Definition(i_Sha => i_Sha, i_Data => i_Data);
  
    g_Easy_Report := Json_Object_t();
  
    g_Easy_Report.Put('fileSha', i_Sha);
  
    if i_File_Name is null then
      g_Easy_Report.Put('fileName', z_Biruni_Files.Load(i_Sha => i_Sha).File_Name);
    else
      g_Easy_Report.Put('fileName', i_File_Name || '.xlsx');
    end if;
  
    g_Easy_Report.Put('version', z_Biruni_Easy_Report_Templates.Load(i_Sha).Version);
    g_Easy_Report.Put('viewProperties', i_View_Properties);
    g_Easy_Report.Put('data', i_Data);
  
    Biruni_Route.Set_Easy_Report(i_Easy_Report_Data => g_Easy_Report);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Validate_Definition
  (
    i_Sha  varchar2,
    i_Data Json_Object_t
  ) is
    v_Definition_Data clob;
    v_Definition      Json_Array_t;
  
    --------------------------------------------------
    Procedure Validate
    (
      i_Definition Json_Array_t,
      i_Data       Json_Object_t
    ) is
      v_Key     varchar2(100);
      v_Items   Json_Array_t;
      v_Element Json_Object_t;
    begin
      for i in 0 .. i_Definition.Get_Size - 1
      loop
        v_Element := Treat(i_Definition.Get(i) as Json_Object_t);
        v_Key     := v_Element.Get_String('key');
      
        if not i_Data.Has(v_Key) then
          b.Raise_Error('Biruni ER: keyword $1 from workbook is not found in definition', v_Key);
        end if;
      
        if v_Element.Has('items') then
          if i_Data.Get_Type(v_Key) <> 'ARRAY' then
            b.Raise_Error('Biruni ER: object with keyword $1 from workbook is not an array', v_Key);
          end if;
        
          v_Items := i_Data.Get_Array(v_Key);
          continue when v_Items.Get_Size = 0;
        
          Validate(v_Element.Get_Array('items'), Treat(v_Items.Get(0) as Json_Object_t));
        end if;
      end loop;
    end;
  
  begin
    begin
      select t.Definition
        into v_Definition_Data
        from Biruni_Easy_Report_Templates t
       where t.Sha = i_Sha;
    exception
      when No_Data_Found then
        b.Raise_Error('Birun ER: no data found with sha $1', i_Sha);
    end;
  
    v_Definition := Json_Array_t(v_Definition_Data);
  
    Validate(v_Definition, i_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_Easy_Report_Properties
  (
    i_Sha          varchar2,
    i_File_Size    number,
    i_File_Name    varchar2,
    i_Content_Type varchar2,
    i_Store_Kind   varchar2
  ) is
  begin
    Biruni_File_Manager.Save_File_Properties(i_Sha          => i_Sha,
                                             i_File_Size    => i_File_Size,
                                             i_File_Name    => i_File_Name,
                                             i_Content_Type => i_Content_Type,
                                             i_Store_Kind   => i_Store_Kind);
  
    z_Biruni_Easy_Report_Generated_Files.Insert_One(i_Sha);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Delete_Easy_Report(i_Sha varchar2) is
    r_File Biruni_Files%rowtype;
  begin
    r_File := z_Biruni_Files.Load(i_Sha);
  
    delete Biruni_Easy_Report_Generated_Files q
     where q.Sha = i_Sha;
  
    Biruni_Core.Bf_Try_Delete(i_Sha => i_Sha, i_Store_Kind => r_File.Store_Kind);
  
    if r_File.Store_Kind = 'D' then
      delete Biruni_Filespace q
       where q.Sha = i_Sha;
    end if;
  exception
    when others then
      null;
  end;

  ----------------------------------------------------------------------------------------------------
  -- called by job to delete old easy report files
  ----------------------------------------------------------------------------------------------------
  Procedure Clean_Easy_Reports is
  begin
    for r in (select t.Sha
                from Biruni_Easy_Report_Generated_Files t
               where exists (select 1
                        from Biruni_Files q
                       where q.Sha = t.Sha
                         and (sysdate - q.Created_On) * 24 > 1))
    loop
      Delete_Easy_Report(r.Sha);
    end loop;
  end;

end Biruni_Easy_Report;
/
