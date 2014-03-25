{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}
{ additions were made by FreePascal development team }

unit Gadgets;

{
  Useful gadgets: clock and heap available viewer
}

{$F+,O+,E+,N+}
{$X+,R-,I-,Q-,V-}

interface

uses Dos, Objects, Views, App;

type
  THeapViewMode = (HVNormal, HVComma, HVKb, HVMb);

  PHeapView = ^THeapView;
  THeapView = object(TView)
    Mode: THeapViewMode;
    OldMem: LongInt;
    constructor Init(var Bounds: TRect);
    constructor InitComma(var Bounds: TRect);
    constructor InitKb(var Bounds: TRect);
    constructor InitMb(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update;
    function Comma(N: LongInt): string;
  end;

  PClockView = ^TClockView;
  TClockView = object(TView)
    am: Char;
    Refresh: Byte;
    LastTime: DateTime;
    TimeStr: string[10];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function FormatTimeStr(H, M, S: Word): string; virtual;
    procedure Update; virtual;
  end;


implementation

uses Drivers;

{*****************************************************************************
                                     HeapView
*****************************************************************************}

constructor THeapView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  mode := HVNormal;
  OldMem := 0;
end;

constructor THeapView.InitComma(var Bounds: TRect);
begin
  inherited Init(Bounds);
  mode := HVComma;
  OldMem := 0;
end;

constructor THeapView.InitKb(var Bounds: TRect);
begin
  inherited Init(Bounds);
  mode := HVKb;
  OldMem := 0;
end;

constructor THeapView.InitMb(var Bounds: TRect);
begin
  inherited Init(Bounds);
  mode := HVMb;
  OldMem := 0;
end;

procedure THeapView.Draw;
var
  S: string;
  B: TDrawBuffer;
  C: Byte;
begin
  OldMem := MemAvail;
  case mode of
    HVNormal:
      Str(OldMem: Size.X, S);
    HVComma:
      S := Comma(OldMem);
    HVKb:
      begin
        Str(OldMem shr 10: Size.X - 1, S);
        S := S + 'K';
      end;
    HVMb:
      begin
        Str(OldMem shr 20: Size.X - 1, S);
        S := S + 'M';
      end;
  end;
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1, B);
end;


procedure THeapView.Update;
begin
  if (OldMem <> MemAvail) then DrawView;
end;


function THeapView.Comma(n: LongInt): string;
var
  num, loc: Byte;
  s: string;
  t: string;
begin
  Str(n, s);
  Str(n: Size.X, t);

  num := length(s) div 3;
  if (length(s) mod 3) = 0 then dec(num);

  delete(t, 1, num);
  loc := length(t) - 2;

  while num > 0 do
  begin
    Insert(',', t, loc);
    dec(num);
    dec(loc, 3);
  end;

  Comma := t;
end;


{*****************************************************************************
                                     ClockView
*****************************************************************************}

function LeadingZero(w: Word): string;
var
  s: string;
begin
  Str(w: 0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;

constructor TClockView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;


procedure TClockView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, TimeStr, C);
  WriteLine(0, 0, Size.X, 1, B);
end;


procedure TClockView.Update;
var
  h, m, s, hund: {$IFNDEF virtualpascal}word{$ELSE}longint{$ENDIF};
begin
  GetTime(h, m, s, hund);
  if Abs(s - LastTime.sec) >= Refresh then
  begin
    with LastTime do
    begin
      Hour := h;
      Min := m;
      Sec := s;
    end;
    TimeStr := FormatTimeStr(h, m, s);
    DrawView;
  end;
end;

function TClockView.FormatTimeStr(H, M, S: Word): string;
begin
  FormatTimeStr := LeadingZero(h) + ':' + LeadingZero(m) +
    ':' + LeadingZero(s);
end;

end.