(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

{
// -----------------------------------
// Field      | Length    | Offsets
// -----------+-----------+-----------
// Tag        |3          |0-2
// -----------+-----------+-----------
// Songname   |30         |3-32
// -----------+-----------+-----------
// Artist     |30         |33-62
// -----------+-----------+-----------
// Album      |30         |63-92
// -----------+-----------+-----------
// Year       |4          |93-96
// -----------+-----------+-----------
// Comment    |30         |97-126
// -----------+-----------+-----------
// Genre      |1          |127
// -----------------------------------
}
type
  TID3v1 = packed record
    Tag: array [1..3] of Char;
    Songname,
      Artist,
      Album: array [1..30] of Char;
    Year: array [1..4] of Char;
    Comment: array [1..30] of Char;
    Genre: Byte;
  end;