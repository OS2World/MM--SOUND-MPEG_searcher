(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit StatusW;

interface

uses Drivers, Dialogs, Views;

type
  PStatusWindow = ^TStatusWindow;
  TStatusWindow = object(TDialog)
    ALabel: PStaticText;
    constructor Init(AMessage: string);
  end;

implementation

uses Objects;

constructor TStatusWindow.Init(AMessage: string);
var
  R: TRect;
begin
  R.Assign(1, 1, Length(AMessage) + 5, 6);
  inherited Init(R, '');
  Options := Options or ofCentered;

  R.Assign(2, 2, R.B.X - 3, 3);
  ALabel := New(PStaticText, Init(R, AMessage));
  Insert(ALabel);
end;

end.