#!/bin/sh
# OverOS hardware inventory: read-only, no root required.
set -u

section() { printf '\n== %s ==\n' "$1"; }

section "Sistema"
uname -a 2>/dev/null || true
[ ! -r /etc/os-release ] || cat /etc/os-release

section "CPU"
if [ -r /proc/cpuinfo ]; then
  awk -F: '
    /^model name/ && !m {sub(/^[ \t]+/, "", $2); print "Modelo: " $2; m=1}
    /^flags/ && !f {sub(/^[ \t]+/, "", $2); print "Flags: " $2; f=1}
    /^Features/ && !e {sub(/^[ \t]+/, "", $2); print "Features: " $2; e=1}
    /^processor[ \t]*:/ {n++}
    END {if (n) print "Processadores lógicos: " n}
  ' /proc/cpuinfo
else
  echo "cpuinfo indisponível"
fi

section "Memória"
if [ -r /proc/meminfo ]; then
  awk '/^(MemTotal|MemAvailable|SwapTotal|SwapFree):/ {print}' /proc/meminfo
else
  echo "meminfo indisponível"
fi

section "Dispositivos PCI e drivers"
seen=0
for d in /sys/bus/pci/devices/*; do
  [ -e "$d" ] || continue
  seen=1
  v=""; p=""; c=""; drv=""
  [ ! -r "$d/vendor" ] || v=$(cat "$d/vendor")
  [ ! -r "$d/device" ] || p=$(cat "$d/device")
  [ ! -r "$d/class" ] || c=$(cat "$d/class")
  [ ! -L "$d/driver" ] || drv=$(basename "$(readlink "$d/driver")")
  printf '%s vendor=%s device=%s class=%s driver=%s\n' "${d##*/}" "$v" "$p" "$c" "$drv"
done
[ "$seen" -eq 1 ] || echo "sysfs PCI indisponível"

section "Vídeo"
if [ -d /sys/class/drm ]; then
  for d in /sys/class/drm/*; do
    [ -e "$d" ] || continue
    printf '%s' "${d##*/}"
    [ ! -r "$d/status" ] || printf ' status=%s' "$(cat "$d/status")"
    [ ! -r "$d/enabled" ] || printf ' enabled=%s' "$(cat "$d/enabled")"
    printf '\n'
  done
else
  echo "DRM não encontrado em /sys/class/drm"
fi
if [ -r /proc/fb ]; then
  echo "Framebuffer:"
  cat /proc/fb
fi

section "Rede"
if [ -d /sys/class/net ]; then
  for d in /sys/class/net/*; do
    [ -e "$d" ] || continue
    state=""
    [ ! -r "$d/operstate" ] || state=$(cat "$d/operstate")
    printf '%s state=%s\n' "${d##*/}" "$state"
  done
fi

section "Ferramentas de diagnóstico"
for c in lspci lsusb glxinfo eglinfo; do
  command -v "$c" 2>/dev/null || echo "$c: não instalado"
done

printf '\nRelatório concluído. Nenhuma alteração foi feita.\n'
