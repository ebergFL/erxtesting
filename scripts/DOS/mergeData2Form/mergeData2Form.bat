::==
@echo off
copy header fileOut.reg

setLocal EnableDelayedExpansion
for /f "tokens=1,2" %%a in (list) do (
echo	%%a> string2
echo	%%b> string1
copy /b fileOut.reg + file1 + string1 + file2 + string2 + file3 fileOut.reg
)
