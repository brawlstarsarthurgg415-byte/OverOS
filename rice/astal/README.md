# OverOS Astal Shell

This directory is the implementation home for the OverOS desktop shell, inspired by the layout density and modularity of Matshell while keeping an original OverOS identity.

## Planned first screen

- Compact top status panel: clock, workspace indicator, network and battery state.
- Touch-friendly application launcher with large targets.
- Control center for brightness, audio, network and power actions (only when supported).
- Notification surface and a clear exit/recovery path.
- Responsive layout for tablet portrait/landscape and conventional desktop.

## Runtime contract

Astal is the shell/widget layer; Hyprland is the compositor. They are separate processes.
The shell must not be required to start the compositor or expose a recovery terminal.

The eventual entry point will use the Astal GTK4 runtime and installed Astal libraries.
Do not guess package versions or copy a GTK3 example into this GTK4 shell. Confirm the
Astal API version, GJS bindings and Buildroot dependency closure before adding executable
imports or a package recipe.

## Resource profiles

- balanced: subtle transitions; no blur; normal panel refresh.
- low-memory: no blur/shadows, reduced animation, fewer background polls.
- touch: larger hit targets, launcher-first navigation and on-screen keyboard integration.

## Current status

Scaffold only. No Astal application entry point, package recipe, compositor binary or
bootable image is claimed by this directory yet. See docs/DATEN-USB-ASTAL.md.
