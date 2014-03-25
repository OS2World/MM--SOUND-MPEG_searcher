(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit MP3List;

interface

{$IFNDEF virtualpascal}
  {$IFNDEF fpc}
    {$DEFINE bp}
  {$ENDIF}
{$ENDIF}
{$I-}

uses
  Dialogs, Objects, Views, DOS, Drivers, TagEdit, Sortings, mp3lb, Reports,
  SortType, Config, InfoPane
  {$IFDEF fpc}, Commands{$ENDIF}
  {$IFDEF virtualpascal}, VPUtils{$ENDIF}
  ;

const
  cmTagEdit = 206;
  cmListRemove = 207;
  cmListAdd = 208;
  cmListGenerate = 209;
  cmListSort = 210;
  cmTagsUpdate = 212;

var
  mp3s: PCollection;

type
  PMP3List = ^TMP3List;
  TMP3List = object(TDialog)

    lstList: PMP3ListBox;
    lblTitle,
      lblArtist,
      lblAlbum,
      lblComment,
      lblYear,
      lblSize: PStaticText;

    destructor Done; virtual;
    constructor Init(mp3z: PCollection);
    procedure HandleEvent(var Event: TEvent); virtual;
    function SeparateAndSort(firstFactor,
      secondFactor: TSepFactor): PCollection;
  private
    procedure UpdateInfo(readTags: Boolean);
    procedure PathFilenameSort;
    procedure FilenameSort;
    procedure TwoItemsSort(firstFactor, secondFactor: TSepFactor);
    procedure RandomSort;
  end;

implementation

uses
  MsgBox, ID3v1, StdDlg, App, Codepage, MP3Opt, StatusW, SortOpt, Wizard
  {$IFNDEF fpc}, EditChD{$ENDIF};

{$I nonfpc.inc}

function GetMP3Tag(FN: string): PjID3v1;
var
  stream: PDosStream;
  tag: PTagData;
  mp3: Pmp3;
  cp: Byte;

  function SearchTag(const Filename: string): Pmp3;
  var
    i: Integer;
    mp3: Pmp3;
  begin
    Result := nil;
    for i := 0 to mp3s^.Count - 1 do
    begin
      mp3 := Pmp3(mp3s^.Items^[i]);
      if mp3^.Filename = Filename then
      begin
        Result := mp3;
        Exit;
      end;
    end;
  end;

begin

  mp3 := SearchTag(FN);

  if (mp3 = nil) or (mp3^.tag = nil) then
  begin
    GetMem(Result, SizeOf(TjID3v1));
    stream := New(PDosStream, Init(FN, stOpenRead));
    tag := New(PTagData, Init(stream));

    tag^.ReadTag;

    if rpUseCodepage then
    begin
      with tag^.tag do
      begin
        cp := DetermineCodepage(Songname + Artist + Album + Comment);
        Songname := X2Y(Songname, cp, rpCodepage);
        Artist := X2Y(Artist, cp, rpCodepage);
        Album := X2Y(Album, cp, rpCodepage);
        Comment := X2Y(Comment, cp, rpCodepage);
      end;
    end;
    Move(tag^.tag, Result^, SizeOf(TjID3v1));

    if mp3 <> nil then
    begin
      GetMem(mp3^.tag, SizeOf(TjID3v1));
      Move(tag^.tag, mp3^.tag^, SizeOf(TjID3v1));
    end;

    Dispose(tag, Done);
    Dispose(stream, Done);
  end
  else
  begin
    GetMem(Result, SizeOf(TjID3v1));
    if rpUseCodepage then
    begin
      with mp3^.tag^ do
      begin
        cp := DetermineCodepage(Songname + Artist + Album + Comment);
        Songname := X2Y(Songname, cp, rpCodepage);
        Artist := X2Y(Artist, cp, rpCodepage);
        Album := X2Y(Album, cp, rpCodepage);
        Comment := X2Y(Comment, cp, rpCodepage);
      end;
    end;
    Move(mp3^.tag^, Result^, SizeOf(TjID3v1));
  end;

end;

destructor TMP3List.Done;
begin
  lstList^.NewList(nil);
  inherited Done;
end;

constructor TMP3List.Init(mp3z: PCollection);
var
  R: TRect;
begin

  R.Assign(0, 0, 75, 15);
  inherited Init(R, 'MPEGs list');
  Options := Options or ofCentered;

  mp3s := mp3z;

  R.Assign(2, 2, 33, 13);
  lstList := New(PMP3ListBox, Init(R, nil));
  Insert(lstList);
  lstList^.NewList(mp3s);

  R.Assign(34, 2, 40, 3);
  Insert(New(PStaticText, Init(R, ' Tag:')));

  R.Assign(40, 2, 54, 4);
  Insert(New(PButton, Init(R, '~E~dit tag', cmTagEdit, 0)));

  R.Assign(55, 2, 74, 4);
  Insert(New(PButton, Init(R, '~U~pdate list', cmTagsUpdate, 0)));

  R.Assign(34, 4, 74, 5);
  lblTitle := New(PStaticText, Init(R, 'Title  :                               '));
  Insert(lblTitle);

  R.Assign(34, 5, 74, 6);
  lblArtist := New(PStaticText, Init(R, 'Artist :                               '));
  Insert(lblArtist);

  R.Assign(34, 6, 74, 7);
  lblAlbum := New(PStaticText, Init(R, 'Album  :                               '));
  Insert(lblAlbum);

  R.Assign(34, 7, 74, 8);
  lblComment := New(PStaticText, Init(R, 'Comment:                               '));
  Insert(lblComment);

  R.Assign(34, 8, 50, 9);
  lblYear := New(PStaticText, Init(R, 'Year   :     '));
  Insert(lblYear);

  R.Assign(51, 8, 70, 9);
  lblSize := New(PStaticText, Init(R, 'Size:              '));
  Insert(lblSize);

  UpdateInfo(false);

  R.Assign(34, 10, 41, 11);
  Insert(New(PStaticText, Init(R, ' List:')));

  R.Assign(40, 10, 54, 12);
  Insert(New(PButton, Init(R, 'A~d~d item', cmListAdd, 0)));

  R.Assign(55, 10, 74, 12);
  Insert(New(PButton, Init(R, '~R~emove item', cmListRemove, 0)));

  R.Assign(40, 12, 59, 14);
  Insert(New(PButton, Init(R, '~G~enerate list', cmListGenerate, 0)));

  R.Assign(59, 12, 74, 14);
  Insert(New(PButton, Init(R, '~S~ort list', cmListSort, 0)));

  lstList^.Select;

end;

procedure TMP3List.UpdateInfo(readTags: Boolean);
var
  mp3: Pmp3;
  cp: Byte;
begin

  lstList^.List^.Pack;

  if lstList^.Range = 0 then
  begin
    lblTitle^.Text^ := 'Title  :';
    lblArtist^.Text^ := 'Artist :';
    lblAlbum^.Text^ := 'Album  :';
    lblComment^.Text^ := 'Comment:';
    lblYear^.Text^ := 'Year   :';
    lblSize^.Text^ := 'Size:';

    ReDraw;
    Exit;
  end;

  if lstList^.Focused > lstList^.List^.Count - 1 then
  begin
    lstList^.FocusItem(0);
  end;

  mp3 := mp3s^.Items^[lstList^.Focused];
  if readTags then
    mp3^.ReadTagNow;
  if mp3^.tag = nil then
  begin
    mp3^.tag := GetMP3Tag(mp3^.Filename);
  end;

  with mp3^.tag^ do
  begin

    { codepage stuff }

    if rpUseCodepage then
    begin
      cp := DetermineCodepage(Songname + Artist + Album + Comment);
      Songname := X2Y(Songname, cp, rpCodepage);
      Artist := X2Y(Artist, cp, rpCodepage);
      Album := X2Y(Album, cp, rpCodepage);
      Comment := X2Y(Comment, cp, rpCodepage);
    end;

    { labels stuff }

    lblTitle^.Text^ := 'Title  : ' + Songname;
    lblArtist^.Text^ := 'Artist : ' + Artist;
    lblAlbum^.Text^ := 'Album  : ' + Album;
    lblComment^.Text^ := 'Comment: ' + Comment;
    lblYear^.Text^ := 'Year   : ' + Year;
    lblSize^.Text^ := 'Size: ' + Long2StrFmt(Size);
  end;

  ReDraw;
end;

{$I sort.inc}

var
  compareFactor: TSepFactor;

function ShortGetMP3Tag(mp3: Pmp3): PjID3v1;
begin
  GetMem(Result, SizeOf(TjID3v1));
  FillChar(Result^, SizeOf(TjID3v1), 0);
  if mp3^.tag = nil then
    Exit;
  Move(mp3^.tag^, Result^, SizeOf(TjID3v1));
end;

function ItemCompare(item1, item2: Pointer): Integer;
var
  tag1, tag2: PjID3v1;
  cmpItem1, cmpItem2: string;
begin
  tag1 := ShortGetMP3Tag(Pmp3(item1));
  tag2 := ShortGetMP3Tag(Pmp3(item2));

  case compareFactor of
    faAlbum:
      begin cmpItem1 := tag1^.Album; cmpItem2 := tag2^.Album;
      end;
    faArtist:
      begin cmpItem1 := tag1^.Artist; cmpItem2 := tag2^.Artist;
      end;
    faTitle:
      begin cmpItem1 := tag1^.Songname; cmpItem2 := tag2^.Songname;
      end;
    faComment:
      begin cmpItem1 := tag1^.Comment; cmpItem2 := tag2^.Comment;
      end;
    faYear:
      begin cmpItem1 := tag1^.Year; cmpItem2 := tag2^.Year;
      end;
  end;

  Result := StringCompare(@cmpItem1, @cmpItem2);

  FreeMem(tag1, SizeOf(tag1^));
  FreeMem(tag2, SizeOf(tag2^));
end;

function CollectionItemCompare(item1, item2: Pointer): Integer;
var
  tag1, tag2: PjID3v1;
  cmpItem1, cmpItem2: string;
begin
  tag1 := ShortGetMP3Tag(Pmp3(PCollection(item1)^.Items^[0]));
  tag2 := ShortGetMP3Tag(Pmp3(PCollection(item2)^.Items^[0]));

  case compareFactor of
    faAlbum:
      begin cmpItem1 := tag1^.Album; cmpItem2 := tag2^.Album;
      end;
    faArtist:
      begin cmpItem1 := tag1^.Artist; cmpItem2 := tag2^.Artist;
      end;
    faTitle:
      begin cmpItem1 := tag1^.Songname; cmpItem2 := tag2^.Songname;
      end;
    faComment:
      begin cmpItem1 := tag1^.Comment; cmpItem2 := tag2^.Comment;
      end;
    faYear:
      begin cmpItem1 := tag1^.Year; cmpItem2 := tag2^.Year;
      end;
  end;

  Result := StringCompare(@cmpItem1, @cmpItem2);

  FreeMem(tag1, SizeOf(tag1^));
  FreeMem(tag2, SizeOf(tag2^));
end;

function FilenameCompare(item1, item2: Pointer): Integer;
var
  str1, str2: string;
begin
  str1 := ExtractFilename(Pmp3(item1)^.Filename);
  str2 := ExtractFilename(Pmp3(item2)^.Filename);
  Result := StringCompare(@str1, @str2);
end;

function PathFilenameCompare(item1, item2: Pointer): Integer;
begin
  Result := StringCompare(@Pmp3(item1)^.Filename, @Pmp3(item2)^.Filename);
end;

procedure TMP3List.PathFilenameSort;
begin
  QuickSort(mp3s^.Items, 0, mp3s^.Count - 1, PathFilenameCompare);
end;

procedure TMP3List.FilenameSort;
begin
  QuickSort(mp3s^.Items, 0, mp3s^.Count - 1, FilenameCompare);
end;

function TMP3List.SeparateAndSort(firstFactor,
  secondFactor: TSepFactor): PCollection;
var
  bigColl: PCollection;
  coll: PCollection;
  i, j: Integer;
begin

  // 1. make big collection that will contain small collections

  bigColl := SeparateCollection(firstFactor, mp3s, GetMP3Tag);

  // 2. sort small collections

  compareFactor := secondFactor;
  for i := 0 to bigColl^.Count - 1 do
  begin
    coll := PCollection(bigColl^.Items^[i]);
    QuickSort(coll^.Items, 0, coll^.Count - 1, ItemCompare);
  end;

  // 3. sort big collection

  compareFactor := firstFactor;
  QuickSort(bigColl^.Items, 0, bigColl^.Count - 1, CollectionItemCompare);

  Result := bigColl;

end;

procedure TMP3List.TwoItemsSort(firstFactor, secondFactor: TSepFactor);
var
  bigColl: PCollection;
  coll: PCollection;
  i, j: Integer;
begin

  bigColl := SeparateAndSort(firstFactor, secondFactor);

  // 4. make mp3s collection from bigColl

  for i := 0 to bigColl^.Count - 1 do
  begin
    coll := PCollection(bigColl^.Items^[i]);
    for j := 0 to coll^.Count - 1 do
    begin
      mp3s^.AtInsert(mp3s^.Count, NewStr(PString(coll^.Items^[j])^));
    end;
  end;

  Dispose(bigColl, Done);

  // 5. yeeeeeehaaaw ;-) with no memory leaks from first attempt..
  // as usually, by the way ;-)

end;

procedure TMP3List.RandomSort;
var
  dupColl: PCollection;
  i, j: Integer;
  p: Pointer;
begin
  dupColl := New(PCollection, Init(10, 10));
  Randomize;

  for i := 0 to mp3s^.Count - 1 do
  begin
    dupColl^.Insert(mp3s^.Items^[i]);
  end;

  for i := 0 to mp3s^.Count - 1 do
  begin
    p := nil;
    while p = nil do
    begin
      j := Random(mp3s^.Count);
      p := dupColl^.Items^[j];
    end;
    dupColl^.Items^[j] := nil;
    mp3s^.Items^[i] := p;
  end;

  dupColl^.DeleteAll;

  Dispose(dupColl, Done);
end;

procedure TMP3List.HandleEvent(var Event: TEvent);
var
  dlg: PDialog;
  theFile: FNameStr;
  option: Integer;
  factor: TSepFactor;
  twoItemsRec: TTwoItemsRec;
  tplNum: Byte;
  tempColl: PStringCollection;

 function MakeShortColl(tpls: PStringCollection): PStringCollection;
 var
   i: Integer;
 begin
   Result := New(PStringCollection, Init(10, 10));
   for i := 0 to tpls^.Count - 1 do
   begin
     Result^.AtInsert(Result^.Count,
       NewStr(JustFileName(PString(tpls^.At(i))^)));
   end;
 end;

begin
  inherited HandleEvent(Event);

  case Event.What of
    evKeyDown:
      begin
        case Event.KeyCode of
          kbF2:
            begin
              dlg := New(PMpegInfo,
                Init(Pmp3(mp3s^.At(lstList^.Focused))^.tag));
              Application^.ExecuteDialog(dlg, nil);
            end;
        end;
      end;
    evBroadcast, evCommand:
      begin
        case Event.Command of
          cmTagsUpdate:
            begin
              UpdateInfo(true);
              ClearEvent(Event);
            end;
          cmListItemSelected, cmListItemFocused:
            begin

              if (lstList = nil) or (mp3s = nil) or (lblTitle = nil) or
                (lblArtist = nil) or (lblAlbum = nil) or (lblComment = nil) or
                (lblYear = nil) then
                Exit;

              UpdateInfo(false);

              ClearEvent(Event);
            end;
          cmTagEdit:
            begin
              if lstList^.Range = 0 then
                Exit;
              dlg := New(PTagEditor, Init(
                Pmp3(mp3s^.Items^[lstList^.Focused])^.Filename));

              if Application^.ExecuteDialog(dlg, nil) = cmOk then
              begin
                UpdateInfo(false);
              end;

              ClearEvent(Event);
            end;
          cmListRemove:
            begin
              if lstList^.Range = 0 then
                Exit;
              mp3s^.FreeItem(mp3s^.At(lstList^.Focused));
              mp3s^.AtDelete(lstList^.Focused);

              lstList^.SetRange(mp3s^.Count);
              lstList^.Draw;
              UpdateInfo(false);

              ClearEvent(Event);
            end;
          cmListAdd:
            begin
              theFile := '*.*';
              if OpenFile(theFile, 214) then
              begin
                mp3s^.Insert(New(Pmp3, Init(theFile, true)));
                lstList^.SetRange(mp3s^.Count);
                lstList^.Draw;
                UpdateInfo(false);
              end;
              ClearEvent(Event);
            end;
          cmListGenerate:
            begin
              dlg := New(PMP3Options, Init); option := 0;

              if Application^.ExecuteDialog(dlg, @option) = cmOk then
              begin
                theFile := ExtractDir(ParamStr(0));
                ChDir(Copy(theFile, 1, Length(theFile) - 1));
                case option of
                  0:
                    begin
                      theFile := '*.m3u';
                      if SaveAs(theFile, 215) then
                      begin
                        if SaveM3U(theFile, mp3s, GetMP3Tag) then
                          MessageBox(#3'Internet-playlist successfully created.',
                            nil, mfInformation or mfOkButton);
                      end;
                    end;
                  1:
                    begin
                      theFile := '*.bbs';
                      if SaveAs(theFile, 215) then
                      begin
                        if SaveFilesBBS(theFile, mp3s, GetMP3Tag) then
                          MessageBox(#3'files.bbs successfully created.',
                            nil, mfInformation or mfOkButton);
                      end;
                    end;
                  2:
                    begin
                      tplNum := 0;
                      if tplWhole^.Count = 0 then
                      begin
                        MessageBox('There is no templates available.', nil,
                          mfError or mfOkButton);
                        Exit;
                      end;
                      tempColl := MakeShortColl(tplWhole);
                      dlg := New(PTemplateDialog, Init(tempColl));
                      Dispose(tempColl, Done);
                      if Application^.ExecuteDialog(dlg, @tplNum) = cmCancel then
                        Exit;
                      theFile := '*.rpt';
                      if SaveAs(theFile, 215) then
                      begin
                        if SaveListWhole(theFile,
                          PString(tplWhole^.Items^[tplNum])^, mp3s,
                          GetMP3Tag) then
                        begin
                          MessageBox(#3'List successfully created.',
                            nil, mfInformation or mfOkButton);
                        end;
                      end;
                    end;
                  3:
                    begin
                      tplNum := 0;
                      if tplBy^.Count = 0 then
                      begin
                        MessageBox('There is no templates available.', nil,
                          mfError or mfOkButton);
                        Exit;
                      end;
                      tempColl := MakeShortColl(tplBy);
                      dlg := New(PTemplateDialog, Init(tempColl));
                      Dispose(tempColl, Done);
                      if Application^.ExecuteDialog(dlg, @tplNum) = cmCancel then
                        Exit;
                      theFile := '*.rpt';
                      if SaveAs(theFile, 215) then
                        dlg := New(PTwoItemsDialog, Init('Separate by'));
                        with twoItemsRec do
                        begin
                          firstFactor := faArtist;
                          secondFactor := faArtist;
                        end;
                        if Application^.ExecuteDialog(dlg, @twoItemsRec) = cmOk then
                          if SaveSeparatedList(theFile,
                            PString(tplBy^.Items^[tplNum])^, mp3s, GetMP3Tag,
                            twoItemsRec) then
                          begin
                            MessageBox(#3'List successfully created.', nil,
                              mfInformation or mfOkButton);
                          end;
                    end;
                end;
              end;
              ClearEvent(Event);
            end;
          cmListSort:
            begin
              dlg := New(PSortOptions, Init);
              mp3s^.Pack;

              option := 0;
              if Application^.ExecuteDialog(dlg, @option) = cmOk then
              begin
                case option of
                  0:
                    begin
                      PathFilenameSort;
                    end;
                  1:
                    begin
                      FilenameSort;
                    end;
                  2:
                    begin
                      factor := faArtist;
                      dlg := New(POneItemDialog, Init);
                      if Application^.ExecuteDialog(dlg, @factor) = cmOk then
                      begin
                        compareFactor := factor;
                        QuickSort(mp3s^.Items, 0, mp3s^.Count - 1, ItemCompare);
                      end;
                    end;
                  3:
                    begin
                      with twoItemsRec do
                      begin
                        firstFactor := faArtist;
                        secondFactor := faArtist;
                      end;
                      dlg := New(PTwoItemsDialog, Init('Sort by'));
                      if Application^.ExecuteDialog(dlg,
                        @twoItemsRec) = cmOk then
                      begin
                        with twoItemsRec do
                          TwoItemsSort(firstFactor, secondFactor);
                      end;
                    end;
                  4:
                    begin
                      RandomSort;
                    end;
                end;
                UpdateInfo(false);
              end;

              ClearEvent(Event);
            end;
        end;
      end;
  end;
end;

end.
