# Teclado virtual e experiência touchscreen

## Objetivo
O OverOS terá uma interface confortável para toque e teclado físico. O teclado virtual será um componente do shell, não uma janela que apenas desenha teclas: a integração final precisa enviar eventos ao aplicativo em foco por uma interface autorizada do compositor Wayland.

## Experiência do teclado
- Abre automaticamente quando um campo de texto recebe foco em perfil tablet, se o compositor não oferecer teclado virtual nativo.
- Pode ser aberto/fechado por botão persistente na barra do sistema.
- Fecha por Escape, pelo botão de ocultar ou quando o campo perde foco conforme a política do shell.
- O shell reserva espaço inferior e desloca/redimensiona a área de conteúdo para não cobrir o campo ativo.
- Layout inicial ABNT2 em português brasileiro, com camadas de números/símbolos e navegação.
- Teclas grandes, espaçamento generoso e retorno visual ao toque.
- Shift momentâneo e Caps Lock persistente; Backspace, Enter, Espaço, Tab e Escape.
- Campos de senha sem sugestões, autocorreção ou histórico.
- Não registrar texto digitado nem conteúdo de campos.
- Respeitar orientação, escala e tamanho da tela.

## Integração de entrada
O backend precisa ser escolhido junto do compositor. Em Wayland, a interface gráfica não deve escrever diretamente em `/dev/input/event*` nem simular teclas com privilégios de root.

1. Detectar se o compositor já fornece teclado virtual.
2. Se usar compositor wlroots compatível, avaliar `wlr-virtual-keyboard-unstable-v1` e sua política de acesso.
3. Para outro compositor, implementar o adaptador suportado ou integrar teclado virtual upstream compatível.
4. Se o backend não estiver disponível, manter o shell e o teclado físico funcionando e informar que o teclado virtual está indisponível.
5. Testar foco, composição de acentos, dead keys, ABNT2, senha, acessibilidade e rotação.

O frontend e o layout declarativo ficam desacoplados do backend. Nenhuma tecla é considerada funcional até passar pelo teste de entrada no aplicativo em foco.

## Perfil touch
- Alvos interativos de pelo menos 48 × 48 dp no perfil tablet.
- Espaçamento entre alvos de pelo menos 6 dp quando houver espaço.
- Não depender de hover; todos os estados devem funcionar com toque.
- Suportar toque, mouse, trackpad e teclado físico simultaneamente.
- Gestos com alternativa por botão.
- Scroll com inércia moderada e sem animações pesadas.
- Respeitar escala e orientação retrato/paisagem.
- Não forçar calibração nem alterar o digitizer sem inventário.

## Layout e aceite
O layout inicial está em `rice/keyboard/pt-BR-abnt2.json`. É uma descrição declarativa; não é, sozinho, driver ou backend de eventos.

- [ ] Toque detectado por libinput no dispositivo real.
- [ ] Teclas visuais com alvos mínimos de 48 dp.
- [ ] Teclado aparece ao focar campo editável no perfil tablet.
- [ ] Teclas chegam ao aplicativo em foco pelo backend autorizado.
- [ ] ABNT2, acentos, cedilha, Shift, Caps Lock, números e símbolos validados.
- [ ] Campos de senha sem histórico ou sugestões.
- [ ] Teclado pode ser fechado sem prender o foco.
- [ ] Layout adapta-se a retrato/paisagem e escalas diferentes.
- [ ] Teclado físico continua funcionando com o virtual aberto.
- [ ] Testes em VM e no tablet real concluídos.

## Estado honesto
Este commit adiciona especificação, layout ABNT2, perfil de toque e estilo visual. O backend de eventos Wayland e a abertura automática por foco ainda precisam ser implementados e testados com o compositor escolhido. Não declarar o teclado virtual operacional antes disso.
