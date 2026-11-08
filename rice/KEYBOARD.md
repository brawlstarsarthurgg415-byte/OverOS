# Teclado virtual e componentes touch

O tema GTK4/Astal importa `touch-keyboard.css` junto dos componentes base.

- `.overos-keyboard`: painel inferior.
- `.overos-keyboard-row`: linha de teclas.
- `button.overos-key`: tecla padrão.
- `button.overos-key.utility`: modificadores e ações.
- `.overos-touch`: perfil com alvos maiores.
- `keyboard/keyboard.ui`: estrutura GtkBuilder com IDs estáveis.
- `keyboard/pt-BR-abnt2.json`: mapa lógico ABNT2.

O perfil tablet usa teclas com pelo menos 56 px de altura e controles gerais com pelo menos 48 px. O layout deve adaptar-se à orientação e à escala da tela sem remover o suporte a mouse, trackpad e teclado físico.

O arquivo GtkBuilder fornece a estrutura visual; o shell deve ligar os botões ao adaptador de teclado virtual Wayland autorizado. Não ligar teclas a comandos de shell nem abrir `/dev/input` com privilégios elevados.

Veja `keyboard/README.md` e `../core/TOUCH-AND-KEYBOARD.md` para o contrato do backend, privacidade e testes de aceite. A entrega de eventos, composição de dead keys e abertura automática por foco continuam pendentes até a implementação e teste do backend do compositor.
