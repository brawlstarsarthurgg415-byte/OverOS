#version=F45
lang pt_BR.UTF-8
keyboard --xlayouts='br'
timezone America/Sao_Paulo --utc
rootpw --lock
user --name=liveuser --groups=wheel --password=liveuser --plaintext
firewall --enabled --service=mdns,ssh
selinux --enforcing
bootloader --timeout=2 --append="rhgb quiet rd.live.ram=1"
zerombr
clearpart --all --initlabel
autopart --type=plain
shutdown

%packages
dracut-live
@^workstation-product-environment
gnome-shell
gnome-session-wayland-session
hyprland
xdg-desktop-portal-hyprland
waybar
wofi
kitty
sddm
kernel
kernel-modules
kernel-modules-extra
linux-firmware
libinput
mesa-dri-drivers
NetworkManager
firewalld
openssh-server
gnome-software
-onboard
%end

%post --erroronfail
systemctl enable NetworkManager
systemctl enable firewalld
# Leave the signed Fedora shim/GRUB/kernel packages intact for Secure Boot validation.
# RAM boot is requested via rd.live.ram=1; actual USB removal must be tested on target hardware.
%end
