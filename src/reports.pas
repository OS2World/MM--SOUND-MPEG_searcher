(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

{$I-}
unit Reports;

interface

uses
  Objects, mp3lb, ID3v1, MsgBox, DOS, StdDlg, Dialogs, App, Views,
  SortType, Macroz, MacrozTV
  {$IFNDEF fpc}, EditChD{$ENDIF}
  {$IFDEF virtualpascal}, Use32{$ENDIF}
  ;

type
  TFNGetMP3Tag = function(FN: string): PjID3v1;

function SaveFilesBBS(const FN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag): Boolean;
function SaveM3U(const FN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag): Boolean;
function SaveListWhole(FN, templateFN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag): Boolean;
function SaveSeparatedList(FN, templateFN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag; twoItemsRec: TTwoItemsRec): Boolean;
procedure MakeStandardMacros(const tag: PjID3v1; mc: PMacrosEngine;
  var totalSize: Longint; Filename: string);

implementation

uses
  Config, Wizard, StatusW, MP3List, Drivers, Gadgets, Codepage,
  Sortings
  {$ifdef win32}, Windows, Strings {$endif}
  ;

{$I nonfpc.inc}
type
  PMP3Searcher = ^TMP3Searcher;
  TMP3Searcher = object(TApplication)
    StatusWindow: PStatusWindow;
    MP3ListDialog: PMP3List;
  end;

// from mp3list (c) by sk [2:6033/27]
function MakeShortName(const LongName: string): string;
var
  AName, AShortName: PChar;
begin
{$ifdef win32}
  GetMem(AName, Length(LongName) + 1);
  GetMem(AShortName, 4096);

  StrPCopy(AName, LongName);

  GetShortPathName(AName, AShortName, 4095);

  Result := StrPas(AShortName);

  FreeMem(AShortName, 4096);
  FreeMem(AName, Length(LongName) + 1);
{$else}
  Result := LongName;
{$endif}
end;

procedure MakeStandardMacros(const tag: PjID3v1; mc: PMacrosEngine;
  var totalSize: Longint; Filename: string);
var
  Size, i, playTime, playTimeSec: Longint;
  line: string;
begin
  if Length(tag^.Songname) = 0 then
    tag^.Songname := '?';
  if Length(tag^.Artist) = 0 then
    tag^.Artist := '?';
  if Length(tag^.Album) = 0 then
    tag^.Album := '?';

  mc^.AddMacro('@title', tag^.Songname, mcUser);
  mc^.AddMacro('@album', tag^.Album, mcUser);
  mc^.AddMacro('@artist', tag^.Artist, mcUser);
  mc^.AddMacro('@comment', tag^.Comment, mcUser);
  mc^.AddMacro('@year', tag^.Year, mcUser);
//  Size := Wizard.GetFileSize(mp3^.Filename);
  Size := tag^.Size;
  inc(totalSize, Size);
  mc^.AddMacro('@size', Long2Str(Size), mcUser);
  if tplMakeShortFilenames then
    line := JustFilename(MakeShortName(Filename))
  else
    line := JustFilename(Filename);
  mc^.AddMacro('@filename', line, mcUser);
  case tag^.hLayer of
    $01: line := mcLayerI;
    $02: line := mcLayerII;
    $03: line := mcLayerIII;
    else line := mcLayerUnknown;
  end;
  mc^.AddMacro('@layer', line, mcUser);
  case tag^.hMPEGVersion of
    $10: line := mcMpeg10;
    $20: line := mcMpeg20;
    $25: line := mcMpeg25;
    else line := mcMpegUnknown;
  end;
  mc^.AddMacro('@mpegversion', line, mcUser);
  case tag^.hMode of
    cmStereo: line := mcModeStereo;
    cmJointStereo: line := mcModeJointStereo;
    cmDualChannel: line := mcModeDualChannel;
    cmSingleChannel: line := mcModeSingleChannel;
  end;
  mc^.AddMacro('@mode', line, mcUser);
  mc^.AddMacro('@samplerate', Long2Str(tag^.hSampleRate), mcUser);
  mc^.AddMacro('@bitrate', Long2Str(tag^.hBitRate), mcUser);
  if tag^.tagExists then
    Size := 128
  else
    Size := 0;
  playTime := 8 * (tag^.Size - Size - tag^.RiffHeaderSize)
    div tag^.hBitrate div 1000;
  playTimeSec := playTime mod 60;
  mc^.AddMacro('@playtimesec', Long2Str(playTimeSec),
    mcUser);
  mc^.AddMacro('@playtimemin', Long2Str((playTime - playTimeSec) div 60),
    mcUser);
end;

function MakeCollectionFromFile(const FN: FNameStr): PStringCollection;
var
  inf: Text;
  line: string;
begin
  Result := New(PStringCollection, Init(5, 5));

  Assign(inf, FN);
  Reset(inf);

  while not EOF(inf) do
  begin
    Readln(inf, line);
    Result^.AtInsert(Result^.Count, NewStr(line));
  end;

  Close(inf);
end;

function SaveSeparatedList(FN, templateFN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag; twoItemsRec: TTwoItemsRec): Boolean;
var
  line: string;
  f, inf: Text;
  mc: PMacrosEngine;
  totSize, totNum, subSize, subNum, i, j, k, temp: Longint;
  coll, subColl: PCollection;
  tag: PjID3v1;
  mp3: Pmp3;
  subFooter, subHeader, info: PStringCollection;
begin

  Result := false;

  line := ExtractDir(ParamStr(0));
  line := Copy(line, 1, Length(line) - 1);
  ChDir(line);

  templateFN := FExpand(templateFN);

  totSize := 0;
  totNum := 0;

  if (not ExistFile(ForceExtension(templateFN, 'hdr'))) or
    (not ExistFile(ForceExtension(templateFN, 'inf'))) or
    (not ExistFile(ForceExtension(templateFN, 'ftr'))) or
    (not ExistFile(ForceExtension(templateFN, 'shd'))) or
    (not ExistFile(ForceExtension(templateFN, 'sft'))) then
  begin
    MsgBox.MessageBox(#3'There are some template''s files missing.', nil,
      mfError or mfOkButton);
    Exit;
  end;

  mc := New(PMacrosEngine, Init);
  mc^.AddAdditionalMacros;
  mc^.AddMacro('@version', Version, mcUser);
  mc^.AddMacro('@longversion', Concat('MPEG Searcher (', Platform, ') v',
    Version), mcUser);

  Assign(f, FN);
  Rewrite(f);

  Assign(inf, ForceExtension(templateFN, 'hdr'));
  Reset(inf);

  while not EOF(inf) do
  begin
    Readln(inf, line);
    line := mc^.Process(line);
    if not mc^.EmptyLine then
      Writeln(f, line);
  end;

  Close(inf);

  coll := PMP3Searcher(Application)^.MP3ListDialog^.SeparateAndSort(
    twoItemsRec.firstFactor, twoItemsRec.secondFactor);

  subHeader := MakeCollectionFromFile(ForceExtension(templateFN, 'shd'));
  subFooter := MakeCollectionFromFile(ForceExtension(templateFN, 'sft'));
  info := MakeCollectionFromFile(ForceExtension(templateFN, 'inf'));

  for i := 0 to coll^.Count - 1 do
  begin

    subColl := PCollection(coll^.Items^[i]);
    mp3 := Pmp3(subColl^.Items^[0]);

    tag := GetMP3Tag(mp3^.Filename);

    MakeStandardMacros(tag, mc, temp, mp3^.Filename);

    FreeMem(tag, SizeOf(TjID3v1));

    for k := 0 to subHeader^.Count - 1 do
    begin
      if subHeader^.Items^[k] = nil then
        line := ''
      else
        line := PString(subHeader^.Items^[k])^;
      line := mc^.Process(line);
      if not mc^.EmptyLine then
        Writeln(f, line);
    end;

    subSize := 0;
    subNum := 0;

    for j := 0 to subColl^.Count - 1 do
    begin
      inc(totNum);

      mp3 := Pmp3(subColl^.Items^[j]);
      tag := GetMP3Tag(mp3^.Filename);

      inc(subNum);
      inc(subSize, tag^.Size);

      MakeStandardMacros(tag, mc, totSize, mp3^.Filename);

      for k := 0 to info^.Count - 1 do
      begin
        if info^.Items^[k] = nil then
          line := ''
        else
          line := PString(info^.Items^[k])^;
        line := mc^.Process(line);
        if not mc^.EmptyLine then
          Writeln(f, line);
      end;

      FreeMem(tag, SizeOf(TjID3v1));
    end;

    mc^.AddMacro('@subnum', Long2Str(subNum), mcUser);
    mc^.AddMacro('@subsize', Long2Str(subSize), mcUser);

    for k := 0 to subFooter^.Count - 1 do
    begin
      if subFooter^.Items^[k] = nil then
        line := ''
      else
        line := PString(subFooter^.Items^[k])^;
      line := mc^.Process(line);
      if not mc^.EmptyLine then
        Writeln(f, line);
    end;

  end;

  mc^.AddMacro('@totsize', Long2Str(totSize), mcUser);
  mc^.AddMacro('@totnum', Long2Str(totNum), mcUser);

  Assign(inf, ForceExtension(templateFN, 'ftr'));
  Reset(inf);

  while not EOF(inf) do
  begin
    Readln(inf, line);
    line := mc^.Process(line);
    if not mc^.EmptyLine then
      Writeln(f, line);
  end;

  Close(inf);

  Dispose(subHeader, Done);
  Dispose(subFooter, Done);
  Dispose(info, Done);

  for i := 0 to coll^.Count - 1 do
  begin
    subColl := PCollection(coll^.Items^[i]);
    for j := 0 to subColl^.Count - 1 do
    begin
      mp3s^.AtInsert(mp3s^.Count, subColl^.Items^[j]);
    end;
    subColl^.DeleteAll;
  end;

  Dispose(coll, Done);
  Dispose(mc, Done);
  Close(f);

  Result := true;

end;

function SaveListWhole(FN, templateFN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag): Boolean;
var
  f, inf: Text;
  tag: PjID3v1;
  i, j: Integer;
  line: string;
  mc: PMacrosEngine;
  infoBuffer: PStringCollection;
  totSize, Size: Longint;
begin

  Result := false;

  totSize := 0;
  line := ExtractDir(ParamStr(0));
  line := Copy(line, 1, Length(line) - 1);
  ChDir(line);

  templateFN := FExpand(templateFN);

  if (not ExistFile(ForceExtension(templateFN, 'hdr'))) or
    (not ExistFile(ForceExtension(templateFN, 'inf'))) or
    (not ExistFile(ForceExtension(templateFN, 'ftr'))) then
  begin
    MsgBox.MessageBox(#3'There are some template''s files missing.', nil,
      mfError or mfOkButton);
    Exit;
  end;

  Assign(f, FN);
  Rewrite(f);

  mc := New(PMacrosEngine, Init);
  mc^.AddAdditionalMacros;
  mc^.AddMacro('@version', Version, mcUser);
  mc^.AddMacro('@longversion', Concat('MPEG Searcher (', Platform, ') v',
    Version), mcUser);

  Assign(inf, ForceExtension(templateFN, 'hdr'));
  Reset(inf);

  while not EOF(inf) do
  begin
    Readln(inf, line);
    line := mc^.Process(line);
    if not mc^.EmptyLine then
      Writeln(f, line);
  end;

  Close(inf);

  infoBuffer := New(PStringCollection, Init(10, 10));

  infoBuffer := MakeCollectionFromFile(ForceExtension(templateFN, 'inf'));

  for i := 0 to mp3s^.Count - 1 do
  begin
    tag := GetMP3Tag(Pmp3(mp3s^.Items^[i])^.Filename);

    MakeStandardMacros(tag, mc, totSize, Pmp3(mp3s^.Items^[i])^.Filename);

    for j := 0 to infoBuffer^.Count - 1 do
    begin
      if infoBuffer^.Items^[j] = nil then
        line := ''
      else
        line := mc^.Process(PString(infoBuffer^.Items^[j])^);
      if not mc^.EmptyLine then
        Writeln(f, line);
    end;

    FreeMem(tag, SizeOf(TjID3v1));

  end;

  mc^.AddMacro('@totsize', Long2Str(totSize), mcUser);
  mc^.AddMacro('@totnum', Long2Str(mp3s^.Count), mcUser);

  Assign(inf, ForceExtension(templateFN, 'ftr'));
  Reset(inf);

  while not EOF(inf) do
  begin
    Readln(inf, line);
    line := mc^.Process(line);
    if not mc^.EmptyLine then
      Writeln(f, line);
  end;

  Close(inf);

  Dispose(infoBuffer, Done);
  Dispose(mc, Done);

  Close(f);

  Result := true;

end;

function SaveFilesBBS(const FN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag): Boolean;
var
  F: PBufStream;
  i: Integer;
  line: string;
  tag: PjID3v1;
begin
  Result := false;
  F := New(PBufStream, Init(FN, stCreate, 2048));

  if F^.Status <> stOk then
  begin
    MsgBox.MessageBox(#3'Unable to create' + #13#10#3 + ShrinkPath(FN, 33),
      nil, mfError or mfOkButton);
    Dispose(F, Done);
    Exit;
  end;

  for i := 0 to mp3s^.Count - 1 do
  begin
    line := Pmp3(mp3s^.Items^[i])^.Filename;
    tag := GetMP3Tag(line);

    if Length(tag^.Songname) = 0 then
      tag^.Songname := '?';
    if Length(tag^.Artist) = 0 then
      tag^.Artist := '?';
    if Length(tag^.Album) = 0 then
      tag^.Album := '?';

    line := ExtractFilename(line) + ExtractFileExt(line);

    if (Length(tag^.Artist) <> 0) and (Length(tag^.Songname) <> 0) then
    begin

      line := line + ' ' + tag^.Artist + ' - ' + tag^.Songname;

    end;

    F^.Write(line[1], Length(line));
    line := #13#10;
    F^.Write(line[1], Length(line));
  end;

  Dispose(F, Done);
  Result := true;
end;

function SaveM3U(const FN: FNameStr; mp3s: PCollection;
  GetMP3Tag: TFNGetMP3Tag): Boolean;
var
  F: PBufStream;
  i: Integer;
  line: string;
begin
  Result := false;
  F := New(PBufStream, Init(FN, stCreate, 2048));

  if F^.Status <> stOk then
  begin
    MsgBox.MessageBox(#3'Unable to create' + #13#10#3 + ShrinkPath(FN, 33),
      nil, mfError or mfOkButton);
    Dispose(F, Done);
    Exit;
  end;

  for i := 0 to mp3s^.Count - 1 do
  begin
    line := Pmp3(mp3s^.Items^[i])^.Filename;
    F^.Write(line[1], Length(line));
    line := #13#10;
    F^.Write(line[1], Length(line));
  end;

  Dispose(F, Done);
  Result := true;
end;

end.
