@echo off
REM Batch script to copy OpenClaw configuration to system directory

echo OpenClaw Configuration Installer
echo =================================
echo.

REM Define paths
set "SOURCE=%~dp0openclaw-config.json"
set "OPENCLAW_DIR=%USERPROFILE%\.openclaw"
set "TARGET=%OPENCLAW_DIR%\openclaw.json"

REM Check if source exists
if not exist "%SOURCE%" (
    echo ERROR: Source configuration file not found: %SOURCE%
    pause
    exit /b 1
)

echo Source: %SOURCE%
echo Target: %TARGET%
echo.

REM Create .openclaw directory if it doesn't exist
if not exist "%OPENCLAW_DIR%" (
    echo Creating OpenClaw directory: %OPENCLAW_DIR%
    mkdir "%OPENCLAW_DIR%"
)

REM Backup existing config if it exists
if exist "%TARGET%" (
    echo Backing up existing config...
    copy "%TARGET%" "%TARGET%.backup" >nul
)

REM Copy the configuration file
echo Copying configuration file...
copy "%SOURCE%" "%TARGET%" >nul

if exist "%TARGET%" (
    echo.
    echo SUCCESS! Configuration installed successfully.
    echo.
    echo Configuration location: %TARGET%
    echo.
    echo Next steps:
    echo 1. Set your GitHub token in: %OPENCLAW_DIR%\.env
    echo    Example: COPILOT_GITHUB_TOKEN=your_token_here
    echo.
    echo 2. Start OpenClaw gateway:
    echo    openclaw gateway
    echo.
) else (
    echo ERROR: Failed to copy configuration file.
    pause
    exit /b 1
)

pause
