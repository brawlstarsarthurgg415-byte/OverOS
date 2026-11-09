#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Dependência ausente no runner: $1" >&2
    exit 1
  }
}

need node
need meson
need ninja

echo "[1/4] Validando sintaxe JavaScript como módulo ES"
node --input-type=module --check < rice/astal/app.js

echo "[2/4] Conferindo arquivos referenciados pelo shell"
for file in rice/overos-shell.css rice/astal.css rice/components.css rice/astal/app.js rice/astal/overos-shell.desktop rice/astal/overos-shell.ini; do
  test -s "$file" || {
    echo "Arquivo ausente ou vazio: $file" >&2
    exit 1
  }
done

echo "[3/4] Configurando projeto Meson"
BUILD_DIR="$ROOT/out/astal-scaffold-build"
DESTDIR="$ROOT/out/astal-scaffold-install"
rm -rf "$BUILD_DIR" "$DESTDIR"
meson setup "$BUILD_DIR" rice/astal
meson install -C "$BUILD_DIR" --destdir "$DESTDIR"

echo "[4/4] Conferindo instalação dos assets"
test -s "$DESTDIR/usr/local/share/overos-shell/app.js"
test -s "$DESTDIR/usr/local/share/overos-shell/overos-shell.css"
test -s "$DESTDIR/usr/local/share/overos-shell/astal.css"
test -s "$DESTDIR/usr/local/share/overos-shell/components.css"

echo "Astal scaffold: verificações estáticas aprovadas."
echo "Aviso: runtime Astal/GJS, Hyprland, Buildroot e hardware não são testados por este script."
