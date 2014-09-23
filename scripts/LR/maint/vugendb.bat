::==v09.11
@echo off
cls

rem defaults
set file=live
set env=ash
set svr=ashprdldr01

dir /d *.
set /p action=Using input list file "%file%" (Y/Name)? 
if /i "%action%"=="Y" (goto start) else set file=%action%

:start
cls
echo =======================================
echo Using file "%file%", would you like to:
echo C change the dat files (default "%env%")
echo S change the remote server (default "%svr%")
echo R remotely run the scripts (PsExec.exe required)
echo L locally run the scripts
echo V view the output files
echo O open the result1 report
echo E edit the script files
echo X exit
echo =======================================

set /p action=Please enter a letter C, R, L, V, O, E or X: 

if /i "%action%"=="X" goto exit 
if /i "%action%"=="C" set /p env=Please enter environment to work in "ash", "sec", sc3 or "int"...: 
if /i "%action%"=="S" set /p svr=Please enter remote server to run in "ashprdldr01", "secprdldr01", or "local"...: 

setLocal EnableDelayedExpansion
for /f "tokens=1,2 delims= " %%a in (%file%) do (
if /i "%action%"=="C" copy %%a\%%b\*.dat.%env% %%a\%%b\*.
if /i "%action%"=="R" psexec \\%svr% -u gsiccorp\berge -p %ERX_PWD2% -e -w C:\Progra~1\HP\LoadRunner\bin -d C:\Progra~1\HP\LoadRunner\bin\mmdrv.exe -usr -usr %%a\%%b\%%b.usr
if /i "%action%"=="L" start "execute script %%b" cmd /c "%VUGEN_PATH%bin\mmdrv.exe" -usr %%a\%%b\%%b.usr
if /i "%action%"=="V" start "view %%b output" cmd /c %%a\%%b\output.txt
if /i "%action%"=="O" pause & start "view %%b result1" cmd /c "%VUGEN_PATH%bin\QTReport.exe" %%a\%%b\result1\Results.qtp
if /i "%action%"=="E" pause & start "edit %%b script" %%a\%%b\%%b.usr
)
pause

goto start
:exit

::Notes:
::Add to batch file to prep Live scripts:
:: cmd /k Tasklist.exe /FI "IMAGENAME eq mmdrv.exe" /S %Hostname% /U %Username%  /P %Password%
:: Parse log file output.txt data to include-
:: Virtual User Script started at : 2012-05-07 10:17:03	[MsgId: MMSG-15967]
:: Run-Time Settings file: "e:\pe\script\lr\live\wil\wil_checkout\default.cfg"  	[MsgId: MMSG-27141]
:: Starting iteration 1.	[MsgId: MMSG-15968]
:: then search for .SEC and .ASH lines
:: Vuser Terminated.	[MsgId: MMSG-15963]

::Sample format for live.txt file of path and script, note the space before the file script name-
::E:\PE\Script\LR\Live PageNavigation_new_ec2
::E:\PE\Script\LR\Live Search_Script_new_EC2

::==
