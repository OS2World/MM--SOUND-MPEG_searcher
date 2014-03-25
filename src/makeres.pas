(*
 * making a resource file with genres
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

uses Objects, DOS;

var
  res: PResourceFile;
  coll: PStringCollection;
  stream: PDosStream;
  oldSize: Longint;

{.$define exe}

procedure MakeGenres;
var
  src: Text;
  S: string;
begin
  Assign (src, 'genres.lst');
  Reset (src);

  while not EOF (src) do
  begin
    Readln (src, S);
    if Length (S) > 0 then
      coll^.AtInsert (coll^.Count, NewStr (S));
  end;

  Close (src);
end;

function FileExists (AFile: FNameStr): Boolean;
begin
  FileExists := FSearch (AFile,'') <> '';
end;

begin
  if not FileExists ('genres.lst') then
    Halt (254);

  RegisterObjects;
{$ifdef exe}
  stream := New (PDosStream, Init ('tagger.exe', stOpen));
  stream^.Seek (stream^.GetSize);
{$else}
  stream := New (PDosStream, Init ('tagger.res', stCreate));
{$endif}

  if stream^.Status <> stOk then
  begin
    Writeln ('An error occured while trying to open resource-file.');
    Writeln ('Therefore, I am exiting...');
    Dispose (stream, Done);
    Halt (253);
  end;

  oldSize := stream^.GetSize;

  res := New (PResourceFile, Init (stream));
  coll := New (PStringCollection, Init (127, 10));

  MakeGenres;

  res^.Put (coll, 'genres');
  res^.Flush;

  Writeln ('actual size of resource was ', res^.Stream^.GetSize - oldSize, ' bytes');
  Writeln ('this is important once you decided to change the genre-list, heh');

  Dispose (coll, Done);
  Dispose (res, Done);

  Writeln ('resources successfully created..');

end.