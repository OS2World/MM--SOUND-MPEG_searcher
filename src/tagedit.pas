(*
 * tag editing form
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit TagEdit;

interface

uses Dialogs, Objects, Drivers, Views, ID3v1
  ;

const
  ResourceSize = 1180; { !!!!!!!!!!!!!! you need to change this if the
                         genre-list has been modified !!!!!!!!!!!!!!!! }

type
  PTagEditor = ^TTagEditor;
  TTagEditor = object(TDialog)
    iSongname,
      iArtist,
      iAlbum,
      iYear,
      iComment: PInputLine;
    iGenre: PListBox;
    iCodepage: PRadioButtons;
    constructor Init(AFilename: string);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  private
    Genres: PStringCollection;
    stream: PDosStream;
    tag: PTagData;
    srcCodepage: Byte;
  end;

function MakeGenres: PStringCollection;

implementation

uses Codepage, StdDlg, MsgBox, DOS, App
  {$IFNDEF fpc}, EditChD{$ENDIF}
  {$IFDEF fpc}, Commands{$ENDIF}
  ;

{$I nonfpc.inc}

function LoCase(c: Char): Char;
begin
  case c of
    'A'..'Z': c := Char(Byte(c) + (97 - 65));
    'Ä'..'è': c := Char(Byte(c) + (160 - 128));
    'ê'..'ü': c := Char(Byte(c) + (224 - 144));
    '': c := 'Ò';
  end;
  LoCase := c;
end;

function stLoCase(S: string): string;
var
  k: Byte;
begin
  for k := 1 to Length(S) do
    S[k] := locase(S[k]);
  stLocase := S;
end;

function MakeGenres: PStringCollection;
var
  res: PResourceFile;
  stream: PDosStream;
begin
  stream := New(PDosStream, Init(ExtractDir(ParamStr(0)) + 'tagger.res',
    stOpenRead));

  stream^.Seek(stream^.GetSize - ResourceSize);
  res := New(PResourceFile, Init(stream));

  MakeGenres := PStringCollection(res^.Get('genres'));

  Dispose(res, Done);
end;

constructor TTagEditor.Init(AFilename: string);
var
  R: TRect;
begin
  R.Assign(0, 0, 56, 19);
{$ifndef win32}
  inherited Init(R, 'ID3v1 tag editing (' + stLocase(ExtractFilename(
    AFilename)) + ')');
{$else}
  inherited Init(R, 'ID3v1 tag editing (' + Win2Alt(stLocase(ExtractFilename(
    AFilename))) + ')');
{$endif}

  Options := Options or ofCentered;

  R.Assign(2, 3, 34, 4);
  iSongname := New(PInputLine, Init(R, 30));
  Insert(iSongname);
  R.Assign(2, 2, 34, 3);
  Insert(New(PLabel, Init(R, ' ~S~ong name:', iSongname)));

  R.Assign(2, 6, 34, 7);
  iArtist := New(PInputLine, Init(R, 30));
  Insert(iArtist);
  R.Assign(2, 5, 34, 6);
  Insert(New(PLabel, Init(R, ' A~r~tist:', iArtist)));

  R.Assign(2, 9, 34, 10);
  iAlbum := New(PInputLine, Init(R, 30));
  Insert(iAlbum);
  R.Assign(2, 8, 34, 9);
  Insert(New(PLabel, Init(R, ' A~l~bum:', iAlbum)));

  R.Assign(2, 12, 34, 13);
  iComment := New(PInputLine, Init(R, 30));
  Insert(iComment);
  R.Assign(2, 11, 34, 12);
  Insert(New(PLabel, Init(R, ' Co~m~ment:', iComment)));

  R.Assign(2, 14, 34, 17);
  iCodepage := New(PRadioButtons, Init(R,
    NewSItem('Save ~u~sing 1251 codepage',
    NewSItem('Save us~i~ng Koi8-r codepage',
    NewSItem('Sa~v~e using Alt codepage', nil)))));
  Insert(iCodepage);

  R.Assign(35, 3, 54, 13);
  iGenre := New(PListBox, Init(R, 1, nil));
  Insert(iGenre);
  iGenre^.NewList(MakeGenres);
  R.Assign(35, 2, 54, 3);
  Insert(New(PLabel, Init(R, ' ~G~enre:', iGenre)));

  R.Assign(42, 14, 48, 15);
  iYear := New(PInputLine, Init(R, 4));
  Insert(iYear);
  R.Assign(34, 14, 41, 15);
  Insert(New(PLabel, Init(R, ' ~Y~ear:', iYear)));

  R.Assign(34, 16, 44, 18);
  Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));
  R.Assign(44, 16, 54, 18);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, 0)));

  iSongname^.Select;

  tag := nil;
  stream := New(PDosStream, Init(AFilename, stOpen));

  if stream^.Status <> stOk then
  begin
    MessageBox(#3'An error occured while trying to open the audio-file. ' +
      'Therefore, there is no information to display.',
      nil, mfInformation or mfOkButton);
  end;

  tag := New(PTagData, Init(stream));
  if IsThereATag(stream) then
  begin
    tag^.ReadTag;
    with tag^.tag do
    begin
      srcCodepage := DecodeTag(@tag^.tag);
      case srcCodepage of
        cpWin: iCodepage^.Press(0);
        cpKoi: iCodepage^.Press(1);
        cpAlt: iCodepage^.Press(2);
      end;
      iSongname^.Data^ := Songname;
      iArtist^.Data^ := Artist;
      iAlbum^.Data^ := Album;
      iYear^.Data^ := Year;
      iComment^.Data^ := Comment;
      if Genre > $7D then
      begin
        iGenre^.FocusItem(0);
      end
      else
      begin
        iGenre^.FocusItem(Genre + 1);
      end;
    end;
  end;
end;

procedure TTagEditor.HandleEvent(var Event: TEvent);
begin
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmOK:
        begin
          with tag^.tag do
          begin
            Songname := iSongname^.Data^;
            Artist := iArtist^.Data^;
            Album := iAlbum^.Data^;
            Comment := iComment^.Data^;
            Year := iYear^.Data^;
            if iGenre^.Focused = 0 then
              Genre := $FF
            else
              Genre := iGenre^.Focused - 1;
            if iCodepage^.Mark(0) then
            begin
              Songname := Alt2Win(Songname);
              Artist := Alt2Win(Artist);
              Album := Alt2Win(Album);
              Comment := Alt2Win(Comment);
            end;
            if iCodepage^.Mark(1) then
            begin
              Songname := Alt2Koi(Songname);
              Artist := Alt2Koi(Artist);
              Album := Alt2Koi(Album);
              Comment := Alt2Koi(Comment);
            end;
          end;
          tag^.WriteTag;
        end;
    end;
  end;
  inherited HandleEvent(Event);
end;

destructor TTagEditor.Done;
begin
  if iGenre^.List <> nil then
    Dispose(iGenre^.List, Done);
  Dispose(stream, Done);
  if tag <> nil then
    Dispose(tag, Done);
  inherited Done;
end;

end.