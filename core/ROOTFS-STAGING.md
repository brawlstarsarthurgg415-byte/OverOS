# Staging do rootfs de desenvolvimento

O script `scripts/stage-rootfs.sh` organiza os binarios compilados em uma arvore temporaria em `out/rootfs-staging`.

## Uso

```sh
bash scripts/build-core.sh
bash scripts/stage-rootfs.sh
```

O staging contem somente os cinco programas nativos iniciais e metadados `os-release`. Ele **nao e inicializavel**: ainda faltam kernel, libc, shell, drivers, firmware, bootloader, rede, audio e banco de pacotes.

O script remove e recria somente `out/rootfs-staging/`, dentro do repositorio. Nao procura, monta, particiona ou grava em discos fisicos.

Este resultado serve para validar layout e permissao dos binarios, nao para gravar em pendrive.
