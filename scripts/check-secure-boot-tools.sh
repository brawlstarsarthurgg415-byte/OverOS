#!/usr/bin/env bash
set -euo pipefail

# Read-only inventory of tools useful for Secure Boot development.
# This script does not install packages, create keys, sign files, or modify firmware.

tools=(
  sbsign
  sbverify
  mokutil
  pesign
  qemu-system-x86_64
  qemu-system-aarch64
  ukify
  objcopy
  openssl
)

missing=0
printf '%s\n' 'OverOS Secure Boot tool preflight (read-only)'
for tool in "${tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'FOUND  %s  %s\n' "$tool" "$(command -v "$tool")"
  else
    printf 'MISSING %s\n' "$tool"
    missing=$((missing + 1))
  fi
done

printf '\n%s\n' 'Firmware state is not changed or inferred by this check.'
printf 'Missing tools: %s\n' "$missing"
printf '%s\n' 'Install only the tools needed on a disposable development host or VM.'
exit 0