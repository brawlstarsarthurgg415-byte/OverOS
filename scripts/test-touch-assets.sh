#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LAYOUT="$ROOT/rice/keyboard/pt-BR-abnt2.json"
CSS="$ROOT/rice/touch-keyboard.css"
PROFILE="$ROOT/rice/input-tablet.conf"

command -v node >/dev/null 2>&1 || { echo "ERRO: Node.js necessario para validar JSON." >&2; exit 1; }
node - "$LAYOUT" <<'NODE'
const fs = require("fs");
const path = process.argv[2];
const data = JSON.parse(fs.readFileSync(path, "utf8"));
if (data.id !== "pt-BR-abnt2" || data.language !== "pt-BR") throw new Error("Identidade do layout incorreta");
if (!Array.isArray(data.rows) || data.rows.length < 4) throw new Error("Linhas do teclado ausentes");
const keys = data.rows.flat();
for (const key of keys) {
  if (!Array.isArray(key) || typeof key[0] !== "string" || typeof key[1] !== "string") {
    throw new Error("Definicao de tecla invalida");
  }
}
for (const required of ["BackSpace", "Return", "space", "Shift_L", "Shift_R"]) {
  if (!keys.some(key => key[1] === required)) throw new Error("Tecla obrigatoria ausente: " + required);
}
if (data.behavior.passwordSuggestions !== false || data.behavior.storeTypedText !== false) {
  throw new Error("Politica de privacidade do teclado invalida");
}
console.log("Layout ABNT2 valido: " + keys.length + " teclas/acoes.");
NODE

grep -q 'min-width: 48px' "$CSS" || { echo "ERRO: teclas abaixo do alvo touch minimo." >&2; exit 1; }
grep -q 'min-height: 48px' "$CSS" || { echo "ERRO: altura de tecla abaixo do alvo touch minimo." >&2; exit 1; }
grep -q 'show_virtual_keyboard=on_text_focus' "$PROFILE" || { echo "ERRO: perfil tablet sem politica de foco." >&2; exit 1; }
echo "Ativos touch e teclado validados."
