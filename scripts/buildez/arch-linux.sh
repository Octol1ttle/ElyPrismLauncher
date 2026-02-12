#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/dist/linux"
BUILD_TYPE="${1:-Release}"
JOBS="$(nproc)"

echo "=== BLauncher: Arch Linux build ==="
echo "Project: $PROJECT_ROOT"
echo "Build type: $BUILD_TYPE"
echo ""

# Check dependencies
missing=()
for pkg in cmake ninja extra-cmake-modules qt6-base qt6-5compat qt6-svg qt6-imageformats qt6-networkauth cmark zlib libarchive tomlplusplus qrencode; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        missing+=("$pkg")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing packages: ${missing[*]}"
    echo "Install them with:"
    echo "  sudo pacman -S --needed ${missing[*]}"
    exit 1
fi

# Use JDK 8 if available (needed for -target 7)
if [ -d /usr/lib/jvm/java-8-openjdk ]; then
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
    echo "Using JDK 8: $JAVA_HOME"
fi

# Init submodules
cd "$PROJECT_ROOT"
git submodule update --init --recursive

# Clean previous build
rm -rf "$BUILD_DIR" "$INSTALL_DIR"

# Configure
echo ""
echo "=== Configuring ==="
cmake -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
    -G "Ninja Multi-Config" \
    -DENABLE_LTO=ON \
    -DLauncher_BUILD_PLATFORM=linux

# Build
echo ""
echo "=== Building ($BUILD_TYPE) ==="
cmake --build "$BUILD_DIR" --config "$BUILD_TYPE" -j"$JOBS"

# Install
echo ""
echo "=== Installing to $INSTALL_DIR ==="
cmake --install "$BUILD_DIR" --config "$BUILD_TYPE" --prefix "$INSTALL_DIR"

# Create portable tarball
echo ""
echo "=== Creating portable tarball ==="
PORTABLE_DIR="$PROJECT_ROOT/dist/linux-portable"
rm -rf "$PORTABLE_DIR"
cmake --install "$BUILD_DIR" --config "$BUILD_TYPE" --prefix "$PORTABLE_DIR"
cmake --install "$BUILD_DIR" --config "$BUILD_TYPE" --prefix "$PORTABLE_DIR" --component portable

ARCH="$(uname -m)"
TARBALL="$PROJECT_ROOT/dist/BLauncher-Linux-${ARCH}.tar.gz"
cd "$PORTABLE_DIR"
tar czf "$TARBALL" ./*

echo ""
echo "=== Done ==="
echo "Install dir:      $INSTALL_DIR"
echo "Portable tarball:  $TARBALL"
