# Arquitetura inicial do OverOS

## Princípios

1. **Hardware primeiro:** identificar CPU, GPU, RAM, firmware e dispositivos antes de fixar a stack gráfica.
2. **Separação de camadas:** sistema-base, compositor, shell, tema e serviços devem ser independentes.
3. **Leveza mensurável:** registrar RAM em idle, tempo de boot, uso de CPU/GPU e estabilidade.
4. **Sem promessas falsas:** uma configuração só passa a ser suportada depois de ser testada.
5. **Reversibilidade:** manter uma sessão de recuperação em texto e configurações fáceis de restaurar.

## Camadas propostas

| Camada | Direção inicial | Situação |
|---|---|---|
| Base | Arch Linux minimal | Proposta |
| Init e serviços | systemd com serviços mínimos | A avaliar |
| Vídeo | Wayland, condicionado ao driver | Não validado |
| Compositor | Comparar opções leves com suporte real ao hardware | Em pesquisa |
| Shell | Astal como candidato; alternativas leves também serão medidas | Em pesquisa |
| Tema | OverOS Dark, próprio | Conceito |
| Rede | NetworkManager ou configuração mínima por perfil | A avaliar |
| Recuperação | TTY e ferramentas de diagnóstico | Obrigatório |

## Regra importante sobre Astal

Astal é uma ferramenta para criar shell, painéis e widgets. Ele não substitui o compositor Wayland nem fornece, por si só, suporte ao driver da GPU. A compatibilidade depende da sessão gráfica, do compositor, do driver e das bibliotecas usadas.

## Perfis de hardware

### Perfil moderno
Máquinas x86_64 com drivers gráficos funcionais para a stack escolhida. Receberá os efeitos visuais e animações completos.

### Perfil legado experimental
Máquinas antigas, incluindo o Intelbras i30. Deve priorizar renderização simples, poucos processos, baixa memória e uma forma de recuperação. A stack gráfica só será definida após confirmar a GPU e testar o suporte do kernel/driver.

## Critérios para aprovar um compositor

- Inicia no hardware-alvo sem falhas.
- Detecta corretamente monitor e resolução.
- Teclado, mouse e touchpad funcionam.
- Não exige uma GPU ou driver ausente no equipamento.
- Consumo de RAM e CPU medido em sessão ociosa.
- Recuperação para TTY funcional.

## Próximas etapas

1. Registrar o estado inicial do repositório e a lista de hardware-alvo.
2. Comparar compositores e shells com foco em drivers antigos e memória.
3. Escolher uma stack principal e uma alternativa de recuperação.
4. Criar um protótipo visual independente do instalador.
5. Automatizar testes e só então começar a imagem inicializável.
