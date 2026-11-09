# OverOS Fedora Live — GNOME + Hyprland + broad Linux input support
# Live-only image: no automatic installation or disk partitioning.
lang en_US.UTF-8
keyboard us
timezone UTC --utc
selinux --enforcing
firewall --enabled
services --enabled=NetworkManager,gdm
bootloader --timeout=5
rootpw --lock
user --name=overos --groups=wheel --password='' --plaintext
autopart --type=plain
%packages
@^workstation-product-environment
hyprland
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
waybar
fuzzel
foot
NetworkManager-wifi
kernel-modules
kernel-modules-extra
linux-firmware
mesa-dri-drivers
vulkan-loader
gnome-tweaks
onboard
%end

%post --erroronfail
# Ensure graphical boot and keep touchscreen support in the standard Fedora kernel.
systemctl set-default graphical.target
mkdir -p /etc/modules-load.d
cat > /etc/modules-load.d/overos-touch.conf <<'EOF'
hid_multitouch
i2c_hid
i2c_hid_acpi
usbhid
hid_generic
EOF
# Prefer GDM/GNOME for the first boot; Hyprland is available as an optional session.
systemctl enable gdm
%end
