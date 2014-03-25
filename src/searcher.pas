(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit Searcher;

interface

{$IFNDEF virtualpascal}
  {$IFNDEF fpc}
    {$DEFINE bp}
  {$ENDIF}
{$ENDIF}

uses
  Objects;

type

  TSearchProc = procedure(FoundFilename: string);

  PSearcher = ^TSearcher;
  TSearcher = object(TObject)
    { must be filled before searching (BeginningPath must be backslashed) }
    EnumProc: TSearchProc;
    Mask, BeginningPath: string;

    procedure BeginSearch;

  end;

implementation

uses DOS;

{$IFDEF bp}

procedure FindClose(var SR: SearchRec);
begin

end;
{$ENDIF}

procedure TSearcher.BeginSearch;

  procedure SearchHere(Where: string);
  var
    SR: SearchRec;
  begin

    FindFirst(Where + '*.*', Directory, SR);
    while DOSError = 0 do
    begin
      if (SR.Name <> '..') and (SR.Name <> '.') then
        SearchHere(Where + SR.Name + '\');
      FindNext(SR);
    end;
    FindClose(SR);

    FindFirst(Where + Mask, AnyFile - Directory - VolumeID - SysFile, SR);
    while DOSError = 0 do
    begin
      EnumProc(Where + SR.Name);
      FindNext(SR);
    end;
    FindClose(SR);

  end;

begin
  SearchHere(BeginningPath);
end;

end.