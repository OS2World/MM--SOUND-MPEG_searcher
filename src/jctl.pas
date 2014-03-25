{
   .ctl files reader

   version 1.07

   Copyright (c) 1999 by Alexander Trunov [2:5069/10] [345:818/1]

        вы можете свободно использовать, изменять этот модyль, но мне бyдет
   очень приятно, если вы включите мое имя в кредитсы, а также пришлете
   исходник исправленной/модифицированой версии, если таковая бyдет,
   конечно ;)

   1.0  base realisation
   1.01 fixed mistype - tab symbol was #8, now it's #9
   1.02 fixed logical error - starting memory stream size was 1024
   1.03 rewritten initialization part
   1.04 added macros '@include'
   1.05 fixed stupid memory leak. great help was provided by HeapTrc unit
    from FreePascal package
   1.06 added work with pools
   1.07 fix for huge strings

}

unit jCtl;

interface

uses
  Objects;

type

  PKeyRecord = ^TKeyRecord;
  TKeyRecord = record
    Key, Value: string;
  end;

  PSCollection = ^TSCollection;
  TSCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

  PCtl = ^TCtl;
  TCtl = object(TObject)

    coll: PSCollection;
    wasExist: Boolean;

    constructor Init(CtlName: string);
    destructor Done; virtual;

    function GetMString(Num: Longint; Param: string): string;
        { полyчить параметр номер Num }
    function GetString(Param: string): string;
    function GetMBoolean(Num: Longint; Param: string): Boolean;
    function GetBoolean(Param: string): Boolean;
    function GetMLongint(Num: Longint; Param: string): Longint;
    function GetLongint(Param: string): Longint;
    function GetPool(Param: string): PStringCollection;

    function ExistKey(Param: string): Boolean;

  private

    CtlFile: Text;
    i: Longint;
    kr: PKeyRecord;

    procedure IncludeFile(aFileName: string);

  end;

implementation

uses Wizard;

procedure TSCollection.FreeItem(P: Pointer);
begin
  Dispose(PKeyRecord(P));
end;

procedure TCtl.IncludeFile(aFileName: string);
var
  S: string;
  F: Text;
begin
  if not ExistFile(aFileName) then Exit;
  Assign(F, aFileName);
  Reset(F);

  while not EOF(F) do
  begin
    ReadLn(F, S);
    s := Trim(s);
    if ((Length(s) > 0) and (s[1] <> ';')) and (s <> '') then
    begin
      New(kr);
      kr^.key := ExtractWord(1, s, [' ', #9]);
      Delete(s, 1, Length(kr^.key));
      kr^.value := Trim(ExtractWord(1, Trim(s), [';']));
      if Copy(Trim(s), 1, 1) = ';' then kr^.Value := '';
      if stLocase(kr^.Key) <> '@include' then
      begin
        coll^.Insert(kr);
      end
      else
      begin
        S := kr^.Value;
        Dispose(kr);
        if JustPathName(aFileName) = '' then
          IncludeFile(S)
        else
          IncludeFile(JustPathname(aFileName) + '\' + S);
      end;
    end;
  end;

  Close(F);
end;

constructor TCtl.Init(CtlName: string);
begin
  inherited Init;

  coll := New(PSCollection, Init(10, 10));
  Assign(CtlFile, CtlName);
{$I-}
  Reset(CtlFile);
  if IOResult <> 0 then
  begin
    wasExist := False;
    Exit
  end
  else
    wasExist := True;
  Close(CtlFile);
  IncludeFile(CtlName);
end;

function TCtl.GetMString(Num: Longint; Param: string): string;
var
  j: Longint;
begin
  GetMString := '';
  i := 0; j := 0;
  while (i <> num) and (j <= coll^.Count - 1) do
  begin
    if stLocase(PKeyRecord(coll^.Items^[j])^.Key) = stLocase(Param) then
    begin
      inc(i);
    end;
    inc(j);
  end;

  if num = i then
  begin
    kr := PKeyRecord(coll^.Items^[j - 1]);
    GetMString := kr^.value;
  end
end;

function TCtl.GetString(Param: string): string;
begin
  GetString := GetMString(1, Param);
end;

function TCtl.GetMBoolean(Num: Longint; Param: string): Boolean;

  function Str2Bool(s: string): Boolean;
  var
    s1: string;
  begin
    s1 := stLocase(s);
    if (s1 = 'yes') or (s1 = 'true') or (s1 = 'yeah') then
      Str2Bool := True
    else
      Str2Bool := False;
  end;
begin
  GetMBoolean := Str2Bool(GetMString(Num, Param));
end;

function TCtl.GetBoolean(Param: string): Boolean;
begin
  GetBoolean := GetMBoolean(1, Param);
end;

function TCtl.GetMLongint(Num: Longint; Param: string): Longint;
var
  Tmp: Longint;
begin
  Str2Longint(GetMString(Num, Param), Tmp);
  GetMLongint := Tmp;
end;

function TCtl.GetLongint(Param: string): Longint;
begin
  GetLongint := GetMLongint(1, Param);
end;

function TCtl.ExistKey(Param: string): Boolean;
begin
  if GetString(Param) = '' then
    ExistKey := False
  else
    ExistKey := True;
end;

function TCtl.GetPool(Param: string): PStringCollection;
var
  poolStr, Command, S: string;
  pool: PStringCollection;

  procedure AddFile(aFileName: string);
  var
    f: Text;
  begin
    if not ExistFile(aFileName) then Exit;
    Assign(f, aFileName);
    Reset(f);
    while not EOF(f) do
    begin
      Readln(f, S);
      pool^.AtInsert(pool^.Count, NewStr(S));
    end;
    Close(f);
  end;
begin
  pool := New(PStringCollection, Init(5, 5));
  if not ExistKey(Param) then
  begin
    GetPool := pool;
    Exit;
  end;
  i := 1;
  while GetMString(i, Param) <> '' do
  begin
    poolStr := GetMString(i, Param);
    Command := stLocase(ExtractWord(1, poolStr, [' ', #9]));
    if Command = 'kill' then pool^.FreeAll;
    if Command = 'replace' then
    begin
      pool^.FreeAll;
      Delete(poolStr, 1, 8);
      pool^.AtInsert(pool^.Count, NewStr(Trim(poolStr)));
    end;
    if Command = 'add' then
    begin
      Delete(poolStr, 1, 4);
      pool^.AtInsert(pool^.Count, NewStr(Trim(poolStr)));
    end;
    if Command = 'addfile' then
    begin
      Delete(poolStr, 1, 8);
      AddFile(Trim(poolStr));
    end;
    if Command = 'replacefile' then
    begin
      Delete(poolStr, 1, 12);
      pool^.FreeAll;
      AddFile(Trim(poolStr));
    end;

    inc(i);
  end;

  GetPool := pool;
end;

destructor TCtl.Done;
begin
  Dispose(coll, Done);
  inherited Done;
end;

end.

