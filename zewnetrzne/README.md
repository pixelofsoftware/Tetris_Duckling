# Biblioteki zewnętrzne

Ten katalog zawiera wszystko, czego gra potrzebuje poza własnym kodem. Po sklonowaniu repozytorium na macOS z Apple Silicon nie trzeba nic pobierać ani budować: `./uruchom.sh` albo `cd gra && duck run` działa od razu.

| Ścieżka | Zawartość | Źródło i licencja |
| --- | --- | --- |
| `grafika/` | pakiet duck `grafika` (okno, rysowanie, klawiatura, mysz, dźwięk) w wersji dla macOS | [duckling-biblioteki](https://github.com/andr729/duckling-biblioteki), gałąź `paczki-duck`, commit `489707f`; autor: Paweł Kępczyński; licencja MIT (`grafika/LICENSE`) |
| `raylib/lib/libraylib.dylib` | raylib 5.5 zbudowana jako biblioteka współdzielona dla macOS (arm64) | [raysan5/raylib](https://github.com/raysan5/raylib), tag 5.5, commit `c1ab645`; licencja zlib/libpng (`raylib/LICENSE`) |
| `linux/grafika/` | oryginalny pakiet z duckling-biblioteki dla Linuksa (ze skryptem `zbuduj_raylib.py`) | jak wyżej |

## Zmiany względem oryginału (wersja dla macOS)

Pakiety z duckling-biblioteki są przygotowane dla Linuksa. Wersja dla macOS różni się tylko tym:

* `grafika/src/src.dk`: `__errno_location` zamienione na `__error` (tak macOS udostępnia `errno`), a `clock_gettime(1i32, …)` na `clock_gettime(6i32, …)` (`CLOCK_MONOTONIC` ma na macOS numer 6, a na Linuksie 1);
* `grafika/quackconfig.yaml`: `external-libs: [raylib]` i ścieżka względna `../raylib/lib`. Biblioteka współdzielona raylib sama dołącza frameworki macOS (Cocoa, OpenGL, IOKit), a `duck` przyjmuje tylko nazwy bibliotek;
* `libraylib.dylib` ma nazwę instalacji `@executable_path/../../../zewnetrzne/raylib/lib/libraylib.dylib`, czyli względem pliku gry w `gra/.duck_build/dev/`. Dzięki temu gra znajduje raylib w każdym miejscu, do którego sklonujesz repozytorium.

## Inny procesor albo system

* **macOS na procesorze Intel:** `./przygotuj_macos.sh` zbuduje raylib dla tego procesora w `raylib/lib/`. Potrzebne są Xcode Command Line Tools; `./uruchom.sh` zrobi to sam.
* **Linux:** `./przygotuj_linux.sh` (albo po prostu `./uruchom.sh`) kopiuje wersję z `linux/` do `grafika/` i buduje statyczną raylib 5.5 skryptem pakietu. Zmienione pliki oznacza w git jako `skip-worktree`, żeby `git status` pozostał czysty. Potrzebne pakiety (Ubuntu): `build-essential git cmake libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libgl-dev libasound2-dev`. **Kroki dla Linuksa nie zostały sprawdzone na prawdziwej maszynie z Linuksem.**
