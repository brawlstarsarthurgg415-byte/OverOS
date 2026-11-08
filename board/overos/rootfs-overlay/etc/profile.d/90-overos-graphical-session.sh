# Start the lightweight graphical session on the first virtual console.
# If Xfbdev/Openbox cannot start, return to the normal shell.
if [ -t 0 ] && [ "$(id -u 2>/dev/null)" = "0" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && [ -z "${OVEROS_GUI_ATTEMPTED:-}" ]; then
    OVEROS_GUI_ATTEMPTED=1
    export OVEROS_GUI_ATTEMPTED
    if [ -x /usr/bin/overos-gui ]; then
        /usr/bin/overos-gui || echo "OverOS: interface grafica indisponivel; terminal continua ativo."
    fi
fi
