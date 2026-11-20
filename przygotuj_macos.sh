#!/bin/bash
# Przygotowanie gry Tetris na macOS (Apple Silicon i Intel), jednorazowo:
#  1. buduje raylib 5.5 jako bibliotekę współdzieloną do zewnetrzne/raylib/lib,
#  2. tworzy zewnetrzne/grafika: kopię pakietu grafika z duckling-biblioteki
#     z konfiguracją linkowania i dwiema poprawkami dla macOS.
#
# Użycie: ./przygotuj_macos.sh [ścieżka do duckling-biblioteki]   (domyślnie ~/duckling-biblioteki)
# Wymaga: Xcode Command Line Tools (git, make, clang) i Ducklinga z `duck` w PATH.
set -euo pipefail

cd "$(dirname "$0")"
ROOT="$PWD"
BIBLIOTEKI="${1:-$HOME/duckling-biblioteki}"
RAYLIB="$ROOT/zewnetrzne/raylib"
GRAFIKA="$ROOT/zewnetrzne/grafika"
RAYLIB_TAG=5.5
RAYLIB_COMMIT=c1ab645ca298a2801097931d1079b10ff7eb9df8   # ten sam co w grafika/zbuduj_raylib.py

[ "$(uname -s)" = "Darwin" ] || { echo "Ten skrypt jest dla macOS. Na Linuksie użyj grafika/zbuduj_raylib.py." >&2; exit 2; }
[ -f "$BIBLIOTEKI/grafika/src/src.dk" ] || { echo "Brak $BIBLIOTEKI/grafika/src/src.dk; podaj ścieżkę do duckling-biblioteki." >&2; exit 2; }

# --- 1. raylib 5.5 ---------------------------------------------------------------
# Biblioteka współdzielona sama linkuje frameworki macOS (Cocoa, OpenGL, IOKit...),
# a `duck` przyjmuje tylko nazwy bibliotek (external-libs), bez flag -framework.
if [ ! -f "$RAYLIB/lib/libraylib.dylib" ]; then
    mkdir -p "$RAYLIB"
    if [ ! -d "$RAYLIB/zrodla" ]; then
        git clone --quiet --depth 1 --branch "$RAYLIB_TAG" https://github.com/raysan5/raylib.git "$RAYLIB/zrodla"
    fi
    HEAD=$(git -C "$RAYLIB/zrodla" rev-parse HEAD)
    [ "$HEAD" = "$RAYLIB_COMMIT" ] || { echo "raylib ma commit $HEAD, oczekiwano $RAYLIB_COMMIT (5.5)" >&2; exit 1; }
    echo "Buduję raylib $RAYLIB_TAG..."
    make -C "$RAYLIB/zrodla/src" PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED -j"$(sysctl -n hw.ncpu)" > "$RAYLIB/make.log" 2>&1 \
        || { echo "Błąd budowy raylib, dziennik: $RAYLIB/make.log" >&2; exit 1; }
    mkdir -p "$RAYLIB/lib"
    # Jeden plik, bez .a obok (duck woli .a od biblioteki współdzielonej).
    cp "$RAYLIB/zrodla/src/libraylib.5.5.0.dylib" "$RAYLIB/lib/libraylib.dylib"
    # Bezwzględna nazwa instalacji: program znajdzie bibliotekę bez rpath.
    install_name_tool -id "$RAYLIB/lib/libraylib.dylib" "$RAYLIB/lib/libraylib.dylib"
    codesign --force --sign - "$RAYLIB/lib/libraylib.dylib"
fi
echo "raylib: $RAYLIB/lib/libraylib.dylib"

# --- 2. pakiet grafika dla macOS --------------------------------------------------
mkdir -p "$GRAFIKA/src"
# Poprawki: errno na macOS czyta __error() (glibc: __errno_location),
# a CLOCK_MONOTONIC ma numer 6 (Linux: 1).
sed -e 's/__errno_location/__error/g' \
    -e 's/libc::clock_gettime(1i32,/libc::clock_gettime(6i32,/' \
    "$BIBLIOTEKI/grafika/src/src.dk" > "$GRAFIKA/src/src.dk"
grep -q '__error()' "$GRAFIKA/src/src.dk" && grep -q 'clock_gettime(6i32' "$GRAFIKA/src/src.dk" \
    || { echo "Nie udało się nanieść poprawek macOS na grafika/src/src.dk" >&2; exit 1; }
cat > "$GRAFIKA/quackconfig.yaml" <<YAML
metadata:
  name: grafika
  version: '0.1.0'
  license: MIT
  description: Kopia pakietu grafika z duckling-biblioteki przygotowana dla macOS (raylib 5.5)
  external-libs: [raylib]
  external-lib-paths: [$RAYLIB/lib]
YAML
cp "$BIBLIOTEKI/LICENSE" "$GRAFIKA/LICENSE" 2>/dev/null || true
echo "grafika: $GRAFIKA (z $BIBLIOTEKI/grafika, commit $(git -C "$BIBLIOTEKI" rev-parse --short HEAD 2>/dev/null || echo '?'))"
echo "Gotowe. Uruchom grę: cd gra && duck run"
