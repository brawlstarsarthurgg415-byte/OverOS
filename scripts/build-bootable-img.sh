#!/usr/bin/env bash
set -Eeuo pipefail

# Creates a disposable OverOS Custom development image. This script only
# writes to the image file under out/; it never selects or formats a host disk.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
IMG="${OVEROS_IMAGE:-$OUT/OverOS-Custom.img}"
ROOTFS="$OUT/bootable-rootfs"
MNT="$OUT/image-mount"
LOOP=""

fail() { printf 'ERRO: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "ferramenta ausente: $1"; }
for tool in debootstrap parted losetup mkfs.ext4 mkfs.vfat mount umount chroot grub-install; do need "$tool"; done
[ "$(uname -m)" = x86_64 ] || fail "a imagem atual exige host de build x86_64"
[ -x "$OUT/core-build/overos-init" ] || fail "execute scripts/build-core.sh antes"
[ -x "$OUT/core-build/overos-session" ] || fail "binarios do OverOS ausentes"

mkdir -p "$OUT" "$MNT"
sudo_cleanup() {
  set +e
  if mountpoint -q "$MNT/boot/efi"; then umount "$MNT/boot/efi"; fi
  if mountpoint -q "$MNT"; then umount "$MNT"; fi
  if [ -n "$LOOP" ]; then losetup -d "$LOOP" 2>/dev/null; fi
}
trap sudo_cleanup EXIT

rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"
rm -f "$IMG"
# 1900 MB keeps the raw image below GitHub Releases' 2 GB asset limit.
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
[ -b "$P1" ] && [ -b "$P2" ] || fail "particoes da imagem nao apareceram"

mkfs.ext4 -F -L OVEROS_ROOT "$P1"
mkfs.vfat -F 32 -n OVEROS_EFI "$P2"
mount "$P1" "$MNT"
mkdir -p "$MNT/boot/efi"
mount "$P2" "$MNT/boot/efi"

printf 'Preparando rootfs Debian minimo para o prototipo inicializavel...\n'
debootstrap --arch=amd64 --variant=minbase trixie "$MNT" https://deb.debian.org/debian

# Let the chroot resolve package mirrors; do not inherit a broken host resolver.
cp /etc/resolv.conf "$MNT/etc/resolv.conf"
mount --bind /dev "$MNT/dev"
mount --bind /dev/pts "$MNT/dev/pts"
mount -t proc proc "$MNT/proc"
mount -t sysfs sysfs "$MNT/sys"
# Register chroot mounts for reliable cleanup even if a later package step fails.
cleanup_chroot() {
  set +e
  umount "$MNT/sys" 2>/dev/null
  umount "$MNT/proc" 2>/dev/null
  umount "$MNT/dev/pts" 2>/dev/null
  umount "$MNT/dev" 2>/dev/null
}
trap 'cleanup_chroot; sudo_cleanup' EXIT

chroot "$MNT" /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get update
chroot "$MNT" /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  linux-image-amd64 systemd-sysv systemd-timesyncd network-manager sudo \
  bash coreutils util-linux procps iproute2 iputils-ping ca-certificates locales \
  openssh-server libgtk-4-1 xserver-xorg-core xserver-xorg-input-libinput \
  xserver-xorg-video-fbdev xserver-xorg-video-vesa xinit openbox tint2 xterm
chroot "$MNT" /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get clean
rm -rf "$MNT/var/lib/apt/lists/"*

# Install the custom OverOS programs without pretending the prototype init is
# production-ready PID 1. The standard Linux init handles the boot sequence.
install -d "$MNT/usr/local/sbin" "$MNT/usr/local/bin" "$MNT/usr/share/overos"
for f in overos-init overos-session overos-supervisor; do
  install -m 0755 "$OUT/core-build/$f" "$MNT/usr/local/sbin/$f"
done
for f in overos-hardware-info overosctl; do
  install -m 0755 "$OUT/core-build/$f" "$MNT/usr/local/bin/$f"
done
if [ -x "$OUT/core-build/overos-desktop" ]; then
  install -m 0755 "$OUT/core-build/overos-desktop" "$MNT/usr/local/bin/overos-desktop"
fi
install -m 0644 "$ROOT/core/tests/services.conf.example" "$MNT/usr/share/overos/services.conf.example"

cat > "$MNT/etc/os-release" <<'EOF'
NAME="OverOS Custom"
PRETTY_NAME="OverOS Custom — imagem de desenvolvimento"
ID=overos
ID_LIKE=debian
VERSION="0.2.1-dev"
VERSION_ID="0.2.1"
EOF
printf 'OverOS Custom (imagem de desenvolvimento)\\n' > "$MNT/etc/issue"
printf 'overos-custom\\n' > "$MNT/etc/hostname"
cat > "$MNT/etc/hosts" <<'EOF'
127.0.0.1 localhost
127.0.1.1 overos-custom
::1 localhost ip6-localhost ip6-loopback
EOF

# Ensure all optional desktop/network groups exist in the minimal bootstrap.\nfor group in audio video plugdev netdev; do chroot "$MNT" groupadd --force "$group"; done\nchroot "$MNT" useradd --create-home --shell /bin/bash --groups sudo,audio,video,plugdev,netdev overos
# Development image: no password is set; local console autologin is intentional.
install -d "$MNT/etc/systemd/system/getty@tty1.service.d" "$MNT/etc/systemd/system/serial-getty@ttyS0.service.d"
cat > "$MNT/etc/systemd/system/getty@tty1.service.d/autologin.conf" <<'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin overos --noclear %I $TERM
EOF
cat > "$MNT/etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf" <<'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin overos --keep-baud 115200,38400,9600 %I $TERM
EOF
install -d -o overos -g overos "$MNT/home/overos"
cat > "$MNT/home/overos/.xinitrc" <<'EOF'
#!/bin/sh
if command -v overos-desktop >/dev/null 2>&1; then overos-desktop & fi
tint2 &
exec openbox-session
EOF
chroot "$MNT" chown overos:overos /home/overos/.xinitrc
chmod 0755 "$MNT/home/overos/.xinitrc"
install -d "$MNT/home/overos/.config/openbox"
cat > "$MNT/home/overos/.config/openbox/autostart" <<'EOF'
tint2 &
if command -v overos-desktop >/dev/null 2>&1; then overos-desktop & fi
EOF
chroot "$MNT" chown -R overos:overos /home/overos/.config

# NetworkManager is available when the user chooses to enable/configure it;
# SSH is installed but deliberately not enabled by default.
chroot "$MNT" systemctl enable NetworkManager
chroot "$MNT" systemctl set-default multi-user.target

ROOT_UUID="$(blkid -s UUID -o value "$P1")"
KERNEL="$(basename "$(find "$MNT/boot" -maxdepth 1 -type f -name 'vmlinuz-*' | sort -V | tail -n1)")"
INITRD="$(basename "$(find "$MNT/boot" -maxdepth 1 -type f -name 'initrd.img-*' | sort -V | tail -n1)")"
[ -n "$KERNEL" ] && [ -f "$MNT/boot/$KERNEL" ] || fail "kernel nao foi instalado"
[ -n "$INITRD" ] && [ -f "$MNT/boot/$INITRD" ] || fail "initramfs nao foi gerado"

install -d "$MNT/boot/grub"
cat > "$MNT/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0
menuentry "OverOS Custom (desenvolvimento)" {
    search --no-floppy --fs-uuid --set=root $ROOT_UUID
    linux /boot/$KERNEL root=UUID=$ROOT_UUID ro console=tty0 console=ttyS0,115200n8 systemd.show_status=1
    initrd /boot/$INITRD
}
EOF

# Install both legacy BIOS and removable UEFI bootloaders to the image only.
grub-install --target=i386-pc --boot-directory="$MNT/boot" --recheck "$LOOP"
grub-install --target=x86_64-efi --efi-directory="$MNT/boot/efi" --boot-directory="$MNT/boot" --removable --no-nvram --recheck

cat > "$MNT/usr/share/overos/BUILD-MANIFEST.txt" <<EOF
OverOS Custom bootable development preview
Built: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Architecture: x86_64
Image: raw disk image with BIOS GRUB and removable UEFI GRUB
Kernel and base userland: upstream Debian packages (temporary development bootstrap)
OverOS components: native C/C++ prototype programs installed under /usr/local
This is not yet the final independent OverOS distribution; secure boot is not validated.
Local console autologin is enabled for development testing. Do not use as a secure daily OS.
EOF

cleanup_chroot
trap sudo_cleanup EXIT
sync
umount "$MNT/boot/efi"
umount "$MNT"
losetup -d "$LOOP"
LOOP=""
trap - EXIT

# Structural checks: partition table, bootloader files, kernel and initramfs.
parted -s "$IMG" print
test -s "$IMG"
printf '\nImagem criada: %s (%s bytes)\n' "$IMG" "$(stat -c %s "$IMG")"
printf 'Kernel: %s | Initramfs: %s\n' "$KERNEL" "$INITRD"
