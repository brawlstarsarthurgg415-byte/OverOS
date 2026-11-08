# OverOS UI Components

Biblioteca inicial de componentes visuais reutilizáveis para o shell GTK4/Astal.

## Botões disponíveis

Carregue `astal.css`, que importa `components.css`, e combine a classe base com uma variante:

| Classe | Uso |
|---|---|
| `overos-button primary` | Ação principal, como iniciar ou confirmar |
| `overos-button secondary` | Ação normal |
| `overos-button ghost` | Ação discreta em barras e menus |
| `overos-button danger` | Ação destrutiva, sempre explícita |
| `overos-button icon` | Botão apenas com ícone |
| `overos-button pill` | Filtro, alternância ou etiqueta clicável |
| `overos-button card-action` | Ação grande em cartões |
| `overos-button selected` | Estado selecionado |
| `overos-button loading` | Ação em andamento; adicionar spinner no conteúdo |

Exemplo de marcação GTK:

```xml
<button class="overos-button primary">
  <label label="Iniciar OverOS"/>
</button>
<button class="overos-button secondary">
  <label label="Configurações"/>
</button>
<button class="overos-button danger">
  <label label="Desligar"/>
</button>
```

Em Astal, aplique as mesmas classes ao widget GTK Button. A classe `overos-touch` no contêiner raiz ativa alvos maiores para telas sensíveis ao toque.

## Regras de interface

- Área mínima de toque: 44 × 44 px; perfil tablet: 48 × 48 px.
- Sempre mostrar texto ou dica acessível em botões só de ícone.
- Ação destrutiva nunca deve ser a ação principal.
- Estados hover, pressionado, selecionado, foco e desabilitado têm aparência própria.
- Animações curtas e sem blur obrigatório para preservar máquinas com pouca RAM.
- Não depender apenas da cor para comunicar estado.

## Estado

A folha de estilos e a especificação dos componentes estão versionadas. A integração em uma tela real do shell e os testes em GTK/Astal ainda precisam ser executados.


## Teclado virtual

Consulte `KEYBOARD.md` para os componentes visuais, `keyboard/pt-BR-abnt2.json` para o layout ABNT2 e `input-tablet.conf` para os padrões do perfil tablet. A integração de eventos Wayland ainda está em desenvolvimento.
