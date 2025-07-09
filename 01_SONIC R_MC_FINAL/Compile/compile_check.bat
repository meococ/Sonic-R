@echo off
echo ========================================
echo APEX Pullback EA v4 - Syntax Check
echo ========================================
echo.
echo Checking for MetaEditor installation...

REM Try to find MetaEditor in common locations
set METAEDITOR_PATH=""
if exist "C:\Program Files\MetaTrader 5\MetaEditor64.exe" (
    set METAEDITOR_PATH="C:\Program Files\MetaTrader 5\MetaEditor64.exe"
) else if exist "C:\Program Files (x86)\MetaTrader 5\MetaEditor64.exe" (
    set METAEDITOR_PATH="C:\Program Files (x86)\MetaTrader 5\MetaEditor64.exe"
) else (
    echo MetaEditor not found in standard locations.
    echo Please compile manually in MetaEditor.
    pause
    exit /b 1
)

echo Found MetaEditor at: %METAEDITOR_PATH%
echo.
echo Compiling APEX_Pullback_EA_v4.mq5...

REM Compile the EA
%METAEDITOR_PATH% /compile:"%~dp0..\APEX_Pullback_EA_v4.mq5" /log

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo COMPILATION SUCCESSFUL!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo COMPILATION FAILED!
    echo Check MetaEditor logs for details.
    echo ========================================
)

echo.
echo Compilation completed. Check results above.
REM Auto-exit without pause