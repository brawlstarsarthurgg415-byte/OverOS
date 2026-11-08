#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ARCH_DIR="$REPO_ROOT/x86_64"
DB="$ARCH_DIR/overvault.db.tar.zst"

: "${OVERVAULT_SIGNING_KEY:?Set OVERVAULT_SIGNING_KEY to the verified signing key ID}"
[ "$#" -gt 0 ] || {
    echo "Usage: OVERVAULT_SIGNING_KEY=KEY_ID $0 package.pkg.tar.zst [...]" >&2
    exit 2
}

command -v gpg >/dev/null 2>&1 || { echo "gpg is required" >&2; exit 1; }
command -v repo-add >/dev/null 2>&1 || { echo "repo-add is required (from Pacman)" >&2; exit 1; }
mkdir -p "$ARCH_DIR"

for package in "$@"; do
    [ -f "$package" ] || { echo "Package not found: $package" >&2; exit 1; }
    case "$package" in
        *.pkg.tar.zst) ;;
        *) echo "Unsupported package format: $package (expected .pkg.tar.zst)" >&2; exit 1 ;;
    esac
    echo "Signing $(basename "$package")"
    gpg --batch --yes --local-user "$OVERVAULT_SIGNING_KEY" \
        --detach-sign --output "$package.sig" "$package"
done

echo "Updating and signing OverVault database"
repo-add --sign --key "$OVERVAULT_SIGNING_KEY" "$DB" "$@"

echo "OverVault database updated: $DB"
echo "Publish the package archives, their .sig files, and all database files together."
