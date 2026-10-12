@echo off
rem Pornire Finn cu dublu-click (Windows)
chcp 65001 >nul
cd /d "%~dp0"

set "PY="
where py >nul 2>nul
if not errorlevel 1 set "PY=py -3"
if defined PY goto havepy
where python >nul 2>nul
if not errorlevel 1 set "PY=python"
:havepy
if not defined PY (
  echo Python nu este instalat. Descarca-l de pe https://www.python.org/downloads/ ^(bifeaza "Add Python to PATH"^).
  pause
  exit /b 1
)

if not exist .venv (
  echo ^> Creez mediul Python ^(.venv^)...
  %PY% -m venv .venv
)
call .venv\Scripts\activate.bat
echo ^> Instalez pachetele ^(prima data dureaza ~1 minut^)...
python -m pip install -q --upgrade pip >nul
python -m pip install -q -r requirements.txt
if errorlevel 1 (
  echo Instalarea pachetelor a esuat. Verifica conexiunea la internet.
  pause
  exit /b 1
)

if exist .env goto run
if defined ANTHROPIC_API_KEY goto run
echo.
set "KEY="
set /p "KEY=Cheia Claude (ANTHROPIC_API_KEY) - sau Enter pentru modul fara AI: "
if "%KEY%"=="" goto run
> .env echo ANTHROPIC_API_KEY=%KEY%
echo ^> Cheia a fost salvata in .env ^(fisierul nu se urca pe GitHub^).

:run
echo.
echo ^> Finn porneste la http://localhost:8000  ^(inchide fereastra pentru oprire^)
start "" cmd /c "timeout /t 4 >nul & start http://localhost:8000"
python -m uvicorn backend.main:app --port 8000
pause
