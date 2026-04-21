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

REM --- Connexion Docker Hub via token (stocke dans .docker_token) ---
echo [1/4] Connexion a Docker Hub...
if exist ".docker_token" (
    for /f "tokens=1,2" %%a in (.docker_token) do (
        set "DOCKER_USER=%%a"
        set "DOCKER_TOKEN=%%b"
    )
    echo %DOCKER_TOKEN%| docker login -u "%DOCKER_USER%" --password-stdin
) else (
    echo [AVERTISSEMENT] Fichier .docker_token absent, connexion manuelle...
    echo Creez un fichier .docker_token avec : votre_user  votre_token
    docker login
)
if %errorlevel% neq 0 (
    echo [ERREUR] Connexion Docker Hub echouee.
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
