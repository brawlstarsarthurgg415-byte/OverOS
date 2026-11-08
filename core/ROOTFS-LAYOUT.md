# OverOS root filesystem layout (design draft)

This is the target layout for a root filesystem assembled from individually built upstream components and OverOS packages. It is not a prebuilt distro rootfs.

- `/sbin/overos-init` — future production PID 1 (not the current prototype).
- `/sbin/overos-session` — native console session.
- `/usr/bin/overos-hardware-info` — read-only hardware report.
- `/etc/overos/` — system configuration.
- `/var/log/overos/` — service logs.
- `/var/lib/overos/` — state and package metadata.
- `/boot/` — signed EFI boot components and kernel.
- `/home/` — user data on the USB persistence partition.

## Build stages

1. Cross/native toolchain and sysroot.
2. Kernel and modules for verified target hardware.
3. C library and base utilities.
4. OverOS init, service supervision, device management and networking.
5. Package database and repository metadata.
6. Graphical session and touch profile.
7. Signed UEFI boot chain and USB image.

Do not assemble a bootable image until the boot chain, rootfs, recovery path and hardware drivers have been tested. The image builder must require an explicit output file and must never target an internal disk automatically.
