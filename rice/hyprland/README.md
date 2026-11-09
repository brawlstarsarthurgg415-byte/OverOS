# OverOS Hyprland profile

The configuration in this folder is a starting profile, not a packaged compositor.

Before enabling it on hardware:

1. Confirm a working DRM/KMS driver and a supported GPU.
2. Build and validate the exact Hyprland release and its wlroots ecosystem dependencies.
3. Confirm Wayland seat access, libinput, Mesa/renderer and a recovery TTY.
4. Replace the example terminal binding with a terminal actually included in the image.
5. Add device-specific touch calibration only after identifying the controller.

Blur and shadows are disabled by default to avoid unnecessary GPU and memory costs.
The Astal shell is a separate process and must be started only after its runtime is installed.
