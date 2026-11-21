# Grafika

Ten katalog jest pakietem duck `grafika`: okno, rysowanie, klawiatura, mysz i dźwięk
dla gier 2D. Kod jest w Ducklingu ([src/src.dk](src/src.dk)) i woła raylib 5.5
bezpośrednio przez `extern("C")`.

raylib nie jest częścią repozytorium. Przed pierwszą budową uruchom:

```sh
python3 grafika/zbuduj_raylib.py
```

Skrypt buduje statyczną raylib do `grafika/zewnetrzne/` (katalog ignorowany
przez git), skąd bierze ją `external-libs` z `quackconfig.yaml`.
Lista funkcji, wymagane pakiety systemowe i podłączenie do własnego projektu:
[obraz i dźwięk w grach](../dokumentacja/fizyka/GRAFIKA.md). Gotowe gry są
w [przykładach gier](../przyklady/gry/README.md).
