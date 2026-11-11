#version=F45
lang pt_BR.UTF-8
keyboard --xlayouts='br'
timezone America/Sao_Paulo --utc
url --metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-45&arch=x86_64
network --bootproto=dhcp --device=link --activate
repo --name=hyprland-copr --baseurl=https://download.copr.fedorainfracloud.org/results/sdegler/hyprland/fedora-45-x86_64/
rootpw --lock
user --name=liveuser --groups=wheel --password=liveuser --plaintext
firewall --enabled --service=mdns,ssh
selinux --enforcing
bootloader --location=none --timeout=2 --append="rhgb quiet rd.live.ram=1"
zerombr
clearpart --all --initlabel
part / --fstype=ext4 --size=16384 --grow
shutdown

%packages --retries=10
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
