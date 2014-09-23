::Copy this file to the root directory you want to "thin"
cls
@echo off
echo -	-	-	-	-	-	-	-	-	-
echo			::Thin VuGen v0.2::
echo	This batch file will delete the following files from every 
echo	folder and subdirectory-
echo -	-	-	-	-	-	-	-	-	-
echo 	*.idx	mdrv*.log	mdrv.txt	*.ci
echo.
echo 	debug.inf	*.bak	\result1	combined_*.c
SET /P ent2continue=using current directory "%CD%" press enter to continue:
@echo on
::-Change log:
::-	-9/10
::-	-	-Consolidated deleting and zeroing of batch output log files.
::-	-	-Removed output.txt from the scope of deletion.
::-	-	-Consolidated deletion of files to one line for performance+.
::-	-	-Included removal of FoldersDeleted.txt log as cleanup at end.
::-	-9/11
::-	-	-Improved deletion of results folders using wildcard \result*
::-	-
::-	-

REM Create and/or blank any existing log files from previous runs of this batch file for later file comparisons.
type nul > %temp%\blankfile.txt
type nul > %temp%\FilesDeleted.txt
type nul > %temp%\FoldersDeleted.txt
type nul > %temp%\BadParms.txt

REM Delete the unwanted LoadRunner files and pipe any output into the %temp%\FilesDeleted.txt file.
dir *.idx  mdrv*.log  mdrv.txt  *.ci  combined_*.c  debug.inf  *.bak  /s /b
SET /P ent2continue=Press enter to delete files listed:
del *.idx  mdrv*.log  mdrv.txt  *.ci  combined_*.c  debug.inf  *.bak  /s >> %temp%\FilesDeleted.txt

REM This deletes any sub-folders called result1 and pipes any output into the %temp%\FoldersDeleted.txt file.
for %%d in (h) do (
	  for /f "delims=" %%a in ('dir/s/b/ad %CD%\result*') do (
	  	  echo "deleted %%a" >> %temp%\FoldersDeleted.txt
   	  	  rd /s /q %%a 
   )
)
REM This deletes the local result1 directory if it exists
rd result* /s /q

REM This function looks for explicit file paths rather than relative file paths and writes them to the %temp%\BadParameters.txt file.
findstr /S ":\\" *.prm > %temp%\BadParms.txt

REM If FilesDeleted.txt, FoldersDeleted.txt or BadParms.txt exist, open them up in Notepad so we can see them.
fc %temp%\FilesDeleted.txt %temp%\blankfile.txt > nul
if errorlevel 1 "Notepad.exe" "%temp%\FilesDeleted.txt"

fc %temp%\FoldersDeleted.txt %temp%\blankfile.txt > nul
if errorlevel 1 "Notepad.exe" "%temp%\FoldersDeleted.txt"

fc %temp%\BadParameters.txt %temp%\blankfile.txt > nul
if errorlevel 1 "Notepad.exe" "%temp%\BadParms.txt"

REM Finally delete the superfluous temporary files.
IF EXIST %temp%\blankfile.txt  del %temp%\blankfile.txt /q
IF EXIST %temp%\FilesDeleted.txt  del %temp%\FilesDeleted.txt /q
IF EXIST %temp%\BadParms.txt  del %temp%\BadParms.txt /q
IF EXIST %temp%\FoldersDeleted.txt del %temp%\FoldersDeleted.txt /q
