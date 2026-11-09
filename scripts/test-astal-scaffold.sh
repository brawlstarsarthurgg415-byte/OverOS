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
need cc
need pkg-config
need desktop-file-validate

mkdir -p "$ROOT/out"

echo "[1/5] Validando sintaxe JavaScript como módulo ES"
node --input-type=module --check < rice/astal/app.js

echo "[2/5] Validando sintaxe dos estilos GTK4"
cc scripts/validate-gtk-css.c -o "$ROOT/out/validate-gtk-css" $(pkg-config --cflags --libs gtk4)
"$ROOT/out/validate-gtk-css" rice/overos-shell.css

desktop-file-validate rice/astal/overos-shell.desktop

echo "[3/5] Conferindo arquivos referenciados pelo shell"
for file in rice/overos-shell.css rice/astal.css rice/components.css rice/touch-keyboard.css rice/astal/app.js rice/astal/overos-shell.desktop rice/astal/overos-shell.ini; do
  test -s "$file" || {
    echo "Arquivo ausente ou vazio: $file" >&2
    exit 1
  }
done

echo "[4/5] Configurando projeto Meson"
BUILD_DIR="$ROOT/out/astal-scaffold-build"
DESTDIR="$ROOT/out/astal-scaffold-install"
rm -rf "$BUILD_DIR" "$DESTDIR"
meson setup "$BUILD_DIR" rice/astal --prefix=/usr
meson install -C "$BUILD_DIR" --destdir "$DESTDIR"

echo "[5/5] Conferindo instalação dos assets"
test -s "$DESTDIR/usr/share/overos-shell/app.js"
test -s "$DESTDIR/usr/share/overos-shell/overos-shell.css"
test -s "$DESTDIR/usr/share/overos-shell/astal.css"
test -s "$DESTDIR/usr/share/overos-shell/components.css"
test -s "$DESTDIR/usr/share/overos-shell/touch-keyboard.css"
test -s "$DESTDIR/usr/share/overos-shell/overos-shell.ini"
test -s "$DESTDIR/usr/share/applications/overos-shell.desktop"
grep -q 'Exec=gjs -m /usr/share/overos-shell/app.js' "$DESTDIR/usr/share/applications/overos-shell.desktop"

echo "Astal scaffold: verificações estáticas aprovadas."
echo "Aviso: runtime Astal/GJS, Hyprland, Buildroot e hardware não são testados por este script."
