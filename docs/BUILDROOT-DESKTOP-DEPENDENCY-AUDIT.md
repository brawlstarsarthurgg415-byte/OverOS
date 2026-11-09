# Buildroot desktop dependency audit — OverOS DATEN branch

## Scope

This audit checks the upstream Buildroot **2025.02** package tree used by
`scripts/build-buildroot-rootfs.sh`. It is a package-availability audit, not
a hardware compatibility test.

Upstream package tree:
https://github.com/buildroot/buildroot/tree/2025.02/package

## Components already present upstream

The 2025.02 tree contains package recipes for:

- Wayland and wayland-protocols
- libinput
- seatd
- Mesa 3D
- wlroots
- GLib 2
- GObject Introspection
- Cairo and Pango

These are useful building blocks, but do not by themselves provide the
selected OverOS desktop.

## Critical components not present as upstream packages

The same package tree does not contain direct package recipes for:

- GTK 4
- GJS
- Astal
- Hyprland

A similarly named GTK-related package (for example gtkmm3 or gtk2-engines)
is not a substitute for GTK 4. wlroots is not a substitute for Hyprland,
and a GTK4 host development package does not provide target-side libraries.

## Engineering consequence

Do not add `BR2_PACKAGE_GTK4=y`, `BR2_PACKAGE_GJS=y`,
`BR2_PACKAGE_ASTAL=y` or `BR2_PACKAGE_HYPRLAND=y` as guessed Kconfig
symbols: they are not supplied by this Buildroot release.

To deliver the selected stack, the project needs a maintained
`BR2_EXTERNAL` tree or upstreamed package recipes, each with:

1. Pinned release/tag or immutable source commit.
2. Verified archive hash and license metadata.
3. Complete target dependency closure and correct host tools.
4. Cross-compilation support for x86_64/musl.
5. Runtime integration and reproducible tests.

GTK 4 and GJS are foundational dependencies for the current Astal app.
Hyprland also needs a compatible graphics/Wayland stack and its own
dependency set. This is a separate engineering milestone, not a small
configuration toggle.

## Safe current state

- Keep the existing Buildroot/Openbox fallback as-is.
- Do not enable the experimental Hyprland config at boot.
- Do not claim Astal is runnable until the target runtime is packaged and
  the shell launches successfully.
- Keep the DATEN's Windows 11 installation and internal storage untouched.
- Keep Secure Boot enabled; do not bypass it or change firmware keys.

This audit prevents a misleading "successful build" caused by adding
nonexistent Kconfig options.
