#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
WORK="$OUT/archiso-work"
PROFILE="$WORK/profile"
ISO_OUT="$OUT/iso"

command -v mkarchiso >/dev/null 2>&1 || {
  echo "Erro: mkarchiso não está instalado. Instale o pacote archiso no Arch Linux." >&2
  exit 1
}
[[ -d /usr/share/archiso/configs/releng ]] || {
  echo "Erro: perfil oficial releng do Archiso não encontrado." >&2
  exit 1
}

mkdir -p "$OUT"
rm -rf "$WORK"
mkdir -p "$PROFILE" "$ISO_OUT"
cp -a /usr/share/archiso/configs/releng/. "$PROFILE/"

# Acrescenta os pacotes do OverOS sem substituir a base oficial do Archiso.
if [[ -f "$ROOT/iso/packages.x86_64" ]]; then
  cat "$ROOT/iso/packages.x86_64" >> "$PROFILE/packages.x86_64"
  awk 'NF && $1 !~ /^#/ && !seen[$1]++' "$PROFILE/packages.x86_64" > "$PROFILE/packages.x86_64.tmp"
  mv "$PROFILE/packages.x86_64.tmp" "$PROFILE/packages.x86_64"
fi

# Sobrepõe somente os arquivos de personalização do OverOS.
if [[ -d "$ROOT/iso/airootfs" ]]; then
  cp -a "$ROOT/iso/airootfs/." "$PROFILE/airootfs/"
fi

echo "Gerando ISO Arch Linux personalizada do OverOS..."
mkarchiso -v -w "$WORK/build" -o "$ISO_OUT" "$PROFILE"

shopt -s nullglob
images=("$ISO_OUT"/*.iso)
if (( ${#images[@]} == 0 )); then
  echo "Erro: mkarchiso terminou sem produzir uma ISO." >&2
  exit 1
fi
printf 'ISO gerada: %s\n' "${images[@]}"
