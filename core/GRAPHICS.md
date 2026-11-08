# Gráficos e imagens no OverOS

A interface não será feita com uma única linguagem. Cada tecnologia terá uma função clara:

- **C++20:** lógica do shell, janelas, serviços de interface e integração com dispositivos.
- **Cairo/Pango ou toolkit GTK:** desenho 2D, texto, ícones e componentes acessíveis.
- **OpenGL ES/Vulkan:** aceleração 2D/3D somente quando GPU e driver suportarem.
- **GLSL:** shaders para sombras, gradientes e efeitos opcionais; nunca necessários para iniciar o desktop.
- **SVG:** ícones vetoriais escaláveis e leves.
- **PNG/WebP:** imagens rasterizadas e fundos.
- **C:** pequenos serviços de sistema e interfaces de baixo nível.

## Regras de desempenho

- Renderização sem GPU deve continuar possível.
- Desativar blur, transparência e animações no perfil de pouca memória.
- Escalar interface para telas pequenas e toque.
- Não incluir dependência de GPU não identificada.
- Não carregar imagens gigantes na memória sem necessidade.

GTK4 foi selecionado para o primeiro protótipo de shell nativo, com build opcional via CMake. O protótipo `overos-desktop` inclui tela inicial e editor de interface touch-friendly. Ainda faltam compositor Wayland, gerenciamento de sessão/login, integração do teclado virtual e validação de GPU, RAM e touch nos equipamentos reais. GTK4 não é ainda uma sessão de desktop completa.
