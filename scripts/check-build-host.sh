#!/usr/bin/env bash
set -Eeuo pipefail

printf 'OverOS — verificacao somente leitura do host de build\n\n'
printf 'Sistema: '
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  printf '%s %s\n' "${NAME:-desconhecido}" "${VERSION_ID:-}"
else
  uname -s
fi
printf 'Kernel: %s\n' "$(uname -r)"
printf 'Arquitetura do host: %s\n' "$(uname -m)"
printf '\nFerramentas:\n'

missing=0
for tool in bash cmake cc c++ make git sha256sum; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  [OK] %s: %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  [FALTA] %s\n' "$tool"
    missing=1
  fi
done

if command -v cmake >/dev/null 2>&1; then
  printf '\n'
  cmake --version | head -n 1
fi
if command -v cc >/dev/null 2>&1; then
  cc --version | head -n 1
fi
if command -v c++ >/dev/null 2>&1; then
  c++ --version | head -n 1
fi

printf '\nEsta verificacao nao instala pacotes, nao altera discos e nao escolhe a arquitetura-alvo.\n'
if (( missing )); then
  printf 'Resultado: host incompleto; instale as ferramentas ausentes pelo gerenciador do seu host.\n' >&2
  exit 1
fi
printf 'Resultado: ferramentas basicas presentes. Isso ainda nao valida uma toolchain OverOS.\n'
