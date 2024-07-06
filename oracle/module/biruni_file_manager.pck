create or replace package Biruni_File_Manager is
  ----------------------------------------------------------------------------------------------------
  Procedure Save_File_Properties
  (
    i_Sha          varchar2,
    i_File_Size    number,
    i_File_Name    varchar2,
    i_Content_Type varchar2,
    i_Store_Kind   varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Save_File_Download_Link
  (
    i_Sha           varchar2,
    i_Redirect_Kind varchar2,
    i_Access_Link   varchar2,
    i_Expires_In    number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Get_File_Info
  (
    i_Sha           varchar2,
    i_Redirect_Kind varchar2,
    o_Store_Kind    out varchar2,
    o_Access_Link   out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Lock_File_Uploading
  (
    i_Sha     varchar2,
    o_Command out varchar2,
    o_Error   out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Delete_File
  (
    i_Sha        varchar2,
    o_Store_Kind out varchar2
  );
end Biruni_File_Manager;
/
create or replace package body Biruni_File_Manager is
  ----------------------------------------------------------------------------------------------------
  Procedure Save_File_Properties
  (
    i_Sha          varchar2,
    i_File_Size    number,
    i_File_Name    varchar2,
    i_Content_Type varchar2,
    i_Store_Kind   varchar2
  ) is
  begin
    z_Biruni_Files.Save_One(i_Sha          => i_Sha,
                            i_File_Size    => i_File_Size,
                            i_File_Name    => i_File_Name,
                            i_Content_Type => i_Content_Type,
                            i_Store_Kind   => i_Store_Kind);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Save_File_Download_Link
  (
    i_Sha           varchar2,
    i_Redirect_Kind varchar2,
    i_Access_Link   varchar2,
    i_Expires_In    number -- in hours
  ) is
  begin
    z_Biruni_File_Links.Save_One(i_Sha             => i_Sha,
                                 i_Kind            => i_Redirect_Kind,
                                 i_Access_Link     => i_Access_Link,
                                 i_Link_Expires_On => sysdate + i_Expires_In / 24);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Get_File_Info
  (
    i_Sha           varchar2,
    i_Redirect_Kind varchar2,
    o_Store_Kind    out varchar2,
    o_Access_Link   out varchar2
  ) is
    r_File_Link Biruni_File_Links%rowtype;
  begin
    o_Store_Kind := z_Biruni_Files.Load(i_Sha).Store_Kind;
  
    if o_Store_Kind = 'S' and
       z_Biruni_File_Links.Exist(i_Sha => i_Sha, i_Kind => i_Redirect_Kind, o_Row => r_File_Link) then
      if r_File_Link.Link_Expires_On - 1 / 24 > sysdate then
        o_Access_Link := r_File_Link.Access_Link;
      end if;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Lock_File_Uploading
  (
    i_Sha     varchar2,
    o_Command out varchar2,
    o_Error   out varchar2
  ) is
    --------------------------------------------------    
    Function Get_Command(i_Sha varchar2) return varchar2 is
      v_Dummy varchar2(1);
    begin
      select 'x'
        into v_Dummy
        from Biruni_Filespace q
       where q.Sha = i_Sha;
    
      return 'I'; -- ignore
    exception
      when No_Data_Found then
        return 'U'; -- upload
    end;
  begin
    z_Biruni_Files.Lock_Only(i_Sha);
    o_Command := Get_Command(i_Sha);
  exception
    when others then
      o_Command := 'E';
      o_Error   := sqlerrm;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Delete_File
  (
    i_Sha        varchar2,
    o_Store_Kind out varchar2
  ) is
    r_File Biruni_Files%rowtype;
  begin
    r_File := z_Biruni_Files.Load(i_Sha);
  
    delete Biruni_Files q
     where q.Sha = i_Sha;
  
    if r_File.Store_Kind = 'D' then
      delete Biruni_Filespace q
       where q.Sha = i_Sha;
    end if;
  
    o_Store_Kind := r_File.Store_Kind;
  end;

end Biruni_File_Manager;
/
