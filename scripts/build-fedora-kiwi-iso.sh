#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root/vendor/fedora-kiwi-descriptions"
output_dir="$repo_root/out/fedora-kiwi"

git -C "$repo_root" submodule update --init --recursive
test -f "$source_dir/Fedora.kiwi"
mkdir -p "$output_dir"

cd "$source_dir"
git apply --check "$repo_root/patches/overos-fedora-kiwi.patch"
git apply "$repo_root/patches/overos-fedora-kiwi.patch"

./kiwi-build \
  --kiwi-file=Fedora.kiwi \
  --image-type=iso \
  --image-profile=Workstation-Live \
  --output-dir "$output_dir"

shopt -s nullglob
isos=("$output_dir"/*.iso)
if [ "${#isos[@]}" -ne 1 ] || [ ! -s "${isos[0]}" ]; then
  echo "Expected exactly one non-empty Fedora KIWI Live ISO in $output_dir" >&2
  find "$output_dir" -maxdepth 2 -type f -printf '%p (%s bytes)\\n' >&2 || true
  exit 1
fi
echo "Validated Fedora KIWI ISO: ${isos[0]} ($(stat -c%s "${isos[0]}") bytes)"
