(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit SortType;

interface

{&Use32+}

uses
  Objects, Views, App, Dialogs, Sortings;

type

  TTwoItemsRec = record
    firstFactor, secondFactor: TSepFactor;
  end;

  POneItemDialog = ^TOneItemDialog;
  TOneItemDialog = object(TDialog)
    rdoOption: PRadioButtons;
    constructor Init;
    procedure GetData(var R); virtual;
    function DataSize: Integer; virtual;
    procedure SetData(var R); virtual;
  end;

  PTwoItemsDialog = ^TTwoItemsDialog;
  TTwoItemsDialog = object(TDialog)
    rdoFirstOption, rdoSecondOption: PRadioButtons;
    constructor Init(theCaption: string);
    procedure GetData(var R); virtual;
    function DataSize: Integer; virtual;
    procedure SetData(var R); virtual;
  end;

  PTemplateDialog = ^TTemplateDialog;
  TTemplateDialog = object(TDialog)
    lstList: PListBox;
    constructor Init(templates: PStringCollection);
    destructor Done; virtual;
    procedure GetData(var R); virtual;
    function DataSize: Integer; virtual;
    procedure SetData(var R); virtual;
  end;

implementation

procedure TTemplateDialog.GetData(var R);
begin
  Byte(R) := lstList^.Focused;
end;

function TTemplateDialog.DataSize: Integer;
begin
  Result := SizeOf(Byte);
end;

procedure TTemplateDialog.SetData(var R);
begin
  lstList^.FocusItem(Byte(R));
end;

constructor TTemplateDialog.Init(templates: PStringCollection);
var
  R: TRect;
  i: Integer;
begin
  R.Assign(0, 0, 31, 9);
  inherited Init(R, 'Choose a template');

  Options := Options or ofCentered;

  R.Assign(2, 2, 16, 7);
  lstList := New(PListBox, Init(R, 1, nil));
  Insert(lstList);
  lstList^.NewList(New(PStringCollection, Init(10, 10)));

  for i := 0 to templates^.Count - 1 do
  begin
    lstList^.List^.AtInsert(lstList^.List^.Count,
      NewStr(PString(templates^.Items^[i])^));
  end;

  lstList^.SetRange(lstList^.List^.Count);

  R.Assign(17, 2, 29, 4);
  Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));

  R.Assign(17, 5, 29, 7);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, 0)));

  lstList^.Select;
end;

destructor TTemplateDialog.Done;
begin
  lstList^.NewList(nil);
  inherited Done;
end;

constructor TTwoItemsDialog.Init(theCaption: string);
var
  R: TRect;
begin
  R.Assign(0, 0, 46, 10);
  inherited Init(R, theCaption);

  Options := Options or ofCentered;

  R.Assign(2, 3, 16, 8);
  rdoFirstOption := New(PRadioButtons, Init(R,
    NewSItem('~a~rtist',
    NewSItem('~t~itle',
    NewSItem('a~l~bum',
    NewSItem('c~o~mment',
    NewSItem('~y~ear', nil)))))));
  Insert(rdoFirstOption);

  R.Assign(2, 2, 16, 3);
  Insert(New(PLabel, Init(R, '~F~irst:', rdoFirstOption)));

  R.Assign(17, 3, 31, 8);
  rdoSecondOption := New(PRadioButtons, Init(R,
    NewSItem('a~r~tist',
    NewSItem('t~i~tle',
    NewSItem('al~b~um',
    NewSItem('co~m~ment',
    NewSItem('y~e~ar', nil)))))));
  Insert(rdoSecondOption);

  R.Assign(17, 2, 31, 3);
  Insert(New(PLabel, Init(R, '~S~econd:', rdoSecondOption)));

  R.Assign(32, 3, 44, 5);
  Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));

  R.Assign(32, 6, 44, 8);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, 0)));

  rdoFirstOption^.Select;
end;

procedure TTwoItemsDialog.GetData(var R);
begin
  case rdoFirstOption^.Value of
    0: TTwoItemsRec(R).firstFactor := faArtist;
    1: TTwoItemsRec(R).firstFactor := faTitle;
    2: TTwoItemsRec(R).firstFactor := faAlbum;
    3: TTwoItemsRec(R).firstFactor := faComment;
    4: TTwoItemsRec(R).firstFactor := faYear;
  end;
  case rdoSecondOption^.Value of
    0: TTwoItemsRec(R).secondFactor := faArtist;
    1: TTwoItemsRec(R).secondFactor := faTitle;
    2: TTwoItemsRec(R).secondFactor := faAlbum;
    3: TTwoItemsRec(R).secondFactor := faComment;
    4: TTwoItemsRec(R).secondFactor := faYear;
  end;
end;

function TTwoItemsDialog.DataSize: Longint;
begin
  Result := SizeOf(TTwoItemsRec);
end;

procedure TTwoItemsDialog.SetData(var R);
begin
  rdoSecondOption^.Select;
  case TTwoItemsRec(R).secondFactor of
    faArtist: rdoSecondOption^.Press(0);
    faTitle: rdoSecondOption^.Press(1);
    faAlbum: rdoSecondOption^.Press(2);
    faComment: rdoSecondOption^.Press(3);
    faYear: rdoSecondOption^.Press(4);
  end;
  rdoFirstOption^.Select;
  case TTwoItemsRec(R).firstFactor of
    faArtist: rdoFirstOption^.Press(0);
    faTitle: rdoFirstOption^.Press(1);
    faAlbum: rdoFirstOption^.Press(2);
    faComment: rdoFirstOption^.Press(3);
    faYear: rdoFirstOption^.Press(4);
  end;
end;

constructor TOneItemDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 31, 9);
  inherited Init(R, 'One item sort options');

  Options := Options or ofCentered;

  R.Assign(2, 2, 16, 7);
  rdoOption := New(PRadioButtons, Init(R,
    NewSItem('~a~rtist',
    NewSItem('~t~itle',
    NewSItem('a~l~bum',
    NewSItem('c~o~mment',
    NewSItem('~y~ear', nil)))))));
  Insert(rdoOption);

  R.Assign(17, 2, 29, 4);
  Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));

  R.Assign(17, 5, 29, 7);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, 0)));

  rdoOption^.Select;
end;

procedure TOneItemDialog.GetData(var R);
begin
  case rdoOption^.Value of
    0: TSepFactor(R) := faArtist;
    1: TSepFactor(R) := faTitle;
    2: TSepFactor(R) := faAlbum;
    3: TSepFactor(R) := faComment;
    4: TSepFactor(R) := faYear;
  end;
end;

function TOneItemDialog.DataSize: Integer;
begin
  Result := SizeOf(TSepFactor);
end;

procedure TOneItemDialog.SetData(var R);
begin
  case TSepFactor(R) of
    faArtist: rdoOption^.Press(0);
    faTitle: rdoOption^.Press(1);
    faAlbum: rdoOption^.Press(2);
    faComment: rdoOption^.Press(3);
    faYear: rdoOption^.Press(4);
  end;
  Redraw;
end;

end.
