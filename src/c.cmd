@echo off

vpc mp3srch.pas -M %1 %2 %3 %4 %5 %6 %7 %8 %9
vpc makeres.pas -M %1 %2 %3 %4 %5 %6 %7 %8 %9

makeres
del makeres.exe

:quit

ren mp3srch.exe mp3srch2.exe

del *.lnk > nul
del *.obj > nul
del *.vpi > nul
del *.lib > nul
