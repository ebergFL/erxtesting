echo	LR VUGen File and Settings Merge > %1Report.txt

echo	[~~VUGen File~~] >> %1Report.txt
dir /b *.usr >> %1Report.txt

del	combined_*.c
del	pre_cci.c

echo	[~~Recording~~] >> %1Report.txt
copy %1Report.txt + data\web_persist_settings.dat %1Report.txt
echo	[~~Recording2~~] >> %1Report.txt
copy %1Report.txt + data\web_proxy_settings.ini %1Report.txt
echo	[~~Scripts~~] >> %1Report.txt
copy %1Report.txt + *.c %1Report.txt
echo	[~~Globals~~] >> %1Report.txt
copy %1Report.txt + globals.h %1Report.txt
echo	[~~HostNames~~] >> %1Report.txt
copy %1Report.txt + data\HostNames.dat %1Report.txt
echo	[~~Runtime Settings~Transactions~ExtraFiles~Actions~~] >> %1Report.txt
copy %1Report.txt + *.usr %1Report.txt
echo	[~~Logfile~~] >> %1Report.txt
copy %1Report.txt + logfile.log %1Report.txt
echo	[~~Output~~] >> %1Report.txt
copy %1Report.txt + output.txt %1Report.txt
echo	[~~CorrelationLog~~] >> %1Report.txt
copy %1Report.txt + data\CorrelationLog.txt %1Report.txt

echo	[~~End~~] >> %1Report.txt

start %1Report.txt
