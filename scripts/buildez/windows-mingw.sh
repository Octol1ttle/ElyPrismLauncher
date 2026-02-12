#!/bin/bash
# Run this script inside MSYS2 CLANG64 shell
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/install"
BUILD_TYPE="${1:-Release}"
JOBS="$(nproc)"

echo "=== BLauncher: Windows MinGW (MSYS2 CLANG64) build ==="
echo "Project: $PROJECT_ROOT"
echo "Build type: $BUILD_TYPE"
echo ""

# Check we're in CLANG64
if [ "${MSYSTEM:-}" != "CLANG64" ]; then
    echo "WARNING: Expected MSYS2 CLANG64 environment (MSYSTEM=$MSYSTEM)"
    echo "Run this from: MSYS2 CLANG64 terminal"
fi

# Install dependencies
echo "=== Installing dependencies ==="
pacman -S --needed --noconfirm \
    mingw-w64-clang-x86_64-toolchain \
    mingw-w64-clang-x86_64-cmake \
    mingw-w64-clang-x86_64-ninja \
    mingw-w64-clang-x86_64-extra-cmake-modules \
    mingw-w64-clang-x86_64-qt6-base \
    mingw-w64-clang-x86_64-qt6-5compat \
    mingw-w64-clang-x86_64-qt6-svg \
    mingw-w64-clang-x86_64-qt6-imageformats \
    mingw-w64-clang-x86_64-qt6-networkauth \
    mingw-w64-clang-x86_64-cmark \
    mingw-w64-clang-x86_64-zlib \
    mingw-w64-clang-x86_64-libarchive \
    mingw-w64-clang-x86_64-tomlplusplus \
    mingw-w64-clang-x86_64-qrencode

# Init submodules
cd "$PROJECT_ROOT"
git submodule update --init --recursive

# Clean
rm -rf "$BUILD_DIR" "$INSTALL_DIR"

# Configure
echo ""
echo "=== Configuring ==="
cmake --preset windows_mingw

# Build
echo ""
echo "=== Building ($BUILD_TYPE) ==="
cmake --build "$BUILD_DIR" --config "$BUILD_TYPE" -j"$JOBS"

# Install
echo ""
echo "=== Installing ==="
cmake --install "$BUILD_DIR" --config "$BUILD_TYPE"

# Create portable
echo ""
echo "=== Creating portable build ==="
PORTABLE_DIR="$PROJECT_ROOT/install-portable"
rm -rf "$PORTABLE_DIR"
cp -r "$INSTALL_DIR" "$PORTABLE_DIR"
cmake --install "$BUILD_DIR" --config "$BUILD_TYPE" --prefix "$PORTABLE_DIR" --component portable

# Create zip archives
echo ""
echo "=== Packing ==="
DIST_DIR="$PROJECT_ROOT/dist"
mkdir -p "$DIST_DIR"

cd "$INSTALL_DIR"
7z a "$DIST_DIR/BLauncher-Windows-x86_64.zip" ./* || true

cd "$PORTABLE_DIR"
7z a "$DIST_DIR/BLauncher-Windows-x86_64-Portable.zip" ./* || true

# Build NSIS installer if available
if command -v makensis &>/dev/null; then
    echo ""
    echo "=== Building installer ==="
    cd "$INSTALL_DIR"
    makensis -NOCD "$BUILD_DIR/program_info/win_install.nsi"
    mv ElyPrismLauncher-Setup.exe "$DIST_DIR/" 2>/dev/null || true
else
    echo ""
    echo "NOTE: makensis not found, skipping installer. Install with:"
    echo "  pacman -S mingw-w64-clang-x86_64-nsis"
fi

echo ""
echo "=== Done ==="
echo "Install dir:  $INSTALL_DIR"
echo "Portable dir: $PORTABLE_DIR"
echo "Dist dir:     $DIST_DIR"
