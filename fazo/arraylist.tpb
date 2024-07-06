create or replace type body Fazo_Schema.Arraylist is

  ------------------------------------------------------------------------------------------------------
  constructor Function Arraylist(self in out nocopy Fazo_Schema.Arraylist) return self as result is
  begin
    Self.Type := 'A';
    Self.Val  := Fazo_Schema.w_Array_Wrapper();
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  constructor Function Arraylist
  (
    self in out nocopy Fazo_Schema.Arraylist,
    Val  Fazo_Schema.w_Array_Wrapper
  ) return self as result is
  begin
    Self.Type := 'A';
    Self.Val  := Val;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.w_Wrapper
  ) is
  begin
    if v is null then
      Raise_Application_Error(-20999, 'Arraylist is pushed null object');
    end if;
    Self.Val.Extend;
    Val(Val.Count) := v;
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    varchar2
  ) is
  begin
    Self.Push(Fazo_Schema.Option_Varchar2(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    number
  ) is
  begin
    Self.Push(Fazo_Schema.Option_Number(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    date
  ) is
  begin
    Self.Push(Fazo_Schema.Option_Date(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    timestamp
  ) is
  begin
    Self.Push(Fazo_Schema.Option_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    timestamp with time zone
  ) is
  begin
    Self.Push(Fazo_Schema.Option_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    timestamp with local time zone
  ) is
  begin
    Self.Push(Fazo_Schema.Option_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Varchar2
  ) is
  begin
    Self.Push(Fazo_Schema.w_Array_Varchar2(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Number
  ) is
  begin
    Self.Push(Fazo_Schema.w_Array_Number(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Date
  ) is
  begin
    Self.Push(Fazo_Schema.w_Array_Date(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Procedure Push
  (
    self in out nocopy Fazo_Schema.Arraylist,
    v    Fazo_Schema.Array_Timestamp
  ) is
  begin
    Self.Push(Fazo_Schema.w_Array_Timestamp(v));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function count return pls_integer is
  begin
    return Val.Count;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    if Val.Count = 1 then
      return Val(1).As_Varchar2(i_Format, i_Nlsparam);
    elsif Val.Count = 0 then
      raise No_Data_Found;
    else
      raise Too_Many_Rows;
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    if Val.Count = 1 then
      return Val(1).As_Number(i_Format, i_Nlsparam);
    elsif Val.Count = 0 then
      raise No_Data_Found;
    else
      raise Too_Many_Rows;
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    if Val.Count = 1 then
      return Val(1).As_Date(i_Format, i_Nlsparam);
    elsif Val.Count = 0 then
      raise No_Data_Found;
    else
      raise Too_Many_Rows;
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    if Val.Count = 1 then
      return Val(1).As_Timestamp(i_Format, i_Nlsparam);
    elsif Val.Count = 0 then
      raise No_Data_Found;
    else
      raise Too_Many_Rows;
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
    result Fazo_Schema.Array_Varchar2 := Fazo_Schema.Array_Varchar2();
  begin
    Result.Extend(Val.Count);
    for i in 1 .. Val.Count
    loop
      result(i) := Val(i).As_Varchar2(i_Format, i_Nlsparam);
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
    result Fazo_Schema.Array_Number := Array_Number();
  begin
    Result.Extend(Val.Count);
    for i in 1 .. Val.Count
    loop
      result(i) := Val(i).As_Number(i_Format, i_Nlsparam);
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Date
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
    result Fazo_Schema.Array_Date := Fazo_Schema.Array_Date();
  begin
    Result.Extend(Val.Count);
    for i in 1 .. Val.Count
    loop
      result(i) := Val(i).As_Date(i_Format, i_Nlsparam);
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Timestamp
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
    result Fazo_Schema.Array_Timestamp := Fazo_Schema.Array_Timestamp();
  begin
    Result.Extend(Val.Count);
    for i in 1 .. Val.Count
    loop
      result(i) := Val(i).As_Timestamp(i_Format, i_Nlsparam);
    end loop;
    return result;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    return Val(i).As_Varchar2(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    return Val(i).As_Number(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    return Val(i).As_Date(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    return Val(i).As_Timestamp(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    return Val(i).As_Array_Varchar2(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
  begin
    return Val(i).As_Array_Number(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
  begin
    return Val(i).As_Array_Date(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Array_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
  begin
    return Val(i).As_Array_Timestamp(i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Calc(i pls_integer) return Fazo_Schema.Calc is
  begin
    return Treat(Val(i) as Fazo_Schema.Calc);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Arraylist(i pls_integer) return Fazo_Schema.Arraylist is
  begin
    return Fazo_Schema.Arraylist.As_Arraylist(Val(i));
  end;

  ------------------------------------------------------------------------------------------------------
  member Function r_Hashmap(i pls_integer) return Fazo_Schema.w_Wrapper is
  begin
    return Val(i);
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Varchar2(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Number(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return date is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Date(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return timestamp is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Timestamp(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Varchar2
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Varchar2 is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Array_Varchar2(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Number
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Number is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Array_Number(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Date
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Date is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Array_Date(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Array_Timestamp
  (
    i          pls_integer,
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Fazo_Schema.Array_Timestamp is
  begin
    if 0 < i and i <= Val.Count then
      return Val(i).As_Array_Timestamp(i_Format, i_Nlsparam);
    end if;
    return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Calc(i pls_integer) return Fazo_Schema.Calc is
  begin
    return Treat(Val(i) as Fazo_Schema.Calc);
  exception
    when others then
      return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Arraylist(i pls_integer) return Fazo_Schema.Arraylist is
  begin
    return Fazo_Schema.Arraylist.As_Arraylist(Val(i));
  exception
    when others then
      return null;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function o_Hashmap(i pls_integer) return Fazo_Schema.w_Wrapper is
  begin
    return Val(i);
  exception
    when others then
      return null;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Arraylist return boolean is
  begin
    return true;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Varchar2(i pls_integer) return boolean is
  begin
    return Val(i).Is_Varchar2;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Number(i pls_integer) return boolean is
  begin
    return Val(i).Is_Number;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Date(i pls_integer) return boolean is
  begin
    return Val(i).Is_Date;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Timestamp(i pls_integer) return boolean is
  begin
    return Val(i).Is_Timestamp;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Varchar2(i pls_integer) return boolean is
  begin
    return Val(i).Is_Array_Varchar2;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Number(i pls_integer) return boolean is
  begin
    return Val(i).Is_Array_Number;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Date(i pls_integer) return boolean is
  begin
    return Val(i).Is_Array_Date;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Array_Timestamp(i pls_integer) return boolean is
  begin
    return Val(i).Is_Array_Timestamp;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  member Function Is_Arraylist(i pls_integer) return boolean is
  begin
    return Val(i).Is_Arraylist;
  exception
    when others then
      return false;
  end;
  ------------------------------------------------------------------------------------------------------
  member Function Is_Calc(i pls_integer) return boolean is
  begin
    return Val(i).Is_Calc;
  exception
    when others then
      return false;
  end;
  ------------------------------------------------------------------------------------------------------
  member Function Is_Hashmap(i pls_integer) return boolean is
  begin
    return Val(i).Is_Hashmap;
  exception
    when others then
      return false;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Procedure Print_Json
  (
    self in Fazo_Schema.Arraylist,
    out  in out nocopy Fazo_Schema.Stream
  ) is
  begin
    Out.Print('[');
  
    for i in 1 .. Val.Count
    loop
    
      Self.Val(i).Print_Json(out);
    
      if i <> Val.Count then
        Out.Print(',');
      end if;
    
    end loop;
  
    Out.Print(']');
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
    result varchar2(32767);
  begin
    result := '[';
  
    for i in 1 .. Val.Count
    loop
    
      result := result || Val(i).Json;
    
      if i <> Val.Count then
        result := result || ',';
      end if;
    
    end loop;
  
    return result || ']';
  end;

  ------------------------------------------------------------------------------------------------------
  static Function As_Arraylist(v Fazo_Schema.w_Wrapper) return Arraylist is
  begin
    case
      when v.Is_Arraylist then
        return Treat(v as Fazo_Schema.Arraylist);
      
      when v.Is_Array_Varchar2 then
        declare
          Va Fazo_Schema.Array_Varchar2 := v.As_Array_Varchar2;
          r  Fazo_Schema.Arraylist := Fazo_Schema.Arraylist();
        begin
          for i in 1 .. Va.Count
          loop
            r.Push(Va(i));
          end loop;
          return r;
        end;
      
      when v.Is_Array_Number then
        declare
          Va Fazo_Schema.Array_Number := v.As_Array_Number;
          r  Fazo_Schema.Arraylist := Fazo_Schema.Arraylist();
        begin
          for i in 1 .. Va.Count
          loop
            r.Push(Va(i));
          end loop;
          return r;
        end;
      
      when v.Is_Array_Date then
        declare
          Va Fazo_Schema.Array_Date := v.As_Array_Date;
          r  Fazo_Schema.Arraylist := Fazo_Schema.Arraylist();
        begin
          for i in 1 .. Va.Count
          loop
            r.Push(Va(i));
          end loop;
          return r;
        end;
      
      when v.Is_Array_Timestamp then
        declare
          Va Fazo_Schema.Array_Timestamp := v.As_Array_Timestamp;
          r  Fazo_Schema.Arraylist := Fazo_Schema.Arraylist();
        begin
          for i in 1 .. Va.Count
          loop
            r.Push(Va(i));
          end loop;
          return r;
        end;
      
      when v.Is_Varchar2 then
        return Fazo_Schema.Arraylist(Fazo_Schema.w_Array_Wrapper(Fazo_Schema.Option_Varchar2(v.As_Varchar2)));
      
      when v.Is_Number then
        return Fazo_Schema.Arraylist(Fazo_Schema.w_Array_Wrapper(Fazo_Schema.Option_Number(v.As_Number)));
      
      when v.Is_Date then
        return Fazo_Schema.Arraylist(Fazo_Schema.w_Array_Wrapper(Fazo_Schema.Option_Date(v.As_Date)));
      
      when v.Is_Timestamp then
        return Fazo_Schema.Arraylist(Fazo_Schema.w_Array_Wrapper(Fazo_Schema.Option_Timestamp(v.As_Timestamp)));
      
    end case;
  
  end;

end;
/
