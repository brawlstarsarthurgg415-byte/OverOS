#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS="$ROOT/out/rootfs-staging"

fail() { printf 'ERRO: %s\n' "$1" >&2; exit 1; }

[ -d "$ROOTFS" ] || fail "staging rootfs ausente"
[ -x "$ROOTFS/usr/sbin/overos-init" ] || fail "overos-init ausente"
[ -x "$ROOTFS/usr/sbin/overos-session" ] || fail "overos-session ausente"
[ -x "$ROOTFS/usr/sbin/overos-supervisor" ] || fail "overos-supervisor ausente"
[ -x "$ROOTFS/usr/bin/overos-hardware-info" ] || fail "inventario de hardware ausente"
[ -x "$ROOTFS/usr/bin/overosctl" ] || fail "overosctl ausente"
[ -L "$ROOTFS/bin" ] || fail "link /bin ausente"
[ -L "$ROOTFS/sbin" ] || fail "link /sbin ausente"
grep -q '^ID=overos$' "$ROOTFS/etc/os-release" || fail "os-release incorreto"
grep -q 'not a bootable operating system' "$ROOTFS/usr/share/overos/BUILD-MANIFEST.txt" || fail "manifesto nao identifica staging como nao inicializavel"

printf 'Staging rootfs validado: cinco binarios, metadados e links de compatibilidade.\n'
printf 'Este artefato continua sendo somente uma arvore de desenvolvimento, nao um SO bootavel.\n'
