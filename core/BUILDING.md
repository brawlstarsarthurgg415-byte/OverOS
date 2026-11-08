# Compilar o núcleo inicial

O núcleo é escrito principalmente em C11 e C++20. A compilação atual usa o compilador do computador hospedeiro; ela ainda não constrói uma toolchain independente nem um sistema inicializável.

## Requisitos do computador de desenvolvimento

- Linux x86-64 recomendado para o primeiro ciclo de desenvolvimento.
- CMake 3.16 ou superior.
- GCC/G++ ou Clang com suporte a C++20.
- Make ou Ninja.
- Bash e ferramentas POSIX básicas.

Confira o ambiente sem instalar nem alterar nada:

```sh
bash scripts/check-build-host.sh
```

## Compilar e testar

Na raiz do repositório:

```sh
bash scripts/build-core.sh
```

Os binários ficam em `out/core-build/`. O script executa os testes CTest.

Para organizar os programas em uma árvore temporária:

```sh
bash scripts/stage-rootfs.sh
bash scripts/test-rootfs-staging.sh
```

O resultado fica em `out/rootfs-staging/`. É apenas uma árvore de arquivos para desenvolvimento, **não inicializa e não deve ser gravada em pendrive**.

## Componentes

- `overos-init`: protótipo de PID 1; não usar como init de produção.
- `overos-session`: menu inicial de console.
- `overos-hardware-info`: inventário de hardware somente leitura.
- `overosctl`: ferramenta de diagnóstico.
- `overos-supervisor`: supervisor experimental; ainda não é iniciado pelo PID 1.

## Limites e segurança

- Não copie o protótipo de init para o sistema em execução nem o configure como PID 1.
- Não execute scripts de imagem em discos internos.
- O build atual não gera kernel, libc, initramfs, bootloader, Pacman funcional, imagem USB ou cadeia Secure Boot.
- A arquitetura de destino ainda precisa ser confirmada para cada equipamento.
- O tablet DATEN deve continuar com Secure Boot ativo e o Windows intacto. Não altere chaves, partições ou configurações de firmware para contornar incompatibilidades.

Consulte `core/BOOTSTRAP-ROADMAP.md` para a sequência completa e os critérios de conclusão.
