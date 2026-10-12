#!/usr/bin/env bash
# Pornire Finn cu un singur pas (macOS / Linux): ./start.sh
set -e
cd "$(dirname "$0")"

PY="$(command -v python3 || command -v python || true)"
if [ -z "$PY" ]; then
  echo "Python nu este instalat. Descarcă-l de pe https://www.python.org/downloads/ (versiunea 3.10 sau mai nouă)."
  exit 1
fi

if [ ! -d .venv ]; then
  echo "▸ Creez mediul Python (.venv)…"
  "$PY" -m venv .venv
fi
. .venv/bin/activate
echo "▸ Instalez pachetele (prima dată durează ~1 minut)…"
python -m pip install -q --upgrade pip >/dev/null
python -m pip install -q -r requirements.txt

if [ ! -f .env ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo
  read -rp "Cheia Claude (ANTHROPIC_API_KEY) — sau Enter pentru modul fără AI: " KEY || KEY=""
  if [ -n "$KEY" ]; then
    printf 'ANTHROPIC_API_KEY=%s\n' "$KEY" > .env
    echo "▸ Cheia a fost salvată în .env (fișierul nu se urcă pe GitHub)."
  fi
fi

echo
echo "▸ Finn pornește la http://localhost:8000  (Ctrl+C pentru oprire)"
( sleep 3; (open http://localhost:8000 || xdg-open http://localhost:8000) >/dev/null 2>&1 || true ) &
exec python -m uvicorn backend.main:app --port 8000
