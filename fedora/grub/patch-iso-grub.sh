#!/usr/bin/env bash
set -euo pipefail

iso_dir="${1:?usage: patch-iso-grub.sh DIRECTORY}"
shopt -s nullglob
isos=("$iso_dir"/*.iso)
if [ "${#isos[@]}" -ne 1 ]; then
  echo "Expected exactly one ISO in $iso_dir; found ${#isos[@]}" >&2
  exit 1
fi

input="${isos[0]}"
patched="${input%.iso}-overos.iso"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

xorriso -osirrox on -indev "$input" -extract / "$work/tree" >/dev/null 2>&1
mapfile -t configs < <(find "$work/tree" -type f -iname 'grub.cfg' -o -type f -iname 'grub.conf')
if [ "${#configs[@]}" -eq 0 ]; then
  echo "No GRUB configuration found in ISO; refusing to publish an unmodified image." >&2
  exit 1
fi

for cfg in "${configs[@]}"; do
  python3 - "$cfg" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
s = p.read_text(errors="replace")
# Keep Fedora's signed shim/GRUB binaries intact. Only adjust text configuration.
s = re.sub(r'(?m)^\s*set\s+default=.*$', 'set default=0', s)
s = re.sub(r'(?m)^\s*set\s+timeout_style=.*$', 'set timeout_style=menu', s)
s = re.sub(r'(?m)^\s*set\s+timeout=.*$', 'set timeout=1', s)
if not re.search(r'(?m)^\s*set\s+default=', s):
    s = 'set default=0\n' + s
if not re.search(r'(?m)^\s*set\s+timeout=', s):
    s = 'set timeout=1\n' + s
if not re.search(r'(?m)^\s*set\s+timeout_style=', s):
    s = 'set timeout_style=menu\n' + s
p.write_text(s)
PY
done

# Rebuild the ISO while replaying its original BIOS/UEFI boot metadata.
args=()
for cfg in "${configs[@]}"; do
  rel="${cfg#"$work/tree"}"
  args+=( -map "$cfg" "$rel" )
done
xorriso -indev "$input" -outdev "$patched" -boot_image any replay "${args[@]}" -commit
test -s "$patched"
mv "$patched" "$input"
echo "Patched GRUB menu configuration in $input"
