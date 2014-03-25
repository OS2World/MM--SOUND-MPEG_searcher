{
 Common stuff for any good programmer. ;-)

 version 2.13, 02/11/1999
  replace/replaceex code rewritten

 version 2.12, 24/08/1999
  sysutils free [os2, w32]

 version 2.11, 08/07/1999
  ToJulian, FromJulian, GetCurrentJulian, FixTabs added

 version 2.10, 06/06/1999
  EraseFile added

 version 2.09, 11/05/1999
  ClrIO, __IOcheck, __IOresult, __IOclear added

 version 2.08, 15/04/1999
  JustFileNameOnly added
  GetAttr, SetAttr bugs

 version 2.07, 11/04/1999
  GrowDate added

 version 2.06
  GetFileSize bugfixed

 version 2.05
  MakeFmt added

 version 2.04
  GetBinkDateTime added

 version 2.03
  DELPHI support removed, only BP 7.0 and VP 2.0 still remain

 version 2.02
  added CheckWildcard

 version 2.01
  added TextFileSize, TextFilePos, TextSeek

 version 2.0
  complete rewritten

 (q) by sk // [rAN] [2:5033/27], 1999.
}
{&Delphi+,CDecl-}

unit Wizard;

{$IFDEF DPMI}
 {$DEFINE DOS}
{$ENDIF}
{$IFDEF MSDOS}
 {$DEFINE DOS}
{$ENDIF}

{$IFDEF VIRTUALPASCAL}
 {$H-}
{$ENDIF}

interface
uses
     {$IFDEF VIRTUALPASCAL}
     vpSysLow,
     {$ENDIF}

     Dos;

type
 CharSet = Set Of Char;

{$IFDEF VIRTUALPASCAL}
 xWord = Longint;
 xInteger = Longint;
{$ELSE}
 xWord = Word;
 xInteger = Integer;
{$ENDIF}

var
 Replaced: Boolean; { True if Replace/ReplaceEx did anything }

const
 Months: Array[1..12] Of String[3] =
  ('Jan','Feb','Mar','Apr','May','Jun',
   'Jul','Aug','Sep','Oct','Nov','Dec');

 Days: array[Boolean, 1..12] of Longint =
        ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
         (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

(* Procedures/functions definition *)

{ Strings and numbers stuff }

function  Center(S: String; Width: Byte): String;
function  CenterCh(S: String; Ch: Char; Width: Byte): String;
function  ExtractWord(N: Byte; const S: String; WordDelims: CharSet): String;
function  GetAllAfterChar(const S: String; Spc: Byte; Ch: Char): String;
function  GetAllAfterSpace(const S: String; Spc: Byte): String;
function  GetPString(S: Pointer): String;
function  HexB(B: Byte): String;
function  HexL(L: Longint): String;
function  HexPtr(P: Pointer): String;
function  HexW(W: Word): String;
function  LTrim(S: String): String;
function  LeftPad(const S: String; Len: Byte): String;
function  LeftPadCh(const S: String; Ch: Char; Len: Byte): String;
function  Long2Str(L: Longint): String;
function  Long2StrFmt(L: Longint): String;
function  Pad(const S: String; Len: Byte): String;
function  PadCh(const S: String; Ch: Char; Len: Byte): String;
function  RTrim(S: String): String;
function  Replace(S: String; const A, B: String): String;
function  StLoCase(S: String): String;
function  StUpCase(S: String): String;
function  Str2Char(const S: String): Char;
function  Str2Number(const S: String): Boolean;
function  Trim(S: String): String;
function  WordCount(const S: String; WordDelims: CharSet): Byte;
procedure GetPStringEx(S: Pointer; var R: String);
procedure ReplaceChar(var S: String; Source, Dest: Char);
procedure ReplaceEx(var S: String; A: String; const B: String);
procedure StLocaseEx(var S: String);
procedure StUpcaseEx(var S: String);
procedure Str2Byte(const S: String; var A: Byte);
procedure Str2Longint(const S: String; var A: Longint);
procedure Str2Word(const S: String; var A: Word);
procedure Str2XWord(const S: String; var A: XWord);
procedure TrimEx(var S: String);

{ Files stuff }

function  AddBackSlash(S: String): String;
function  ExistDir(const S: String): Boolean;
function  ExistFile(const S: String): Boolean;
function  FExpand(const S: String): String;
function  ForceExtension(const Name, Ext: String): String;
function  GetAttr(const FName: String): Longint;
function  GetFileDate(const FName: String): Longint;
function  GetFileSize(const S: String): Longint;
function  GetStamp(const FName: String): Longint;
function  HasExtension(const Name: String; var DotPos: Word): Boolean;
function  JustExtension(const Name: String): String;
function  JustFilename(const PathName: String): String;
function  JustFilenameOnly(const PathName: String): String;
function  JustPathname(const PathName: String): String;
function  RemoveBackSlash(S: String): String;
procedure SetAttr(const FName: String; K: Longint);
procedure SetStamp(const FName: String; K: Longint);

{ Other stuff }

function  Clock: Longint;
function  DayOfWeek (y, m, d: WORD): WORD;
function  StackOverflow: boolean;
function  TimeFix: Longint;
function  _Date(L: Longint): String;
function  _Time(L: Longint): String;
procedure IWannaDate(var D, M, Y: Word);
procedure IWannaTime(var H, M, S: Word);
procedure TimeDif(L: Longint; var DT: DateTime);
procedure Wait(const ms: Longint);
procedure GrowDate(var Date: Longint; const Delta: Longint);

{ FidoNet stuff :-) }

function  GetPktDateTime: String;
function  GetPktDateTimeCustom(Day, Month, Year, Hour, Min, Sec: Word): String;
procedure ParsePktDateTime(S: String; var Day, Month, Year, Hour, Min, Sec, Dow: XWord);

{ Multiplatform stuff }

{$IFDEF DOS}
procedure FindClose(var SR: SearchRec);
{$ENDIF}

{ Added in 2.01 }
function TextSeek(var F: Text; Target: LongInt): Boolean;
function TextFileSize(var F: Text) : LongInt;
function TextPos(var F: Text): LongInt;

{ Added in 2.02 }
function CheckWildcard(S, Mask: String): Boolean;

{ Added in 2.04 }
function GetBinkDateTime: String;

{ Added in 2.05 }
function MakeFmt(const R: String): String;

{ Added in 2.09 }
procedure ClrIO;
function __IOcheck: Boolean;
function __IOerror: String;
procedure __IOclear;

{ Added in 2.10 }

function EraseFile(const FName: String): Boolean;

{ Added in 2.11 }

function ToJulian(_Day, _Month, _Year: Longint): LongInt;
procedure FromJulian(JulianDN: LongInt; var Year, Month, Day: Longint);
function GetCurrentJulian: Longint;
procedure FixTabs(var S: String);

implementation

(* Internal Constants *)

const
 DosDelimSet: Set Of Char = ['\', ':', #0];

 Digits: array[0..$F] of Char = '0123456789ABCDEF';

var
 ValL: XInteger;

type
 Long = record
  LowWord, HighWord: Word;
 end;
 DateTimeRec = record
  FTime,FDate: Word;
 end;

{$IFNDEF VIRTUALPASCAL}
 PTextBuffer = ^TTextBuffer;
 TTextBuffer = array[0..65520] of Byte;
 TText = record
  Handle: Word;
  Mode: Word;
  BufSize: Word;
  Priv: Word;
  BufPos: Word;
  BufEnd: Word;
  BufPtr: PTextBuffer;
  OpenProc: Pointer;
  InOutProc: Pointer;
  FlushProc: Pointer;
  CloseProc: Pointer;
  UserData: array[1..16] of Byte;
  Name: array[0..79] of Char;
  Buffer: array[0..127] of Char;
 end;

const
 FMClosed      = $D7B0;
 FMInput       = $D7B1;
 FMOutput      = $D7B2;
 FMInOut       = $D7B3;
{$ENDIF}

const
 C1970         = 2440588;
 D0            = 1461;
 D1            = 146097;
 D2            = 1721119;

(* Internal stuff *)
function UpCase(C: Char): Char;
 begin
  case c of
   'a'..'z': c:=chr(ord(c)-(97-65));
   ' '..'¯': c:=chr(ord(c)-(160-128));
   'à'..'ï': c:=chr(ord(c)-(224-144));
   'ñ': c:='ð';
  end;
  upCase:=c;
 end;

function LoCase(c: Char): Char;
 begin
  case c of
   'A'..'Z': c:=chr(ord(c)+(97-65));
   '€'..'': c:=chr(ord(c)+(160-128));
   ''..'Ÿ': c:=chr(ord(c)+(224-144));
   'ð': c:='ñ';
  end;
  loCase:=c;
 end;

(* Procedures and functions *)

{ Strings and numbers stuff }

function Center(S: String; Width: Byte): String;
 begin
  Center:=CenterCh(S, ' ', Width);
 end;

function CenterCh(S: String; Ch: Char; Width: Byte): String;
 var
  O: String;
  SLen: Byte Absolute S;
 begin
  if SLen >= Width then
   CenterCh := S
  else
   if SLen < 255 then
    begin
     O[0]:=Chr(Width);
     FillChar(O[1], Width, Ch);
     Move(S[1], O[Succ((Width-SLen) shr 1)], SLen);
     CenterCh:=O;
    end;
 end;

function ExtractWord(N: Byte; const S: String; WordDelims: CharSet): String;
  var
    I: Word;                 {!!.12}
    Count, Len: Byte;
    SLen: Byte absolute S;
  begin
    Count := 0;
    I := 1;
    Len := 0;
    ExtractWord[0] := #0;

    while (I <= SLen) and (Count <> N) do begin
      {skip over delimiters}
      while (I <= SLen) and (S[I] in WordDelims) do
        Inc(I);

      {if we're not beyond end of S, we're at the start of a word}
      if I <= SLen then
        Inc(Count);

      {find the end of the current word}
      while (I <= SLen) and not(S[I] in WordDelims) do begin
        {if this is the N'th word, add the I'th Character to Tmp}
        if Count = N then begin
          Inc(Len);
          ExtractWord[0] := Char(Len);
          ExtractWord[Len] := S[I];
        end;

        Inc(I);
      end;
    end;
  end;

function GetAllAfterChar(const S: String; Spc: Byte; Ch: Char): String;
 var
  K, L: Byte;
  Out: String;
 begin
  Out:='';
  L:=0;
  for K:=1 to Length(S) do
   if L >= Spc then
    Out:=Out + S[K]
   else
    if S[K] = Ch then
     Inc(L);
  GetAllAfterChar:=Out;
 end;

function GetAllAfterSpace(const S: String; Spc: Byte): String;
 var
  K, L: Byte;
  Out: String;
 begin
  Out:='';
  L:=0;
  for K:=1 to Length(S) do
   if L >= Spc then
    Out:=Out + S[K]
   else
    if S[K] = ' ' then Inc(L);
  GetAllAfterSpace:=Out;
 end;

function GetPString(S: Pointer): String;
 var
  R: String;
 begin
  GetPStringEx(S, R);

  GetPString:=R;
 end;

function HexB(B: Byte): String;
 begin
  HexB[0]:=#2;
  HexB[1]:=Digits[B shr 4];
  HexB[2]:=Digits[B and $F];
 end;

function HexL(L: Longint): String;
 begin
  with Long(L) do
   HexL:=HexW(HighWord) + HexW(LowWord);
 end;

function HexPtr(P: Pointer): String;
 var
  Z: record S,O: Word end absolute P;
 begin
  HexPtr:=HexW(Z.S) + ':' + HexW(Z.o);
 end;

function HexW(W: Word): String;
 begin
  HexW[0]:=#4;
  HexW[1]:=Digits[hi(W) shr 4];
  HexW[2]:=Digits[hi(W) and $F];
  HexW[3]:=Digits[lo(W) shr 4];
  HexW[4]:=Digits[lo(W) and $F];
 end;

function LTrim(S: String): String;
 begin
  while (Length(S)<>0) and (S[1]=' ') do Delete(S,1,1);
  LTrim:=S;
 end;

function LeftPad(const S: String; Len: Byte): String;
 begin
  LeftPad:=LeftPadCh(S, ' ', Len);
 end;

function LeftPadCh(const S: String; Ch: Char; Len: Byte): String;
 var
  O: String;
  SLen: Byte Absolute S;
 begin
  if Length(S) >= Len then
   LeftPadCh:=S
  else
   if SLen < 255 then
    begin
     O[0]:=Chr(Len);
     Move(S[1], O[Succ(Word(Len))-SLen], SLen);
     FillChar(O[1], Len - SLen, Ch);
     LeftPadCh:=O;
    end;
 end;

function Long2Str(L: Longint): String;
 var
  S: String;
 begin
  Str(L, S);

  Long2Str:=S;
 end;

function Long2StrFmt(L: Longint): String;
 begin
  Long2StrFmt:=MakeFmt(Long2Str(L));
 end;

function Pad(const S: String; Len: Byte): String;
 begin
  Pad:=PadCh(S, ' ', Len);
 end;

function PadCh(const S: String; Ch: Char; Len: Byte): String;
 var
  O: String;
  SLen: Byte Absolute S;
 begin
  if Length(S) >= Len then
   PadCh:=S
  else
   begin
    O[0]:=Chr(Len);

    Move(S[1], O[1], SLen);

    if SLen < 255 then
     FillChar(O[Succ(SLen)], Len - SLen, Ch);

    PadCh:=O;
   end;
 end;

function RTrim(S: String): String;
 begin
  while (Length(S)<>0) and (S[Length(S)]=' ') do
   Dec(S[0]);

  RTrim:=S;
 end;

function Replace(S: String; const A, B: String): String;
 begin
  ReplaceEx(S, A, B);

  Replace:=S;
 end;

function StLoCase(S: String): String;
 var
  k: byte;
 begin
  for k:=1 to Length(S) do
   s[k]:=locase(s[k]);
  stLocase:=S;
 end;

function StUpCase(S: String): String;
 var
  k: byte;
 begin
  for k:=1 to Length(S) do
   s[k]:=upcase(s[k]);
  stUpcase:=S;
 end;

function Str2Char(const S: String): Char;
 begin
  if S[0] = #0 then
   Str2Char:=#0
  else
   Str2Char:=S[1];
 end;

function Str2Number(const S: String): Boolean;
 var
  X: Longint;
  C: xInteger;
 begin
  Val(S, X, C);
  Str2Number:=C = 0;
 end;

function Trim(S: String): String;
 begin
  while (Length(S)<>0) and (S[1]=' ') do Delete(S,1,1);
  while (Length(S)<>0) and (S[Length(S)]=' ') do Dec(S[0]);
  Trim:=S;
 end;

function WordCount(const S: String; WordDelims: CharSet): Byte;
 var
  Count: Byte;
  I: Word;
  SLen: Byte absolute S;
 begin
  Count := 0;
  I := 1;
  while I <= SLen do begin
   while (I <= SLen) and (S[I] in WordDelims) do
    Inc(I);
    if I <= SLen then Inc(Count);
    while (I <= SLen) and not(S[I] in WordDelims) do
     Inc(I);
    end;
  WordCount := Count;
 end;

procedure GetPStringEx(S: Pointer; var R: String);
 type
  PString = ^String;
 begin
  if S = Nil then
   R[0]:=#0
  else
   Move(S^, R, Length(PString(S)^) + 1);
 end;

procedure ReplaceChar(var S: String; Source, Dest: Char);
 var
  K: Byte;
 begin
  for K:=1 to Length(S) do
   if S[K] = Source then
    S[K]:=Dest;
 end;

procedure ReplaceEx(var S: String; A: String; const B: String);
 var
  K, L: Byte;
 begin
  StUpcaseEx(A);

  Replaced:=False;

  K:=Pos(A, StUpcase(S));
  L:=0;

  while K <> 0 do
   begin
    Replaced:=True;

    Delete(S, K, Length(A));

    Insert(B, S, K);

    L:=K + Length(B);

    K:=Pos(A, StUpcase(Copy(S, L, 255)));

    if K <> 0 then
     begin
      Dec(K);

      Inc(K, L);
     end;
   end;
 end;

procedure StLocaseEx(var S: String);
 var
  K: Byte;
 begin
  for k:=1 to Length(S) do
   s[k]:=locase(s[k]);
 end;

procedure StUpcaseEx(var S: String);
 var
  k: byte;
 begin
  for k:=1 to Length(S) do
   s[k]:=upcase(s[k]);
 end;

procedure Str2Byte(const S: String; var A: Byte);
 begin
  if S = '' then
   A:=0
  else
   Val(S, A, ValL);
 end;

procedure Str2Longint(const S: String; var A: Longint);
 begin
  if S='' then
   A:=0
  else
   Val(S, A, ValL);
 end;

procedure Str2Word(const S: String; var A: Word);
 begin
  if S='' then
   A:=0
  else
   Val(S, A, ValL);
 end;

procedure Str2XWord(const S: String; var A: XWord);
 begin
  if S='' then
   A:=0
  else
   Val(S, A, ValL);
 end;

procedure TrimEx(var S: String);
 begin
  while (Length(S)<>0) and (S[1]=' ') do Delete(S,1,1);
  while (Length(S)<>0) and (S[Length(S)]=' ') do Dec(S[0]);
 end;

{ Files stuff }

function AddBackSlash(S: String): String;
 begin
  if S[0]<>#0 then
   if S[Length(S)]<>'\' then S:=S+'\';
  AddBackSlash:=S;
 end;

function ExistDir(const S: String): Boolean;
 var
  SR: SearchRec;
 begin
  FindFirst(AddBackSlash(S) + '*.*', AnyFile, SR);
  ExistDir:=DosError = 0;
  FindClose(Sr);
 end;

function ExistFile(const S: String): Boolean;
 var
  F: File;
  A: XWord;
 begin
  Assign(F, S);

  GetFAttr(F,A);

  ExistFile:=DosError = 0;
 end;

function FExpand(const S: String): String;
 begin
  FExpand:=Dos.FExpand(S);
 end;

function ForceExtension(const Name, Ext: String): String;
 var
  DotPos: Word;
 begin
  if HasExtension(Name, DotPos) then
   ForceExtension := Copy(Name, 1, DotPos)+Ext
  else
   ForceExtension := Name+'.'+Ext;
 end;

function GetAttr(const FName: String): Longint;
 var
  F: File;
  K: xWord;
 begin
  Assign(F, FName);

  GetFAttr(F, K);

  GetAttr:=K;
 end;

function GetFileDate(const FName: String): Longint;
 var
  SR: SearchRec;
 begin
  FindFirst(FName, AnyFile, SR);

  if DosError <> 0 then
   GetFileDate:=-1
  else
   GetFileDate:=SR.Time;

  FindClose(Sr);
 end;

function GetFileSize(const S: String): Longint;
 var
  SR: SearchRec;
 begin
  FindFirst(S, AnyFile, SR);
  if DosError <> 0 then
   GetFileSize:=-1
  else
   GetFileSize:=SR.Size;
  FindClose(Sr);
 end;

function GetStamp(const FName: String): Longint;
 var
  F: File;
  K: Longint;
 begin
  if IOResult <> 0 then;

  Assign(F, FName);
  Reset(F);

  if IOResult <> 0 then
   begin
    GetStamp:=-1;

    Exit;
   end;

  GetFTime(F, K);

  Close(F);

  GetStamp:=K;

  if IOResult <> 0 then;
 end;

function HasExtension(const Name: String; var DotPos: Word): Boolean;
 var
  I: Word;
 begin
  DotPos:=0;
  for I:=Length(Name) downto 1 do
   if (Name[I] = '.') and (DotPos = 0) then
    DotPos:=I;
  HasExtension:=(DotPos > 0) and (Pos('\', Copy(Name, Succ(DotPos), 64)) = 0);
 end;

function JustExtension(const Name: String): String;
 var
  DotPos: Word;
 begin
  if HasExtension(Name, DotPos) then
   JustExtension:=Copy(Name, Succ(DotPos), 3)
  else
   JustExtension[0]:=#0;
 end;

function JustFilename(const PathName: String): String;
 var
  I: Word;
 begin
  I:=Succ(Word(Length(PathName)));
  repeat
   Dec(I);
  until (PathName[I] in DosDelimSet) or (I = 0);
  JustFilename:=Copy(PathName, Succ(I), 64);
 end;

function JustPathname(const PathName: String): String;
 var
  I: Word;
 begin
  I := Succ(Word(Length(PathName)));
  repeat
   Dec(I);
  until (PathName[I] in DosDelimSet) or (I = 0);
  if I = 0 then
   JustPathname[0] := #0
  else
   if I = 1 then JustPathname := PathName[1]
  else
   if (PathName[I] = '\') then
    begin
     if PathName[Pred(I)] = ':' then
      JustPathname := Copy(PathName, 1, I)
     else
      JustPathname := Copy(PathName, 1, Pred(I));
    end
   else
    JustPathname := Copy(PathName, 1, I);
 end;

function RemoveBackSlash(S: String): String;
 begin
  S:=AddBackSlash(S);
  if S[0] > #3 then Dec(S[0]);
  RemoveBackSlash:=S;
 end;

procedure SetAttr(const FName: String; K: Longint);
 var
  F: File;
 begin
  Assign(F, FName);

  SetFAttr(F, K);

  if IOResult <> 0 then;
 end;

procedure SetStamp(const FName: String; K: Longint);
 var
  F: File;
 begin
  if IOResult <> 0 then;

  Assign(F, FName);
  Reset(F);

  if IOResult <> 0 then
   Exit;

  SetFTime(F, K);

  Close(F);

  if IOResult <> 0 then;
 end;

{ Other stuff }

function Clock: Longint;
{$IFDEF VIRTUALPASCAL}
 begin
  Clock:=SysSysMsCount;
 end;
{$ELSE}
 assembler;
  asm
             push    ds              { save caller's data segment }
             mov     ds, seg0040     {  access ticker counter }
             mov     bx, 6ch         { offset of ticker counter in segm.}
             mov     dx, 43h         { timer chip control port }
             mov     al, 4           { freeze timer 0 }
             pushf                   { save caller's int flag setting }
             cli                     { make reading counter an atomic operation}
             mov     di, ds:[bx]     { read bios ticker counter }
             mov     cx, ds:[bx+2]
             sti                     { enable update of ticker counter }
             out     dx, al          { latch timer 0 }
             cli                     { make reading counter an atomic operation}
             mov     si, ds:[bx]     { read bios ticker counter }
             mov     bx, ds:[bx+2]
             in      al, 40h         { read latched timer 0 lo-byte }
             mov     ah, al          { save lo-byte }
             in      al, 40h         { read latched timer 0 hi-byte }
             popf                    { restore caller's int flag }
             xchg    al, ah          { correct order of hi and lo }
             cmp     di, si          { ticker counter updated ? }
             je      @no_update      { no }
             or      ax, ax          { update before timer freeze ? }
             jns     @no_update      { no }
             mov     di, si          { use second }
             mov     cx, bx          {  ticker counter }
@no_update:  not     ax              { counter counts down }
             mov     bx, 36edh       { load multiplier }
             mul     bx              { w1 * m }
             mov     si, dx          { save w1 * m (hi) }
             mov     ax, bx          { get m }
             mul     di              { w2 * m }
             xchg    bx, ax          { ax = m, bx = w2 * m (lo) }
             mov     di, dx          { di = w2 * m (hi) }
             add     bx, si          { accumulate }
             adc     di, 0           {  result }
             xor     si, si          { load zero }
             mul     cx              { w3 * m }
             add     ax, di          { accumulate }
             adc     dx, si          {  result in dx:ax:bx }
             mov     dh, dl          { move result }
             mov     dl, ah          {  from dl:ax:bx }
             mov     ah, al          {   to }
             mov     al, bh          {    dx:ax:bh }
             mov     di, dx          { save result }
             mov     cx, ax          {  in di:cx }
             mov     ax, 25110       { calculate correction }
             mul     dx              {  factor }
             sub     cx, dx          { subtract correction }
             sbb     di, si          {  factor }
             xchg    ax, cx          { result back }
             mov     dx, di          {  to dx:ax }
             pop     ds              { restore caller's data segment }
  end;
{$ENDIF}

function DayOfWeek(Y, M, D: Word): Word;
 var
  Tmp1, Tmp2, yy, mm, dd: Longint;
 begin
  yy := y;
  mm := m;
  dd := d;
  Tmp1 := mm + 10;
  Tmp2 := yy + (mm - 14) DIV 12;
  DayOfWeek :=  ((13 *  (Tmp1 - Tmp1 DIV 13 * 12) - 1) DIV 5 +
                dd + 77 + 5 * (Tmp2 - Tmp2 DIV 100 * 100) DIV 4 +
                Tmp2 DIV 400 - Tmp2 DIV 100 * 2) MOD 7;
 end;

function StackOverflow: boolean;
 begin
  StackOverflow:=SPtr < $1000;
 end;

function TimeFix: Longint;
 var
  DT: DateTime;
  L: Longint;
  Hour, Min, Sec, Day, Month, Year: Word;
 begin
  IWannaTime(Hour, Min, Sec);
  IWannaDate(Day, Month, Year);
  DT.Hour:=Hour;
  DT.Min:=Min;
  DT.Sec:=Sec;
  DT.Day:=Day;
  DT.Month:=Month;
  DT.Year:=Year;
  PackTime(DT, L);
  TimeFix:=L;
 end;

function _Date(L: Longint): String;
(*{$IFDEF VIRTUALPASCAL}
 begin
  _Date:=DateTimeToStr(L);
 end;
{$ELSE}*)
 var
  DT: DateTime;
 begin
  UnpackTime(L,DT);

  _Date:=LeftPadCh(Long2Str(DT.Day),'0',2) + '.' +  LeftPadCh(Long2Str(DT.Month),'0',2) + '.' + Long2Str(DT.Year);
 end;
(*{$ENDIF}*)

function _Time(L: Longint): String;
(*{$IFDEF VIRTUALPASCAL}
 begin
  _Time:=DateTimeToStr(L);
 end;
{$ELSE}*)
 var
  DT: DateTime;
 begin
   UnpackTime(L,DT);
  _Time:=LeftPadCh(Long2Str(DT.Hour),'0',2)+':'+LeftPadCh(Long2Str(DT.Min),'0',2);
 end;
(*{$ENDIF}*)

procedure IWannaDate(var D, M, Y: Word);
 var
  aY, aM, aD, aT: xWord;
 begin
  GetDate(aY, aM, aD, aT);

  D:=aD;

  M:=aM;

  Y:=aY;
 end;

procedure IWannaTime(var H, M, S: Word);
 var
  aH, aM, _aS, _aT: xWord;
 begin
  GetTime(aH, aM, _aS, _aT);

  H:=aH;

  M:=aM;

  S:=_aS;
 end;

procedure TimeDif(L: Longint; var DT: DateTime);
 begin
  UnpackTime(L, DT);
  with DT do
   if Year >= 1980 then Dec(Year, 1980);
 end;

procedure Wait(const ms: Longint);
 {$IFDEF VIRTUALPASCAL}
 begin
  SysCtrlSleep(ms);
 end;
 {$ELSE}
 var
  Anchor: Longint;
 begin
  Anchor:=Clock;

  repeat until (Clock - Anchor > ms) or (Clock - Anchor < 0);
 end;
 {$ENDIF}

{ FidoNet stuff :-) }

function GetPktDateTime: String;
 var
  Day, Month, Year, Hour, Min, Sec: Word;
 begin
  iWannaTime(Hour, Min, Sec);
  iWannaDate(Day, Month, Year);
  GetPktDateTime:=LeftPadCh(Long2Str(Day),'0',2)+' '+Copy(Months[Month],1,3)+' '+Copy(Long2Str(Year),3,2)+'  '+
     LeftPadCh(Long2Str(Hour),'0',2)+':'+LeftPadCh(Long2Str(Min),'0',2)+':'+LeftPadCh(Long2Str(Sec),'0',2);
 end;

function GetPktDateTimeCustom(Day, Month, Year, Hour, Min, Sec: Word): String;
 begin
  GetPktDateTimeCustom:=LeftPadCh(Long2Str(Day),'0',2)+' '+Copy(Months[Month],1,3)+' '+Copy(Long2Str(Year),3,2)+'  '+
     LeftPadCh(Long2Str(Hour),'0',2)+':'+LeftPadCh(Long2Str(Min),'0',2)+':'+LeftPadCh(Long2Str(Sec),'0',2);
 end;

procedure ParsePktDateTime(S: String; var Day, Month, Year, Hour, Min, Sec, Dow: XWord);
 const
  MonthsU: array[1..12] of String[3] = ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');
 var
  K: Byte;
 begin
  StUpcaseEx(S);
  Str2XWord(ExtractWord(1, S, [' ',':']), Day);
  Month:=0;
  for K:=1 to 12 do
   if Copy(S, 4, 3) = MonthsU[K] then Month:=K;
  Str2XWord(ExtractWord(3, S, [' ',':']), Year);
  if Year<81 then Inc(Year, 2000) else Inc(Year, 1900);
  Str2XWord(ExtractWord(4, S, [' ',':']), Hour);
  Str2XWord(ExtractWord(5, S, [' ',':']), Min);
  Str2XWord(ExtractWord(6, S, [' ',':']), Sec);
  Dow:=DayOfWeek(Year, Month, Day);
 end;

{ Multiplatform stuff }

{$IFDEF DOS}
procedure FindClose(var SR: SearchRec);
 begin
 end;
{$ENDIF}

{ Added in 2.01 }

{$IFNDEF VIRTUALPASCAL}
{ The following part of code has been cut from
  Turbo Professional 5.21 (c) by TurboPower Software, 1987, 1992. }

function TextSeek(var F: Text; Target: LongInt): Boolean;
 var
  T: Long absolute Target;
  Pos: LongInt;
  Regs: Registers;
 begin
  TextSeek:=False;
  with Regs, TText(F) do
   begin
    if Mode <> FMInput then Exit;
    AX:=$4201;
    BX:=Handle;
    CX:=0;
    DX:=0;
    MsDos(Regs);
    if Odd(Flags) then Exit;
    Long(Pos).HighWord := DX;
    Long(Pos).LowWord := AX;
    Dec(Pos, BufEnd);
    Pos:=Target - Pos;
    if (Pos >= 0) and (Pos < BufEnd) then
     BufPos:=Pos
    else
     begin
      AX:=$4200;
      BX:=Handle;
      CX:=T.HighWord;
      DX:=T.LowWord;
      MsDos(Regs);
      if Odd(Flags) then Exit;
      BufEnd := 0;
      BufPos := 0;
     end;
   end;
  TextSeek:=True;
 end;

function TextFileSize(var F: Text) : LongInt;
 var
  OldHi, OldLow: Integer;
  Regs: Registers;
 begin
  with Regs, TText(F) do
   begin
    if Mode = FMClosed then
     begin
      TextFileSize:=-1;
      Exit;
     end;
    AX:=$4201;
    BX:=Handle;
    CX:=0;
    DX:=0;
    MsDos(Regs);
    if Odd(Flags) then
     begin
      TextFileSize := -1;
      Exit;
     end;
    OldHi:=DX;
    OldLow:=AX;
    AX:=$4202;
    BX:=Handle;
    CX:=0;
    DX:=0;
    MsDos(Regs);
    if Odd(Flags) then
     begin
      TextFileSize := -1;
      Exit;
     end;
    TextFileSize:=LongInt(DX) shl 16 + AX;
    AX:=$4200;
    BX:=Handle;
    CX:=OldHi;
    DX:=OldLow;
    MsDos(Regs);
    if Odd(Flags) then
     TextFileSize:=-1;
   end;
 end;

function TextPos(var F: Text): LongInt;
 var
  Position: LongInt;
  Regs: Registers;
 begin
  with Regs, TText(F) do
   begin
    if Mode = FMClosed then
     begin
      TextPos := -1;
      Exit;
     end;
    AX:=$4201;
    BX:=Handle;
    CX:=0;
    DX:=0;
    MsDos(Regs);
    if Odd(Flags) then
     begin
      TextPos:=-1;
      Exit;
     end;
    Long(Position).HighWord := DX;
    Long(Position).LowWord := AX;
    if Mode = FMOutput then
     Inc(Position, BufPos)
    else
     if BufEnd <> 0 then
      Dec(Position, BufEnd - BufPos);
    TextPos:=Position;
   end;
 end;
{$ENDIF}

{$IFDEF VIRTUALPASCAL}
function TextSeek(var F: Text; Target: LongInt): Boolean;
 var
  P: LongInt;
  T: TextRec absolute F;
 begin
  TextSeek:=True;

  SysFileSeek(T.Handle, 0, 1, P);

  Dec(P, T.BufEnd);

  P:=Target - P;

  if (P >= 0) and (P < T.BufEnd) then
   T.BufPos:=P
  else
   begin
    SysFileSeek(T.Handle, Target, 0, P);

    T.BufEnd:=0;
    T.BufPos:=0;
   end;
 end;

function TextFileSize(var F: Text): LongInt;
 var
  T: TextRec absolute F;
  P: Longint;
 begin
  SysFileSeek(T.Handle, 0, 1, P);

  SysFileSeek(T.Handle, 0, 2, Result);

  SysFileSeek(T.Handle, P, 0, P);
 end;

function TextPos(var F: Text): LongInt;
 var
  T: TextRec absolute F;
 begin
  SysFileSeek(T.Handle, 0, 1, Result);

  if T.Mode = fmOutput then
   Inc(Result, T.BufPos)
  else
   if T.BufEnd <> 0 then
    Dec(Result, T.BufEnd - T.BufPos);
 end;
{$ENDIF}

{ Added in 2.02 }

const
 ItsFirst: Integer = 0;

function CheckWildcard(S, Mask: String): Boolean;
 var
  I: integer;
  J: integer;
  Ok: boolean;
  St: string;
  Msk: string;
 begin
  if (Pos('?', Mask) = 0) and (Pos('*', Mask) = 0) then
   begin
    CheckWildcard:=S = Mask;
    Exit;
   end;
  Inc(ItsFirst);
  I:=1;
  if ItsFirst=1 then
   begin
    while True do
     begin
      J:=Length(Mask);
      while I<Length(Mask) do
       begin
        if (Mask[I]='?') And (Mask[I+1]='*') Then Delete(Mask,I,1);
        if (Mask[I]='*') And (Mask[I+1]='?') And (I<Length(Mask)) Then Delete(Mask,I+1,1);
        If (Mask[I]='*') And (Mask[I+1]='*') And (I<Length(Mask)) Then Delete(Mask,I,1);
        Inc(I);
       end;
      if J=Length(Mask) then Break;
      I:=1;
     end;
   end;
  Ok:=True;
  I:=1;
  J:=1;
  while True do
   begin
    case Mask[I] Of
    '*':
      Begin
        Msk:=Copy(Mask,I+1,Length(Mask)-I+1);
        St:=Copy(S,J,Length(S)-J+1);
        while (St<>'') and (not CheckWildcard(St,Msk)) do Delete(St,1,1);
        If (St='') and (Msk<>'') then Ok:=False else J:=Pos(St,S);
      End;
    '?':
      Begin
        If (I=Length(Mask)) And (J<Length(S)) Then Ok:=False;
        If J>Length(S) Then Ok:=False;
        Inc(J);
      End;
    else
     if Mask[I]<>S[J] then Ok:=False else Inc(J);
    end;
    if J-1>Length(S) then Ok:=False;
    if not Ok then Break;
    Inc(I);
    if I>Length(Mask) then Break;
   end;
  CheckWildcard:=Ok;
  Dec(ItsFirst);
 end;

{ Added in 2.04 }
function GetBinkDateTime: String;
 var
  Year, Month, Day, Hour, Min, Sec: Word;
 begin
  IWannaDate(Day, Month, Year);
  IWannaTime(Hour, Min, Sec);
  GetBinkDateTime:=LeftPadCh(Long2Str(Day), '0', 2) + ' ' + Months[Month] + ' ' +
   LeftPadCh(Long2Str(Hour), '0', 2) + ':' + LeftPadCh(Long2Str(Min), '0', 2) + ':' +
   LeftPadCh(Long2Str(Sec), '0', 2);
 end;

{ Added in 2.05 }

function MakeFmt(const R: String): String;
 var
  K, L: Byte;
  S: String;
  Minus: Boolean;
 begin
  S:='';
  L:=0;
  for K:=Length(R) downto 1 do
   begin
    S:=R[K] + S;
    Inc(L);
    if L=3 then
     begin
      S:=','+S;
      L:=0;
     end;
   end;
  Minus:=Copy(S, 1, 1)='-';
  if Minus then Delete(S, 1, 1);
  while Copy(S,1,1)=',' do Delete(S,1,1);
  if Minus then S:='-'+S;
  MakeFmt:=S;
 end;

{ Added in 2.07 }

procedure GrowDateBackward(var Date: Longint);
 var
  DT: DateTime;
 begin
  UnpackTime(Date, DT);

  Dec(DT.Day);

  if DT.Day < 1 then
   begin
    Dec(DT.Month);

    if DT.Month < 1 then
     begin
      DT.Month:=12;

      Dec(DT.Year);
     end;

    DT.Day:=Days[DT.Year mod 4 = 0, DT.Month];
   end;

  PackTime(DT, Date);
 end;

procedure GrowDateForward(var Date: Longint);
 var
  DT: DateTime;
 begin
  UnpackTime(Date, DT);

  Inc(DT.Day);

  if DT.Day > Days[DT.Year mod 4 = 0, DT.Month] then
   begin
    DT.Day:=1;

    Inc(DT.Month);

    if DT.Month > 12 then
     begin
      DT.Month:=1;

      Inc(DT.Year);
     end;
   end;

  PackTime(DT, Date);
 end;

procedure GrowDate(var Date: Longint; const Delta: Longint);
 var
  K: Longint;
 begin
  if Delta < 0 then
   for K:=Delta to -1 do
    GrowDateBackward(Date)
  else
   if Delta > 0 then
    for K:=1 to Delta do
     GrowDateForward(Date);
 end;

{ Added in 2.08 }

function JustFilenameOnly(const PathName: String): String;
 var
  I: Integer;
  S: String;
 begin
  S:=JustFilename(PathName);

  I:=Length(S);

  while (I <> 0) and (S[I] <> '.') do
   Dec(I);

  if I <= 1 then
   JustFileNameOnly:=''
  else
   JustFilenameOnly:=Copy(S, 1, I - 1);;
 end;

{ Added in 2.09 }

procedure ClrIO;
 begin
  InOutRes:=0;
  DosError:=0;
 end;

function __IOcheck: Boolean;
 begin
  __IOcheck:=InOutRes <> 0;
 end;

function __IOerror: String;
 begin
  __IOerror:='rc=#' + HexL(InOutRes);
 end;

procedure __IOclear;
 begin
  InOutRes:=0;
 end;

{ Added in 2.10 }

function EraseFile(const FName: String): Boolean;
 var
  F: Text;
 begin
  if IOResult <> 0 then;

  Assign(F, FName);
  Erase(F);

  EraseFile:=IOResult = 0;
 end;

{ Added in 2.11 }

function ToJulian(_Day, _Month, _Year: Longint): LongInt;
 var
  Century, XYear, Temp, Month: LongInt;
 begin
  Month:=_Month;

  if Month <= 2 then
   begin
    Dec(_Year);
    Inc(Month, 12);
   end;

  Dec(Month, 3);
  Century:=_Year Div 100;
  XYear:=_Year Mod 100;
  Century:=(Century * D1) shr 2;
  XYear:=(XYear * D0) shr 2;
  ToJulian:=((((Month * 153) + 2) div 5) + _Day) + D2 + XYear + Century;
 end;

procedure FromJulian(JulianDN: LongInt; var Year, Month, Day: Longint);
 var
  Temp, XYear: LongInt;
  YYear, YMonth, YDay: Integer;
 begin
  Temp:=(((JulianDN - D2) shl 2) - 1);
  XYear:=(Temp mod D1) or 3;
  JulianDN:=Temp div D1;
  YYear:=(XYear div D0);
  Temp:=((((XYear mod D0) + 4) shr 2) * 5) - 3;
  YMonth:=Temp div 153;
  if YMonth >= 10 then
   begin
    YYear:=YYear + 1;
    YMonth:=YMonth - 12;
   end;
  YMonth:=YMonth + 3;
  YDay:=Temp mod 153;
  YDay:=(YDay + 5) div 5;
  Year:=YYear + (JulianDN * 100);
  Month:=YMonth;
  Day:=YDay;
 end;

function GetCurrentJulian: Longint;
 var
  Day, Month, Year: Word;
 begin
  IWannaDate(Day, Month, Year);

  GetCurrentJulian:=ToJulian(Day, Month, Year);
 end;

procedure FixTabs(var S: String);
 var
  O: String;
  K, L, M: Byte;
 begin
  if Pos(#9, S) = 0 then
   Exit;

  O:=S;

  S:='';

  M:=0;

  for K:=1 to Length(O) do
   case O[K] of
    #9:
     begin
      L:=8 - (M and 7);

      Inc(M, L);

      while L <> 0 do
       begin
        S:=Concat(S, ' ');

        Dec(L);
       end;
     end;
   else
    S:=Concat(S, O[K]);

    Inc(M);
   end;
 end;

end.