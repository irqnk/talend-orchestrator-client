@echo off
cd /d "%~dp0"

echo.
echo ================================================
echo   Talend Orchestrator - Demarrage
echo ================================================
echo.

REM --- Verifie que Docker est installe ---
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas installe ou pas dans le PATH.
    echo Telechargez Docker Desktop : https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM --- Verifie que Docker est demarre ---
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Desktop n'est pas demarre.
    echo Lancez Docker Desktop puis relancez ce script.
    pause
    exit /b 1
)

REM --- Telecharge la derniere image et demarre ---
echo [1/3] Telechargement de la derniere version...
docker-compose -f docker-compose.prod.yml pull
echo       OK

echo [2/3] Demarrage de l'application...
docker-compose -f docker-compose.prod.yml up -d
if %errorlevel% neq 0 (
    echo [ERREUR] Demarrage echoue. Verifiez Docker Desktop.
    pause
    exit /b 1
)
echo       OK

echo [3/3] Demarrage de l'agent Windows...
if exist "agent_windows.bat" (
    start "Talend Agent Windows" /min cmd /k agent_windows.bat
    echo       OK
) else (
    echo       agent_windows.bat absent - ignore
)

echo.
echo ================================================
echo   Application disponible sur :
echo   http://localhost:8001
echo ================================================
echo.
pause
