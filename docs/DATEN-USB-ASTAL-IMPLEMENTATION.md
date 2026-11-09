# OverOS DATEN USB — implementation status

## User-approved desktop direction

Matshell-inspired original OverOS shell:
- Wayland session
- Hyprland compositor/window manager, conditional on GPU/DRM/KMS support
- Astal + GTK4 for the shell, launcher and widgets
- Touch-first controls and a reduced-effects profile

This is not an Arch Linux installation. The system remains the independent Buildroot/BusyBox/musl project.

## Source added

- `rice/hyprland/hyprland.conf`: initial compositor configuration.
- `rice/astal/app.js`: first GTK4/Astal shell application source, with application launcher, search, clock and control panel.
- `rice/astal/meson.build`: install metadata for shell assets.
- `rice/astal/overos-shell.desktop` and `overos-shell.ini`: desktop and instance metadata.
- `rice/overos-shell.css`: shell styling.
- Existing `rice/astal.css` and `rice/components.css`: shared palette and touch-aware controls.

## Automated checks that currently pass

The dedicated GitHub Actions workflow validates the GJS module's JavaScript syntax, parses the GTK4 stylesheet tree with GTK itself, and installs the shell assets plus desktop entry through Meson using the target `/usr` prefix. This is a scaffold/asset validation only; it does not execute the Astal app or build the compositor/runtime.

## Integration gates still open

The repository's current Buildroot configuration is Xorg/Openbox/Xfbdev-oriented. Hyprland is not currently built or integrated. The Astal runtime and its exact GJS/GTK4/Astal dependency versions are not yet packaged in the Buildroot image. Do not mark this shell as runnable until the runtime is built and a smoke test succeeds.

Buildroot does not inherit Arch packages. Each dependency must be available as a Buildroot package or maintained as a reproducible external package with pinned source, license, hash and dependency closure. Avoid introducing a fake package recipe or floating Git branch.

## Hardware and boot safety

- Keep the tablet's Windows 11 installation and internal storage untouched.
- Do not format, partition, mount writable or install a bootloader to internal storage.
- Keep Secure Boot enabled. Do not enroll or erase firmware keys as a workaround.
- Identify CPU, RAM, GPU, firmware architecture, touch controller, Wi-Fi and Secure Boot trust chain first.
- Validate build and session in QEMU before physical USB boot.
- Current GRUB image path is not Secure Boot validated; it cannot be advertised as bootable with Secure Boot enabled.

## Validation checklist

- [ ] Buildroot base build succeeds on current branch head.
- [ ] Hyprland and all pinned dependencies build for target architecture.
- [ ] Astal/GJS/GTK4 runtime and shell build and launch.
- [ ] Shell launcher handles no installed desktop apps without crashing.
- [ ] QEMU/OVMF Wayland session smoke test passes.
- [ ] Touchscreen, rotation, keyboard and on-screen keyboard tested on DATEN.
- [ ] Low-memory profile tested.
- [ ] Secure Boot trust chain validated without changing firmware keys/settings.
- [ ] USB boot tested while Windows 11 and internal storage remain unchanged.

Until these checks pass, this branch contains development source, not a bootable desktop image.
