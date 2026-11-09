#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
TMP_DIR="$(mktemp -d)"
LOG="$TMP_DIR/rejection.log"
LINK="$OUT/.image-output-guard-test-link"
TARGET="$OUT/.image-output-guard-test-target"

cleanup() {
  rm -f "$LINK" "$TARGET"
  rmdir "$OUT" 2>/dev/null || true
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

expect_rejected() {
  local path="$1"
  local message="$2"
  if OVEROS_IMAGE="$path" bash "$ROOT/scripts/build-bootable-img.sh" >"$LOG" 2>&1; then
    echo "Unsafe image output was unexpectedly accepted: $path" >&2
    exit 1
  fi
  grep -Fq "$message" "$LOG" || {
    cat "$LOG" >&2
    echo "Expected rejection message was not found for: $path" >&2
    exit 1
  }
}

expect_rejected "/dev/null" "physical disks and external paths are forbidden"
expect_rejected "$TMP_DIR/outside.img" "physical disks and external paths are forbidden"

mkdir -p "$OUT"
printf 'guard-test\n' > "$TARGET"
ln -s "$TARGET" "$LINK"
expect_rejected "$LINK" "refusing to replace a symbolic link"

echo "Image output guard tests passed."
