
= [ abstract ] ===========================================================

MPEG Searcher

        this small program will find MPEGs for you using  specified  path,
 will edit tags by the way, and will write the resulting list of MPEGs ac-
 cording to templates.

        there is no much features, but they are planned ;-)

        in  that  program  I implemented things that were needed by me, so
 you'll  find  there  two-items sort (there will be three-items sort) that
 sometimes is great thing.

= [ license info ] =======================================================

        common  license principle is AS IS. by using this software, you're
 automatically agreeing this license.

        1)  the  author  will  not answer to any damages of your hardware,
 since no destruction code were used. you can verify that by viewing sour-
 ce code that distributed with that program.

        2)  you  can  freely use and distribute that software without com-
 mercial income, you can not modify original archive and files that it co-
 ntains. if you modify the program, you must point to these modifications.

        3)  you can freely use the fragments of source code and algorithms
 that  were  used without mentioning the author, if your resulting program
 is  not commercial, otherwise you must receive the author's agreement and
 you must mention author by adding 'Portions Copyright (pc) 199 by Alexan-
 der Trunov [2:5069/10, jnc@mail.ru]'.

= [ templates ] ==========================================================

        in  some  cases  it is possible to use the templates, according to
 them MPEG Searcher will generate resulting file.

        there  is  two  cases  when that is possible: "whole" template and
 "by" template.

        "by"  template  is  needed to divide resulting report into several
 groups.  following is the example of the report, that was generated using
 "by" template.

= [ cut ] ================================================================

= [ abstract ] ===========================================================

                             grouped list of mp3s

                       generated at 1999/12/12 21:19:56

= [ list ] ===============================================================

= [ Chris Norman ] =======================================================

s0807.mp3     3,029kb  Chris Norman - Baby Don't Change (03:41)
s0803.mp3     2,872kb  Chris Norman - Baby I Miss You (03:30)
[...]

= [ total 27 mpegs, 90,836kb ] ===========================================

= [ Chris Rea ] ==========================================================

s0410.mp3     4,057kb  Chris Rea - 'Disco' La Passione (04:56)
s0402.mp3     4,974kb  Chris Rea - (Film Theme) Dov'e Il Signore (06:03)
[...]

= [ total 47 mpegs, 180,870kb ] ==========================================

= [ Chris de Burgh ] =====================================================

s0113.mp3     2,819kb  Chris de Burgh - A Rainy Night In Paris (03:26)
s0107.mp3     4,158kb  Chris de Burgh - A Spaceman Game Travelling (05:04)
[...]

= [ total 43 mpegs, 145,649kb ] ==========================================

= [ Gary Moore ] =========================================================

s0608.mp3     5,495kb  Gary Moore - Afraid Of Tomorrow (06:41)
s0201.mp3     3,187kb  Gary Moore - Always Gonna Love You (03:53)
[...]

= [ total 24 mpegs, 113,430kb ] ==========================================

= [ totals ] =============================================================

                       total listed 141 mpegs, 530,785kb

= [ cut ] ================================================================


        the  division  type  must be choosed before the generation. in the
 dialog  first column is the division method, and the second column - sor-
 ting method of resulted groups. in the example that was mentioned, in the
 first column was "Artist", in the second - "Title".

        "whole"  template is composed in three files, as described in con-
 figuration file:

        .hdr
        .inf
        .inf
        [....]
        .ftr

        .inf-file is used on each MPEG-file

        "by" template is composed in five files, as also described in con-
 figuration file:

        .hdr
        .shd
        .inf
        .inf
        [...]
        .sft
        .shd
        .inf
        .inf
        [...]
        .sft
        [...]
        .ftr

        .shd and .sft files are used on each group
        .inf file is used on each MPEG

        in each template you can use the following macros:
 @curhour/@curmin/@cursec - current time;
 @curday/@curmonth/@curyear/@curdow/@curshortdow - current time.

        in .shd you can use:
  @artist,  @title, @album, @comment, @year - from MPEG's tag ('?' symbols
 are used when the tag item empty);
  @mpegversion,  @bitrate,  @samplerate, @layer, @mode (joint-stereo, dual
 channel, etc), @playtimesec, @playtimemin, @size (size of mpegfile), @fi-
 lename (filename of mpeg) of *first* MPEG of the whole group.

        in .inf you can use the same macros as in .shd

        in .sft you can use:
  @subsize  (size  of  all  MPEGs in group), @subnum (quantity of MPEGs ingroup)

        in .ftr you can use:
  @totsize, @totnum in analogy to @subsize and @subnum

= [ source code info ] ===================================================

        this  stuff  is  compiled  by  Virtual  Pascal  2.0  release (rule
 thing!!)     with     DPMI32     addition     by     Veit     Kannegieser
 (Veit.Kannegieser@gmx.de).  I think, it can be easily compiled with anot-
 her compiler, such as BP or FPC.

= [ contact info ] =======================================================

        Alexander Trunov,
          FIDO: 2:5069/10
          Internet: jnc@mail.ru

        new  versions  you  can get at: (russian page, see in the download
 section)
        http://jnc.newmail.ru/mp3srch.htm

        for  problems  that  seems to related to MPEG Searcher please send
 mail to adresses at the top of section. please include:
        * how can the problem recreated ?
        * screen dumps or logfiles
        * etc