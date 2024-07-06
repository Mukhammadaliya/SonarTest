create or replace type Fazo_Schema.Fazo_File force as object
(
  l_Command_Type    varchar2(1),
  l_Attachment_Name varchar2(200),
  l_Files           Fazo_Schema.Arraylist,

------------------------------------------------------------------------------------------------------
  constructor Function Fazo_File(self in out nocopy Fazo_Schema.Fazo_File) return self as result,
------------------------------------------------------------------------------------------------------
  constructor Function Fazo_File
  (
    self            in out nocopy Fazo_Schema.Fazo_File,
    i_Sha           varchar2,
    i_Name          varchar2 := null,
    i_Width         number := null,
    i_Height        number := null,
    i_Cache         boolean := null,
    i_Format        varchar2 := null,
    i_Quality       number := null,
    i_Redirect      boolean := false,
    i_Redirect_Kind varchar2 := 'L' -- 'L' load, 'D' download
  ) return self as result,
------------------------------------------------------------------------------------------------------
  member Procedure Add_File
  (
    self            in out nocopy Fazo_Schema.Fazo_File,
    i_Sha           varchar2,
    i_Name          varchar2 := null,
    i_Redirect      boolean := false,
    i_Redirect_Kind varchar2 := 'L'
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Add_Image
  (
    self            in out nocopy Fazo_Schema.Fazo_File,
    i_Sha           varchar2,
    i_Name          varchar2 := null,
    i_Width         number := null,
    i_Height        number := null,
    i_Cache         boolean := null,
    i_Format        varchar2 := null,
    i_Quality       number := null,
    i_Redirect      boolean := false,
    i_Redirect_Kind varchar2 := 'L'
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Forward_Size(self in out nocopy Fazo_Schema.Fazo_File),
------------------------------------------------------------------------------------------------------
  member Procedure Forward_File(self in out nocopy Fazo_Schema.Fazo_File),
------------------------------------------------------------------------------------------------------
  member Procedure Set_Attachment_Name
  (
    self   in out nocopy Fazo_Schema.Fazo_File,
    i_Name varchar2
  )
------------------------------------------------------------------------------------------------------
)
/
create or replace type body Fazo_Schema.Fazo_File is

  ------------------------------------------------------------------------------------------------------
  constructor Function Fazo_File(self in out nocopy Fazo_Schema.Fazo_File) return self as result is
  begin
    Self.l_Command_Type    := Fazo_Util.c_Ct_Forward_File;
    Self.l_Attachment_Name := '';
    Self.l_Files           := Fazo_Schema.Arraylist();
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  constructor Function Fazo_File
  (
    self            in out nocopy Fazo_Schema.Fazo_File,
    i_Sha           varchar2,
    i_Name          varchar2 := null,
    i_Width         number := null,
    i_Height        number := null,
    i_Cache         boolean := null,
    i_Format        varchar2 := null,
    i_Quality       number := null,
    i_Redirect      boolean := false,
    i_Redirect_Kind varchar2 := 'L'
  ) return self as result is
  begin
    Self.l_Command_Type    := Fazo_Util.c_Ct_Forward_File;
    Self.l_Attachment_Name := '';
    Self.l_Files           := Fazo_Schema.Arraylist();
    Self.Add_Image(i_Sha           => i_Sha,
                   i_Name          => i_Name,
                   i_Width         => i_Width,
                   i_Height        => i_Height,
                   i_Cache         => i_Cache,
                   i_Format        => i_Format,
                   i_Quality       => i_Quality,
                   i_Redirect      => i_Redirect,
                   i_Redirect_Kind => i_Redirect_Kind);
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Add_File
  (
    self            in out nocopy Fazo_Schema.Fazo_File,
    i_Sha           varchar2,
    i_Name          varchar2 := null,
    i_Redirect      boolean := false,
    i_Redirect_Kind varchar2 := 'L'
  ) is
    v_Map Hashmap := Hashmap();
  begin
    v_Map.Put('sha', i_Sha);
  
    if i_Name is not null then
      v_Map.Put('name', i_Name);
    end if;
  
    if i_Redirect then
      v_Map.Put('redirect', 'Y');
      v_Map.Put('redirect_kind', i_Redirect_Kind);
    end if;
  
    Self.l_Files.Push(v_Map);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Add_Image
  (
    self            in out nocopy Fazo_Schema.Fazo_File,
    i_Sha           varchar2,
    i_Name          varchar2 := null,
    i_Width         number := null,
    i_Height        number := null,
    i_Cache         boolean := null,
    i_Format        varchar2 := null,
    i_Quality       number := null,
    i_Redirect      boolean := false,
    i_Redirect_Kind varchar2 := 'L'
  ) is
    v_Map Hashmap := Hashmap();
  begin
    v_Map.Put('sha', i_Sha);
  
    if i_Name is not null then
      v_Map.Put('name', i_Name);
    end if;
  
    if i_Width is not null and i_Height is not null then
      v_Map.Put('width', i_Width);
      v_Map.Put('height', i_Height);
    elsif i_Width is not null or i_Height is not null then
      Raise_Application_Error(-20999, 'Both dimension must be specified');
    end if;
  
    if i_Cache then
      v_Map.Put('cache', 'Y');
    end if;
  
    if i_Format is not null then
      v_Map.Put('format', i_Format);
    end if;
  
    if i_Quality is not null then
      v_Map.Put('quality', i_Quality);
    end if;
  
    if i_Redirect then
      v_Map.Put('redirect', 'Y');
      v_Map.Put('redirect_kind', i_Redirect_Kind);
    end if;
  
    Self.l_Files.Push(v_Map);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Forward_Size(self in out nocopy Fazo_Schema.Fazo_File) is
  begin
    Self.l_Command_Type := Fazo_Util.c_Ct_Forward_Size;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Forward_File(self in out nocopy Fazo_Schema.Fazo_File) is
  begin
    Self.l_Command_Type := Fazo_Util.c_Ct_Forward_File;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Set_Attachment_Name
  (
    self   in out nocopy Fazo_Schema.Fazo_File,
    i_Name varchar2
  ) is
  begin
    Self.l_Attachment_Name := i_Name;
  end;

------------------------------------------------------------------------------------------------------

end;
/
