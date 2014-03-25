(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

{$ifndef fpc}

// these functions are under copyright of FreePascal development team

function ExtractFileName(AFile: FNameStr): NameStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(AFile, D, N, E);
  ExtractFileName := N;
end;

function ExtractFileExt(AFile: FNameStr): NameStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(AFile, D, N, E);
  ExtractFileExt := E;
end;

function TrimmedName(const Name: String; Limit: Byte): String;
var
  B, E, L: Integer;
  S: String;
begin
  L := Length(Name);
  if L <= Limit then TrimmedName := Name
  else
  begin
    B := 1;
    while (B < L) and (Name[B] <> '\') do Inc(B);
    while (B < L) and (Name[B] =  '\') do Inc(B);
    E := B;
    while (E < L) and (L - (E - B) + 3 > Limit) do Inc(E);
    while (E < L) and (Name[E] <> '\') do Inc(E);
    if Name[E] = '\' then
    begin
      S := Name;
      Delete(S, B, E - B);
      Insert('...', S, B);
    end
    else S := ExtractFileName(Name) + ExtractFileExt(Name);
    if Length(S) > Limit then S[0] := Char(Limit);
    TrimmedName := S;
  end;
end;


function ShrinkPath(AFile: FNameStr; MaxLen: Byte): FNameStr;
begin
  Result := TrimmedName(AFile, MaxLen);
end;
{
var
  D1: DirStr;
  N1: NameStr;
  E1: ExtStr;
  i: Longint;
begin
  if Length(AFile) > MaxLen then
  begin
    FSplit(FExpand(AFile), D1, N1, E1);
    AFile := Copy(D1, 1, 3) + '..' + '\';
    i := Pred(Length(D1));
    while (i > 0) and (D1[i] <> '\') do
      Dec(i);
    if (i = 0) then
      AFile := AFile + D1
    else AFile := AFile + Copy(D1, Succ(i), Length(D1) - i);
    if AFile[Length(AFile)] <> '\' then
      AFile := AFile + '\';
    AFile := AFile + N1 + E1;
  end;
  ShrinkPath := AFile;
end;
}

function FileExists (AFile : FNameStr) : Boolean;
begin
  FileExists := (FSearch(AFile,'') <> '');
end;

function OpenFile (var AFile : FNameStr; HistoryID : Byte) : Boolean;
var
  Dlg : PFileDialog;
begin
  Dlg := New(PFileDialog,Init('*.*', 'Open a file..','~N~ame',
        fdOkButton, 0));
  PHistory(Dlg^.FileName^.Next^.Next)^.HistoryID := HistoryID;
  OpenFile := (Application^.ExecuteDialog(Dlg, @AFile) = cmFileOpen);
end;

function SelectDir(var ADir: DirStr; HistoryID: Byte): Boolean;
var
  Dir, Rec: DirStr;
  Dlg: PEditChDirDialog;
begin
  {$I-}
  GetDir(0, Dir);
  {$I+}
  Rec := FExpand(Dir);
  Dlg := New(PEditChDirDialog, Init(0, HistoryID));
  if (Application^.ExecuteDialog(Dlg, @Rec) = cmOk) then
  begin
    SelectDir := True;
    ADir := Rec;
  end
  else SelectDir := False;
end;

type
  PStringRec = record
    AString : PString;
  end;

function ReplaceFileQuery(AFile: FNameStr): Boolean;
var
  Rec: PStringRec;
begin
  AFile := ShrinkPath(AFile, 33);
  Rec.AString := PString(@AFile);
  ReplaceFileQuery :=
     (MsgBox.MessageBox(#3'Replace file?'#13#10#13#3'%s',
       @Rec, mfConfirmation or mfOkCancel) = cmOk);
end;

function SaveAs(var AFile: FNameStr; HistoryID: Word): Boolean;
var
  Dlg: PFileDialog;
begin
  SaveAs := False;
  Dlg := New(PFileDialog, Init('*.*', 'Save As', 'S~a~ve as...',
        fdOkButton or fdHelpButton, 0));
  PHistory(Dlg^.FileName^.Next^.Next)^.HistoryID := HistoryID;
  Dlg^.HelpCtx := hcSaveAs;
  if (Application^.ExecuteDialog(Dlg, @AFile) = cmFileOpen) and
     ((not FileExists(AFile)) or ReplaceFileQuery(AFile)) then
    SaveAs := True;
end;

function ExtractDir(AFile: FNameStr): DirStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(AFile, D, N, E);
  if D = '' then
  begin
    ExtractDir := '';
    Exit;
  end;
  if D[Byte(D[0])] <> '\' then
    D := D + '\';
  ExtractDir := D;
end;

{$endif}

function IntToStr (L: Longint): string;
var
  S: string;
begin
  Str(L, S);
  IntToStr := S;
end;
