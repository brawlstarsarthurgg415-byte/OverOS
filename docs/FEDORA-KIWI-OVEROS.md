# OverOS Fedora KIWI integration

The Fedora image-description repository is included as a Git submodule at
`vendor/fedora-kiwi-descriptions`, pinned to upstream commit
`daf359394913068f4fc18a8b7aafc404caeb8257`.

Official upstream:
https://forge.fedoraproject.org/releng/kiwi-descriptions.git

The pinned commit is an upstream Fedora commit preserved in the public
t2linux mirror's history:
https://github.com/t2linux/fedora-kiwi-descriptions/commit/daf359394913068f4fc18a8b7aafc404caeb8257

OverOS keeps its customizations in `patches/overos-fedora-kiwi.patch`,
rather than rewriting Fedora's source files in place. The patch:

- makes the normal “Start Fedora” menu entry the default;
- sets the x86_64 Live ISO menu timeout to five seconds;
- adds a shared touchscreen-support profile to LiveInstall and BootDiskCore,
  covering both the live environment and the installed system.

The profile installs libinput and linux-firmware. Fedora's kernel modules
remain responsible for controller-specific support and are loaded by udev
from hardware modaliases; this avoids forcing unrelated modules onto every
machine.

The build workflow currently targets the Fedora Workstation Live profile.
