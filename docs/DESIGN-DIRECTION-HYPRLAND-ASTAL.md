# Direção visual — OverOS Shell (Hyprland + Astal)

Estado: especificação visual + primeiros arquivos de configuração/estilo criados; ainda não representa uma sessão gráfica compilada ou testada.

## Objetivo

Criar uma interface própria do OverOS inspirada em boas práticas de personalização de desktops Linux, sem copiar integralmente outro rice ou depender de uma instalação Arch Linux como sistema final.

## Referências para estudo

- Astal: https://www.astal.dev/ — framework para shells e widgets GTK/Wayland.
- Matshell: https://github.com/Neurarian/matshell — referência para painéis, menus e widgets GTK4/Astal.
- CyberArch-Shell: https://github.com/ARCANGEL0/CyberArch-Shell — referência alternativa para widgets futuristas e HUD.
- Hyprland: https://hypr.land/ — compositor Wayland, sujeito a validação de compatibilidade.

As referências servem para estudar padrões de interface e arquitetura; não são dependências automáticas nem conteúdo para copiar integralmente.

## Proposta inicial de identidade

- Tema escuro com contraste alto e texto legível.
- Uma cor de destaque OverOS, aplicada com moderação a estados ativos, foco e controles.
- Painel superior compacto com hora, bateria, rede e indicadores de sistema.
- Launcher touchscreen com alvos grandes e busca simples.
- Central de controles para Wi-Fi, áudio, brilho e energia, apenas quando os serviços e drivers necessários estiverem integrados.
- Widgets e notificações feitos em Astal/GTK4.
- Cantos arredondados e transparência/blur opcionais, desligados no perfil econômico.
- Escala e espaçamento adaptáveis a telas pequenas e toque.
- Navegação por toque e teclado; manter uma rota de recuperação por console.

## Arquitetura pretendida

1. Wayland fornece a sessão gráfica.
2. Hyprland fornece composição e gerenciamento de janelas, somente se o driver DRM/KMS e a GPU do dispositivo forem compatíveis.
3. Astal fornece o shell e os widgets do OverOS; não substitui o compositor.
4. Serviços nativos do OverOS fornecem informações e ações do sistema através de interfaces explícitas e permissões adequadas.
5. O perfil econômico reduz efeitos e animações para preservar recursos.

## Restrições e critérios de engenharia

- OverOS continua baseado no rootfs próprio Buildroot/BusyBox/musl; Arch Linux é referência de personalização, não a base final do sistema.
- Antes de adicionar dependências ao Buildroot, inventariar CPU, RAM, GPU, firmware UEFI e controlador touchscreen do tablet DATEN.
- Não declarar Hyprland, Astal, toque ou Wi-Fi como funcionais antes de compilar e testar.
- Testar primeiro em QEMU; depois, testar por USB sem instalador e sem modificar o Windows 11 ou o armazenamento interno.
- Manter Secure Boot ativado. Se a cadeia de confiança não puder ser validada sem alterar as chaves ou configurações do firmware, não avançar para um teste que exija contornar essa condição.
- Primeiros arquivos adicionados: `rice/hyprland/hyprland.conf`, `rice/astal/README.md` e `rice/overos-shell.css`.
- O CSS e a configuração Hyprland são scaffolds; ainda não há pacote Buildroot, executável Astal, sessão integrada ou imagem testada.
