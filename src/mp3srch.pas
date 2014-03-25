(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

{&AlignRec-} // this is important since vp generated bad code with &AlignRec+

{$IFNDEF virtualpascal}
  {$IFNDEF fpc}
    {$DEFINE bp}
  {$ENDIF}
{$ENDIF}

uses Objects, App, MsgBox, Drivers, Menus, Views, Dialogs, StdDlg, Gadgets,
  DOS, StatusW, Searcher, MP3List, mp3lb, jCtl, Config, Wizard, Idle,
  VPUtils, ID3v1, Codepage
  {$IFNDEF fpc}, EditChD {$ENDIF}
  {$IFDEF fpc}, Commands {$IFDEF win32}, CRT{$ENDIF} {$ENDIF}
  ;

const
  cmAbout = 204;
  cmLoadM3U = 210;

type
  PMP3Searcher = ^TMP3Searcher;
  TMP3Searcher = object(TApplication)
    StatusWindow: PStatusWindow;
    MP3ListDialog: PMP3List;
    constructor Init;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    destructor Done; virtual;
  private
    Clock: PClockView;
    Heap: PHeapView;
    mp3s: PCollection;
    function ReadConfig: Boolean;
  end;

var
  mp3Searcher: PMP3Searcher;
  mp3Count: Longint;

{$I nonfpc.inc}
{$I sort.inc}

function TMP3Searcher.ReadConfig: Boolean;
var
  ctl: PCtl;
  tempStr: string;

 procedure ExpandColl(tpls: PStringCollection);
 var
   i: Integer;
   st: string;
 begin
   for i := 0 to tpls^.Count - 1 do
   begin
     st := PString(tpls^.At(i))^;
     DisposeStr(tpls^.At(i));
     tpls^.Items^[i] := NewStr(FExpand(st));
   end;
 end;

begin
  ctl := New(PCtl, Init(ExtractDir(ParamStr(0)) + 'mp3srch.ctl'));

  Result := ctl^.wasExist;

  if not ctl^.wasExist then
  begin
    tplBy := New(PStringCollection, Init(10, 10));
    tplWhole := New(PStringCollection, Init(10, 10));
    searchMask := New(PStringCollection, Init(10, 10));
    searchMask^.Insert(NewStr('*.mp?'));
    searchExclude := New(PStringCollection, Init(10, 10));
    searchExcludePath := New(PStringCollection, Init(10, 10));
  end;

  tplBy := ctl^.GetPool('templates.by');
  tplWhole := ctl^.GetPool('templates.whole');
  ExpandColl(tplBy);
  ExpandColl(tplWhole);
  searchMask := ctl^.GetPool('search.mask');
  searchExclude := ctl^.GetPool('search.exclude');
  searchExcludePath := ctl^.GetPool('search.excludepath');
  searchExcludeNonMpegs := ctl^.GetBoolean('search.exclude.nonmpegs');

  mcLayerI := ctl^.GetString('templates.macro.layer.I');
  mcLayerII := ctl^.GetString('templates.macro.layer.II');
  mcLayerIII := ctl^.GetString('templates.macro.layer.III');
  mcLayerUnknown := ctl^.GetString('templates.macro.layer.unknown');
  mcMpeg10 := ctl^.GetString('templates.macro.mpegversion.1.0');
  mcMpeg20 := ctl^.GetString('templates.macro.mpegversion.2.0');
  mcMpeg25 := ctl^.GetString('templates.macro.mpegversion.2.5');
  mcMpegUnknown := ctl^.GetString('templates.macro.mpegversion.unknown');
  mcModeStereo := ctl^.GetString('templates.macro.channelmode.stereo');
  mcModeJointStereo := ctl^.GetString('templates.macro.channelmode.jointstereo');
  mcModeDualChannel := ctl^.GetString('templates.macro.channelmode.dualchannel');
  mcModeSingleChannel := ctl^.GetString('templates.macro.channelmode.singlechannel');
  tplMakeShortFilenames := ctl^.GetBoolean('templates.macro.shortfilenames');

  rpUseCodepage := ctl^.GetBoolean('representation.usecodepage');

  searchRange := ctl^.GetLongint('search.riff.header.searchrange');
  headerSearchRange := searchRange;

  rpIgnoreCase := ctl^.GetBoolean('representation.sort.ignorecase');
  cmpIgnoreCase := rpIgnoreCase;

  tempStr := stLocase(ctl^.GetString('representation.targetcodepage'));
  if tempStr = '866' then
    rpCodepage := cpAlt;
  if tempStr = 'koi8-r' then
    rpCodepage := cpKoi;
  if tempStr = '1251' then
    rpCodepage := cpWin;

  Dispose(ctl, Done);
end;

procedure TMP3Searcher.Idle;
begin
//  inherited Idle;
  Clock^.Update;
  Heap^.Update;
  give_up_cpu_time;
end;

constructor TMP3Searcher.Init;
var
  R: TRect;
begin
  inherited Init;

  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  GetExtent(R);
  Dec(R.B.X);
  R.A.X := R.B.X - 12; R.A.Y := R.B.Y - 1;
  Heap := New(PHeapView, Init(R));
  Heap^.Mode := HVComma;
  Insert(Heap);

  if not ReadConfig then
  begin
    MessageBox(^C' An error occured while trying to read control file.', nil,
      mfInformation or mfOkButton);
  end;
end;

destructor TMP3Searcher.Done;
begin
  if searchMask <> nil then
    Dispose(searchMask, Done);
  if tplBy <> nil then
    Dispose(tplBy, Done);
  if tplWhole <> nil then
    Dispose(tplWhole, Done);
  if searchExclude <> nil then
    Dispose(searchExclude, Done);
  if searchExcludePath <> nil then
    Dispose(searchExcludePath, Done);
  inherited Done;
end;

procedure EnumProcedure(FoundFilename: string);
var
  fS, sS: string;
  i: Integer;
  mp3: Pmp3;
begin
  fS := stLocase(FoundFilename);
  for i := 0 to searchExclude^.Count - 1 do
  begin
    fS := ExtractFileName(fS) + ExtractFileExt(fS);
    sS := stLocase(PString(searchExclude^.Items^[i])^);
    if CheckWildcard(fS, sS) then
      Exit;
  end;
  for i := 0 to searchExcludePath^.Count - 1 do
  begin
    fS := ExtractDir(FoundFilename);
    fS := Copy(fS, 1, Length(fS) - 1);
    sS := stLocase(PString(searchExcludePath^.Items^[i])^);
    if CheckWildcard(fS, sS) then
      Exit;
  end;
  mp3 := New(Pmp3, Init(FoundFilename, true));
  if (not mp3^.tag^.isMpeg) and searchExcludeNonMpegs then
  begin
    Dispose(mp3, Done);
    Exit;
  end;
  inc(mp3Count);
  with mp3Searcher^.mp3s^ do
    Insert(mp3);
  with mp3Searcher^.StatusWindow^.ALabel^ do
  begin
    DisposeStr(Text);
    Text := NewStr('Scanning specified path... ' + IntToStr(mp3Count) +
      ' MP3s found yet.');
    Draw;
  end;
  mp3Searcher^.Idle;
end;

procedure TMP3Searcher.HandleEvent(var Event: TEvent);
var
  DirName: DirStr;
  srch: PSearcher;
  i: Integer;
  theFile: FNameStr;
  f: Text;
  line: string;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmOpen:
        begin
          if SelectDir(DirName, 213) then
          begin
            mp3Count := 0;
            mp3s := New(PCollection, Init(10, 10));
            StatusWindow := New(PStatusWindow, Init(
              'Scanning specified path... 0 MP3s found yet.   '));
            InsertWindow(StatusWindow);
            srch := New(PSearcher, Init);
            with srch^ do
            begin
             {$IFDEF bp}@{$ENDIF}EnumProc :=
               {$IFDEF fpc}@{$ENDIF}{$IFDEF bp}@{$ENDIF}EnumProcedure;
              for i := 0 to searchMask^.Count - 1 do
              begin
                BeginningPath := DirName;
                Mask := PString(searchMask^.Items^[i])^;
                BeginSearch;
              end;
            end;
            Dispose(srch, Done);
            Dispose(StatusWindow, Done);

            MP3ListDialog := New(PMP3List, Init(mp3s));
            ExecuteDialog(MP3ListDialog, nil);
          end;
          ClearEvent(Event);
        end;
      cmLoadM3U:
        begin
          theFile := '*.m3u';
          if OpenFile(theFile, 216) then
          begin
            StatusWindow := New(PStatusWindow, Init(
              'Scanning specified path... 0 MP3s found yet.   '));
            InsertWindow(StatusWindow);
            mp3s := New(PCollection, Init(10, 10));
            mp3Count := 0;

            Assign(f, theFile);
            Reset(f);

            while not EOF(f) do
            begin
              Readln(f, line);
              if FileExists(line) then
              begin
                EnumProcedure(line);
              end;
            end;

            Close(f);

            Dispose(StatusWindow, Done);
            MP3ListDialog := New(PMP3List, Init(mp3s));
            ExecuteDialog(MP3ListDialog, nil);
          end;
          ClearEvent(Event);
        end;
      cmAbout:
        begin
          MessageBox(#3'MPEG searcher ' + Version + ' (' +
            Platform + ')' + #13 + #3'Copyright (c) 1999 by' + #13 +
            #3'Alexander Trunov [2:5069/10]', nil,
            mfInformation or mfOkButton);
          ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TMP3Searcher.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
    NewItem('~O~pen path..', 'F3', kbF3, cmOpen, hcNoContext,
    NewItem('~L~oad Internet-playlist..', 'F4', kbF4, cmLoadM3U, hcNoContext,
    NewLine(
    NewItem('~Q~uit', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil))))),
    NewItem('~A~bout', 'Alt-A', kbAltA, cmAbout, hcNoContext, nil)))));
end;

begin
  {$ifdef linux}
  FileSystem := fsDos;
  {$endif}

  RegisterObjects;
  mp3Searcher := New(PMP3Searcher, Init);
  mp3Searcher^.Run;
  Dispose(mp3Searcher, Done);
 {$IFDEF fpc}
  {$IFDEF win32}
  ClrScr;
  {$ENDIF}
 {$ENDIF}
end.
