#!/usr/bin/env bash
set -Eeuo pipefail

cat >&2 <<'NOTICE'
OverOS: geração de ISO bloqueada por segurança.

Este script antigo usava mkarchiso e o perfil releng do Arch Linux.
Esse caminho não produz o sistema independente especificado para o OverOS,
portanto foi desativado para evitar gerar uma imagem com identidade incorreta.

O repositório ainda não possui kernel próprio configurado, initramfs,
rootfs completo, carregador UEFI validado ou cadeia Secure Boot aprovada.
Use scripts/build-core.sh apenas para compilar os protótipos nativos.
Nenhum pendrive ou disco será alterado.
NOTICE
exit 2
