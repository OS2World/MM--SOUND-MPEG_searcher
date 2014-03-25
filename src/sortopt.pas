(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit SortOpt;

interface

uses
  Objects, Dialogs, Views, Drivers
  {$IFDEF fpc}, Commands {$ENDIF}
  ;

type
  PSortOptions = ^TSortOptions;
  TSortOptions = object(TDialog)
    rdoOption: PRadioButtons;
    constructor Init;
    procedure GetData(var R); virtual;
    procedure SetData(var R); virtual;
    function DataSize: Longint; virtual;
  end;

implementation

constructor TSortOptions.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 13);
  inherited Init(R, 'Sorting options');

  Options := Options or ofCentered;

  R.Assign(2, 1, 48, 2);
  Insert(New(PStaticText, Init(R, ^C + 'Sort by:')));

  R.Assign(2, 3, 48, 9);
  rdoOption := New(PRadioButtons, Init(R,
    NewSItem('~p~ath + filename',
    NewSItem('~f~ilename',
    NewSItem('o~n~e item sort',
    NewSItem('~t~wo items sort',
    NewSItem('~r~andom', nil)))))));
  Insert(rdoOption);

  R.Assign(36, 10, 48, 12);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, 0)));

  R.Assign(25, 10, 35, 12);
  Insert(New(PButton, Init(R, 'S~o~rt', cmOk, bfDefault)));

  rdoOption^.Select;

end;

procedure TSortOptions.GetData(var R);
begin
  Integer(R) := rdoOption^.Sel;
end;

procedure TSortOptions.SetData(var R);
begin
  rdoOption^.Press(Integer(R));
end;

function TSortOptions.DataSize: Longint;
begin
  DataSize := SizeOf(Integer);
end;

end.
