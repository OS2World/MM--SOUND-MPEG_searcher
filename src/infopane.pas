unit InfoPane;

interface

uses
  Objects, Dialogs, Views, ID3v1;

type
  PMpegInfo = ^TMpegInfo;
  TMpegInfo = object(TDialog)
    constructor Init(tag: PjID3v1); // nothing would be freed
  end;

implementation

uses
  Macroz, MacrozTV, Reports, Wizard;

constructor TMpegInfo.Init(tag: PjID3v1);
var
  R: TRect;
  mc: PMacrosEngine;
  tempLong: Longint;
  ptMin, ptSec: string;
begin
  R.Assign(0, 0, 46, 15);
  inherited Init(R, 'Info pane');

  Options := Options or ofCentered;

  mc := New(PMacrosEngine, Init);
  MakeStandardMacros(tag, mc, tempLong, '');

  R.Assign(2, 2, 44, 3);
  Insert(New(PStaticText, Init(R, mc^.Process('Title     ³ @title'))));

  R.Assign(2, 3, 44, 4);
  Insert(New(PStaticText, Init(R, mc^.Process('Artist    ³ @artist'))));

  R.Assign(2, 4, 44, 5);
  Insert(New(PStaticText, Init(R, mc^.Process('Album     ³ @album'))));

  R.Assign(2, 5, 44, 6);
  Insert(New(PStaticText, Init(R, mc^.Process('Comment   ³ @comment'))));

  R.Assign(2, 6, 44, 7);
  Insert(New(PStaticText, Init(R, mc^.Process('Year      ³ @year'))));

  R.Assign(2, 7, 44, 8);
  Insert(New(PStaticText, Init(R, mc^.Process('MPEG ver  ³ @mpegversion'))));

  R.Assign(2, 8, 44, 9);
  Insert(New(PStaticText, Init(R, mc^.Process('Layer     ³ @layer'))));

  R.Assign(2, 9, 44, 10);
  Insert(New(PStaticText, Init(R, mc^.Process('Bitrate   ³ @bitrate'))));

  R.Assign(2, 10, 44, 11);
  Insert(New(PStaticText, Init(R, mc^.Process('Smp. rate ³ @samplerate'))));

  R.Assign(2, 11, 44, 12);
  Insert(New(PStaticText, Init(R, mc^.Process('Mode      ³ @mode'))));

  ptMin := LeftPadCh(mc^.Process('@playtimemin'), '0', 2);
  ptSec := LeftPadCh(mc^.Process('@playtimesec'), '0', 2);

  R.Assign(2, 12, 44, 13);
  Insert(New(PStaticText, Init(R, mc^.Process(Concat('Play time ³ ', ptMin,
    ':', ptSec)))));

  Dispose(mc, Done);
end;

end.
