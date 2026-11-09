# OverOS Astal Shell

Este diretório contém o primeiro protótipo de interface GTK4/GJS do OverOS. A direção visual é original e usa Matshell apenas como referência de organização modular — não como código ou identidade para copiar.

## O que o protótipo já contém

- Janela principal com identidade visual OverOS.
- Relógio local.
- Launcher que enumera aplicativos instalados via Gio e permite pesquisar.
- Painel lateral com ações de configurações e bloqueio de sessão (dependem dos serviços disponíveis).
- Estilos GTK4 em `overos-shell.css`, `astal.css` e `components.css`.

## Separação das camadas

Astal/GJS é a camada de shell e widgets; Hyprland é o compositor Wayland. São componentes separados. O protótipo atual cria uma janela GTK normal: ainda não é uma camada de painel/overlay ancorada ao compositor, nem substitui a sessão gráfica padrão.

## Perfis planejados

- **balanced:** transições discretas e sem blur.
- **low-memory:** animações reduzidas e menos atualizações em segundo plano.
- **touch:** alvos maiores, launcher em primeiro plano e teclado virtual.

## Limitações atuais

- O protótipo ainda não foi executado contra uma versão instalada do runtime Astal/GJS.
- Astal, GTK4, GJS, Hyprland e as dependências Wayland ainda não estão empacotados na configuração Buildroot.
- O arquivo de configuração Hyprland é experimental e não é ativado no boot.
- Não há integração com o rootfs, imagem USB, teste QEMU ou teste no tablet.
- A compatibilidade com touchscreen, GPU e Secure Boot do DATEN ainda não foi comprovada.

O CI desta branch verifica sintaxe JavaScript e a instalação dos arquivos estáticos via Meson. Isso não equivale a compilar/validar o runtime Astal nem a testar a interface em hardware.
