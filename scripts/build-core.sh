#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/out/core-build}"

for tool in cmake c++; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf 'ERRO: ferramenta ausente: %s\n' "$tool" >&2
    exit 1
  }
done

cmake -S "$ROOT/core" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD_DIR" --parallel
printf '\nBuild concluido. Binarios em: %s\n' "$BUILD_DIR"
