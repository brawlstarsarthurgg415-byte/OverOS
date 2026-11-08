# Arquitetura do OverOS independente

## Princípios

1. **Sistema final próprio:** o rootfs será montado a partir de componentes individuais; não será uma cópia de Debian, Arch ou Ubuntu.
2. **Host separado do alvo:** uma distribuição Linux pode hospedar o build, mas seus pacotes e seu rootfs não serão usados como sistema final.
3. **Hardware primeiro:** identificar CPU, GPU, RAM, firmware e dispositivos antes de escolher drivers e sessão gráfica.
4. **Camadas independentes:** kernel, libc, utilitários, serviços, gerenciador de pacotes, compositor e shell devem ser componentes distintos.
5. **Leveza mensurável:** medir RAM, tempo de boot, CPU/GPU e estabilidade.
6. **Recuperação:** manter console de emergência e ferramentas de diagnóstico.
7. **Reversibilidade:** a imagem USB não deve alterar o disco interno do computador.

## Camadas alvo

| Camada | Tecnologia/direção | Situação |
|---|---|---|
| Kernel | Linux, configurado por perfil de hardware | Não integrado |
| Toolchain | GCC/binutils ou LLVM, sysroot próprio | Planejado |
| libc | Seleção após teste de compatibilidade | Em avaliação |
| Utilitários | Componentes individuais compilados para o sysroot | Não integrado |
| Init | overos-init em C, atualmente protótipo | Experimental |
| Serviços | Supervisão, logs, dispositivos e rede | Planejado |
| Pacotes | Pacman/libalpm e repositório OverOS assinado | Planejado |
| Sessão | Console nativo com fallback | Protótipo |
| Gráficos | GTK/Cairo/Pango, SVG, OpenGL ES/Vulkan quando suportado | Planejado |
| Boot | UEFI USB, cadeia assinada e persistência | Planejado |

## Gerenciador de pacotes

Pacman/libalpm é a tecnologia escolhida para gerenciar transações e dependências. Isso não obriga o sistema a usar Arch Linux como rootfs. O OverOS terá seus próprios pacotes, repositórios, seleção de componentes, chaves e processo de build. Consulte [PACKAGE-MANAGER.md](../core/PACKAGE-MANAGER.md).

## Perfil visual

A interface deve ser visualmente consistente e reutilizar componentes próprios. O perfil touchscreen terá áreas de toque maiores; o perfil legado reduzirá animações, transparências e dependências gráficas. O console continua disponível para recuperação.

## Perfis de hardware

### Perfil moderno

Máquinas x86_64 com drivers funcionais para o kernel e stack gráfica selecionados. Efeitos visuais serão habilitados conforme a GPU suportar.

### Perfil legado experimental

O Intelbras i30 será tratado como equipamento legado. A GPU SiS Mirage 3+ permanece não confirmada. A seleção do driver, compositor e resolução depende do inventário real e de testes.

### Perfil tablet DATEN

A inicialização deve ocorrer pelo USB, preservar o Windows 10 interno e manter Secure Boot ativado. O modelo exato e a cadeia de confiança do firmware precisam ser confirmados antes de selecionar o carregador UEFI.

## Critérios de aceite

- Compilação reproduzível e testes automatizados aprovados.
- Boot em máquina virtual antes de testar hardware físico.
- Console de recuperação funcional.
- Teclado, touch, vídeo, áudio e rede testados por perfil.
- Persistência USB testada após reinicialização.
- Secure Boot mantido habilitado no tablet.
- Nenhuma alteração no armazenamento interno do tablet.

## Referências de implementação

- [Toolchain e sysroot](../core/TOOLCHAIN.md)
- [Layout do rootfs](../core/ROOTFS-LAYOUT.md)
- [Boot USB](../core/BOOT-AND-USB.md)
- [Build e limitações atuais](../core/BUILDING.md)
