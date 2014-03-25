@echo off

vpc mp3srch.pas -M -CW %1 %2 %3 %4 %5 %6 %7 %8 %9

:quit

ren mp3srch.exe mp3srchw.exe

del *.lnk > nul
del *.obj > nul
del *.vpi > nul
del *.lib > nul
