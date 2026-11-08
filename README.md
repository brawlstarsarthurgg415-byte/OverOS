# OverOS

**OverOS** é um projeto de sistema operacional Linux independente, com espaço de usuário próprio, identidade visual própria e foco em funcionar em computadores diferentes, inclusive hardware antigo.

> Este repositório é o projeto OverOS normal. Ele é separado do projeto `overOS-light`.

## Objetivo do sistema

- Construir um root filesystem próprio a partir de componentes individuais.
- Não usar uma imagem pronta de Debian, Arch ou Ubuntu como sistema final.
- Desenvolver serviços e ferramentas principalmente em C e C++.
- Integrar Pacman/libalpm como gerenciador de pacotes planejado, sem transformar o OverOS em Arch Linux.
- Oferecer uma interface visual moderna, com perfil leve e fallback de console.
- Inicializar por USB, com persistência, sem instalador e sem modificar o disco interno.
- Manter Secure Boot habilitado nos equipamentos que serão testados com ele.

## Arquitetura

- Kernel Linux e drivers selecionados para o hardware confirmado.
- Toolchain e sysroot próprios para a arquitetura alvo.
- libc, shell, utilitários e serviços montados como componentes separados.
- Init e ferramentas nativas do OverOS.
- Pacotes assinados e repositório próprio.
- Sessão gráfica modular, com perfil touchscreen e fallback para hardware legado.

O uso de uma distribuição Linux como máquina hospedeira de desenvolvimento não significa que ela será a base do sistema final.

## Estado real do desenvolvimento

<badge color="warning">Prototipagem inicial</badge>

- [x] Branch de desenvolvimento isolada: `overos-custom-core`.
- [x] Primeiros programas nativos em C e C++.
- [x] Compilação CMake e testes CTest configurados.
- [x] Arquitetura inicial de rootfs, toolchain, pacotes e USB documentada.
- [x] Biblioteca de componentes visuais e perfil touch documentados.
- [x] Script de inventário touchscreen Linux somente leitura.
- [ ] Build validado pelo CI e testes automatizados aprovados para o HEAD atual.
- [ ] Toolchain/sysroot independente.
- [ ] Kernel e drivers compilados para cada perfil.
- [ ] libc e utilitários-base integrados.
- [ ] Init de produção e supervisão de serviços.
- [ ] Pacman/libalpm compilados e integrados.
- [ ] Interface gráfica funcional.
- [ ] Imagem USB inicializável, assinada e testada.

## Pastas importantes

- `core/`: programas nativos, arquitetura do rootfs e toolchain.
- `rice/`: identidade visual e componentes de interface.
- `docs/`: decisões técnicas e inventário de hardware.
- `scripts/`: automação de build e diagnóstico.
- `iso/`: perfil antigo baseado em Archiso, mantido apenas como referência histórica e não como base do OverOS independente.

## Hardware alvo

O Intelbras i30 é um alvo legado experimental. A GPU SiS Mirage 3+ ainda não foi confirmada. O tablet DATEN será testado por USB, preservando o Windows e mantendo Secure Boot ativado. Modelo, CPU, RAM, arquitetura UEFI, GPU, controlador touchscreen e Wi-Fi precisam ser identificados antes de prometer compatibilidade.

Para inventariar a entrada em um Linux iniciado no equipamento, execute `bash scripts/check-touchscreen.sh`. O script não instala drivers nem altera o dispositivo; consulte `core/TOUCHSCREEN-DIAGNOSTICS.md`.

## Segurança

Nenhum script de build deve selecionar ou formatar discos físicos automaticamente. O criador de imagem deverá produzir primeiro um arquivo de imagem e manter a gravação em pendrive como etapa separada e explicitamente escolhida.

## Aviso

O projeto ainda não é um sistema operacional pronto para uso diário. Os programas atuais são protótipos de espaço de usuário; o init ainda não deve ser usado como PID 1 em uma máquina real. Consulte `core/BUILDING.md` e `core/ROOTFS-LAYOUT.md`.
