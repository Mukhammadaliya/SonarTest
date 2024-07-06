create or replace type Fazo_Schema.Stream Force as object
(
  Val Fazo_Schema.Array_Varchar2,
------------------------------------------------------------------------------------------------------
  constructor Function Stream(self in out nocopy Fazo_Schema.Stream) return self as result,
  constructor Function Stream
  (
    self in out nocopy Fazo_Schema.Stream,
    v    varchar2
  ) return self as result,

------------------------------------------------------------------------------------------------------
  member Procedure Print
  (
    self in out nocopy Fazo_Schema.Stream,
    v    varchar2
  ),
  member Procedure Println
  (
    self in out nocopy Fazo_Schema.Stream,
    v    varchar2
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Println(self in out nocopy Fazo_Schema.Stream),
------------------------------------------------------------------------------------------------------
  member Procedure Print
  (
    self in out nocopy Fazo_Schema.Stream,
    v    Fazo_Schema.Array_Varchar2
  ),
  member Procedure Print
  (
    self in out nocopy Fazo_Schema.Stream,
    v    Fazo_Schema.Stream
  ),
------------------------------------------------------------------------------------------------------
  member Function Stream_Length return number,
------------------------------------------------------------------------------------------------------
  member Function Is_Empty return boolean,
------------------------------------------------------------------------------------------------------
  member Function Non_Empty return boolean,
------------------------------------------------------------------------------------------------------
  member Function As_Clob return clob,
------------------------------------------------------------------------------------------------------
  member Function As_Blob return blob,
------------------------------------------------------------------------------------------------------
  member Function Get_Clob return clob,
------------------------------------------------------------------------------------------------------
  member Function Get_Blob return blob,
------------------------------------------------------------------------------------------------------
  member Procedure Write_Clob
  (
    self   in Fazo_Schema.Stream,
    Io_Out in out nocopy clob
  ),
------------------------------------------------------------------------------------------------------
  member Procedure Write_Blob
  (
    self   in Fazo_Schema.Stream,
    Io_Out in out nocopy blob
  )
)
;
/
create or replace type body Fazo_Schema.Stream is

  ------------------------------------------------------------------------------------------------------
  constructor Function Stream(self in out nocopy Fazo_Schema.Stream) return self as result is
  begin
    Self.Val := Fazo_Schema.Array_Varchar2('');
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  constructor Function Stream
  (
    self in out nocopy Fazo_Schema.Stream,
    v    varchar2
  ) return self as result is
  begin
    Self.Val := Fazo_Schema.Array_Varchar2(v);
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Print
  (
    self in out nocopy Fazo_Schema.Stream,
    v    varchar2
  ) is
    p pls_integer := Val.Count;
  begin
  
    Self.Val(p) := Val(p) || v;
  
  exception
    when Value_Error then
    
      if p > 3200 then
        Raise_Application_Error(-20999, 'Stream limit reached 100M');
      end if;
    
      Val.Extend;
      Val(Val.Count) := v;
    
  end Print;

  ------------------------------------------------------------------------------------------------------
  member Procedure Println
  (
    self in out nocopy Fazo_Schema.Stream,
    v    varchar2
  ) is
  begin
    Self.Print(v);
    Self.Print(Chr(13) || Chr(10));
  end Println;

  ------------------------------------------------------------------------------------------------------
  member Procedure Println(self in out nocopy Fazo_Schema.Stream) is
  begin
    Self.Print(Chr(13) || Chr(10));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Print
  (
    self in out nocopy Fazo_Schema.Stream,
    v    Fazo_Schema.Array_Varchar2
  ) is
  begin
    if v is null then
      return;
    end if;
    for i in 1 .. v.Count
    loop
      Self.Print(v(i));
    end loop;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Print
  (
    self in out nocopy Fazo_Schema.Stream,
    v    Fazo_Schema.Stream
  ) is
  begin
    Self.Val := Val multiset union v.Val;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Stream_Length return number is
    result number := 0;
  begin
  
    if Self.Val is null then
      return 0;
    end if;
  
    for i in 1 .. Self.Val.Count
    loop
      result := result + Nvl(Length(Self.Val(i)), 0);
    end loop;
  
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Empty return boolean is
  begin
    if Self.Val is null then
      return true;
    end if;
  
    for i in 1 .. Self.Val.Count
    loop
      if Self.Val(i) is not null then
        return false;
      end if;
    end loop;
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Non_Empty return boolean is
  begin
    return not Is_Empty;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function As_Clob return clob is
    result clob;
  begin
    if Val is not null then
      Dbms_Lob.Createtemporary(result, false);
      Dbms_Lob.Open(result, Dbms_Lob.Lob_Readwrite);
      Write_Clob(result);
      Dbms_Lob.Close(result);
    end if;
    return result;
  end As_Clob;

  ------------------------------------------------------------------------------------------------------
  member Function As_Blob return blob is
    result blob;
  begin
    Dbms_Lob.Createtemporary(result, false);
    Dbms_Lob.Open(result, Dbms_Lob.Lob_Readwrite);
    Write_Blob(result);
    Dbms_Lob.Close(result);
    return result;
  end As_Blob;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Clob return clob is
    result clob;
  begin
    if Val is not null then
      Dbms_Lob.Createtemporary(result, false);
      Dbms_Lob.Open(result, Dbms_Lob.Lob_Readwrite);
      Write_Clob(result);
      Dbms_Lob.Close(result);
    end if;
    return result;
  end Get_Clob;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Blob return blob is
    result blob;
  begin
    Dbms_Lob.Createtemporary(result, false);
    Dbms_Lob.Open(result, Dbms_Lob.Lob_Readwrite);
    Write_Blob(result);
    Dbms_Lob.Close(result);
    return result;
  end Get_Blob;

  ------------------------------------------------------------------------------------------------------
  member Procedure Write_Clob
  (
    self   in Fazo_Schema.Stream,
    Io_Out in out nocopy clob
  ) is
  begin
    if Val is null then
      return;
    end if;
    for i in 1 .. Val.Count
    loop
      if Val(i) is not null then
        Dbms_Lob.Writeappend(Io_Out, Length(Val(i)), Self.Val(i));
      end if;
    end loop;
  end Write_Clob;

  ------------------------------------------------------------------------------------------------------
  member Procedure Write_Blob
  (
    self   in Fazo_Schema.Stream,
    Io_Out in out nocopy blob
  ) is
  begin
    for i in 1 .. Val.Count
    loop
      Dbms_Lob.Append(Io_Out, Utl_Raw.Cast_To_Raw(Self.Val(i)));
    end loop;
  end Write_Blob;

end;
/
