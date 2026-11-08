# OverOS ISO profile

This folder defines the first bootable OverOS live-image overlay.

The build starts from Archiso's upstream `releng` profile, then adds the project's Wayland-oriented package set and a starter Sway configuration for the live user's skeleton directory.

## Build locally on Arch Linux

Install `archiso`, then run:

```sh
bash scripts/build-iso.sh
```

The ISO is written to `out/`.

## Build on GitHub

Open **Actions → Build OverOS ISO → Run workflow**. A successful run uploads an artifact named `OverOS-ISO-<commit>`.

## Important

- This is an initial Arch Linux live ISO, not yet a graphical installer or a finished desktop distribution.
- Sway is a first compositor candidate, not a confirmed choice for the Intelbras i30.
- The Intelbras i30 GPU is not confirmed. Test the ISO in a VM and on supported modern hardware first; do not assume it will start a Wayland session on the i30.
- No disk installation or partitioning is automated by this profile.
