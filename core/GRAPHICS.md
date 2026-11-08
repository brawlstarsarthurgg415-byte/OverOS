# Gráficos e imagens no OverOS

## Primeira sessão leve

A imagem x86_64 de desenvolvimento está sendo preparada com:
- Xfbdev (servidor X leve baseado em framebuffer).
- Openbox como gerenciador de janelas.
- xterm como terminal gráfico.
- `overos-gui` para iniciar a sessão.
- Menu de contexto com botão direito e atalhos de teclado.
- Console como fallback se o servidor gráfico não iniciar.

O perfil gráfico é iniciado ao entrar no primeiro console. Se Xfbdev/Openbox falhar, o usuário permanece no terminal. A configuração inicial de rede apresenta `nmtui` antes da tentativa de iniciar a interface.

## Evolução do shell

A interface própria do OverOS não é substituída por Openbox: Openbox é a primeira camada gráfica leve para disponibilizar janelas e terminal. O protótipo GTK4 `overos-desktop` continua separado e ainda precisa ser compilado contra bibliotecas do alvo antes de entrar na imagem.

## Tecnologias planejadas

- **C++20:** lógica do shell, janelas e integração com dispositivos.
- **Cairo/Pango ou GTK:** desenho 2D, texto, ícones e componentes acessíveis.
- **OpenGL ES/Vulkan:** aceleração somente quando GPU e driver suportarem.
- **GLSL:** efeitos opcionais; nunca necessários para iniciar o desktop.
- **SVG:** ícones vetoriais escaláveis.
- **PNG/WebP:** imagens rasterizadas e fundos.

## Regras de desempenho

- Renderização por framebuffer/software deve continuar possível.
- Desativar blur, transparência e animações no perfil de pouca memória.
- Escalar interface para telas pequenas e toque.
- Não exigir GPU específica para chegar ao console.
- Não carregar imagens gigantes na memória sem necessidade.

Ainda faltam validar Xfbdev, driver de vídeo, teclado, touch e memória no hardware real. A presença dos pacotes na configuração não é prova de compatibilidade física.
