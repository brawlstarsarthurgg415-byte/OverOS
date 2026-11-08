# First-login network setup for the OverOS console.
# NetworkManager is started by its Buildroot SysV init script.
if [ -t 0 ] && [ "$(id -u 2>/dev/null)" = "0" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && [ ! -e /var/lib/overos/network-setup.done ]; then
    if command -v nmtui >/dev/null 2>&1; then
        mkdir -p /var/lib/overos
        echo
        echo "OverOS: configure a rede Wi-Fi ou Ethernet antes de continuar."
        nmtui
        : > /var/lib/overos/network-setup.done
    fi
fi
