create or replace package b is
  ----------------------------------------------------------------------------------------------------
  Error exception;
  Error_n constant number := -20000;
  pragma exception_init(Error, -20000);
  ----------------------------------------------------------------------------------------------------
  Fatal exception;
  Fatal_n constant number := -20999;
  pragma exception_init(Fatal, -20999);
  ----------------------------------------------------------------------------------------------------
  Ora_Child_Record_Found     exception;
  Ora_Check_Violated         exception;
  Ora_Parent_Key_Not_Found   exception;
  Ora_Null_Column_Ins        exception;
  Ora_Null_Column_Upd        exception;
  Ora_Resource_Busy          exception;
  Ora_Value_Too_Large        exception;
  Ora_Number_Too_Large       exception;
  Ora_Numeric_Or_Value_Error exception;
  pragma exception_init(Ora_Child_Record_Found, -02292);
  pragma exception_init(Ora_Check_Violated, -02290);
  pragma exception_init(Ora_Parent_Key_Not_Found, -02291);
  pragma exception_init(Ora_Null_Column_Ins, -1400);
  pragma exception_init(Ora_Null_Column_Upd, -1407);
  pragma exception_init(Ora_Resource_Busy, -54);
  pragma exception_init(Ora_Value_Too_Large, -12899);
  pragma exception_init(Ora_Number_Too_Large, -01438);
  pragma exception_init(Ora_Numeric_Or_Value_Error, -6502);
  ----------------------------------------------------------------------------------------------------
  Function Context_Id return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Run_Job_At
  (
    i_Procedure varchar2,
    i_Arguments varchar2 := null,
    i_At_Time   date := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Run_Job
  (
    i_Procedure     varchar2,
    i_Arguments     varchar2 := null,
    i_After_Seconds number := null
  );
  -- Utils
  ----------------------------------------------------------------------------------------------------
  Function Trim_Ora_Error(i_Error varchar2) return varchar2;
  Function Trimmed_Sqlerrm return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Message
  (
    i_Message varchar2,
    i_Params  Array_Varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Message
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- Translate and raise exceptions
  ----------------------------------------------------------------------------------------------------
  Function Translate
  (
    i_Message   varchar2,
    i_Params    Array_Varchar2 := null,
    i_Lang_Code varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Translate
  (
    i_Message varchar2,
    i_P1      varchar2,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Error
  (
    i_Message varchar2,
    i_Params  Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Error
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Fatal
  (
    i_Message varchar2,
    i_Params  Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Fatal
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Extended
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Title     varchar2,
    i_Solutions Array_Varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Extended
  (
    i_Code    varchar2,
    i_Message varchar2,
    i_Title   varchar2 := null,
    i_S1      varchar2 := null,
    i_S2      varchar2 := null,
    i_S3      varchar2 := null,
    i_S4      varchar2 := null,
    i_S5      varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Not_Implemented;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Unauthenticated;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Payment_Required;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Unauthorized;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Route_Not_Found;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Conflicts;
  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Too_Many_Requests;
  ----------------------------------------------------------------------------------------------------
  Procedure Notify_Watchers
  (
    i_Watching_Expr varchar2,
    i_Expr_Type     varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Function Load_Image
  (
    i_File     Biruni_Files%rowtype,
    i_Width    number,
    i_Height   number,
    i_Format   varchar2,
    i_Quality  number,
    i_Redirect boolean := false
  ) return Fazo_File;
  ----------------------------------------------------------------------------------------------------
  Function Load_File
  (
    i_File     Biruni_Files%rowtype,
    i_Redirect boolean := false
  ) return Fazo_File;
  ----------------------------------------------------------------------------------------------------
  Function Load_File
  (
    i_Sha      varchar2,
    i_Redirect boolean := false
  ) return Fazo_File;
  ----------------------------------------------------------------------------------------------------
  Function Download_File
  (
    i_File     Biruni_Files%rowtype,
    i_Redirect boolean := false
  ) return Fazo_File;
  ----------------------------------------------------------------------------------------------------
  Function Download_File
  (
    i_Sha      varchar2,
    i_Redirect boolean := false
  ) return Fazo_File;
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Arraylist
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Alert
  (
    i_Message  varchar2,
    i_User_Ids Array_Number,
    i_Mute     boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Alert
  (
    i_Message varchar2,
    i_User_Id number,
    i_Mute    boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Message
  (
    i_User_Ids Array_Number,
    i_Data     Hashmap := null,
    i_Mute     boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Message
  (
    i_User_Id number,
    i_Data    Hashmap := null,
    i_Mute    boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Notification
  (
    i_User_Ids Array_Number,
    i_Mute     boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Notification
  (
    i_User_Id number,
    i_Mute    boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Task
  (
    i_User_Ids Array_Number,
    i_Mute     boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Task
  (
    i_User_Id number,
    i_Mute    boolean := null
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Firebase
  (
    i_Fcm_Url          varchar2,
    i_Auth_Key         varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Priority         varchar2,
    i_Data             Hashmap,
    i_Notification     Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Send_Hms
  (
    i_Auth_Server_Url  varchar2,
    i_Send_Message_Url varchar2,
    i_Client_Id        varchar2,
    i_Client_Secret    varchar2,
    i_Access_Token     varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Data             Hashmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Add_Post_Callback(i_Callback_Block varchar2);
  ----------------------------------------------------------------------------------------------------
  Procedure Run_Post_Callback;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_External_Service
  (
    i_Url  varchar2,
    i_Data Gmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Set_External_Service
  (
    i_Url                 varchar2,
    i_Authorization_Type  varchar2,
    i_Authorization_Token varchar2,
    i_Data                Gmap
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Run_Onlyoffice
  (
    i_Sha        varchar2,
    i_File_Name  varchar2,
    i_Properties Json_Object_t
  );
  ----------------------------------------------------------------------------------------------------
  Function Get_Url_Params(i_Data Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Function Get_Eimzo_Api_Key(i_Host_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Get_Nls_Language return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Run_Query
  (
    i_Query  Fazo_Query,
    i_Column Array_Varchar2,
    i_Limit  number := 50,
    i_Offset number := 0,
    i_Filter Arraylist := Arraylist(),
    i_Sort   Array_Varchar2 := null
  ) return Gmap;
end b;
/
create or replace package body b is
  ----------------------------------------------------------------------------------------------------
  Function Context_Id return number is
  begin
    return Biruni_Route.Context_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Job_At
  (
    i_Procedure varchar2,
    i_Arguments varchar2 := null,
    i_At_Time   date := null
  ) is
  begin
    Biruni_Core.Job_Run_At(i_Procedure, i_Arguments, i_At_Time);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Job
  (
    i_Procedure     varchar2,
    i_Arguments     varchar2 := null,
    i_After_Seconds number := null
  ) is
  begin
    Biruni_Core.Job_Run(i_Procedure, i_Arguments, i_After_Seconds);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Trim_Ora_Error(i_Error varchar2) return varchar2 is
  begin
    return Regexp_Replace(i_Error, 'ORA-[0-9]+: ', '');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Trimmed_Sqlerrm return varchar2 is
  begin
    return Trim_Ora_Error(sqlerrm);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Message
  (
    i_Message varchar2,
    i_Params  Array_Varchar2
  ) return varchar2 is
    result varchar2(32767);
  begin
    if i_Params is null then
      return i_Message;
    end if;
  
    result := i_Message;
  
    for i in reverse 1 .. i_Params.Count
    loop
      result := replace(result, '$' || i, i_Params(i));
    end loop;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Message
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2 is
  begin
    return Message(i_Message, Array_Varchar2(i_P1, i_P2, i_P3, i_P4, i_P5));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Translate
  (
    i_Message   varchar2,
    i_Params    Array_Varchar2 := null,
    i_Lang_Code varchar2 := null
  ) return varchar2 is
    v_Message varchar2(4000) := Lower(i_Message);
    result    varchar2(4000);
    --------------------------------------------------
    Function Load(i_Lc varchar2) return varchar2 is
      v_Text   varchar2(4000);
      v_Custom varchar2(1);
    begin
      Biruni_Util.Take_Translation(i_Message   => v_Message,
                                   i_Lang_Code => i_Lc,
                                   o_Text      => v_Text,
                                   o_Custom    => v_Custom);
      if v_Custom = 'Y' then
        v_Text := Nvl(Biruni_Util.Take_Custom_Translation(i_Code      => Biruni_Route.Get_Custom_Translate_Code,
                                                          i_Message   => v_Message,
                                                          i_Lang_Code => i_Lc),
                      v_Text);
      end if;
    
      if v_Text is not null then
        return Message(v_Text, i_Params);
      end if;
      return null;
    end;
  
  begin
    result := Load(Nvl(i_Lang_Code, Biruni_Route.Get_Lang_Code));
    if result is not null then
      return result;
    end if;
  
    return Message(i_Message, i_Params);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Translate
  (
    i_Message varchar2,
    i_P1      varchar2,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2 is
  begin
    return Translate(i_Message, Array_Varchar2(i_P1, i_P2, i_P3, i_P4, i_P5));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Error
  (
    i_Message varchar2,
    i_Params  Array_Varchar2
  ) is
  begin
    Raise_Application_Error(Error_n, Message(i_Message, i_Params));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Error
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) is
  begin
    Raise_Application_Error(Error_n, Message(i_Message, i_P1, i_P2, i_P3, i_P4, i_P5));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Fatal
  (
    i_Message varchar2,
    i_Params  Array_Varchar2
  ) is
  begin
    Raise_Application_Error(Fatal_n, Message(i_Message, i_Params));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Fatal
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) is
  begin
    Raise_Application_Error(Fatal_n, Message(i_Message, i_P1, i_P2, i_P3, i_P4, i_P5));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Extended
  (
    i_Code      varchar2,
    i_Message   varchar2,
    i_Title     varchar2,
    i_Solutions Array_Varchar2
  ) is
    v_Map Hashmap;
  begin
    v_Map := Fazo.Zip_Map('error_code', i_Code, 'message', i_Message);
  
    if i_Title is not null then
      v_Map.Put('title', i_Title);
    end if;
  
    if i_Solutions.Count > 0 then
      v_Map.Put('solutions', i_Solutions);
    end if;
  
    Raise_Application_Error(Error_n, v_Map.Json());
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Extended
  (
    i_Code    varchar2,
    i_Message varchar2,
    i_Title   varchar2 := null,
    i_S1      varchar2 := null,
    i_S2      varchar2 := null,
    i_S3      varchar2 := null,
    i_S4      varchar2 := null,
    i_S5      varchar2 := null
  ) is
    v_Sols      Array_Varchar2 := Array_Varchar2(i_S1, i_S2, i_S3, i_S4, i_S5);
    v_Solutions Array_Varchar2 := Array_Varchar2();
  begin
    for i in 1 .. v_Sols.Count
    loop
      if v_Sols(i) is not null then
        Fazo.Push(v_Solutions, v_Sols(i));
      end if;
    end loop;
  
    Raise_Extended(i_Code      => i_Code,
                   i_Message   => i_Message,
                   i_Title     => i_Title,
                   i_Solutions => v_Solutions);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Not_Implemented is
  begin
    Raise_Application_Error(Fatal_n, 'Not implemented.');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Unauthenticated is
  begin
    raise Biruni_Core.e_Unauthenticated;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Payment_Required is
  begin
    raise Biruni_Core.e_Payment_Required;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Unauthorized is
  begin
    raise Biruni_Core.e_Unauthorized;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Route_Not_Found is
  begin
    raise Biruni_Core.e_Route_Not_Found;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Conflicts is
  begin
    raise Biruni_Core.e_Conflicts;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Raise_Too_Many_Requests is
  begin
    raise Biruni_Core.e_Too_Many_Requests;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Notify_Watchers
  (
    i_Watching_Expr varchar2,
    i_Expr_Type     varchar2
  ) is
    v_Query varchar2(32767);
  begin
    for r in (select t.Watcher_Procedure
                from Biruni_Watchers t
               where t.Watching_Expr = i_Watching_Expr
               order by t.Order_No)
    loop
      v_Query := v_Query || r.Watcher_Procedure || '(v);';
    end loop;
  
    if v_Query is not null then
      execute immediate 'DECLARE v ' || i_Expr_Type || ' := ' || i_Watching_Expr || Chr(10) || --
                        ';BEGIN ' || v_Query || 'END;';
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Image
  (
    i_File     Biruni_Files%rowtype,
    i_Width    number,
    i_Height   number,
    i_Format   varchar2,
    i_Quality  number,
    i_Redirect boolean := false
  ) return Fazo_File is
  begin
    if i_File.Sha is null then
      Raise_Error('File not found');
    end if;
  
    if i_Width < 10 or i_Height < 10 then
      Raise_Error('Invalid definition of image size');
    end if;
  
    if i_Quality < 0.1 then
      Raise_Error('Invalid definition of image quality');
    end if;
  
    -- caching if its not redirected to s3 service (s3 service has its own caching mechanism)
    -- 1 year (60 * 60 * 24 * 365 = 31536000 seconds)
    if i_File.Store_Kind = 'D' or i_Width is not null and i_Height is not null then
      b_Session.Response_Set_Header('Cache-Control', 'max-age=31536000, immutable');
    end if;
  
    b_Session.Response_Set_Header('Content-Disposition', 'filename=' || i_File.File_Name);
    b_Session.Response_Content_Type(i_File.Content_Type);
  
    return Fazo_File(i_Sha           => i_File.Sha,
                     i_Name          => i_File.File_Name,
                     i_Width         => i_Width,
                     i_Height        => i_Height,
                     i_Cache         => false, -- TODO cache not completed
                     i_Format        => i_Format,
                     i_Quality       => i_Quality,
                     i_Redirect      => i_Redirect,
                     i_Redirect_Kind => Biruni_Pref.c_File_Redirect_Load);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_File
  (
    i_File     Biruni_Files%rowtype,
    i_Redirect boolean := false
  ) return Fazo_File is
  begin
    if i_File.Sha is null then
      Raise_Error('File not found');
    end if;
  
    b_Session.Response_Set_Header('Content-Disposition', 'filename=' || i_File.File_Name);
    b_Session.Response_Content_Type(i_File.Content_Type);
  
    return Fazo_File(i_Sha           => i_File.Sha,
                     i_Name          => i_File.File_Name,
                     i_Redirect      => i_Redirect,
                     i_Redirect_Kind => Biruni_Pref.c_File_Redirect_Load);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_File
  (
    i_Sha      varchar2,
    i_Redirect boolean := false
  ) return Fazo_File is
  begin
    return Load_File(i_File => z_Biruni_Files.Take(i_Sha), i_Redirect => i_Redirect);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Download_File
  (
    i_File     Biruni_Files%rowtype,
    i_Redirect boolean := false
  ) return Fazo_File is
  begin
    if i_File.Sha is null then
      Raise_Error('File not found');
    end if;
  
    b_Session.Response_Set_Header('Content-Disposition',
                                  'attachment; filename=' || i_File.File_Name);
    b_Session.Response_Content_Type(i_File.Content_Type);
  
    return Fazo_File(i_Sha           => i_File.Sha,
                     i_Name          => i_File.File_Name,
                     i_Redirect      => i_Redirect,
                     i_Redirect_Kind => Biruni_Pref.c_File_Redirect_Download);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Download_File
  (
    i_Sha      varchar2,
    i_Redirect boolean := false
  ) return Fazo_File is
  begin
    return Download_File(i_File => z_Biruni_Files.Take(i_Sha), i_Redirect => i_Redirect);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Hashmap
  ) is
  begin
    Biruni_Service.Add_Final_Service(i_Class_Name => i_Class_Name, i_Data => i_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Final_Service
  (
    i_Class_Name varchar2,
    i_Data       Arraylist
  ) is
  begin
    Biruni_Service.Add_Final_Service(i_Class_Name => i_Class_Name, i_Data => i_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Alert
  (
    i_Message  varchar2,
    i_User_Ids Array_Number,
    i_Mute     boolean := null
  ) is
  begin
    Biruni_Service.Send_Broadcast(Fazo.Zip_Map('type', 'alert', --
                                   'message', i_Message, --
                                   'mute', Sys.Diutil.Bool_To_Int(Nvl(i_Mute, false))).Json,
                                  i_User_Ids);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Alert
  (
    i_Message varchar2,
    i_User_Id number,
    i_Mute    boolean := null
  ) is
  begin
    Broadcast_Alert(i_Message, Array_Number(i_User_Id), i_Mute);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Message
  (
    i_User_Ids Array_Number,
    i_Data     Hashmap := null,
    i_Mute     boolean := null
  ) is
    v_Message Hashmap;
  begin
    v_Message := Fazo.Zip_Map('type',
                              'message', --
                              'mute',
                              Sys.Diutil.Bool_To_Int(Nvl(i_Mute, false)));
  
    if i_Data is not null then
      v_Message.Put('data', i_Data);
    end if;
  
    Biruni_Service.Send_Broadcast(v_Message.Json, i_User_Ids);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Message
  (
    i_User_Id number,
    i_Data    Hashmap := null,
    i_Mute    boolean := null
  ) is
  begin
    Broadcast_Message(i_User_Ids => Array_Number(i_User_Id), i_Data => i_Data, i_Mute => i_Mute);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Notification
  (
    i_User_Ids Array_Number,
    i_Mute     boolean := null
  ) is
  begin
    Biruni_Service.Send_Broadcast(Fazo.Zip_Map('type', 'notification', --
                                   'mute', Sys.Diutil.Bool_To_Int(Nvl(i_Mute, false))).Json,
                                  i_User_Ids);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Notification
  (
    i_User_Id number,
    i_Mute    boolean := null
  ) is
  begin
    Broadcast_Notification(Array_Number(i_User_Id), i_Mute);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Task
  (
    i_User_Ids Array_Number,
    i_Mute     boolean := null
  ) is
  begin
    Biruni_Service.Send_Broadcast(Fazo.Zip_Map('type', 'task', --
                                   'mute', Sys.Diutil.Bool_To_Int(Nvl(i_Mute, false))).Json,
                                  i_User_Ids);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Broadcast_Task
  (
    i_User_Id number,
    i_Mute    boolean := null
  ) is
  begin
    Broadcast_Task(Array_Number(i_User_Id), i_Mute);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Firebase
  (
    i_Fcm_Url          varchar2,
    i_Auth_Key         varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Priority         varchar2,
    i_Data             Hashmap,
    i_Notification     Hashmap
  ) is
  begin
    Biruni_Service.Send_Firebase(i_Fcm_Url          => i_Fcm_Url,
                                 i_Auth_Key         => i_Auth_Key,
                                 i_Registration_Ids => i_Registration_Ids,
                                 i_Priority         => i_Priority,
                                 i_Data             => i_Data,
                                 i_Notification     => i_Notification);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Send_Hms
  (
    i_Auth_Server_Url  varchar2,
    i_Send_Message_Url varchar2,
    i_Client_Id        varchar2,
    i_Client_Secret    varchar2,
    i_Access_Token     varchar2,
    i_Registration_Ids Array_Varchar2,
    i_Data             Hashmap
  ) is
  begin
    Biruni_Service.Send_Hms(i_Auth_Server_Url  => i_Auth_Server_Url,
                            i_Send_Message_Url => i_Send_Message_Url,
                            i_Client_Id        => i_Client_Id,
                            i_Client_Secret    => i_Client_Secret,
                            i_Access_Token     => i_Access_Token,
                            i_Registration_Ids => i_Registration_Ids,
                            i_Data             => i_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Add_Post_Callback(i_Callback_Block varchar2) is
  begin
    Biruni_Route.Add_Post_Callback(i_Callback_Block);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Post_Callback is
  begin
    Biruni_Route.Run_Post_Callback;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_External_Service
  (
    i_Url  varchar2,
    i_Data Gmap
  ) is
    v_Data Json_Object_t := Json_Object_t;
  begin
    v_Data.Put('url', i_Url);
    v_Data.Put('request_data', i_Data.Val.To_Clob);
  
    Biruni_Route.Set_External_Service(v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_External_Service
  (
    i_Url                 varchar2,
    i_Authorization_Type  varchar2,
    i_Authorization_Token varchar2,
    i_Data                Gmap
  ) is
    v_Data Json_Object_t := Json_Object_t;
  begin
    v_Data.Put('url', i_Url);
    v_Data.Put('auth_type', i_Authorization_Type);
    v_Data.Put('auth_token', i_Authorization_Token);
    v_Data.Put('request_data', i_Data.Val.To_Clob);
  
    Biruni_Route.Set_External_Service(v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Onlyoffice
  (
    i_Sha        varchar2,
    i_File_Name  varchar2,
    i_Properties Json_Object_t
  ) is
    v_Data Json_Object_t := Json_Object_t;
  begin
    v_Data.Put('sha', i_Sha);
    v_Data.Put('fileName', i_File_Name);
    v_Data.Put('properties', i_Properties);
  
    Biruni_Route.Set_Onlyoffice(v_Data);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Url_Params(i_Data Hashmap) return Hashmap is
    v_Params clob := z_Biruni_Url_Params.Load(i_Sha => i_Data.r_Varchar2('sha')).Params;
  begin
    return Fazo.Parse_Map(v_Params);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Get_Eimzo_Api_Key(i_Host_Name varchar2) return varchar2 is
  begin
    return z_Biruni_Eimzo_Api_Keys.Take(i_Host_Name).Api_Key;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Nls_Language return varchar2 is
    v_Language varchar2(20);
  begin
    if Biruni_Route.Get_Lang_Code = 'en' then
      v_Language := 'english';
    elsif Biruni_Route.Get_Lang_Code = 'uz' then
      v_Language := '''latin uzbek''';
    else
      v_Language := 'russian';
    end if;
  
    return 'nls_date_language = ' || v_Language;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Run_Query
  (
    i_Query  Fazo_Query,
    i_Column Array_Varchar2,
    i_Limit  number := 50,
    i_Offset number := 0,
    i_Filter Arraylist := Arraylist(),
    i_Sort   Array_Varchar2 := null
  ) return Gmap is
    v_Params     Hashmap := Hashmap();
    v_Result_Str Array_Varchar2;
    v_Result_Map Gmap := Gmap();
    v_Row_Matrix Glist := Glist();
    v_Col_Array  Array_Varchar2;
    v_Row        Gmap;
    v_Rows       Glist := Glist();
    result       Gmap := Gmap();
  begin
    v_Params.Put('column', i_Column);
    v_Params.Put('limit', i_Limit);
    v_Params.Put('offset', i_Offset);
    v_Params.Put('filter', i_Filter);
    v_Params.Put('sort', i_Sort);
  
    v_Result_Str := Biruni_Core.Pq(i_Query           => i_Query,
                                   i_Params          => v_Params,
                                   i_Check_Procedure => Biruni_Core.Load_Setting().Check_Query_Procedure);
  
    v_Result_Map.Val := Json_Object_t(Fazo.Make_Clob(v_Result_Str));
  
    v_Row_Matrix := v_Result_Map.r_Glist('data');
  
    for i in 1 .. v_Row_Matrix.Count
    loop
      v_Col_Array := v_Row_Matrix.r_Array_Varchar2(i);
      v_Row       := Gmap();
    
      for j in 1 .. i_Column.Count
      loop
        v_Row.Put(i_Column(j), v_Col_Array(j));
      end loop;
    
      v_Rows.Push(v_Row.Val);
    end loop;
  
    Result.Put('count', v_Result_Map.r_Number('count'));
    Result.Put('data', v_Rows);
  
    return result;
  end;

end b;
/
