#!/usr/bin/env bash
set -Eeuo pipefail

# Build the OverOS userland from upstream components with Buildroot.
# Debian/Ubuntu may be used as a CI host only; they are never copied into
# the target root filesystem.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
VERSION="2025.02"
ARCHIVE="$OUT/buildroot-$VERSION.tar.xz"
SOURCE="$OUT/buildroot-$VERSION"
BUILD="$OUT/buildroot-output"
OVERLAY="$SOURCE/board/overos-rootfs-overlay"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing build tool: $1" >&2; exit 1; }; }
for tool in curl tar make gcc g++ cmake git perl python3 cpio rsync bc bison flex; do need "$tool"; done

mkdir -p "$OUT"
if [ ! -d "$SOURCE" ]; then
  curl -fL --retry 3 "https://buildroot.org/downloads/buildroot-$VERSION.tar.xz" -o "$ARCHIVE"
  tar -xJf "$ARCHIVE" -C "$OUT"
fi

# Buildroot resolves overlays and kernel fragments from its source directory.
mkdir -p "$SOURCE/board"
rm -rf "$OVERLAY"
cp -a "$ROOT/board/overos/rootfs-overlay" "$OVERLAY"
mkdir -p "$SOURCE/board/overos"
install -m 0644 "$ROOT/board/overos/linux.fragment" "$SOURCE/board/overos/linux.fragment"
chmod 0755 "$OVERLAY/usr/bin/specman" "$OVERLAY/usr/bin/overos-gui"

make -C "$SOURCE" O="$BUILD" defconfig BR2_DEFCONFIG="$ROOT/buildroot/overos_x86_64_defconfig"

# Build the target compiler first, then compile OverOS native programs against
# the Buildroot sysroot (never against the Ubuntu/Debian host libraries).
make -C "$SOURCE" O="$BUILD" toolchain
TOOLBIN="$BUILD/host/bin"
CC=""
for candidate in "$TOOLBIN"/*-gcc; do
  if [ -x "$candidate" ]; then CC="$candidate"; break; fi
done
[ -n "$CC" ] || { echo "Buildroot target GCC not found in $TOOLBIN" >&2; exit 1; }
CXX="${CC%gcc}g++"
[ -x "$CXX" ] || { echo "Buildroot target G++ not found: $CXX" >&2; exit 1; }
SYSROOT="$("$CC" -print-sysroot)"
[ -d "$SYSROOT" ] || { echo "Buildroot sysroot not found: $SYSROOT" >&2; exit 1; }

cmake -S "$ROOT/core" -B "$OUT/core-target-build" \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_FIND_ROOT_PATH="$SYSROOT" \
  -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
  -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  -DPKG_CONFIG_EXECUTABLE=/bin/false \
  -DBUILD_TESTING=OFF
cmake --build "$OUT/core-target-build" --parallel "$(nproc)"

# Build the upstream Fastfetch project unchanged, with optional integrations
# disabled for a small musl target. Only the OverOS logo/config are customized.
FASTFETCH_SOURCE="$OUT/fastfetch-2.53.0"
if [ ! -d "$FASTFETCH_SOURCE/.git" ]; then
  rm -rf "$FASTFETCH_SOURCE"
  git init "$FASTFETCH_SOURCE"
  git -C "$FASTFETCH_SOURCE" remote add origin https://github.com/fastfetch-cli/fastfetch.git
  git -C "$FASTFETCH_SOURCE" fetch --depth 1 origin 9ab5c33008c4bd116135867dacdc29caad7c6efd
  git -C "$FASTFETCH_SOURCE" checkout --detach FETCH_HEAD
fi
cmake -S "$FASTFETCH_SOURCE" -B "$OUT/fastfetch-target-build" \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_FIND_ROOT_PATH="$SYSROOT" \
  -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
  -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DPKG_CONFIG_EXECUTABLE=/bin/false \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_VULKAN=OFF -DENABLE_WAYLAND=OFF -DENABLE_XCB_RANDR=OFF \
  -DENABLE_XRANDR=OFF -DENABLE_DRM=OFF -DENABLE_GIO=OFF \
  -DENABLE_DCONF=OFF -DENABLE_DBUS=OFF -DENABLE_SQLITE3=OFF \
  -DENABLE_RPM=OFF -DENABLE_IMAGEMAGICK7=OFF -DENABLE_IMAGEMAGICK6=OFF \
  -DENABLE_CHAFA=OFF -DENABLE_EGL=OFF -DENABLE_GLX=OFF \
  -DENABLE_OPENCL=OFF -DENABLE_PULSE=OFF -DENABLE_DDCUTIL=OFF \
  -DENABLE_ELF=OFF -DENABLE_THREADS=OFF -DENABLE_LIBZFS=OFF \
  -DENABLE_PCIACCESS=OFF -DENABLE_DIRECTX_HEADERS=OFF \
  -DENABLE_ZLIB=OFF -DENABLE_SYSTEM_YYJSON=OFF -DENABLE_LTO=OFF \
  -DBUILD_FLASHFETCH=OFF -DBUILD_TESTS=OFF -DSET_TWEAK=OFF -DIS_MUSL=ON
cmake --build "$OUT/fastfetch-target-build" --parallel "$(nproc)"
DESTDIR="$OVERLAY" cmake --install "$OUT/fastfetch-target-build"

install -d "$OVERLAY/usr/bin" "$OVERLAY/usr/sbin"
for binary in overos-hardware-info overosctl; do
  install -m 0755 "$OUT/core-target-build/$binary" "$OVERLAY/usr/bin/$binary"
done
for binary in overos-init overos-session overos-supervisor; do
  install -m 0755 "$OUT/core-target-build/$binary" "$OVERLAY/usr/sbin/$binary"
done

# Build the complete target: kernel, musl/BusyBox rootfs, network stack,
# OpenSSH, Xfbdev/Openbox and the OverOS binaries above.
make -C "$SOURCE" O="$BUILD" -j"$(nproc)"

test -s "$BUILD/images/rootfs.tar"
test -s "$BUILD/images/bzImage"
mkdir -p "$OUT/overos-buildroot"
cp "$BUILD/images/rootfs.tar" "$OUT/overos-buildroot/rootfs.tar"
cp "$BUILD/images/bzImage" "$OUT/overos-buildroot/bzImage"
printf 'OverOS Buildroot rootfs and kernel built successfully.\n'
