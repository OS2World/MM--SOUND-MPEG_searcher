(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit EditChD;

{ the source code below comed from FreeVision package }

interface

uses
  StdDlg, DOS;

{$IFNDEF virtualpascal}
  {$IFNDEF fpc}
    {$DEFINE bp}
  {$ENDIF}
{$ENDIF}

type
  PEditChDirDialog = ^TEditChDirDialog;
  TEditChDirDialog = object(TChDirDialog)
    function DataSize: {$IFNDEF bp}Longint{$ELSE}Word{$ENDIF}; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
  end;

implementation

function TEditChDirDialog.DataSize: {$IFNDEF bp}Longint{$ELSE}Word{$ENDIF};
begin
  DataSize := SizeOf(DirStr);
end;

procedure TEditChDirDialog.GetData(var Rec);
var
  CurDir: DirStr absolute Rec;
begin
  if (DirInput = nil) then
    CurDir := ''
  else
  begin
    CurDir := DirInput^.Data^;
    if (CurDir[Length(CurDir)] <> '\') then
      CurDir := CurDir + '\';
  end;
end;

procedure TEditChDirDialog.SetData(var Rec);
var
  CurDir: DirStr absolute Rec;
begin
  if DirList <> nil then
  begin
    DirList^.NewDirectory(CurDir);
    if DirInput <> nil then
    begin
      if (Length(CurDir) > 3) and (CurDir[Length(CurDir)] = '\') then
        DirInput^.Data^ := Copy(CurDir, 1, Length(CurDir) - 1)
      else
        DirInput^.Data^ := CurDir;
      DirInput^.DrawView;
    end;
  end;
end;

end.