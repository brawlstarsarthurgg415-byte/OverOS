#!/usr/bin/env bash
set -Eeuo pipefail

# Build the OverOS userland from upstream components with Buildroot.
# Debian/Ubuntu may be used as the CI host only; they are never copied into
# the target root filesystem.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
VERSION="2025.02"
ARCHIVE="$OUT/buildroot-$VERSION.tar.xz"
SOURCE="$OUT/buildroot-$VERSION"
BUILD="$OUT/buildroot-output"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing build tool: $1" >&2; exit 1; }; }
for tool in curl tar make gcc g++ perl python3 cpio rsync bc bison flex; do need "$tool"; done

mkdir -p "$OUT"
if [ ! -d "$SOURCE" ]; then
  curl -fL --retry 3 "https://buildroot.org/downloads/buildroot-$VERSION.tar.xz" -o "$ARCHIVE"
  tar -xJf "$ARCHIVE" -C "$OUT"
fi

make -C "$SOURCE" O="$BUILD" defconfig BR2_DEFCONFIG="$ROOT/buildroot/overos_x86_64_defconfig"
make -C "$SOURCE" O="$BUILD" -j"$(nproc)"

test -s "$BUILD/images/rootfs.tar"
test -s "$BUILD/images/bzImage"
mkdir -p "$OUT/overos-buildroot"
cp "$BUILD/images/rootfs.tar" "$OUT/overos-buildroot/rootfs.tar"
cp "$BUILD/images/bzImage" "$OUT/overos-buildroot/bzImage"
printf 'OverOS Buildroot rootfs and kernel built successfully.\n'
