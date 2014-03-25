(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit MP3Opt;

interface

uses
  Objects, Dialogs, Views, Drivers
  {$IFDEF fpc}, Commands{$ENDIF}
  ;

type
  PMP3Options = ^TMP3Options;
  TMP3Options = object(TDialog)
    rdoOption: PRadioButtons;
    constructor Init;
    procedure GetData(var R); virtual;
    procedure SetData(var R); virtual;
    function DataSize: Longint; virtual;
  end;

implementation

constructor TMP3Options.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 11);
  inherited Init(R, 'Playlist generating options');

  Options := Options or ofCentered;

  R.Assign(2, 1, 48, 2);
  Insert(New(PStaticText, Init(R, ^C' Choose an option: ')));

    R.Assign(2, 3, 48, 7);
    rdoOption := New(PRadioButtons, Init(R, NewSItem('~I~nternet-playlist (M3U)',
    NewSItem('~f~iles.bbs',
    NewSItem('~W~hole list',
    NewSItem('~T~wo-items separated list', nil))))));
    Insert(rdoOption);

    R.Assign(36, 8, 48, 10);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, 0)));

    R.Assign(21, 8, 35, 10);
    Insert(New(PButton, Init(R, '~G~enerate', cmOk, bfDefault)));

    rdoOption^.Select;

end;

function TMP3Options.DataSize: Longint;
begin
  DataSize := SizeOf(Integer);
end;

procedure TMP3Options.GetData(var R);
begin
  Integer(R) := rdoOption^.Sel;
end;

procedure TMP3Options.SetData(var R);
begin
  rdoOption^.Press(Integer(R));
end;

end.
