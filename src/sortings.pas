(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit Sortings;

interface

uses
  ID3v1, Objects, mp3lb;

type
  TFNGetTag = function(FN: string): PjID3v1;
  TSepFactor = (faAlbum, faArtist, faTitle, faComment, faYear);

function SeparateCollection(factor: TSepFactor;
  coll: PCollection; GetTag: TFNGetTag): PCollection;

implementation

function SeparateCollection(factor: TSepFactor;
  coll: PCollection; GetTag: TFNGetTag): PCollection;
var
  rColl: PCollection;
  subColl: PStringCollection;
  i: Integer;
  firstItem, FN, Item: string;
  tag: PjID3v1;
begin
  Result := nil;
  rColl := New(PCollection, Init(10, 10));

  while coll^.Count > 0 do
  begin

    subColl := New(PStringCollection, Init(10, 10));

    i := 0;
    firstItem := '1234567890123456789012345678901234567890';
    //  needed tag item will never equal that line
    // since the length of it will be always not greater than 30 bytes
    // o kak zagnul ;)
    while i < coll^.Count do
    begin
      FN := Pmp3(coll^.Items^[i])^.Filename;
      tag := GetTag(FN);
      case factor of
        faAlbum: Item := tag^.Album;
        faArtist: Item := tag^.Artist;
        faTitle: Item := tag^.Songname;
        faComment: Item := tag^.Comment;
        faYear: Item := tag^.Year;
      end;
      if firstItem = '1234567890123456789012345678901234567890' then
      begin
        firstItem := Item;
        subColl^.Insert(coll^.Items^[i]);
        coll^.AtDelete(i);
        FreeMem(tag, SizeOf(tag^));
        Continue;
      end;
      if Item = firstItem then
      begin
        subColl^.Insert(coll^.Items^[i]);
        coll^.AtDelete(i);
        FreeMem(tag, SizeOf(tag^));
        Continue;
      end;

      FreeMem(tag, SizeOf(tag^));
      inc(i);
    end;

    rColl^.Insert(subColl);

  end;

  Result := rColl;

end;

end.
