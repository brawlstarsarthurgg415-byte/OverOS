#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "\${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
SPEC="$ROOT/board/overos/rootfs-overlay/usr/bin/specman"
chmod +x "$SPEC"

"$SPEC" version | grep -q '^Specman 0.1.0$'
mkdir -p "$TMP/pkg/payload/usr/bin"
cat > "$TMP/pkg/.PKGINFO" <<'EOF'
name=hello-overos
version=1.0.0
arch=$(uname -m)
description=Specman test package
bin=hello-overos
EOF
cat > "$TMP/pkg/payload/usr/bin/hello-overos" <<'EOF'
#!/bin/sh
echo "Hello from OverOS"
EOF
chmod 0755 "$TMP/pkg/payload/usr/bin/hello-overos"
"$SPEC" create "$TMP/pkg" "$TMP/hello-overos.spkg" > "$TMP/create.log"
HASH="$(sha256sum "$TMP/hello-overos.spkg" | awk '{print $1}')"
SPEC_MAN_ROOT="$TMP/root" "$SPEC" install "$TMP/hello-overos.spkg" "$HASH"
SPEC_MAN_ROOT="$TMP/root" "$SPEC" list | grep -q 'hello-overos 1.0.0'
SPEC_MAN_ROOT="$TMP/root" "$SPEC" info hello-overos | grep -q '^version=1.0.0$'
"$TMP/root/usr/local/bin/hello-overos" | grep -q 'Hello from OverOS'
SPEC_MAN_ROOT="$TMP/root" "$SPEC" remove hello-overos
[ ! -e "$TMP/root/usr/local/bin/hello-overos" ]
[ ! -e "$TMP/root/opt/specman/packages/hello-overos/1.0.0" ]

if SPEC_MAN_ROOT="$TMP/root2" "$SPEC" install "$TMP/hello-overos.spkg" "0000000000000000000000000000000000000000000000000000000000000000"; then
  echo "Specman accepted an incorrect SHA-256" >&2
  exit 1
fi

echo "Specman package create/install/list/info/remove/hash tests passed."
