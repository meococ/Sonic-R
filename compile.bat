@echo off
SET MQL_COMPILER="C:\Program Files\MetaTrader 5\mql64.exe"
SET EA_SOURCE="C:\Users\ADMIN\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Sonic R_MC\01_SONIC R_MC_FINAL\APEX_PULLBACK_EA_v3.mq5"
SET INCLUDE_PATH="C:\Users\ADMIN\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Include"
SET LOG_FILE="C:\Users\ADMIN\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Sonic R_MC\compile_log.txt"

echo Compiling %EA_SOURCE%...
%MQL_COMPILER% /i:"%INCLUDE_PATH%" %EA_SOURCE% > %LOG_FILE% 2>&1

echo Compilation finished. Check %LOG_FILE% for details.