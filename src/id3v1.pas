(*
 * ID3v1 tag manipulations
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

(*
 * updated on 1999/12/09
 *)

unit ID3v1;

interface

uses
  Objects;

{$I id3v1.inc}

const
  headerSearchRange: Longint = 512; // for RIFF

type

  TChannelMode = (cmStereo, cmJointStereo, cmDualChannel, cmSingleChannel);

  PjID3v1 = ^TjID3v1;
  TjID3v1 = record
    Songname,
      Artist,
      Album,
      Comment: string[30];
    Year: string[4];
    Genre: Byte;
    hProtected,             // protected by CRC
      hCopyrighted,         // copyrighted
      hOriginal: Boolean;   // original version
    hBitrate,               // kbps
      hSampleRate,
      hMPEGVersion,
      hLayer: Longint;
    hMode: TChannelMode;
    Size, RiffHeaderSize: Longint;
    isMpeg, tagExists: Boolean;
  end;

  PTagData = ^TTagData;
  TTagData = object(TObject)
    tag: TjID3v1;
    constructor Init(mp3: PStream);
    procedure ReadTag;
    procedure WriteTag;
  private
    oldTag: TID3v1;
    localHeader: array [1..4] of Byte;
    stream: PStream;
  end;

function DecodeTag(const tag: PjID3v1): Byte;
function IsThereATag(Where: PStream): Boolean;

implementation

uses
  Strings, Codepage;

{$I trims.inc}

function DecodeTag(const tag: PjID3v1): Byte;
var
  line: string;
begin
  with tag^ do
  begin
    line := Songname + Album + Artist + Comment;
    Result := DetermineCodepage(line);
    case Result of
      cpWin:
        begin
          Songname := Win2Alt(Songname);
          Artist := Win2Alt(Artist);
          Album := Win2Alt(Album);
          Comment := Win2Alt(Comment);
        end;
      cpKoi:
        begin
          Songname := Koi2Alt(Songname);
          Artist := Koi2Alt(Artist);
          Album := Koi2Alt(Album);
          Comment := Koi2Alt(Comment);
        end;
    end;
  end;
end;

function IsThereATag(Where: PStream): Boolean;
var
  sign: array[1..3] of Char;
begin
  IsThereATag := false;
  Where^.Seek(Where^.GetSize - 128);
  Where^.Read(sign, 3);
  if (sign[1] = 'T') and (sign[2] = 'A') and (sign[3] = 'G') then
  begin
    IsThereATag := true;
  end;
end;

constructor TTagData.Init(mp3: PStream);
begin
  inherited Init;
  stream := mp3;
end;

procedure TTagData.ReadTag;
var
  line, s: string;
  i: Integer;
  noTag: Boolean;

 function MakeBitrate(hVersion, hLayer, hBitrate: Longint): Longint;
 begin
   Result := 0;

   case hVersion of
     $10:
       case hLayer of
         $01:
           case hBitrate of
             01: Result := 032;
             02: Result := 064;
             03: Result := 096;
             04: Result := 128;
             05: Result := 160;
             06: Result := 192;
             07: Result := 224;
             08: Result := 256;
             09: Result := 288;
             10: Result := 320;
             11: Result := 352;
             12: Result := 384;
             13: Result := 416;
             14: Result := 448;
           end;
         $02:
           case hBitrate of
             01: Result := 032;
             02: Result := 048;
             03: Result := 056;
             04: Result := 064;
             05: Result := 080;
             06: Result := 096;
             07: Result := 112;
             08: Result := 128;
             09: Result := 160;
             10: Result := 192;
             11: Result := 224;
             12: Result := 256;
             13: Result := 320;
             14: Result := 284;
           end;
         $03:
           case hBitrate of
             01: Result := 032;
             02: Result := 040;
             03: Result := 048;
             04: Result := 056;
             05: Result := 064;
             06: Result := 080;
             07: Result := 096;
             08: Result := 112;
             09: Result := 128;
             10: Result := 160;
             11: Result := 192;
             12: Result := 224;
             13: Result := 256;
             14: Result := 320;
           end;
       end;
     $20, $25:
       case hLayer of
         $01:
           case hBitrate of
             01: Result := 032;
             02: Result := 048;
             03: Result := 056;
             04: Result := 064;
             05: Result := 080;
             06: Result := 096;
             07: Result := 112;
             08: Result := 128;
             09: Result := 144;
             10: Result := 160;
             11: Result := 176;
             12: Result := 192;
             13: Result := 224;
             14: Result := 256;
           end;
         $02, $03:
           case hBitrate of
             01: Result := 008;
             02: Result := 016;
             03: Result := 024;
             04: Result := 032;
             05: Result := 040;
             06: Result := 048;
             07: Result := 056;
             08: Result := 064;
             09: Result := 080;
             10: Result := 096;
             11: Result := 112;
             12: Result := 128;
             13: Result := 144;
             14: Result := 160;
           end;
       end;
   end;
 end;

 function MakeSampleRate(hVersion, hSampleRate: Longint): Longint;
 begin
   Result := 0;
   case hVersion of
     $10:
       case hSampleRate of
         0: Result := 44100;
         1: Result := 48000;
         2: Result := 32000;
       end;
     $20:
       case hSampleRate of
         0: Result := 22050;
         1: Result := 24000;
         2: Result := 16000;
       end;
     $25:
       case hSampleRate of
         0: Result := 11025;
         1: Result := 12000;
         2: Result := 08000;
       end;
   end;
 end;

begin
  if not IsThereATag(stream) then
    noTag := true
  else
    noTag := false;

  stream^.Seek(0);
  stream^.Read(localHeader, SizeOf(localHeader));

  stream^.Seek(stream^.GetSize - SizeOf(oldTag));
  stream^.Read(oldTag, SizeOf(oldTag));

  // check for RIFF :-E~~

  if (localHeader[1] = Byte('R')) and
    (localHeader[2] = Byte('I')) and
    (localHeader[3] = Byte('F')) and
    (localHeader[4] = Byte('F')) then
  begin // RIFF processing
    stream^.Seek(4);
    tag.isMpeg := false;
    while (not tag.isMpeg) and (stream^.GetPos <= headerSearchRange) do
    begin
      stream^.Read(localHeader, SizeOf(localHeader));
      line := '';
      for i := 1 to 4 do
      begin
        line := line + BinaryB(localHeader[i]);
      end;
      tag.isMpeg := Bin2Long(Copy(line, 1, 11)) = $7ff;
      if not tag.isMpeg then
        stream^.Seek(stream^.GetPos - 3);
    end;
    tag.RiffHeaderSize := stream^.GetPos - 3;
  end
  else
  begin
    tag.RiffHeaderSize := 0;
  end;

  FillChar(tag, SizeOf(tag), 0);

  with tag do
  begin

    Size := stream^.GetSize;

    SetLength(line, 0); // aka line := '';

    for i := 1 to 4 do
    begin
      line := line + BinaryB(localHeader[i]);
    end;

    hProtected := line[16] = '0';
    hCopyrighted := line[29] = '1';
    hOriginal := line[30] = '1';

    case Bin2Long(line[12] + line[13]) of
      0: hMPEGVersion := $25;
      1: hMPEGVersion := $ff;
      2: hMPEGVersion := $20;
      3: hMPEGVersion := $10;
    end;

    case Bin2Long(line[14] + line[15]) of
      0: hLayer := $ff;
      1: hLayer := $03;
      2: hLayer := $02;
      3: hLayer := $01;
    end;

    hBitrate := MakeBitrate(hMPEGVersion, hLayer,
      Bin2Long(line[17] + line[18] + line[19] + line[20]));

    hSampleRate := MakeSampleRate(hMPEGVersion,
      Bin2Long(line[21] + line[22]));

    case Bin2Long(line[25] + line[26]) of
      0: hMode := cmStereo;
      1: hMode := cmJointStereo;
      2: hMode := cmDualChannel;
      3: hMode := cmSingleChannel;
    end;

    isMpeg := Bin2Long(Copy(line, 1, 11)) = $7ff;

    tagExists := not noTag;
    if noTag then
      Exit;

    Songname := StrPas(PChar(@oldTag.Songname));
    Artist := StrPas(PChar(@oldTag.Artist));
    Album := StrPas(PChar(@oldTag.Album));
    Year := StrPas(PChar(@oldTag.Year));
    Comment := StrPas(PChar(@oldTag.Comment));
    Genre := oldTag.Genre;
    // vp was designed marazmatically ;-)
    Songname := Trim(Songname);
    Artist := Trim(Artist);
    Album := Trim(Album);
    Year := Trim(Year);
    Comment := Trim(Comment);

    if Length(Songname) = 0 then
      Songname := '?';
    if Length(Artist) = 0 then
      Artist := '?';
    if Length(Album) = 0 then
      Album := '?';
    if Length(Year) = 0 then
      Year := '?';
    if Length(Comment) = 0 then
      Comment := '?';

  end;

end;

procedure TTagData.WriteTag;
var
  buf30: array[1..30] of Char;
  buf3: array[1..3] of Char;
  buf4: array[1..4] of Char;
  status: Integer;
begin
  FillChar(oldTag, SizeOf(oldTag), 00);
  with tag do
  begin
    StrPCopy(PChar(@oldTag.Tag), 'TAG');
    StrPCopy(PChar(@oldTag.Songname), Songname);
    StrPCopy(PChar(@oldTag.Artist), Artist);
    StrPCopy(PChar(@oldTag.Album), Album);
    StrPCopy(PChar(@oldTag.Year), Year);
    StrPCopy(PChar(@oldTag.Comment), Comment);
    oldTag.Genre := Genre;
  end;
  if IsThereATag(stream) then
    stream^.Seek(stream^.GetSize - 128)
  else
    stream^.Seek(stream^.GetSize);
  stream^.Write(oldTag, SizeOf(oldTag));
  status := stream^.Status;
end;

end.
