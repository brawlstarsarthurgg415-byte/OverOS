if [ -t 1 ] && [ "$(id -u 2>/dev/null)" = "0" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    echo "OverOS SSH: adicione sua chave publica em /root/.ssh/authorized_keys para acesso remoto."
fi
