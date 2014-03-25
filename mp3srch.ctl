
; = [ abstract ] ============================================================
;

; MPEG Searcher configuration file
; copyright (c) 1999 by Alexander Trunov
;  FIDO: 2:5069/10
;  Internet: jnc@mail.ru
;  homepage: http://jnc.newmail.ru/mp3srch.htm
;

; see documentation for more information (the documentation is available
;  only in Russian yet, sorry)
;

; on some keywords the "pool" syntax can be used (see below for these
;  keywords)
; pool syntax is composed with keyword, action-keyword and value
;
; action-keyword must contain only these words (and actions
;  associated with them):
;
;  Replace  -  clears pool and adds the <value> in pool
;  Add  -  adds the value in pool
;  ReplaceFile  -  clears pool and adds all the strings situated
;   in <value>-file
;  AddFile  -  adds all the strings situated in <value>-file
;  Kill  -  clears the pool
;
; the first action-keyword always must be Replace
; if the action-keyword is AddFile/ReplaceFile, the file must not contain
;  empty lines
;
; examples:
;  templates.by Replace byart1 - pool would be cleared and added "byart1"
;   value
;  templates.by Add byart2 - in pool will be added "byart2" value
;  templates.by Kill - pool would be cleared
;  templates.by AddFile BY - all the strings that contain BY textfile will be
;   inserted into the pool
;

; = [ templates ] ===========================================================
;

  templates.by Replace .\tpl\byart1     ; "by" templates must be formed in
  templates.by Add .\tpl\byalb1         ; five files: *.hdr, *.shd, *.inf,
  templates.by Add .\tpl\byalbhtm       ; *.sft, *.ftr
                                        ;

  templates.whole Replace .\tpl\whole1  ; "whole" templates must be formed in
  templates.whole Add .\tpl\whole2      ; three files: *.hdr, *.inf, *.ftr
  templates.whole Add .\tpl\wholehtm    ;

  templates.macro.layer.I I             ; @layer substitutions
  templates.macro.layer.II II
  templates.macro.layer.III III
  templates.macro.layer.unknown unk

  templates.macro.channelmode.stereo stereo             ; @mode substitutions
  templates.macro.channelmode.jointstereo joint stereo
  templates.macro.channelmode.dualchannel dual channel
  templates.macro.channelmode.singlechannel mono
; templates.macro.channelmode.singlechannel single channel

  templates.macro.mpegversion.1.0 1.0   ; @mpegversion substitutions
  templates.macro.mpegversion.2.0 2.0
  templates.macro.mpegversion.2.5 2.5
  templates.macro.mpegversion.unknown unk

  templates.macro.shortfilenames yes    ; if this options is set to 'yes',
                                        ; each long filename in will be
                                        ; shortenized using standard
                                        ; WinAPI function 'GetShortPathName'
                                        ;
                                        ; this option is applicable only to
                                        ; Win32 version of MPEG Searcher

; = [ MPEGs search stuff ] ==================================================
;

  search.mask Replace *.mp?             ; MPEG Searcher will search MPEGs
  search.mask Add *.wav                 ; using these masks
                                        ;
                                        ; note that this is not standard DOS
                                        ; filemasks, for example '*QuQu' mask
                                        ; will be applicable to 'BeBeQuQu'
                                        ; file and 'QuQu' file
                                        ;
                                        ; default value is *.mp?

  search.exclude Replace *.mpl          ; MPEG Searcher will exclude from
  search.exclude Add *.mpp              ; list files with these filemasks
; search.exclude Add *~* ; fuck windoze

; search.excludepath Replace *~* ; fuck windoze again ;-)
                                        ; MPEG Searcher will exclude from
                                        ; list files that situated in
                                        ; directories (folders) with this
                                        ; mask

  search.exclude.nonmpegs yes           ; exclude non-MPEGs from resulting
                                        ; list

  search.riff.header.searchrange 512    ; on that distance from the beginning
                                        ; of the MPEG program will search
                                        ; the MPEG-header, if the file is
                                        ; RIFF

; = [ Representation stuff ] ================================================
;

  representation.usecodepage yes        ; if this keyword is enabled, MPEG
                                        ; searcher will automatically detect
                                        ; codepage (only cyrillic codepages
                                        ; supported) and recode it to the
                                        ; codepage that you need

  representation.targetcodepage 866     ; MPEG Searcher will recode tag
                                        ; contents to that codepage
                                        ;
                                        ; only '866', 'koi8-r' and '1251'
                                        ; values are applicable to this
                                        ; keyword
                                        ;
                                        ; default codepage is 866

  representation.sort.ignorecase yes    ; if this option is set, MPEG Searcher
                                        ; will lowerize the case of tag items
                                        ; and then compare them (on sorting)

; P.S. excuse me for my curved English :-) feel free to correct it
;

; полуось рулит!!
;