#!/bin/bash
# Uruchom grę Tetris (macOS albo Linux). `./uruchom.sh testy` uruchamia testy logiki Tetrisa.
set -euo pipefail
cd "$(dirname "$0")"
command -v duck >/dev/null || export PATH="$HOME/.local/share/duckling/bin:$PATH"
command -v duck >/dev/null || { echo "Brak narzędzia duck: zainstaluj Ducklinga (install.py z paczki)." >&2; exit 2; }
if [ "${1:-}" = "testy" ]; then
    cd testy && exec duck run
fi
if [ "$(uname -s)" = "Linux" ]; then
    [ -f zewnetrzne/.linux-gotowe ] || ./przygotuj_linux.sh
else
    ./przygotuj_macos.sh    # buduje raylib tylko, gdy brakuje jej dla tego procesora
fi
cd gra && exec duck run
