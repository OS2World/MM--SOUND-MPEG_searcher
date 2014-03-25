(*
 * part of MPEG searcher project
 *  (c) 1999 by Alexander Trunov, 2:5069/10, jnc@mail.ru
 *)

unit Config;

interface

uses
  Objects;

const
  Version = '0.5';
  Platform = {$IFDEF os2}    'OS/2'  {$ENDIF}
             {$IFDEF win32}  'Win32' {$ENDIF}
             {$IFDEF DPMI32} 'DPMI32'{$ENDIF}
             {$IFDEF ver70}  'DPMI'  {$ENDIF} // planned (bp)
             {$IFDEF linux}  'Linux' {$ENDIF} // planned (vp)
             {$IFDEF go32v2} 'DPMI32'{$ENDIF} // planned (fpc)
             ;

var
  tplBy, tplWhole: PStringCollection;

  mcLayerI, mcLayerII, mcLayerIII, mcLayerUnknown: string;
  mcMpeg10, mcMpeg20, mcMpeg25, mcMpegUnknown: string;
  mcModeStereo, mcModeJointStereo, mcModeDualChannel, mcModeSingleChannel: string;
  tplMakeShortFilenames: Boolean;

  searchMask, searchExclude, searchExcludePath: PStringCollection;
  searchExcludeNonMpegs: Boolean;
  searchRange: Longint;

  rpUseCodepage, rpIgnoreCase: Boolean;
  rpCodepage: Longint;

implementation

begin
  tplBy := nil;
  tplWhole := nil;
  searchMask := nil;
  searchExclude := nil;
  searchExcludePath := nil;
end.
