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
# Keep /boot inside the root filesystem for livemedia-creator.
part / --fstype=ext4 --size=16384 --grow
shutdown

%packages
dracut-live
# Required by Lorax for hybrid BIOS and UEFI boot image assembly.
grub2-pc-modules
grub2-efi-x64
grub2-efi-x64-cdboot
shim-x64
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
%end
