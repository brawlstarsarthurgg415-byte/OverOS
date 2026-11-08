# Roteiro de bootstrap independente do OverOS

Este documento transforma a arquitetura em etapas verificáveis. O objetivo é uma distribuição de sistema própria, com identidade, rootfs, serviços, pacotes e interface do OverOS. O kernel Linux upstream é uma base de kernel; isso não significa copiar o rootfs de Debian, Ubuntu ou Arch.

## Estado real

| Camada | Estado |
|---|---|
| Núcleo C/C++ e ferramentas de diagnóstico | Protótipos no repositório |
| Supervisor de serviços | Protótipo experimental |
| Rootfs Buildroot x86_64 (musl + BusyBox) | Configuração e pipeline adicionados; compilação/boot aguardando CI |
| Toolchain e sysroot próprios | Toolchain musl Buildroot e compilação cruzada dos programas OverOS integradas; validação CI pendente |
| Kernel e módulos por equipamento | Kernel x86_64 com fragmento de USB, ext4, EFI, Intel i915 e Broadcom b43; teste físico pendente |
| libc, shell e utilitários-base | musl + BusyBox selecionados; validação de build pendente |
| Gerenciador Specman | MVP local adicionado; CI de criação/instalação/remoção pendente; repositório assinado e dependências ainda faltam |
| Sessão gráfica | Xfbdev + Openbox + xterm configurados; fallback de console; teste em hardware pendente |
| Teclado virtual e touch | Layout ABNT2, perfil tablet e estilos versionados; backend Wayland ainda pendente |
| Boot UEFI e Secure Boot | Planejado, sem cadeia validada |
| Imagem USB persistente | Gerador BIOS/UEFI consome rootfs Buildroot; CI/QEMU ainda pendentes |

## Etapa 0 — identificar os alvos

Não misturar os requisitos dos equipamentos. Cada perfil precisa de inventário próprio, sem gravar no armazenamento interno.

- Intelbras i30: coletar arquitetura, CPU, RAM, GPU, controladores de armazenamento, rede, áudio e dispositivos de entrada.
- Tablet DATEN: coletar modelo exato, arquitetura da CPU, arquitetura do firmware UEFI, RAM, GPU, Wi-Fi, touch e estado de Secure Boot no Windows.
- Registrar o resultado como um perfil de hardware versionado.

**Aceite:** arquitetura e dispositivos identificados; nenhum disco interno alterado. Não presumir que os dois equipamentos usam a mesma arquitetura.

## Etapa 1 — toolchain e sysroot

Primeira configuração adicionada em `buildroot/overos_x86_64_defconfig`. Ela seleciona x86_64, musl, BusyBox init, BusyBox userland e kernel Linux. `scripts/build-buildroot-rootfs.sh` baixa Buildroot 2025.02 e gera `out/overos-buildroot/rootfs.tar` e `bzImage`. Essa primeira configuração ainda precisa ser compilada no CI e validada em QEMU antes de ser considerada aprovada.



- Escolher um triplet de destino explícito por perfil (por exemplo, x86_64 ou aarch64 somente após confirmação).
- Construir ou selecionar uma toolchain cruzada reproduzível.
- Criar sysroot isolado, sem reutilizar bibliotecas do host como bibliotecas do sistema final.
- Fixar origem, versão/commit, SHA-256, patches, flags e dependências de cada componente.
- Registrar compiler ID, linker, ABI e opções de segurança no manifesto de build.

**Aceite:** um programa mínimo C e outro C++ compilam para o destino e são vinculados somente ao sysroot do OverOS.

## Etapa 2 — base de userland

Ordem de integração, com versões e hashes aprovados no manifesto:

1. Headers UAPI do kernel.
2. Binutils e compilador alvo.
3. libc e runtime C/C++.
4. Shell e utilitários essenciais.
5. CA certificates, resolução de nomes, configuração de usuários/grupos e diretórios FHS.
6. Firmware e módulos necessários ao perfil de hardware.

A escolha de libc (glibc ou musl) deve ser feita antes de compilar os demais componentes, porque define ABI e compatibilidade. Não misturar bibliotecas de ABIs diferentes.

**Aceite:** rootfs mínimo executa shell, utilitários, resolução de bibliotecas e operações básicas em ambiente isolado/VM.

## Etapa 3 — kernel e boot de desenvolvimento

- Configurar kernel upstream para cada perfil confirmado.
- Compilar módulos e instalar firmware necessário.
- Criar initramfs reproduzível.
- Implementar boot e recuperação em VM antes de testar hardware real.
- Não instalar bootloader em discos internos.

**Aceite:** boot em VM, console funcional, logs acessíveis e caminho de recuperação testado.

## Etapa 4 — serviços do OverOS

Evoluir init e supervisor antes de usá-los em produção:

- gerenciamento correto de sinais e reaping de processos;
- montagem e verificação do root filesystem;
- logs com rotação e recuperação;
- dependências e ordem dos serviços;
- limites de reinício e backoff;
- encerramento e desligamento seguros;
- permissões, usuários de serviço e isolamento;
- testes de falha e interrupção.

**Aceite:** inicialização, reinicialização de serviço, encerramento e recuperação validados em VM. O protótipo atual não satisfaz esses requisitos.

## Etapa 5 — pacotes

- Compilar e validar o Specman para o mesmo sysroot/ABI; o MVP atual é um script shell instalado no rootfs.
- Criar ferramentas de repositório OverOS e metadados assinados.
- Evoluir o MVP para consultas de repositório e integração com `overosctl`.
- Implementar assinatura do índice, resolução de dependências e transações com rollback; testar em rootfs descartável.
- Só habilitar escrita depois de validar assinaturas, conflitos e recuperação.

**Aceite:** assinatura verificada, instalação e remoção em ambiente descartável, rollback testado e sem tocar no disco interno.

## Etapa 6 — interface gráfica

- Detectar GPU e aceleração disponível antes de escolher compositor.
- Manter perfil econômico com fallback por software.
- A primeira sessão Openbox/Xfbdev já está configurada como desktop leve, com xterm e menu básico. Evoluir o protótipo GTK4 `overos-desktop` para shell e componentes visuais reutilizáveis em C/C++.
- Integrar compositor, login/session manager, teclado virtual e início automático da sessão após o boot.
- Suportar SVG, PNG/WebP, Cairo/Pango e, quando houver driver, OpenGL ES/Vulkan e GLSL.
- Perfil touchscreen com alvos de toque de pelo menos 48 px, teclado virtual ABNT2 e navegação por teclado; backend de eventos ainda pendente.
- Efeitos gráficos devem ser opcionais e desligáveis.

**Aceite:** sessão gráfica utilizável no hardware real e fallback de console disponível.

## Etapa 7 — USB externo, persistência e Secure Boot

- Gerar arquivo de imagem em caminho explicitamente informado.
- Separar criação da imagem de gravação física do pendrive.
- Nunca escolher automaticamente `/dev/sda` ou outro disco.
- Manter rootfs imutável quando possível e dados persistentes em partição separada.
- Para o DATEN, validar uma cadeia EFI assinada que o firmware já confie, sem desativar Secure Boot, apagar chaves ou alterar o Windows.
- Se o firmware não confiar na cadeia disponível, registrar incompatibilidade; não contornar as proteções.

**Aceite:** boot externo e persistência testados, recuperação funcional, Secure Boot ativo e armazenamento interno byte-a-byte preservado.

## Regras de qualidade para todas as etapas

- Builds reproduzíveis e artefatos identificados por hash.
- Testes automatizados em CI e teste manual documentado em VM/hardware.
- Nenhuma etapa pode alegar suporte sem evidência de teste.
- Nenhum script de desenvolvimento pode formatar ou particionar discos físicos.
- Uma falha em um perfil de hardware não deve comprometer os demais.
