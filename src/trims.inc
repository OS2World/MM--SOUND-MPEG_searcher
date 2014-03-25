(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

function  LTrim (const victim: string): string;
var
  i: Integer;
begin
  Result := victim;
  i := 1;
  while i <= Length (Result) do
  begin
    if Result [i] in [' ', #09] then
      Delete (Result, i, 1)
    else
      Exit;
  end;
end;

function  RTrim (const victim: string): string;
var
  i: Integer;
begin
  Result := victim;
  i := Length (Result);
  while i >= 1 do
  begin
    if Result [i] in [' ', #09] then
      Delete (Result, i, 1)
    else
      Exit;
    dec (i);
  end;
end;

function  Trim (const victim: string): string;
begin
  Result := RTrim (LTrim (victim));
end;

procedure TrimEx(var victim: string);
begin
  victim := Trim(victim);
end;

function BinaryB(B: Byte): string; // from TPString
const
  Digits: array [0..15] of Char = '0123456789abcdef';
var
  I, N: Word;
begin
  N := 1;
  Result[0] := #8;
  for I := 7 downto 0 do begin
    Result[N] := Digits[Ord(B and (1 shl I) <> 0)];
    inc(N);
  end;
end;

function Bin2Long(s: String): Longint;
var
  x: Integer;
  r, p: Longint;
begin
  Result := 0;
  p := 1;
  for x := Length(s) downto 1 do
  begin
    if s[x] = '1' then Result := Result + p;
    p := p * 2;
  end;
end;