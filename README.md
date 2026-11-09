# OverOS

**OverOS** é um sistema operacional baseado em **Arch Linux**, com identidade visual própria e foco em computadores e tablets.

> O OverOS usa Arch Linux como distribuição-base. A personalização do projeto acontece sobre essa base: perfil Archiso, seleção de pacotes, configuração do sistema, serviços e interface própria.

## Objetivo

- Usar Arch Linux como base do sistema.
- Gerar uma ISO inicializável por USB, sem instalador automático e sem tocar no armazenamento interno.
- Preservar o Windows 11 do tablet DATEN.
- Desenvolver uma experiência visual própria com Wayland, Hyprland e Astal.
- Priorizar touchscreen, mantendo alternativas para teclado e mouse.
- Manter Secure Boot ativado como requisito de validação; não declarar compatibilidade até configurar e testar uma cadeia de boot assinada no hardware real.

## Arquitetura

- Arch Linux + Archiso para gerar a imagem inicial.
- Kernel e pacotes oficiais do Arch Linux, com configuração OverOS.
- Hyprland + Wayland como sessão gráfica pretendida.
- Astal/GTK4 para shell, widgets e componentes próprios; integração ainda em desenvolvimento.
- Ferramentas, serviços, configurações e identidade visual OverOS.

## Estado real

<badge color="warning">Protótipo em desenvolvimento</badge>

- [x] Branch isolada de desenvolvimento DATEN: `daten-usb-astal`.
- [x] Direção visual e protótipos de interface documentados.
- [x] Configuração inicial de pacotes Arch para o desktop.
- [ ] Perfil Archiso completo e compilação da ISO validados no CI.
- [ ] Hyprland e Astal integrados e testados juntos.
- [ ] Drivers, rede e touchscreen validados no tablet.
- [ ] Cadeia de boot Secure Boot assinada e validada no DATEN.
- [ ] Teste de boot USB no hardware real, sem modificar o Windows 11.

## Segurança

A geração da ISO cria apenas um arquivo de imagem como artefato. Ela não grava automaticamente em pendrives ou discos. A primeira etapa é USB-first e não deve instalar, particionar ou formatar o armazenamento interno.

**Secure Boot:** uma ISO Archiso padrão não deve ser considerada compatível com Secure Boot sem uma cadeia de boot assinada e testes específicos. Não desative Secure Boot nem altere chaves do firmware como solução improvisada.

## Pastas

- `iso/`: perfil e personalizações Archiso.
- `rice/`: identidade visual e protótipos da interface.
- `core/`: protótipos nativos e ferramentas experimentais.
- `docs/`: decisões técnicas e validação de hardware.
- `scripts/`: automação de build e diagnóstico.

O projeto ainda não está pronto para uso diário. A ISO inicial, quando compilada, será uma versão de teste; compatibilidade com o tablet DATEN e Secure Boot dependerá de validação real.
