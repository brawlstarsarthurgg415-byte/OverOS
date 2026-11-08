#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/work"
OUT="$ROOT/out"
PROFILE="$WORK/profile"

command -v mkarchiso >/dev/null 2>&1 || {
  echo "ERRO: mkarchiso não encontrado. Instale o pacote archiso." >&2
  exit 1
}

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
cp -a /usr/share/archiso/configs/releng "$PROFILE"

# Add the OverOS package set to the official ArchISO releng profile.
cat "$ROOT/iso/packages.x86_64" >> "$PROFILE/packages.x86_64"

# Overlay project configuration without replacing the upstream live profile.
if [ -d "$ROOT/iso/airootfs" ]; then
  cp -a "$ROOT/iso/airootfs/." "$PROFILE/airootfs/"
fi

echo "Building OverOS live ISO from Arch Linux releng profile..."
mkarchiso -v -w "$WORK/build" -o "$OUT" "$PROFILE"

echo "Build finished. ISO files:"
find "$OUT" -maxdepth 1 -type f -name '*.iso' -print
