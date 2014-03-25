{ Inprise's sorting routine }

type
  TListSortCompare = function(item1, item2: Pointer): Integer;

const
  cmpIgnoreCase: Boolean = false;

procedure QuickSort(SortList: PItemList; L, R: Integer;
  SCompare: TListSortCompare);
var
  I, J: Integer;
  P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while SCompare(SortList^[I], P) < 0 do
        Inc(I);
      while SCompare(SortList^[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

// from wizard.pas
function upcase(C: Char): Char;
begin
  case c of
    'a'..'z': c := chr(ord(c) - (97 - 65));
    ' '..'¯': c := chr(ord(c) - (160 - 128));
    'à'..'ï': c := chr(ord(c) - (224 - 144));
    'ñ': c := 'ð';
  end;
  upcase := c;
end;

// from wizard.pas
function locase(c: Char): Char;
begin
  case c of
    'A'..'Z': c := chr(ord(c) + (97 - 65));
    '€'..'': c := chr(ord(c) + (160 - 128));
    ''..'Ÿ': c := chr(ord(c) + (224 - 144));
    'ð': c:='ñ';
  end;
  locase:=c;
end;

// from wizard.pas
function stLocase(S: string): string;
var
  k: byte;
begin
  for k := 1 to Length(S) do
    s[k] := locase(s[k]);
  stLocase := S;
end;

// from wizard.pas
function stUpcase(S: string): string;
var
  k: byte;
begin
  for k := 1 to Length(S) do
    s[k] := upcase(s[k]);
  stUpcase:=S;
end;

function StringCompare(item1, item2: Pointer): Integer;
var
  str1, str2: string;
begin

  str1 := PString(item1)^;
  str2 := PString(item2)^;

  if cmpIgnoreCase then
  begin
    str1 := stLocase(str1);
    str2 := stLocase(str2);
  end;

  if str1 > str2 then
    Result := 1
  else
    if str1 < str2 then
      Result := -1
    else
      Result := 0;
end;
