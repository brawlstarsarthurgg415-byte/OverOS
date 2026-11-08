#!/usr/bin/env bash
set -Eeuo pipefail

# Read-only touchscreen/input inventory. Does not open event nodes or change devices.
shopt -s nullglob
events=(/sys/class/input/event*)
found=0

echo "OverOS — diagnóstico de entrada (somente leitura)"
echo "Kernel: $(uname -r 2>/dev/null || echo desconhecido)"
echo

if command -v libinput >/dev/null 2>&1; then
  echo "== Dispositivos reconhecidos pelo libinput =="
  libinput list-devices || true
  echo
else
  echo "libinput não está instalado; usando inventário sysfs/udev."
  echo
fi

echo "== Dispositivos event do kernel =="
for event in "${events[@]}"; do
  name_file="$event/device/name"
  [[ -r "$name_file" ]] || continue
  name="$(<"$name_file")"
  [[ -n "$name" ]] || continue
  found=$((found + 1))
  node="/dev/input/${event##*/}"
  echo "- $node"
  echo "  Nome: $name"

  if command -v udevadm >/dev/null 2>&1; then
    props="$(udevadm info --query=property --path="$(readlink -f "$event/device")" 2>/dev/null || true)"
    if grep -qx 'ID_INPUT_TOUCHSCREEN=1' <<<"$props"; then
      echo "  Classificação: TOUCHSCREEN (udev)"
    elif grep -qx 'ID_INPUT_TABLET=1' <<<"$props"; then
      echo "  Classificação: mesa/caneta digitalizadora (udev)"
    elif grep -qx 'ID_INPUT_MOUSE=1' <<<"$props"; then
      echo "  Classificação: mouse/dispositivo apontador (udev)"
    elif grep -qx 'ID_INPUT_KEY=1' <<<"$props"; then
      echo "  Classificação: teclado (udev)"
    else
      echo "  Classificação: não identificada pelo udev"
    fi
  else
    case "$name" in
      *[Tt]ouch*|*[Ee]lan*|*[Gg]oodix*|*[Ww]acom*)
        echo "  Classificação: possível touchscreen (heurística pelo nome; confirmar com libinput)"
        ;;
      *)
        echo "  Classificação: não determinada (instale libinput/udev para classificar)"
        ;;
    esac
  fi
done

if (( found == 0 )); then
  echo "Nenhum dispositivo /dev/input/event* encontrado em /sys/class/input."
  echo "Isso pode ocorrer em VM, ambiente sem permissões ou sistema sem driver de entrada."
fi

echo
echo "Importante: este diagnóstico não instala drivers nem testa eventos de toque."
echo "Não execute calibração nem altere firmware com base apenas neste relatório."
