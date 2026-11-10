#version=F45
lang pt_BR.UTF-8
keyboard --xlayouts='br'
timezone America/Sao_Paulo --utc
url --url=https://download.fedoraproject.org/pub/fedora/linux/releases/45/Everything/x86_64/os/
network --bootproto=dhcp --device=link --activate
repo --name=hyprland-copr --baseurl=https://download.copr.fedorainfracloud.org/results/sdegler/hyprland/fedora-45-x86_64/
rootpw --lock
user --name=liveuser --groups=wheel --password=liveuser --plaintext
firewall --enabled --service=mdns,ssh
selinux --enforcing
bootloader --timeout=2 --append="rhgb quiet rd.live.ram=1"
zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=600
# Keep /boot inside the root filesystem so livemedia-creator can locate kernels
# while assembling the SquashFS runtime and rebuilding initramfs images.
part / --fstype=ext4 --size=16384 --grow
shutdown

%packages
dracut-live
# Include BIOS GRUB modules required by livemedia-creator when assembling boot.iso.
grub2-pc-modules
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
