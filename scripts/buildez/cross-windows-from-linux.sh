#!/bin/bash
# Cross-compile Windows build from Arch Linux using MinGW-w64
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build-win"
INSTALL_DIR="$PROJECT_ROOT/dist/windows"
BUILD_TYPE="${1:-Release}"
JOBS="$(nproc)"

echo "=== BLauncher: Cross-compile for Windows (from Arch Linux) ==="
echo "Project: $PROJECT_ROOT"
echo "Build type: $BUILD_TYPE"
echo ""

# Check dependencies
missing=()
for pkg in mingw-w64-gcc mingw-w64-cmake; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        missing+=("$pkg")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Cross-compilation requires MinGW packages."
    echo "Install them with:"
    echo "  sudo pacman -S --needed ${missing[*]}"
    echo ""
    echo "NOTE: Cross-compiling Qt6 apps for Windows from Linux is complex."
    echo "It's MUCH easier to build natively on Windows using MSYS2."
    echo "Use: scripts/build/windows-mingw.sh (inside MSYS2 CLANG64)"
    echo ""
    echo "Alternatively, use GitHub Actions (push to repo and let CI build it)."
    exit 1
fi

echo "WARNING: Cross-compiling Qt6 apps for Windows is non-trivial."
echo "You need cross-compiled Qt6 and all dependencies."
echo ""
echo "Recommended approaches instead:"
echo "  1. Build natively on Windows with MSYS2 (scripts/build/windows-mingw.sh)"
echo "  2. Build natively on Windows with MSVC (scripts/build/windows-msvc.bat)"
echo "  3. Push to GitHub and use CI (Actions will build for all platforms)"
echo ""
read -p "Continue anyway? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

cd "$PROJECT_ROOT"
git submodule update --init --recursive

rm -rf "$BUILD_DIR" "$INSTALL_DIR"

x86_64-w64-mingw32-cmake -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DENABLE_LTO=ON

cmake --build "$BUILD_DIR" -j"$JOBS"
cmake --install "$BUILD_DIR" --prefix "$INSTALL_DIR"

echo ""
echo "=== Done ==="
echo "Install dir: $INSTALL_DIR"
