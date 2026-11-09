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
for tool in curl tar make gcc g++ cmake git perl python3 cpio rsync bc bison flex ccache meson ninja; do need "$tool"; done

mkdir -p "$OUT"

# Keep downloaded source archives and compiler objects outside the Buildroot
# output tree so GitHub Actions can cache them between independent runners.
export BR2_DL_DIR="$OUT/buildroot-dl"
CCACHE_STORE="$OUT/buildroot-ccache"
mkdir -p "$BR2_DL_DIR" "$CCACHE_STORE"
ccache --set-config=max_size=5G

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

# Point Buildroot itself at the directory persisted by GitHub Actions.
python3 - "$BUILD/.config" "$CCACHE_STORE" <<'PY'
import pathlib, sys
config = pathlib.Path(sys.argv[1])
cache_dir = sys.argv[2]
lines = config.read_text().splitlines()
entry = 'BR2_CCACHE_DIR="' + cache_dir + '"'
for i, line in enumerate(lines):
    if line.startswith("BR2_CCACHE_DIR="):
        lines[i] = entry
        break
else:
    lines.append(entry)
config.write_text("\n".join(lines) + "\n")
PY
make -C "$SOURCE" O="$BUILD" olddefconfig
grep -qx 'BR2_TOOLCHAIN_BUILDROOT_CXX=y' "$BUILD/.config" || {
  echo "Buildroot config did not enable target C++ support" >&2
  exit 1
}
grep -qx 'BR2_CCACHE=y' "$BUILD/.config" || {
  echo "Buildroot compiler cache is disabled in the effective config" >&2
  exit 1
}

# Build the target compiler first, then compile OverOS native programs against
# the Buildroot sysroot (never against the Ubuntu/Debian host libraries).
make -C "$SOURCE" O="$BUILD" toolchain
TOOLBIN="$BUILD/host/bin"
CC=""
for candidate in "$TOOLBIN"/*-gcc; do
  if [ -x "$candidate" ]; then CC="$candidate"; break; fi
done
[ -n "$CC" ] || { echo "Buildroot target GCC not found in $TOOLBIN" >&2; exit 1; }
CXX=""
for candidate in "$TOOLBIN"/*-g++; do
  if [ -x "$candidate" ]; then CXX="$candidate"; break; fi
done
[ -n "$CXX" ] || {
  echo "Buildroot target G++ not found in $TOOLBIN; inspect $BUILD/.config and toolchain logs" >&2
  exit 1
}
"$CC" -dumpmachine
"$CXX" -dumpmachine
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

# Produce the first native OverVault package from the exact Fastfetch binary
# installed into this OverOS rootfs overlay.
OVEROS_OVERLAY="$OVERLAY" OVERVAULT_OUTPUT="$OUT/overvault/x86_64" \
  bash "$ROOT/overvault/tools/build-fastfetch-package.sh"

install -d "$OVERLAY/usr/bin" "$OVERLAY/usr/sbin"
for binary in overos-hardware-info overosctl; do
  install -m 0755 "$OUT/core-target-build/$binary" "$OVERLAY/usr/bin/$binary"
done
for binary in overos-init overos-session overos-supervisor; do
  install -m 0755 "$OUT/core-target-build/$binary" "$OVERLAY/usr/sbin/$binary"
done


# Build Pacman dependency libraries into the target sysroot before Meson
# cross-compiles against them. `make toolchain` alone does not stage these
# package headers and libraries.
make -C "$SOURCE" O="$BUILD" -j"$(nproc)" libarchive libcurl libgpgme openssl zstd

# Build upstream Pacman/libalpm for the OverOS musl userspace. This does not
# use Arch Linux binary repositories: their packages target glibc and are
# incompatible with this system. Pacman can install local OverOS .pkg.tar.*
# packages now; a signed native OverOS repository is a separate milestone.
PACMAN_SOURCE="$OUT/pacman-7.0.0"
PACMAN_BUILD="$OUT/pacman-target-build"
if [ ! -d "$PACMAN_SOURCE/.git" ]; then
  rm -rf "$PACMAN_SOURCE"
  git init "$PACMAN_SOURCE"
  git -C "$PACMAN_SOURCE" remote add origin https://gitlab.archlinux.org/pacman/pacman.git
  git -C "$PACMAN_SOURCE" fetch --depth 1 origin refs/tags/v7.0.0
  git -C "$PACMAN_SOURCE" checkout --detach FETCH_HEAD
fi
MESON="$(command -v meson)"
NINJA="$(command -v ninja)"
[ -x "$MESON" ] || { echo "Native Meson is unavailable on the build host" >&2; exit 1; }
[ -x "$NINJA" ] || { echo "Native Ninja is unavailable on the build host" >&2; exit 1; }
PKG_CONFIG_WRAPPER="$OUT/pkg-config-overos.sh"
cat > "$PKG_CONFIG_WRAPPER" <<'EOF'
#!/bin/sh
SYSROOT="__SYSROOT__"
export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig:$SYSROOT/usr/lib64/pkgconfig"
exec /usr/bin/pkg-config "$@"
EOF
sed -i "s|__SYSROOT__|$SYSROOT|g" "$PKG_CONFIG_WRAPPER"
chmod 0755 "$PKG_CONFIG_WRAPPER"
CROSS_FILE="$OUT/overos-meson-cross.ini"
cat > "$CROSS_FILE" <<EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '${CC%gcc}ar'
strip = '${CC%gcc}strip'
pkg-config = '$PKG_CONFIG_WRAPPER'

[properties]
sys_root = '$SYSROOT'
pkg_config_libdir = ['$SYSROOT/usr/lib/pkgconfig', '$SYSROOT/usr/share/pkgconfig', '$SYSROOT/usr/lib64/pkgconfig']

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF
"$MESON" setup "$PACMAN_BUILD" "$PACMAN_SOURCE" --cross-file "$CROSS_FILE" --prefix=/usr --buildtype=release -Ddoc=disabled -Di18n=false -Dcrypto=openssl
"$NINJA" -C "$PACMAN_BUILD"
DESTDIR="$OVERLAY" "$MESON" install -C "$PACMAN_BUILD"
test -x "$OVERLAY/usr/bin/pacman"
# Meson may install libalpm under usr/lib or usr/lib64 depending on the
# target layout. Only pass directories that actually exist to find; with
# pipefail, a missing search directory would otherwise fail the whole build.
LIBALPM_SEARCH_DIRS=()
for libdir in "$OVERLAY/usr/lib" "$OVERLAY/usr/lib64"; do
  [ ! -d "$libdir" ] || LIBALPM_SEARCH_DIRS+=("$libdir")
done
[ "${#LIBALPM_SEARCH_DIRS[@]}" -gt 0 ] || {
  echo "Pacman installation created neither usr/lib nor usr/lib64" >&2
  exit 1
}
find "${LIBALPM_SEARCH_DIRS[@]}" -name 'libalpm.so*' -print -quit | grep -q . || {
  echo "libalpm shared library was not installed into the target overlay" >&2
  exit 1
}
install -d "$OVERLAY/etc"
cat > "$OVERLAY/etc/pacman.conf" <<'EOF'
[options]
Architecture = auto
DBPath = /var/lib/pacman/
CacheDir = /var/cache/pacman/pkg/
LogFile = /var/log/pacman.log
GPGDir = /etc/pacman.d/gnupg/
SigLevel = Required DatabaseRequired
# Development builds create local packages before the signing key/repository
# deployment exists. Accept unsigned local files for now; if a signature is
# present, Pacman still verifies it. Remote OverVault remains signature-required.
LocalFileSigLevel = Optional

# Official OverVault repository endpoint. The hosting workflow and trusted
# public signing key must be deployed before remote installs can succeed.
[overvault]
SigLevel = Required DatabaseRequired
Server = https://brawlstarsarthurgg415-byte.github.io/OverOS/overvault/$arch

# Do not add Ubuntu/Arch binary repositories here: their package binaries
# are not compatible with the musl-based OverOS root filesystem.
EOF

# Build the complete target: kernel, musl/BusyBox rootfs, network stack,
# OpenSSH, Xfbdev/Openbox and the OverOS binaries above.
make -C "$SOURCE" O="$BUILD" -j"$(nproc)"

test -s "$BUILD/images/rootfs.tar"
test -s "$BUILD/images/bzImage"
mkdir -p "$OUT/overos-buildroot"
cp "$BUILD/images/rootfs.tar" "$OUT/overos-buildroot/rootfs.tar"
cp "$BUILD/images/bzImage" "$OUT/overos-buildroot/bzImage"
printf 'OverOS Buildroot rootfs and kernel built successfully.\n'
