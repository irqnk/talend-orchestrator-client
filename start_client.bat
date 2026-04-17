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

REM --- Connexion Docker Hub (necessaire pour image privee) ---
echo [1/4] Connexion a Docker Hub...
docker login
if %errorlevel% neq 0 (
    echo [ERREUR] Connexion Docker Hub echouee.
    echo Creez un compte sur https://hub.docker.com puis contactez l'administrateur.
    pause
    exit /b 1
)
echo       OK

REM --- Telecharge la derniere image et demarre ---
echo [2/4] Telechargement de la derniere version...
docker-compose -f docker-compose.prod.yml pull
echo       OK

echo [3/4] Demarrage de l'application...
docker-compose -f docker-compose.prod.yml up -d
if %errorlevel% neq 0 (
    echo [ERREUR] Demarrage echoue. Verifiez Docker Desktop.
    pause
    exit /b 1
)
echo       OK

echo [4/4] Demarrage de l'agent Windows...
if exist "agent_windows.py" (
    pip install --quiet flask waitress requests
    start "Talend Agent Windows" /min cmd /k python agent_windows.py
    echo       OK
) else (
    echo       agent_windows.py absent - ignore
)

echo.
echo ================================================
echo   Application disponible sur :
echo   http://localhost:8001
echo ================================================
echo.
pause
