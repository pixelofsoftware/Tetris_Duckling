#!/bin/bash
# raylib 5.5 dla macOS w zewnetrzne/raylib/lib. Repozytorium zawiera gotową bibliotekę dla
# Apple Silicon (arm64); ten skrypt buduje ją tylko wtedy, gdy jej brakuje albo jest dla innego
# procesora (np. Intel). Pakiety grafika i fizyka są już w zewnetrzne/ (opis: zewnetrzne/README.md).
# Wymaga przy budowie: Xcode Command Line Tools (git, make, clang).
set -euo pipefail
cd "$(dirname "$0")"
RAYLIB="$PWD/zewnetrzne/raylib"
LIB="$RAYLIB/lib/libraylib.dylib"
RAYLIB_TAG=5.5
RAYLIB_COMMIT=c1ab645ca298a2801097931d1079b10ff7eb9df8   # ten sam co w grafika/zbuduj_raylib.py

[ "$(uname -s)" = "Darwin" ] || { echo "Ten skrypt jest dla macOS; na Linuksie uruchom ./przygotuj_linux.sh" >&2; exit 2; }

if [ -f "$LIB" ] && lipo -archs "$LIB" 2>/dev/null | tr ' ' '\n' | grep -qx "$(uname -m)"; then
    exit 0
fi

echo "Brak raylib dla procesora $(uname -m) - buduję raylib $RAYLIB_TAG (około minuty)..." >&2
mkdir -p "$RAYLIB"
if [ ! -d "$RAYLIB/zrodla" ]; then
    git clone --quiet --depth 1 --branch "$RAYLIB_TAG" https://github.com/raysan5/raylib.git "$RAYLIB/zrodla"
fi
HEAD=$(git -C "$RAYLIB/zrodla" rev-parse HEAD)
[ "$HEAD" = "$RAYLIB_COMMIT" ] || { echo "raylib ma commit $HEAD, oczekiwano $RAYLIB_COMMIT (5.5)" >&2; exit 1; }
make -C "$RAYLIB/zrodla/src" PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED -j"$(sysctl -n hw.ncpu)" > "$RAYLIB/make.log" 2>&1 \
    || { echo "Błąd budowy raylib, dziennik: $RAYLIB/make.log" >&2; exit 1; }
mkdir -p "$RAYLIB/lib"
# Jeden plik, bez .a obok (duck woli .a od biblioteki współdzielonej).
cp "$RAYLIB/zrodla/src/libraylib.5.5.0.dylib" "$LIB"
# Nazwa instalacji względem pliku gry (gra/.duck_build/dev/): działa w każdym miejscu repozytorium.
install_name_tool -id "@executable_path/../../../zewnetrzne/raylib/lib/libraylib.dylib" "$LIB"
codesign --force --sign - "$LIB"
echo "raylib: $LIB ($(lipo -archs "$LIB"))" >&2
