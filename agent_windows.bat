@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ================================
echo  Talend Agent Windows - Port 8002
echo ================================
echo.

echo [1/2] Installation des dependances...
python -m pip install --quiet flask waitress requests
echo       OK

echo [2/2] Demarrage de l'agent...
echo.
python agent_windows.py
pause
