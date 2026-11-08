# Staging do rootfs de desenvolvimento

O script `scripts/stage-rootfs.sh` organiza os binarios compilados em uma arvore temporaria em `out/rootfs-staging`.

## Uso

```sh
bash scripts/build-core.sh
bash scripts/stage-rootfs.sh
```

O staging contem somente os quatro programas nativos iniciais e metadados `os-release`. Ele **nao e inicializavel**: ainda faltam kernel, libc, shell, drivers, firmware, bootloader, rede, audio e banco de pacotes.

O script remove e recria somente o diretorio de staging configurado dentro de `out/`. Nao procura, monta, particiona ou grava em discos fisicos. Para escolher outro caminho de staging, defina `ROOTFS=/caminho/de/staging`; use somente um diretorio de trabalho descartavel.

Este resultado serve para validar layout e permissao dos binarios, nao para gravar em pendrive.
