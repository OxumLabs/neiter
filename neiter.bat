@echo off
setlocal EnableDelayedExpansion

:: Set variables
set "NEIT_URL=https://github.com/OxumLabs/neit/releases/download/0.0.38.1/neit"
set "TDM_GCC_URL=https://github.com/jmeubank/tdm-gcc/releases/download/v10.3.0-tdm64-2/tdm64-gcc-10.3.0-2.exe"
set "DWNLD_FOLD=C:\Program Files\Neit"
set "NEIT_BIN=neit.exe"
set "TDM_GCC_BIN=tdm64-gcc-10.3.0-2.exe"
set "BATCH_FILE=%USERPROFILE%\neit_installer.bat"

:: Check if the script is run with administrator privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [ERROR] Please run this script as administrator.
    pause
    exit /b 1
)
echo [INFO] Running with administrator privileges.

:: Check if Neit already exists and remove it
if exist "%DWNLD_FOLD%\%NEIT_BIN%" (
    echo [INFO] Found existing Neit installation. Removing...
    del /f /q "%DWNLD_FOLD%\%NEIT_BIN%"
    if exist "%DWNLD_FOLD%\%NEIT_BIN%" (
        echo [ERROR] Failed to remove old Neit binary.
        pause
        exit /b 1
    ) else (
        echo [INFO] Old Neit binary removed.
    )
) else (
    echo [INFO] No existing Neit installation found.
)

:: Create download directory if it doesn't exist
if not exist "%DWNLD_FOLD%" (
    echo [INFO] Creating download directory at %DWNLD_FOLD%...
    mkdir "%DWNLD_FOLD%"
) else (
    echo [INFO] Download directory %DWNLD_FOLD% already exists.
)

:: Download the Neit binary
echo [INFO] Downloading Neit from %NEIT_URL%...
PowerShell -Command "Invoke-WebRequest -Uri '%NEIT_URL%' -OutFile '%DWNLD_FOLD%\%NEIT_BIN%'"
if errorlevel 1 (
    echo [ERROR] Failed to download Neit. Please check the URL or your internet connection.
    pause
    exit /b 1
)
echo [INFO] Neit downloaded successfully to %DWNLD_FOLD%\%NEIT_BIN%.

:: Download TDM-GCC
echo [INFO] Downloading TDM-GCC from %TDM_GCC_URL%...
PowerShell -Command "Invoke-WebRequest -Uri '%TDM_GCC_URL%' -OutFile '%DWNLD_FOLD%\%TDM_GCC_BIN%'"
if errorlevel 1 (
    echo [ERROR] Failed to download TDM-GCC. Please check the URL or your internet connection.
    pause
    exit /b 1
)
echo [INFO] TDM-GCC downloaded successfully to %DWNLD_FOLD%\%TDM_GCC_BIN%.

:: Run the TDM-GCC installer
echo [INFO] Running TDM-GCC installer...
"%DWNLD_FOLD%\%TDM_GCC_BIN%"
if errorlevel 1 (
    echo [ERROR] TDM-GCC installation failed. Please check the installer.
    pause
    exit /b 1
)
echo [INFO] TDM-GCC installed successfully.

:: Warning message for Clang installation
echo [WARNING] For better-optimized code, please install the Clang compiler and set it up accordingly. You can find it at https://clang.llvm.org/.

:: Function to set PATH
echo [INFO] Adding %DWNLD_FOLD% to your PATH...
set "newPath=%DWNLD_FOLD%"
set "oldPath=%PATH%"
set "PATH=%newPath%;%oldPath%"
echo "set PATH=%newPath%;%%PATH%%" >> "%BATCH_FILE%"
echo [INFO] Path added. Please run '%BATCH_FILE%' to update your current session.

echo [INFO] Installation completed successfully.
pause

exit /b 0
