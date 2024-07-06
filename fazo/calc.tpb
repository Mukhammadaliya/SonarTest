create or replace type body Fazo_Schema.Calc is

  ------------------------------------------------------------------------------------------------------
  constructor Function Calc(self in out nocopy Fazo_Schema.Calc) return self as result is
  begin
    Self.Buckets := Fazo_Schema.w_Calc_Bucket_Array();
    Self.Buckets.Extend(64);
    Self.Sep := '~';
    return;
  end Calc;

  ------------------------------------------------------------------------------------------------------
  constructor Function Calc
  (
    self      in out nocopy Fazo_Schema.Calc,
    Separator varchar2
  ) return self as result is
  begin
    Self.Buckets := Fazo_Schema.w_Calc_Bucket_Array();
    Self.Buckets.Extend(64);
    Self.Sep := Separator;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Find_Or_Create
  (
    self  in out nocopy Fazo_Schema.Calc,
    i_Key varchar2,
    i     out pls_integer,
    j     out pls_integer
  ) is
    n     pls_integer;
    v_Key varchar2(100) := Lower(i_Key);
  begin
    i := Dbms_Utility.Get_Hash_Value(v_Key, 1, 64);
  
    if Self.Buckets(i) is not null then
    
      n := Buckets(i).Count;
      for k in 1 .. n
      loop
        if Buckets(i)(k).Key = v_Key then
          j := k;
          return;
        end if;
      end loop;
    
      Buckets(i).Extend;
      j := n + 1;
      Buckets(i)(j) := Fazo_Schema.Calc_Entry(v_Key);
    
    else
    
      Buckets(i) := Fazo_Schema.Calc_Bucket(Fazo_Schema.Calc_Entry(v_Key));
      j := 1;
    
    end if;
  
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key  varchar2,
    v    number
  ) is
    i pls_integer;
    j pls_integer;
  begin
    if v is null or v = 0 then
      return;
    end if;
    Self.Find_Or_Create(Key, i, j);
    Buckets(i)(j).Plus(v);
  end Plus;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    v    number
  ) is
  begin
    Self.Plus(Key1 || Sep || Key2, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    v    number
  ) is
  begin
    Self.Plus(Key1 || Sep || Key2 || Sep || Key3, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    v    number
  ) is
  begin
    Self.Plus(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    Key5 varchar2,
    v    number
  ) is
  begin
    Self.Plus(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4 || Sep || Key5, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Plus
  (
    self in out nocopy Fazo_Schema.Calc,
    That in Fazo_Schema.Calc
  ) is
  begin
    for i in 1 .. That.Buckets.Count
    loop
      if That.Buckets(i) is not null then
        for j in 1 .. That.Buckets(i).Count
        loop
          Self.Plus(That.Buckets(i)(j).Key, That.Buckets(i)(j).Val);
        end loop;
      end if;
    end loop;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function count return binary_integer is
    result binary_integer := 0;
  begin
    for i in 1 .. Buckets.Count
    loop
      if Buckets(i) is not null then
        result := result + Buckets(i).Count;
      end if;
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Value(Key varchar2) return number is
    i     pls_integer;
    n     pls_integer;
    v_Key varchar2(100) := Lower(Key);
  begin
    i := Dbms_Utility.Get_Hash_Value(v_Key, 1, 64);
  
    if Self.Buckets(i) is not null then
    
      n := Buckets(i).Count;
      for k in 1 .. n
      loop
        if Buckets(i)(k).Key = v_Key then
          return Buckets(i)(k).Val;
        end if;
      end loop;
    
    end if;
  
    return 0;
  end Get_Value;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2
  ) return number is
  begin
    return Get_Value(Key1 || Sep || Key2);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2
  ) return number is
  begin
    return Get_Value(Key1 || Sep || Key2 || Sep || Key3);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2
  ) return number is
  begin
    return Get_Value(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Value
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    Key5 varchar2
  ) return number is
  begin
    return Get_Value(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4 || Sep || Key5);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key  varchar2,
    v    number
  ) is
    i pls_integer;
    j pls_integer;
  begin
    Self.Find_Or_Create(Key, i, j);
    Buckets(i)(j).Val := v;
  end Set_Value;

  ------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    v    number
  ) is
  begin
    Self.Set_Value(Key1 || Sep || Key2, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    v    number
  ) is
  begin
    Self.Set_Value(Key1 || Sep || Key2 || Sep || Key3, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    v    number
  ) is
  begin
    Self.Set_Value(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Set_Value
  (
    self in out nocopy Fazo_Schema.Calc,
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2,
    Key5 varchar2,
    v    number
  ) is
  begin
    Self.Set_Value(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4 || Sep || Key5, v);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Sum_By_Prefix(Prefix varchar2) return number is
    v_Prefix varchar2(100) := Lower(Prefix) || '%';
    result   number := 0;
  begin
    for i in 1 .. Buckets.Count
    loop
      if Buckets(i) is not null then
        for j in 1 .. Buckets(i).Count
        loop
          if Buckets(i)(j).Key like v_Prefix then
            result := result + Buckets(i)(j).Val;
          end if;
        end loop;
      end if;
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Sum_By_Like(Expr varchar2) return number is
    result number := 0;
  begin
    for i in 1 .. Buckets.Count
    loop
      if Buckets(i) is not null then
        for j in 1 .. Buckets(i).Count
        loop
          if Buckets(i)(j).Key like Expr then
            result := result + Buckets(i)(j).Val;
          end if;
        end loop;
      end if;
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key(Key1 varchar2) return number is
  begin
    return Sum_By_Prefix(Key1 || Sep);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key
  (
    Key1 varchar2,
    Key2 varchar2
  ) return number is
  begin
    return Sum_By_Prefix(Key1 || Sep || Key2 || Sep);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2
  ) return number is
  begin
    return Sum_By_Prefix(Key1 || Sep || Key2 || Sep || Key3 || Sep);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Sum_By_Key
  (
    Key1 varchar2,
    Key2 varchar2,
    Key3 varchar2,
    Key4 varchar2
  ) return number is
  begin
    return Sum_By_Prefix(Key1 || Sep || Key2 || Sep || Key3 || Sep || Key4 || Sep);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Get_Bucket return Fazo_Schema.Calc_Bucket is
    result Calc_Bucket := Fazo_Schema.Calc_Bucket();
  begin
    for i in 1 .. Buckets.Count
    loop
      if Buckets(i) is not null then
        for j in 1 .. Buckets(i).Count
        loop
          Result.Extend;
          result(Result.Count) := Buckets(i) (j);
        end loop;
      end if;
    end loop;
    return result;
  end Get_Bucket;

  ------------------------------------------------------------------------------------------------------
  member Function Keyset return Fazo_Schema.Array_Varchar2 is
    result Array_Varchar2 := Array_Varchar2();
  begin
    for i in 1 .. Buckets.Count
    loop
      if Buckets(i) is not null then
        for j in 1 .. Buckets(i).Count
        loop
          Result.Extend;
          result(Result.Count) := Buckets(i)(j).Key;
        end loop;
      end if;
    end loop;
  
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Calc return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Calc,
    out  in out nocopy Fazo_Schema.Stream
  ) is
    First_Entry boolean := true;
  begin
    Out.Print('{');
  
    for i in 1 .. Self.Buckets.Count
    loop
    
      if Buckets(i) is not null then
        for j in 1 .. Buckets(i).Count
        loop
        
          if First_Entry then
            Out.Print(',');
            First_Entry := false;
          end if;
        
          Out.Print('"' || Buckets(i)(j)
                    .Key || '":"' || Fazo_Schema.Fazo.Format_Number(Buckets(i)(j).Val) || '"');
        
        end loop;
      end if;
    
    end loop;
  
    Out.Print('}');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
    First_Entry boolean := true;
    result      varchar2(32767);
  begin
    result := '{';
  
    for i in 1 .. Self.Buckets.Count
    loop
    
      if Buckets(i) is not null then
        for j in 1 .. Buckets(i).Count
        loop
        
          if First_Entry then
            result      := result || ',';
            First_Entry := false;
          end if;
        
          result := result || '"' || Buckets(i)(j)
                   .Key || '":"' || Fazo_Schema.Fazo.Format_Number(Buckets(i)(j).Val) || '"';
        
        end loop;
      end if;
    
    end loop;
  
    return result || '}';
  end;

end;
/
