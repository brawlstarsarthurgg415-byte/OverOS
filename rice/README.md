# OverOS Rice

Esta pasta guarda a identidade visual e o protótipo do desktop OverOS.

## Direção visual inicial

- Tema escuro com superfícies em camadas.
- Painel compacto e legível.
- Transparência discreta, sem blur obrigatório.
- Ícones consistentes e tipografia limpa.
- Animações curtas e opcionais.
- Modo econômico que desliga efeitos sem quebrar o layout.

## Regra de implementação

O tema deve funcionar sem depender de Astal. Primeiro definimos tokens visuais e componentes; depois conectamos esses componentes ao shell escolhido. Isso permite trocar o shell se o hardware não suportar a opção inicial.

O protótipo nativo GTK4 agora oferece uma tela inicial e um editor de interface; ainda não é um desktop completo, não possui compositor/login integrado e não foi testado em hardware.


## Biblioteca de componentes

A folha `components.css` é importada por `astal.css` e fornece botões reutilizáveis:
`primary`, `secondary`, `ghost`, `danger`, `icon`, `pill`, `card-action`, `selected` e `loading`.

Consulte [COMPONENTS.md](COMPONENTS.md) para exemplos e regras de acessibilidade. O perfil `.overos-touch` aumenta as áreas de toque para tablets.

## Perfil tablet por USB

O plano de validação do tablet DATEN está em [../docs/tablet-usb.md](../docs/tablet-usb.md). O Windows interno permanece fora do escopo de qualquer instalação: o alvo é inicialização USB independente. Secure Boot e arquitetura UEFI ainda precisam ser identificados e testados.
