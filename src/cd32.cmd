@echo off

vpc mp3srch.pas -M -CW:D32:DPMI32 %1 %2 %3 %4 %5 %6 %7 %8 %9

:quit

pe2le mp3srch.exe mp3srchd.exe /s:wdosxle.exe
del mp3srch.exe

del *.lnk > nul
del *.obj > nul
del *.vpi > nul
del *.lib > nul