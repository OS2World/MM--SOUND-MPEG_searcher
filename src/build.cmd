
del mp3src*.exe
del *.bak

call cd32.cmd -$s- %1 %2 %3 %4 %5 %6 %7
call cw32.cmd -$s- %1 %2 %3 %4 %5 %6 %7
call c.cmd -$s- %1 %2 %3 %4 %5 %6 %7

chcase * /cl /r /y+

md current

cd current
del *.* /n

md src
md examples
md docs
md tpl

copy ..\*.pas src\
copy ..\*.inc src\
copy ..\*.cmd src\
copy ..\genres.lst src\

copy ..\examples\*.* examples\

md docs\rus
md docs\eng
copy ..\whatnews.txt docs\rus\
copy ..\readme.rus docs\rus\
copy ..\macros.rus docs\rus\
copy ..\todo.txt docs\rus\
copy ..\readme.txt docs\eng\
copy ..\macros.txt docs\eng\

copy ..\tpl\*.* tpl\

copy ..\mp3srch?.exe .\
copy ..\tagger.res .\
copy ..\file_id.* .\
copy ..\mp3srch.ctl .\

rar2 m mp3_sr_c.rar -m5 -r -std

copy mp3_sr_c.rar mp3osr_c.rar
copy mp3_sr_c.rar mp3dsr_c.rar
copy mp3_sr_c.rar mp3wsr_c.rar

rar2 d mp3osr_c.rar mp3srchw.exe mp3srchd.exe -std
rar2 d mp3wsr_c.rar mp3srch2.exe mp3srchd.exe -std
rar2 d mp3dsr_c.rar mp3srch2.exe mp3srchw.exe -std

cd ..