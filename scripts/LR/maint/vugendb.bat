::==v09.12
@echo off
cls
::Set VUGEN_PATH_REMOTE, scriptList, dataGroup, and vugenSvr
call %~n0.init.bat

echo Files in working directory:
dir /d /b *.
echo Using input list file "%scriptList%"
set /p action=press enter to accept or type name of file: 
if "%action%"=="" (goto start) else set scriptList=%action%

:start
cls
echo =======================================
echo Using file "%scriptList%", would you like to:
echo C change the dat files (current "%dataGroup%")
echo S change the remote server (current "%vugenSvr%")
echo R remotely run the scripts (PsExec.exe required)
echo L locally run the scripts
echo V view the output files
echo O open the result1 report
echo E edit the script files
echo X exit
echo =======================================
set /p action=Please enter a letter C, S, R, L, V, O, E or X: 

if /i "%action%"=="X" exit /b
if /i "%action%"=="R" if /i "%ERX_PASS%"=="" set /p ERX_PASS=Enter your password for remote %USERDOMAIN%\%USERNAME%: & cls
if /i "%action%"=="C" set /p dataGroup=Please enter dat file group to work in "dev", "uat", or "int" (current "%dataGroup%")...: 
if /i "%action%"=="S" set /p vugenSvr=Please enter remote server to run in "psin0p280", etc. (current "%vugenSvr%")..: 

setLocal EnableDelayedExpansion
for /f "tokens=1,2" %%a in (%scriptList%) do (
	if /i "%action%"=="C" copy %%a\%%b\*.dat.%dataGroup% %%a\%%b\*.
	::Use System account -s, don't load profile -e, set working directory -w, don't wait for process to terminate -d
	if /i "%action%"=="R" psexec \\%vugenSvr% -u %USERDOMAIN%\%USERNAME% -p %ERX_PASS% -e -w "%VUGEN_PATH_REMOTE%" -d "%VUGEN_PATH_REMOTE%\bin\mmdrv.exe" -usr %%a\%%b\%%b.usr
	if /i "%action%"=="L" start "execute script %%b" cmd /c "%VUGEN_PATH%bin\mmdrv.exe" -usr %%a\%%b\%%b.usr
	if /i "%action%"=="V" start "view %%b output" cmd /c %%a\%%b\output.txt
	if /i "%action%"=="O" pause & start "view %%b result1" cmd /c "%VUGEN_PATH%bin\QTReport.exe" %%a\%%b\result1\Results.qtp
	if /i "%action%"=="E" pause & start "edit %%b script" %%a\%%b\%%b.usr
)

pause & goto start

::Notes:
::Add to batch file to prep Live scripts:
:: cmd /k Tasklist.exe /FI "IMAGENAME eq mmdrv.exe" /S %Hostname% /U %Username%  /P %Password%
:: Parse log file output.txt data to include-
:: Virtual User Script started at : 2012-05-07 10:17:03	[MsgId: MMSG-15967]
:: Run-Time Settings file: "e:\pe\script\lr\live\wil\wil_checkout\default.cfg"  	[MsgId: MMSG-27141]
:: Starting iteration 1.	[MsgId: MMSG-15968]
:: then search for .SEC and .ASH lines
:: Vuser Terminated.	[MsgId: MMSG-15963]

::Sample format for live.txt file of path and script, note the tab delimiter before the file script name-
::E:\PE\Script\LR\Live	PageNavigation
::E:\PE\Script\LR\Live	Search_Script