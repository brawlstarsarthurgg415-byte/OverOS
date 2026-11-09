# OverOS

**OverOS** é um projeto de sistema operacional Linux independente, com espaço de usuário próprio, identidade visual própria e foco em funcionar em computadores diferentes, inclusive hardware antigo.

> Este repositório é o projeto OverOS normal. Ele é separado do projeto `overOS-light`.

## Objetivo do sistema

- Construir um root filesystem próprio a partir de componentes individuais.
- Não usar uma imagem pronta de Debian, Arch ou Ubuntu como sistema final.
- Desenvolver serviços e ferramentas principalmente em C e C++.
- Desenvolver o gerenciador próprio Specman, sem depender do gerenciador de outra distribuição.
- Oferecer uma interface visual moderna, com perfil leve e fallback de console.
- Inicializar primeiro por USB, com persistência, sem instalador e sem modificar o disco interno.
- Priorizar boot externo por USB, sem instalador e sem alterar o Windows 11 nem o armazenamento interno do tablet DATEN; dual boot fica fora da primeira etapa.
- Manter Secure Boot habilitado nos equipamentos que serão testados com ele.

## Arquitetura

- Kernel Linux e drivers selecionados para o hardware confirmado.
- Toolchain e sysroot próprios para a arquitetura alvo.
- libc, shell, utilitários e serviços montados como componentes separados.
- Init e ferramentas nativas do OverOS.
- Pacotes assinados e repositório próprio.
- Sessão gráfica modular, com perfil touchscreen e fallback para hardware legado.

O uso de Ubuntu no runner do GitHub Actions serve apenas como máquina hospedeira de desenvolvimento. O rootfs de destino agora é construído pelo Buildroot com BusyBox e musl; Debian não é usado como sistema-base da imagem.

## Estado real do desenvolvimento

<badge color="warning">Prototipagem inicial</badge>

- [x] Branch de desenvolvimento isolada: `overos-custom-core`.
- [x] Primeiros programas nativos em C e C++.
- [x] Compilação CMake e testes CTest configurados.
- [x] Arquitetura inicial de rootfs, toolchain, pacotes e USB documentada.
- [x] Biblioteca de componentes visuais e perfil touch documentados.
- [x] Script de inventário touchscreen Linux somente leitura.
- [ ] Build validado pelo CI e testes automatizados aprovados para o HEAD atual.
- [x] Configuração Buildroot para toolchain musl, kernel Linux e rootfs BusyBox x86_64.
- [x] Compilação cruzada dos programas nativos OverOS integrada ao fluxo Buildroot.
- [x] Configuração inicial de NetworkManager/nmtui, OpenSSH, Xfbdev, Openbox e xterm.
- [x] Specman MVP local com pacote .spkg, SHA-256 obrigatório e testes automatizados.
- [ ] Pacman/libalpm 7.0.0 compilado para musl e integrado à imagem; validação pendente no CI. Pacotes Arch/glibc não são compatíveis; instalação local de pacotes OverOS é o primeiro alvo.
- [ ] Repositório Specman assinado, dependências e rollback.
- [ ] Validar build completo e boot em QEMU no CI.
- [ ] Validar drivers, rede, touch e interface no hardware real.
- [ ] Evoluir init e supervisor para produção.
- [ ] Validar imagem USB e Secure Boot; perfil específico do tablet DATEN em `docs/DATEN-USB-ASTAL.md`.
- [ ] Integrar e testar Wayland + Hyprland como sessão gráfica, com Astal/GTK4 para shell e widgets; os arquivos CSS em `rice/` são apenas a base visual.
- [ ] Dual boot opcional com Windows 10 projetado, testado e reversível (bloqueado até concluir os critérios de `core/DUAL-BOOT-WINDOWS.md`).

## Pastas importantes

- `core/`: programas nativos, arquitetura do rootfs e toolchain.
- `rice/`: identidade visual e componentes de interface.
- `docs/`: decisões técnicas e inventário de hardware.
- `scripts/`: automação de build e diagnóstico.
- `iso/`: perfil antigo baseado em Archiso, mantido apenas como referência histórica e não como base do OverOS independente.

## Hardware alvo

O Intelbras i30 é um alvo legado experimental. A GPU SiS Mirage 3+ ainda não foi confirmada. O tablet DATEN será testado por USB, preservando o Windows 11 e mantendo Secure Boot ativado. Consulte `docs/DATEN-USB-ASTAL.md`. Modelo, CPU, RAM, arquitetura UEFI, GPU, controlador touchscreen e Wi-Fi precisam ser identificados antes de prometer compatibilidade.

Para inventariar a entrada em um Linux iniciado no equipamento, execute `bash scripts/check-touchscreen.sh`. O script não instala drivers nem altera o dispositivo; consulte `core/TOUCHSCREEN-DIAGNOSTICS.md`.

## Segurança

Nenhum script de build deve selecionar ou formatar discos físicos automaticamente. O criador de imagem deverá produzir primeiro um arquivo de imagem e manter a gravação em pendrive como etapa separada e explicitamente escolhida.

## Aviso

O projeto ainda não é um sistema operacional pronto para uso diário. A rota Buildroot, o desktop leve e o Specman MVP foram adicionados ao código. A imagem ainda precisa passar pelo CI e por testes de boot antes de ser considerada funcional. Os programas atuais são protótipos de espaço de usuário; o init ainda não deve ser usado como PID 1 em uma máquina real. Consulte `core/BUILDING.md` e `core/ROOTFS-LAYOUT.md`.
