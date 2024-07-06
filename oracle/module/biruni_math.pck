create or replace package Biruni_Math is
  ----------------------------------------------------------------------------------------------------
  c_Base       constant number(18) := 1000000000000;
  c_Base_Speed constant number(2) := 12;
  ----------------------------------------------------------------------------------------------------
  Function Hex_To_Dec(i_Hex varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Dec_To_Hex(i_Dec varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Rsa_Hex
  (
    i_Hex_Val varchar2,
    i_Exp     varchar2,
    i_Mod     varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Test;
end Biruni_Math;
/
create or replace package body Biruni_Math is
  ----------------------------------------------------------------------------------------------------
  Function reverse(i_Val Array_Number) return Array_Number is
    result Array_Number := Array_Number();
    j      Simple_Integer := 1;
  begin
    Result.Extend(i_Val.Count);
    for i in reverse 1 .. i_Val.Count
    loop
      result(j) := i_Val(i);
      j := j + 1;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Val
  (
    i_Val   Array_Number,
    i_Index number
  ) return number is
  begin
    if i_Val.Count < i_Index or i_Index < 1 then
      return 0;
    end if;
    return i_Val(i_Index);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Encode_Base(i_Big Array_Number) return Array_Number is
    result  Array_Number := Array_Number();
    v_Size  pls_integer := Floor((i_Big.Count + c_Base_Speed - 1) / c_Base_Speed);
    v_Value number;
  begin
    Result.Extend(v_Size);
    for i in 1 .. v_Size
    loop
      v_Value := 0;
      for j in 1 .. c_Base_Speed
      loop
        v_Value := v_Value * 10 + Get_Val(i_Big, i_Big.Count - (v_Size - i + 1) * c_Base_Speed + j);
      end loop;
      result(i) := v_Value;
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Decode_Base(i_Big Array_Number) return Array_Number is
    result  Array_Number := Array_Number();
    v_Value number;
  begin
    for i in 1 .. i_Big.Count
    loop
      v_Value := i_Big(i_Big.Count - i + 1);
      for j in 1 .. c_Base_Speed
      loop
        Result.Extend();
        result(Result.Count) := mod(v_Value, 10);
        v_Value := Floor(v_Value / 10);
      end loop;
    end loop;
    v_Value := Result.Count + 1;
    for i in 1 .. Result.Count - 1
    loop
      if result(Result.Count - i + 1) = 0 then
        v_Value := Result.Count - i + 1;
      else
        exit;
      end if;
    end loop;
    Result.Delete(v_Value, Result.Count);
    return reverse(result);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Add_Private
  (
    i_a    Array_Number,
    i_b    Array_Number,
    i_Flag pls_integer := 0
  ) return Array_Number is
    result Array_Number := i_a;
    a_Len  pls_integer := i_a.Count;
    b_Len  pls_integer := i_b.Count;
    v_Size pls_integer := Greatest(a_Len, b_Len + i_Flag);
    j      pls_integer := 1 - i_Flag;
    v_Rem  number := 0;
  begin
    if v_Size > a_Len then
      Result.Extend(v_Size - a_Len);
    end if;
    for i in 1 .. v_Size
    loop
      if i <= a_Len then
        v_Rem := v_Rem + result(i);
      end if;
      if j <= b_Len and j > 0 then
        v_Rem := v_Rem + i_b(j);
      end if;
      if v_Rem >= c_Base then
        result(i) := v_Rem - c_Base;
        v_Rem := 1;
      else
        result(i) := v_Rem;
        v_Rem := 0;
      end if;
      j := j + 1;
    end loop;
  
    if v_Rem = 1 then
      Result.Extend();
      result(v_Size + 1) := 1;
    end if;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Compare
  (
    i_a            Array_Number,
    i_b            Array_Number,
    i_Invert_First boolean := false
  ) return Simple_Integer is
    i  Simple_Integer := i_a.Count;
    ex Simple_Integer := -1;
    j  Simple_Integer := i_a.Count;
  begin
    if i_a.Count > i_b.Count then
      return 1;
    elsif i_a.Count < i_b.Count then
      return - 1;
    else
      if i_Invert_First then
        j  := 1;
        ex := 1;
      end if;
      while i > 0
      loop
        if i_a(j) > i_b(i) then
          return 1;
        elsif i_a(j) < i_b(i) then
          return - 1;
        end if;
        i := i - 1;
        j := j + ex;
      end loop;
    end if;
    return 0;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Doc(i_a Array_Number) return Array_Varchar2 is
    a Array_Number := reverse(i_a);
    r Array_Varchar2 := Array_Varchar2();
  begin
    r.Extend(a.Count);
    for i in 1 .. a.Count
    loop
      if i = 1 then
        r(i) := to_char(a(i));
      else
        r(i) := to_char(a(i), '000000000000');
      end if;
    end loop;
    return r;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Subtract
  (
    i_Greater Array_Number,
    i_Lower   Array_Number
  ) return Array_Number is
    v_a       Array_Number := i_Greater;
    g_Len     pls_integer := i_Greater.Count;
    l_Len     pls_integer := i_Lower.Count;
    Is_Delete boolean := false;
    Val       number;
    Qsub      number;
    Qrem      number := 0;
  begin
    for i in 1 .. g_Len
    loop
      if i <= l_Len then
        Val := v_a(i) - i_Lower(i) - Qrem;
      else
        Val := v_a(i) - Qrem;
      end if;
    
      if Val < 0 then
        Qrem := 1;
        Val  := Val + c_Base;
      else
        Qrem := 0;
      end if;
      v_a(i) := Val;
    end loop;
    while v_a(g_Len) = 0 and g_Len > 1
    loop
      g_Len := g_Len - 1;
    end loop;
    if g_Len <> v_a.Count then
      v_a.Delete(g_Len + 1, v_a.Count);
    end if;
    return v_a;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Multiply
  (
    i_a Array_Number,
    i_b number
  ) return Array_Number is
    v_a   Array_Number := i_a;
    a_Len Simple_Integer := i_a.Count;
    Val   number;
    Rem   number := 0;
  begin
    for i in 1 .. a_Len
    loop
      Val := v_a(i) * i_b + Rem;
      if Val >= c_Base then
        Rem := Floor(Val / c_Base);
        v_a(i) := Val - Rem * c_Base;
      else
        v_a(i) := Val;
        Rem := 0;
      end if;
    end loop;
    if Rem <> 0 then
      v_a.Extend();
      v_a(a_Len + 1) := Rem;
    end if;
    return v_a;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Multiply_Private
  (
    i_a Array_Number,
    i_b Array_Number
  ) return Array_Number is
    result Array_Number := Array_Number(0);
  begin
    for i in 1 .. i_b.Count
    loop
      result := Add_Private(result, Multiply(i_a, i_b(i)), i - 1);
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Divide
  (
    i_a   Array_Number,
    i_b   number,
    i_Rem in out number
  ) return Array_Number is
    result   Array_Number := Array_Number();
    v_Rem    number := 0;
    Val      number;
    v_Value  number;
    v_Access boolean := false;
  begin
  
    for i in 1 .. i_a.Count
    loop
      Val     := i_a(i) + v_Rem;
      v_Value := Floor(Val / i_b);
      i_Rem   := Val - v_Value * i_b;
      v_Rem   := i_Rem * c_Base;
      if v_Value <> 0 then
        v_Access := true;
      end if;
      if v_Access then
        Result.Extend();
        result(Result.Count) := v_Value;
      end if;
    end loop;
    if Result.Count = 0 then
      Result.Extend();
      result(1) := 0;
    end if;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mod_Big
  (
    i_a Array_Number,
    i_b Array_Number
  ) return Array_Number is
    a_Len pls_integer := i_a.Count;
    b_Len pls_integer := i_b.Count;
    Cmp   Simple_Integer := Compare(i_a, i_b, true);
  
    result Array_Number := Array_Number();
    v_Mult Array_Number;
  
    Qhat number;
    v_Vl number;
  
    v_Dl    number := i_b(b_Len) * c_Base + i_b(b_Len - 1);
    v_Dlong number := v_Dl * c_Base + i_b(b_Len - 2);
  
  begin
    if Cmp = 0 then
      return Array_Number(0);
    elsif Cmp = -1 then
      return i_a;
    end if;
    /*if i_b.Count < 3 then
      b.Raise_Error('mod is too small');
    end if;
    */
    for i in reverse 1 .. a_Len
    loop
      Result.Extend();
      result(Result.Count) := i_a(i);
      if Result.Count >= i_b.Count then
        Cmp := Compare(result, i_b, true);
        continue when Cmp = -1;
        if Cmp = 0 then
          result := Array_Number();
        else
        
          ----- divide operation -----          
          v_Vl := (result(1) * c_Base + result(2)) * c_Base + result(3);
          if Result.Count > i_b.Count then
            Qhat := Least(Floor(v_Vl / v_Dl), c_Base - 1);
          else
            Qhat := Least(Floor(v_Vl / v_Dlong), c_Base - 1);
          end if;
          v_Mult := Multiply(i_b, Qhat);
          if Compare(result, v_Mult, true) = -1 then
            v_Mult := Multiply(i_b, Qhat - 1);
          end if;
          ----reverse----
          result := reverse(result);
          result := Subtract(result, v_Mult);
          ----reverse----
          result := reverse(result);
        
        end if;
      end if;
    end loop;
  
    if Result.Count = 0 then
      return Array_Number(0);
    end if;
    return reverse(result);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mod_Pow
  (
    i_Val Array_Number,
    i_Pow Array_Number,
    i_Mod Array_Number
  ) return Array_Number is
    result  Array_Number := Array_Number(1);
    v_Val   Array_Number := reverse(i_Val);
    v_Pow   Array_Number := i_Pow;
    v_Mod   Array_Number := reverse(i_Mod);
    v_Rem   number;
    v_Count number := 0;
  begin
    if Compare(v_Val, v_Mod) = 1 then
      b.Raise_Error('value is greater than mod');
    end if;
    while not (v_Pow.Count = 1 and v_Pow(1) = 0) and v_Pow.Count > 0
    loop
      v_Count := v_Count + 1;
      if mod(v_Pow(v_Pow.Count), 2) = 1 then
        result := Mod_Big(Multiply_Private(result, v_Val), v_Mod);
      end if;
      v_Val := Mod_Big(Multiply_Private(v_Val, v_Val), v_Mod);
      v_Pow := Divide(v_Pow, 2, v_Rem);
    end loop;
    return reverse(result);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Mod_Power
  (
    i_a   Array_Number,
    i_Exp Array_Number,
    i_Mod Array_Number
  ) return Array_Number is
  
    v_a   Array_Number := Encode_Base(i_a);
    v_Exp Array_Number := Encode_Base(i_Exp);
    v_Mod Array_Number := Encode_Base(i_Mod);
  begin
  
    return Decode_Base(Mod_Pow(v_a, v_Exp, v_Mod));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Hex_To_Decimal(i_Hex_Val varchar2) return Array_Number is
    Res       Array_Number := Array_Number(0);
    Hex_Power Array_Number := Array_Number(1);
    v_Len     pls_integer := Length(i_Hex_Val);
    --------------------------------
    Function Decode(i_Char varchar2) return number is
      v_Code number := Ascii(i_Char);
    begin
      if v_Code >= Ascii('A') and v_Code <= Ascii('F') then
        return v_Code - Ascii('A') + 10;
      end if;
      if v_Code >= Ascii('0') and v_Code <= Ascii('9') then
        return v_Code - Ascii('0');
      end if;
      b.Raise_Error('Hex value incorrect : ' || i_Char);
    end;
  
  begin
    for i in 1 .. v_Len
    loop
      Res       := Add_Private(Res,
                               Multiply(Hex_Power, Decode(Substr(i_Hex_Val, v_Len - i + 1, 1))));
      Hex_Power := Multiply(Hex_Power, 16);
    end loop;
    return Decode_Base(reverse(Res));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Decimal_To_Hex(i_Val Array_Number) return varchar2 is
    v_Val  Array_Number := Encode_Base(i_Val);
    v_Rem  number;
    v_Ans  varchar2(32000);
    result Array_Number := Array_Number();
    -------------------------------
    Function Encode(i_a number) return varchar2 is
    begin
      if i_a >= 0 and i_a <= 9 then
        return Chr(i_a + Ascii('0'));
      end if;
      if i_a >= 10 and i_a <= 15 then
        return Chr(i_a - 10 + Ascii('A'));
      end if;
      b.Raise_Error('encoding dec to hex fail ' || i_a || ' !');
    end;
  
  begin
    while not (v_Val.Count = 1 and v_Val(1) = 0)
    loop
      v_Val := Divide(v_Val, 16, v_Rem);
      Result.Extend();
      result(Result.Count) := v_Rem;
    end loop;
    if Result.Count = 0 then
      return '0';
    end if;
    result := reverse(result);
    for i in 1 .. Result.Count
    loop
      v_Ans := v_Ans || Encode(result(i));
    end loop;
    return v_Ans;
  end;

  ----------------------------------------------------------------------------------------------------
  Function To_Array(r varchar2) return Array_Number is
    result Array_Number := Array_Number();
  begin
    Result.Extend(Length(r));
    for i in 1 .. Result.Count
    loop
      result(i) := to_number(Substr(r, i, 1));
    end loop;
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Hex_To_Dec(i_Hex varchar2) return varchar2 is
  begin
    return Fazo.Gather(Hex_To_Decimal(i_Hex), '');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Dec_To_Hex(i_Dec varchar2) return varchar2 is
  begin
    return Decimal_To_Hex(To_Array(i_Dec));
  end;

  ----------------------------------------------------------------------------------------------------
  Function Rsa_Hex
  (
    i_Hex_Val varchar2,
    i_Exp     varchar2,
    i_Mod     varchar2
  ) return varchar2 is
    Res   Array_Number := Array_Number(1);
    v_Val Array_Number := Hex_To_Decimal(Upper(i_Hex_Val));
    v_Exp Array_Number;
    v_Mod Array_Number;
  begin
    v_Exp := To_Array(i_Exp);
    v_Mod := To_Array(i_Mod);
    Res   := Mod_Power(i_a => v_Val, i_Exp => v_Exp, i_Mod => v_Mod);
    return Decimal_To_Hex(Res);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Test is
    Aa  varchar2(4000) := 'A124412312423523423444444444444444BBBBDACDACD444444444444444444444444444444444444444444444444444444441A';
    Exp varchar2(4000) := '29';
    Nn  varchar2(4000) := '6157750990843564899040526104103265719297860652172632823400065455699068450255812459659898039342299176739625908677540037844125877114187853026418999188757801';
    Dd  varchar2(4000) := '2972707374889996847812667774394680002419656866566098604400031599302998562192384595754389927039245776685876687343128498677629624892701967351358081915610133';
    Enc varchar2(4000);
    dec varchar2(4000) := 'fail';
  begin
  
    Enc := Rsa_Hex(Aa, Exp, Nn);
    dec := Rsa_Hex(Enc, Dd, Nn);
    Dbms_Output.Put_Line('a =   ' || Aa);
    Dbms_Output.Put_Line('e =   ' || Exp);
    Dbms_Output.Put_Line('n =   ' || Nn);
    Dbms_Output.Put_Line('d =   ' || Dd);
    Dbms_Output.Put_Line('enc = ' || Enc);
    Dbms_Output.Put_Line('dec = ' || dec);
    if dec = Aa then
      Dbms_Output.Put_Line('successfull!!!');
    else
      Dbms_Output.Put_Line('fail (^_^) ');
    end if;
  end;

end Biruni_Math;
/
