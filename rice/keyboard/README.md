# OverOS Virtual Keyboard

This directory contains the ABNT2 layout and GTK4 presentation contract.

- `pt-BR-abnt2.json`: declarative key labels, symbols, layers and privacy policy.
- `keyboard.ui`: GtkBuilder presentation skeleton with stable widget IDs.
- `README.md`: frontend/backend integration contract.

## Runtime contract

The shell owns visibility and focus tracking. A key press is translated to a keysym and sent through a compositor-approved virtual-keyboard protocol adapter. The UI must never write to `/dev/input/event*`, invoke shell commands for key presses, or run as root just to inject input.

The adapter should expose `press(keysym)`, `release(keysym)`, `set_modifiers(shift, caps_lock, control, alt)`, `set_visible(bool)` and `set_layout("pt-BR-abnt2")`. It must report unavailable protocol support; the shell then disables virtual input while preserving physical input.

Dead keys are stateful: acute, grave, tilde and circumflex must compose with compatible characters. Password fields disable suggestions and all text retention. No key logging, telemetry of key content, clipboard scraping, or persisted typed text is permitted.

## Release acceptance tests

1. Type into a GTK text entry and a non-GTK Wayland app.
2. Validate ç, Ç, á, à, ã, â, é, ê, í, ó, ô, õ and ú.
3. Validate Shift, Caps Lock, Backspace, Enter, Tab, Space and symbol layer.
4. Confirm password entries never receive suggestions or history.
5. Confirm physical keyboard and pointer work while the virtual keyboard is visible.
6. Rotate the display and test 100%, 125% and 150% scaling.
7. Confirm no privileged device access is required.

A visual mockup or successful CSS load does not satisfy these tests.
