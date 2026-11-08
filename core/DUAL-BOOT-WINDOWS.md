# Plano de dual boot OverOS + Windows 10

> Estado: proposta de arquitetura. Não é instalador e não autoriza alterar partições, BCD, NVRAM ou arquivos do Windows. Nenhum procedimento de instalação interna foi implementado.

## Objetivo

Permitir que o usuário escolha OverOS ou Windows 10 ao ligar o DATEN, sem precisar manter um pendrive conectado, preservando o Windows e mantendo Secure Boot ativado.

## Decisão de segurança

A instalação no armazenamento interno é **opcional e posterior**. O primeiro alvo continua sendo iniciar e validar OverOS por USB/VM. Não tocar no disco interno até que:
- o inventário completo do DATEN esteja disponível;
- exista backup verificado dos arquivos importantes e um meio de recuperação do Windows;
- o boot externo do OverOS esteja validado em VM e em equipamento de teste;
- a cadeia Secure Boot seja aceita pelo firmware sem desativar a proteção, trocar chaves ou cadastrar MOK;
- o usuário compreenda e aprove separadamente qualquer alteração de armazenamento ou de opções de boot.

Não presumir que há espaço livre, partição adequada, firmware x64 ou autoridade Microsoft Third-Party UEFI CA habilitada.

## Arquitetura pretendida

1. Preservar Windows Boot Manager e suas partições EFI/recuperação.
2. Instalar os arquivos EFI assinados do OverOS apenas em espaço dedicado e previamente aprovado, sem sobrescrever arquivos do Windows.
3. Adicionar uma opção UEFI identificável para OverOS, mantendo Windows Boot Manager disponível como opção independente.
4. Exibir uma seleção simples de sistema operacional quando suportado; caso contrário, permitir seleção pelo menu de boot UEFI.
5. Manter Windows como opção de recuperação e caminho padrão caso OverOS falhe.
6. Permitir remover a opção OverOS e seus arquivos dedicados sem apagar dados do Windows, com procedimento de reversão validado antes de qualquer instalação.

## Secure Boot é um bloqueio obrigatório

O firmware valida o primeiro executável EFI pela base de confiança UEFI. Um binário próprio não se torna confiável apenas por estar no disco ou por ser iniciado pelo Windows Boot Manager. A cadeia completa (carregador, kernel e componentes seguintes) deve ser validada por uma autoridade que o equipamento já confie.

- Não desativar Secure Boot.
- Não apagar, substituir ou cadastrar chaves UEFI/MOK.
- Não contornar BitLocker ou alterar suas proteções.
- Se não existir cadeia de confiança compatível com as restrições, não oferecer dual boot nativo nesse DATEN. Continuar com USB externo ou VM.

## Rufus e o armazenamento interno

Rufus é uma ferramenta de gravação de mídia inicializável. Não transforma, por si só, um sistema em dual boot instalado no disco interno. Para o objetivo deste projeto, primeiro se produz e testa uma imagem inicializável; a instalação interna é um projeto separado, com instalador e recuperação próprios.

## Etapas de engenharia

- [ ] Identificar modelo, CPU, RAM, arquitetura UEFI, GPU, armazenamento, touchscreen e estado Secure Boot.
- [ ] Concluir rootfs independente, kernel, initramfs e sessão de recuperação.
- [ ] Validar boot UEFI em OVMF e testes de falha/recuperação.
- [ ] Validar cadeia Secure Boot de laboratório em VM.
- [ ] Determinar se o firmware DATEN aceita uma cadeia de lançamento sem mudança de chaves.
- [ ] Validar primeiro em hardware de teste com disco descartável.
- [ ] Projetar instalador interno com detecção explícita de destino, proteção contra sobrescrita, pré-visualização e reversão.
- [ ] Fazer backup e validar recuperação do Windows antes de qualquer alteração real.
- [ ] Só então avaliar dual boot no DATEN com consentimento específico.

## Critérios de aceite

- Windows inicia normalmente antes e depois do teste.
- OverOS inicia pelo seletor UEFI com Secure Boot ligado.
- O carregador nunca sobrescreve Windows Boot Manager nem partições de recuperação.
- A falha do OverOS não impede a inicialização do Windows.
- A reversão remove somente componentes do OverOS e restaura a opção de boot anterior.
- Nenhum dado do usuário é apagado.
- Os testes são repetíveis e documentados.

## Estado atual

Nenhum instalador interno, gerenciador de partições, integração BCD/UEFI NVRAM ou cadeia Secure Boot de lançamento está implementado. Este documento registra o desenho e os bloqueios; não declara dual boot disponível.
