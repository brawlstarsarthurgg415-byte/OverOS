# OverOS

**OverOS** é um projeto independente de sistema Linux com base Arch, identidade visual própria e foco em uma experiência moderna, rápida e configurável.

> Este repositório é a edição normal do OverOS. Ele é separado do projeto `overOS-light`.

## Objetivos

- Interface visual moderna, limpa e consistente.
- Baixo consumo de RAM e inicialização enxuta.
- Componentes modulares: ambiente gráfico, shell, tema e serviços podem ser trocados sem refazer o sistema.
- Compatibilidade testada por perfil de hardware, sem prometer suporte a GPUs antigas antes dos testes.
- Instalação reproduzível e documentação em português.

## Direção visual

A primeira direção será um desktop escuro, elegante e tridimensional, com transparência discreta, painéis compactos, cantos suaves e animações moderadas. O visual não deve depender de efeitos pesados para parecer bom.

## Arquitetura em avaliação

- **Base:** Arch Linux, com seleção mínima de pacotes.
- **Sessão gráfica:** Wayland é a direção preferida; o compositor será escolhido após validar drivers e GPU.
- **Shell/widgets:** Astal será avaliado como opção visual, não tratado como compositor.
- **Plano de compatibilidade:** perfis separados para hardware atual e hardware legado.
- **Xorg:** não faz parte da direção principal do projeto.

Nenhuma dessas escolhas será considerada pronta até passar por testes reais de inicialização, vídeo, entrada, memória e estabilidade.

## Estado atual

<badge>Em planejamento e prototipagem</badge>

- [x] Repositório independente criado.
- [x] Objetivos e critérios técnicos iniciais documentados.
- [ ] Inventário de hardware e matriz de compatibilidade.
- [ ] Escolha e protótipo do compositor.
- [ ] Protótipo visual do shell.
- [ ] Imagem inicializável e testes em máquinas reais.

## Estrutura

- `docs/`: arquitetura, decisões técnicas e testes.
- `rice/`: identidade visual, tema e protótipo do desktop.
- `config/`: configurações versionadas dos componentes.
- `scripts/`: automação de desenvolvimento e montagem.

## Aviso de compatibilidade

O computador Intelbras i30 é tratado como um alvo legado experimental. A GPU SiS Mirage 3+ ainda é uma hipótese, não uma identificação confirmada. Wayland, Astal e aceleração gráfica não serão declarados compatíveis até haver teste no equipamento.

## Licença

A licença será definida antes da primeira distribuição pública.
