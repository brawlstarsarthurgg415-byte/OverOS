#!/usr/bin/env bash
set -Eeuo pipefail

# Produces a raw OverOS disk image from the Buildroot-built rootfs and kernel.
# This script only writes to out/OverOS-Custom.img; it never selects a host disk.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
IMG="${OVEROS_IMAGE:-$OUT/OverOS-Custom.img}"
ROOTFS_TAR="$OUT/overos-buildroot/rootfs.tar"
KERNEL_IMAGE="$OUT/overos-buildroot/bzImage"
MNT="$OUT/image-mount"
LOOP=""

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "missing tool: $1"; }
for tool in parted losetup mkfs.ext4 mkfs.vfat mount umount grub-install tar blkid udevadm; do need "$tool"; done
[ "$(uname -m)" = x86_64 ] || fail "the current image target requires an x86_64 build host"
if [ ! -s "$ROOTFS_TAR" ] || [ ! -s "$KERNEL_IMAGE" ]; then
  bash "$ROOT/scripts/build-buildroot-rootfs.sh"
fi
[ -s "$ROOTFS_TAR" ] || fail "Buildroot rootfs archive missing"
[ -s "$KERNEL_IMAGE" ] || fail "Buildroot kernel missing"

mkdir -p "$OUT" "$MNT"
LOOP=""
cleanup() {
  set +e
  mountpoint -q "$MNT/boot/efi" && umount "$MNT/boot/efi"
  mountpoint -q "$MNT" && umount "$MNT"
  [ -z "$LOOP" ] || losetup -d "$LOOP" 2>/dev/null
}
trap cleanup EXIT

rm -rf "$MNT"
mkdir -p "$MNT"
rm -f "$IMG"
# Keep the raw image below the 2 GB GitHub release asset limit.
truncate -s 1900MiB "$IMG"
parted -s "$IMG" mklabel msdos
parted -s "$IMG" mkpart primary ext4 1MiB 1780MiB
parted -s "$IMG" set 1 boot on
parted -s "$IMG" mkpart primary fat32 1780MiB 100%
parted -s "$IMG" set 2 esp on
LOOP="$(losetup --find --show --partscan "$IMG")"
udevadm settle
P1="${LOOP}p1"
P2="${LOOP}p2"
for _ in $(seq 1 20); do [ -b "$P1" ] && [ -b "$P2" ] && break; sleep 1; done
[ -b "$P1" ] && [ -b "$P2" ] || fail "image partitions did not appear"

mkfs.ext4 -F -L OVEROS_ROOT "$P1"
mkfs.vfat -F 32 -n OVEROS_EFI "$P2"
mount "$P1" "$MNT"
mkdir -p "$MNT/boot/efi"
mount "$P2" "$MNT/boot/efi"

printf 'Installing the independent Buildroot root filesystem...\n'
tar --numeric-owner -xpf "$ROOTFS_TAR" -C "$MNT"
install -D -m 0644 "$KERNEL_IMAGE" "$MNT/boot/vmlinuz-overos"
install -D -m 0644 "$ROOT/rice/fastfetch/overos.txt" "$MNT/usr/share/fastfetch/logos/overos.txt"
install -D -m 0644 "$ROOT/rice/fastfetch/config.jsonc" "$MNT/etc/fastfetch/config.jsonc"

# BusyBox init provides the initial console login. Enable a serial console for
# virtual-machine smoke tests without replacing the target's init system.
if [ -f "$MNT/etc/inittab" ] && ! grep -q 'ttyS0' "$MNT/etc/inittab"; then
  printf '\nttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100\n' >> "$MNT/etc/inittab"
fi
printf 'overos\n' > "$MNT/etc/hostname"

ROOT_UUID="$(blkid -s UUID -o value "$P1")"
install -d "$MNT/boot/grub"
cat > "$MNT/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0
menuentry "OverOS Custom" {
    search --no-floppy --fs-uuid --set=root $ROOT_UUID
    linux /boot/vmlinuz-overos root=UUID=$ROOT_UUID rootwait rw console=tty0 console=ttyS0,115200n8
}
EOF

# Install BIOS and removable UEFI bootloaders into the image, never the host disk.
grub-install --target=i386-pc --boot-directory="$MNT/boot" --recheck "$LOOP"
grub-install --target=x86_64-efi --efi-directory="$MNT/boot/efi" --boot-directory="$MNT/boot" --removable --no-nvram --recheck

cat > "$MNT/usr/share/overos-build-info.txt" <<EOF
OverOS Custom development image
Architecture: x86_64
Root filesystem: Buildroot-built BusyBox/musl userland
Kernel: upstream Linux kernel built by Buildroot
Init: BusyBox init
Desktop: Xfbdev + Openbox + xterm (console fallback)
Network: NetworkManager + nmtui + WPA supplicant
Remote access: OpenSSH server
Packages: Pacman/libalpm 7.0.0 for local OverOS packages; Specman MVP
System info: upstream Fastfetch with OverOS logo/configuration
Buildroot version: 2025.02
This is an early development image, not a production-ready OS.
EOF

sync
umount "$MNT/boot/efi"
umount "$MNT"
losetup -d "$LOOP"
LOOP=""
trap - EXIT

parted -s "$IMG" print
test -s "$IMG"
printf '\nImage created: %s (%s bytes)\n' "$IMG" "$(stat -c %s "$IMG")"
