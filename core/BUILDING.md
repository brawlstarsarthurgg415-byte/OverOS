# Compilar o núcleo inicial

O build compila componentes nativos em C e C++ usando CMake e um compilador C++.

## Dependências no computador de desenvolvimento

- CMake 3.16 ou superior
- GCC/G++ ou Clang com suporte a C++20
- Make ou Ninja

## Compilar

Na raiz do repositório:

```sh
bash scripts/build-core.sh
```

Os binários ficam em `out/core-build/`.

## Componentes

- `overos-init`: protótipo de PID 1; instalado em `sbin/`, mas não deve ser usado como init de produção.
- `overos-hardware-info`: inventário de hardware somente leitura.
- `overos-session`: primeira sessão de console com menu nativo, instalada em `sbin/`.
- `overosctl` e `overos-hardware-info`: ferramentas de diagnóstico instaladas em `bin/`.

## Aviso

Ainda não copie `overos-init` para o sistema em execução nem o configure como PID 1 no computador principal. O init ainda não possui gerenciamento completo de sinais, montagem de root real, supervisão de serviços, logs persistentes, tratamento de falhas e desligamento seguro. É um componente em desenvolvimento, não um init de produção.

Esta compilação não gera uma ISO nem grava pendrive. A imagem USB depende da toolchain/rootfs, bootloader UEFI assinado e testes de Secure Boot.
