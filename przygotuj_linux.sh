#!/bin/bash
# Przygotowanie gry na Linuksie (jednorazowo):
#  1. wersje pakietów dla Linuksa z zewnetrzne/linux/ trafiają do zewnetrzne/ (w repozytorium
#     są tam wersje dla macOS); zmienione pliki dostają w git znacznik skip-worktree,
#  2. skrypt pakietu grafika buduje statyczną raylib 5.5 do zewnetrzne/grafika/zewnetrzne/lib.
# Wymaga: git, cmake, kompilator C, nagłówki X11, OpenGL i ALSA. Ubuntu:
#   sudo apt install build-essential git cmake libx11-dev libxrandr-dev libxinerama-dev \
#       libxcursor-dev libxi-dev libgl-dev libasound2-dev
# Uwaga: te kroki nie zostały sprawdzone na prawdziwej maszynie z Linuksem.
set -euo pipefail
cd "$(dirname "$0")"
[ "$(uname -s)" = "Linux" ] || { echo "Ten skrypt jest dla Linuksa; na macOS uruchom ./uruchom.sh" >&2; exit 2; }
command -v python3 >/dev/null || { echo "Brak python3." >&2; exit 2; }

for pakiet in grafika fizyka; do
    [ -d "zewnetrzne/linux/$pakiet" ] || continue
    cp -R "zewnetrzne/linux/$pakiet/." "zewnetrzne/$pakiet/"
    # Wersja dla Linuksa zastępuje pliki z repozytorium tylko lokalnie; git status pozostaje czysty.
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git ls-files -z "zewnetrzne/$pakiet" | xargs -0 -r git update-index --skip-worktree
    fi
    echo "$pakiet: wersja dla Linuksa w zewnetrzne/$pakiet"
done

python3 zewnetrzne/grafika/zbuduj_raylib.py
touch zewnetrzne/.linux-gotowe
echo "Gotowe. Uruchom grę: ./uruchom.sh"
echo "(Powrót do wersji z repozytorium: git ls-files -z zewnetrzne | xargs -0 git update-index --no-skip-worktree && git checkout -- zewnetrzne && rm -f zewnetrzne/.linux-gotowe)"
