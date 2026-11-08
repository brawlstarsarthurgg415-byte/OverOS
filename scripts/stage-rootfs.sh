#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/out/core-build}"
ROOTFS="${ROOTFS:-$ROOT/out/rootfs-staging}"

if [ ! -x "$BUILD_DIR/overos-init" ] || [ ! -x "$BUILD_DIR/overos-session" ]; then
  echo "ERRO: binarios ausentes. Execute bash scripts/build-core.sh primeiro." >&2
  exit 1
fi

# This only creates a staging directory under the repository's out/ folder.
# It never discovers, mounts, formats, or writes to physical disks.
rm -rf -- "$ROOTFS"
mkdir -p "$ROOTFS/usr/sbin" "$ROOTFS/usr/bin" "$ROOTFS/etc" "$ROOTFS/usr/share/overos"

install -m 0755 "$BUILD_DIR/overos-init" "$ROOTFS/usr/sbin/overos-init"
install -m 0755 "$BUILD_DIR/overos-session" "$ROOTFS/usr/sbin/overos-session"
install -m 0755 "$BUILD_DIR/overos-hardware-info" "$ROOTFS/usr/bin/overos-hardware-info"
install -m 0755 "$BUILD_DIR/overosctl" "$ROOTFS/usr/bin/overosctl"

ln -s usr/bin "$ROOTFS/bin"
ln -s usr/sbin "$ROOTFS/sbin"

cat > "$ROOTFS/etc/os-release" <<'EOF'
NAME="OverOS"
PRETTY_NAME="OverOS Development RootFS"
ID=overos
ID_LIKE=linux
VERSION="0.2.1-dev"
VERSION_ID="0.2.1"
EOF

cat > "$ROOTFS/etc/issue" <<'EOF'
OverOS development root filesystem (not bootable)
EOF

cat > "$ROOTFS/usr/share/overos/BUILD-MANIFEST.txt" <<EOF
OverOS staged core root filesystem
Build timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Source branch: overos-custom-core
Contents: init prototype, console session, hardware inventory, overosctl
Status: INCOMPLETE — no kernel, libc, shell, drivers, bootloader or package database
This staging tree is not a bootable operating system.
EOF

printf 'Rootfs de desenvolvimento preparado em: %s\n' "$ROOTFS"
printf 'Conteudo: '
find "$ROOTFS" -type f | wc -l
