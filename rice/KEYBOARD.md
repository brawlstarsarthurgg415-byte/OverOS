# Teclado virtual e componentes touch

O tema importa `touch-keyboard.css` junto dos componentes base.

- `.overos-keyboard`: painel inferior do teclado.
- `.overos-keyboard-row`: linha de teclas.
- `button.overos-key`: tecla padrão.
- `button.overos-key.utility`: modificadores e ações.
- `.overos-touch`: perfil com alvos maiores.

Exemplo GTK:

```xml
<box class="overos-keyboard" orientation="vertical" spacing="6">
  <box class="overos-keyboard-row" spacing="6">
    <button class="overos-key"><label label="Q"/></button>
    <button class="overos-key"><label label="W"/></button>
    <button class="overos-key"><label label="E"/></button>
  </box>
</box>
```

O exemplo documenta a aparência; os handlers precisam chamar o backend Wayland autorizado descrito em `core/TOUCH-AND-KEYBOARD.md`. Não ligar teclas a comandos de shell nem abrir `/dev/input` com privilégios elevados.
