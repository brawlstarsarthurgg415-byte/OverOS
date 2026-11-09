# Perfil Archiso do OverOS

Este diretório contém as personalizações aplicadas ao perfil oficial `releng` do Archiso.

A distribuição-base do OverOS é Arch Linux. O script `scripts/build-iso.sh` copia o perfil oficial instalado pelo pacote `archiso`, acrescenta os pacotes listados em `packages.x86_64` e sobrepõe os arquivos em `airootfs/`.

A ISO gerada é uma imagem de teste para inicialização externa. Ela não instala o sistema nem altera o armazenamento interno automaticamente.

Hyprland + Wayland + Astal são a direção planejada da interface. A presença de arquivos de configuração ou pacotes candidatos não significa que a sessão gráfica já esteja completamente integrada ou validada.

A ISO padrão não é declarada compatível com Secure Boot. Isso exige uma cadeia de boot assinada e validação no equipamento DATEN mantendo Secure Boot habilitado.
