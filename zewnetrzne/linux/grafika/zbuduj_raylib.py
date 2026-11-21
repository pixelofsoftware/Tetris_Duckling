#!/usr/bin/env python3
"""Zbuduj statyczną raylib 5.5 do grafika/zewnetrzne/, skąd bierze ją pakiet grafika.

quackconfig.yaml pakietu ma `external-lib-paths: [zewnetrzne/lib]`, więc po tym kroku
`duck build` znajduje zewnetrzne/lib/libraylib.a. Nagłówki trafiają do zewnetrzne/include.

Wymaga git, cmake, kompilatora C oraz nagłówków X11 i OpenGL (w Ubuntu: libx11-dev,
libxrandr-dev, libxinerama-dev, libxcursor-dev, libxi-dev, libgl-dev, libasound2-dev).
"""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
TARGET = HERE / 'zewnetrzne'
URL = 'https://github.com/raysan5/raylib.git'
TAG = '5.5'
COMMIT = 'c1ab645ca298a2801097931d1079b10ff7eb9df8'
CMAKE_OPTIONS = ['-DCMAKE_BUILD_TYPE=Release', '-DBUILD_EXAMPLES=OFF', '-DBUILD_SHARED_LIBS=OFF',
                 '-DPLATFORM=Desktop', '-DOPENGL_VERSION=3.3', '-DUSE_EXTERNAL_GLFW=OFF',
                 '-DGLFW_BUILD_WAYLAND=OFF', '-DGLFW_BUILD_X11=ON']


def run(command, **options):
    print('$ ' + ' '.join(map(str, command)), flush=True)
    subprocess.run(list(map(str, command)), check=True, **options)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--zrodla', type=Path,
                        help='Istniejące drzewo git raylib; bez tego skrypt klonuje tag 5.5')
    parser.add_argument('-j', '--jobs', type=int, default=4)
    args = parser.parse_args()
    for tool in ('git', 'cmake'):
        if shutil.which(tool) is None:
            sys.exit('Brak narzędzia: ' + tool)
    source = args.zrodla.resolve() if args.zrodla else TARGET / 'zrodla/raylib'
    if not source.exists():
        source.parent.mkdir(parents=True, exist_ok=True)
        run(['git', 'clone', '--quiet', '--depth', '1', '--branch', TAG, URL, source])
    head = subprocess.run(['git', '-C', source, 'rev-parse', 'HEAD'], capture_output=True, text=True, check=True)
    if head.stdout.strip() != COMMIT:
        sys.exit(f'raylib w {source} ma commit {head.stdout.strip()}, oczekiwano {COMMIT} (5.5)')
    build = TARGET / 'budowa'
    run(['cmake', '-S', source, '-B', build, *CMAKE_OPTIONS, '-DCMAKE_INSTALL_PREFIX=' + str(TARGET)])
    run(['cmake', '--build', build, '--parallel', str(args.jobs)])
    run(['cmake', '--install', build])
    library = TARGET / 'lib/libraylib.a'
    if not library.is_file():
        sys.exit('Brak ' + str(library) + ' po instalacji')
    print('Gotowe: ' + str(library))
    return 0


if __name__ == '__main__':
    sys.exit(main())
