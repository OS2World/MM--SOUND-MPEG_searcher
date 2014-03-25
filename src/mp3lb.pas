(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit mp3lb;

interface

uses
  Objects, Views, Dialogs, ID3v1, DOS, Drivers
  {$IFDEF virtualpascal}, Use32{$ENDIF}
  ;

const
  cmListItemFocused = 205;

type
  Pmp3 = ^Tmp3;
  Tmp3 = object(TObject)
    tag: PjID3v1;
    Filename: FNameStr;
    constructor Init(const FN: FNameStr; ReadTag: Boolean);
    destructor Done; virtual;
    procedure ReadTagNow;
  end;

  PMP3ListBox = ^TMP3ListBox;
  TMP3ListBox = object(TListViewer)
    List: PCollection;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar);
    procedure NewList(AList: PCollection); virtual;
    function GetText(Item: Integer; MaxLen: Integer): string; virtual;
    procedure FocusItem(Item: Integer); virtual;
  end;

implementation

uses
  StdDlg, App, MsgBox, Codepage
{$IFNDEF fpc}, EditChD{$ENDIF}
  ;

{$I nonfpc.inc}

procedure TMP3ListBox.FocusItem(Item: Integer);
begin
  inherited FocusItem(Item);
  Message(Owner, evBroadcast, cmListItemFocused, @Self);
end;

function TMP3ListBox.GetText(Item: Integer; MaxLen: Integer): string;
begin
  if List <> nil then
    Result := ShrinkPath(Pmp3(List^.Items^[Item])^.Filename, MaxLen - 3)
  else
    Result := '';
  {$ifdef win32}
  Result := Win2Alt(Result);
  {$endif}
end;

constructor TMP3ListBox.Init(var Bounds: TRect; AScrollBar: PScrollBar);
begin
  inherited Init(Bounds, 1, nil, AScrollBar);
  List := nil;
  SetRange(0);
end;

procedure TMP3ListBox.NewList(AList: PCollection);
begin
  if List <> nil then
    Dispose(List, Done);
  List := AList;
  if List <> nil then
    SetRange(List^.Count)
  else
    SetRange(0);
  if Range > 0 then
    FocusItem(0);
  DrawView;
end;

procedure Tmp3.ReadTagNow;
var
  stream: PDosStream;
  tagData: PTagData;
begin
  if tag <> nil then
    FreeMem(tag);
  stream := New(PDosStream, Init(Filename, stOpenRead));
  tagData := New(PTagData, Init(stream));

  tagData^.ReadTag;
  GetMem(tag, SizeOf(TjID3v1));
  Move(tagData^.tag, tag^, SizeOf(TjID3v1));

  Dispose(tagData, Done);
  Dispose(stream, Done);
end;

constructor Tmp3.Init(const FN: FNameStr; ReadTag: Boolean);
var
  tagData: PTagData;
  stream: PDosStream;
begin
  inherited Init;
  tag := nil;
  Filename := FN;
  tag := nil;
  if ReadTag then
  begin
    ReadTagNow;
  end;
end;

destructor Tmp3.Done;
begin
  if tag <> nil then
    FreeMem(tag, SizeOf(TjID3v1));
  inherited Done;
end;

end.
