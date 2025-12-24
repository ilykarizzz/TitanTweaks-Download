@echo off
title TitanTweaks - Loader
color 0b
cls

:: ========================================================
::    TitanTweaks - Auto-Elevate to Admin (Required)
:: ========================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [INFO] Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: ========================================================
::    TitanTweaks - Permanent Install Path
:: ========================================================
set "FINAL_DIR=%LocalAppData%\TitanTweaks"
set "LOADER_NAME=TitanTweaks_Launcher.bat"
set "LOADER_PATH=%FINAL_DIR%\%LOADER_NAME%"

:: Create directory if missing
if not exist "%FINAL_DIR%" mkdir "%FINAL_DIR%"

:: If not running from the final directory, copy self and create shortcut
if /i "%~dp0" neq "%FINAL_DIR%\" (
    echo  [PREP] Setting up permanent installation...
    copy /y "%~f0" "%LOADER_PATH%" >nul
    
    :: Create Shortcut via PowerShell
    powershell -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'TitanTweaks.lnk')); $s.TargetPath='%LOADER_PATH%'; $s.WorkingDirectory='%FINAL_DIR%'; $s.Save();"
    
    echo  [OK] Shortcut created on Desktop!
    echo       Next time, launch TitanTweaks from your Desktop.
    timeout /t 3 >nul
)

cd /d "%FINAL_DIR%"

echo.
echo ========================================================
echo        TitanTweaks - System Check & Update
echo ========================================================
echo.
echo  [1/3] Connecting to TitanTweaks server...

set "URL=https://raw.githubusercontent.com/ilykarizzz/TitanTweaks-Download/main/TitanTweaks_Lite.zip"
set "ZIP_FILE=Update_temp.zip"
set "APP_DIR=App_Data"

:: Update check (Download every time as requested to ensure latest version)
echo  [2/3] Checking for latest elite patches (70MB)...
echo        (This ensures you always have the latest zero-delay settings)
echo.

curl -L -f -o "%ZIP_FILE%" "%URL%" --progress-bar

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Connection failed. Running local version...
    if exist "%APP_DIR%\TitanTweaks_Lite\main.py" goto :launch
    pause
    exit /b
)

echo.
echo  [3/3] Finalizing Installation...
echo.

:: Extract with force overwrite
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%APP_DIR%' -Force"

:: Cleanup zip
if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%"

:launch
if not exist "%APP_DIR%\TitanTweaks_Lite\main.py" (
    echo.
    echo  [ERROR] App files missing. Please check your antivirus.
    pause
    exit /b
)

:: Run the application
cd "%APP_DIR%\TitanTweaks_Lite"
echo  Launching TitanTweaks...
start "" "python\pythonw.exe" "main.py"
exit
