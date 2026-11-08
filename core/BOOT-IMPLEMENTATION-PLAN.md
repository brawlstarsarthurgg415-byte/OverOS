# Plano de implementação do boot USB

> Estado: especificação de engenharia. Ainda não há bootloader, kernel, initramfs ou imagem USB aprovados. Este documento não declara o OverOS inicializável.

## Objetivo prioritário

Inicializar o OverOS diretamente de um pendrive, sem instalador e sem escrever no armazenamento interno. No tablet DATEN, o Secure Boot deve permanecer ligado e o Windows 10 deve continuar intacto.

## Decisões que não podem ser presumidas

Antes de compilar o primeiro kernel, registrar por equipamento:
- arquitetura da CPU e arquitetura do firmware UEFI (podem ser diferentes);
- modo UEFI de 64 ou 32 bits;
- RAM, GPU, controladores de armazenamento, USB, rede e entrada;
- estado de Secure Boot e autoridades presentes no banco de confiança do firmware;
- suporte do firmware a USB UEFI e sistema de arquivos FAT32 na ESP.

Não escolher x86_64, AArch64, kernel config ou módulos por suposição. O DATEN e o Intelbras i30 terão perfis independentes.

## Caminho de boot proposto

### Fase A — boot de desenvolvimento em VM (Secure Boot de laboratório)

1. Gerar um kernel Linux upstream para a arquitetura confirmada.
2. Gerar um initramfs mínimo contendo os módulos necessários para USB, controlador de armazenamento e sistema de arquivos.
3. Construir um rootfs mínimo próprio do OverOS, com /init funcional e console de recuperação.
4. Empacotar os artefatos em uma ESP FAT32 de teste.
5. Usar OVMF/UEFI em uma VM. Testar primeiro sem Secure Boot e depois com chaves de laboratório controladas pela VM.
6. Validar boot, logs, reinicialização, falha de rootfs e recuperação antes de envolver qualquer equipamento físico.

As chaves de laboratório da VM não são confiáveis pelo firmware do tablet. Um teste positivo na VM não comprova compatibilidade com o DATEN.

### Fase B — cadeia Secure Boot para hardware real

O firmware valida o primeiro executável EFI usando seu banco db e revogações dbx. Um carregador intermediário pode validar os próximos componentes, mas cada elo precisa pertencer a uma cadeia de confiança aceita.

Caminhos a investigar, sem assumir que algum deles está disponível:
- um shim assinado por uma autoridade já confiável pelo firmware, seguido de um carregador/kernel aceito por essa cadeia;
- um executável EFI/UKI assinado por uma autoridade que o próprio firmware já confie.

Uma chave criada pelo projeto OverOS não passa a ser confiável automaticamente. Inscrever uma MOK, alterar chaves do firmware ou desativar Secure Boot exige intervenção no equipamento e não faz parte deste plano. Se o firmware não confiar em uma cadeia utilizável sem essas mudanças, o DATEN será considerado não compatível com esse requisito até surgir uma solução legítima.

Nunca substituir, apagar ou atualizar chaves do firmware como tentativa de teste. Nunca desativar Secure Boot para contornar uma falha.

### Fase C — imagem USB externa

Layout lógico pretendido:
- ESP FAT32 com diretório EFI e configuração de boot;
- partição raiz do OverOS, inicialmente somente leitura;
- partição de dados separada para persistência, se suportada.

A ferramenta de imagem deverá apenas criar um arquivo de imagem em um caminho de saída explícito. Gravar fisicamente o pendrive será uma operação separada, com identificação visual do dispositivo e confirmação do destino. Nenhum script poderá selecionar automaticamente /dev/sda, formatar discos internos ou instalar bootloader no Windows.

## Artefatos obrigatórios antes do primeiro teste

| Artefato | Critério |
|---|---|
| Perfil de hardware | CPU e arquitetura UEFI confirmadas |
| Kernel | Compilado para o perfil, com configuração e hash registrados |
| Módulos/firmware | Compatíveis com USB e armazenamento do alvo |
| Initramfs | Contém /init, drivers e recuperação |
| Rootfs | Independente, com libc, shell, utilitários e init funcionais |
| Boot EFI | Executável válido para a arquitetura UEFI |
| Assinaturas | Cadeia verificável; confiança real documentada |
| Imagem USB | Layout validado e checksum publicado |
| Teste VM | Boot e recuperação reproduzíveis |
| Teste físico | USB inicia sem modificar armazenamento interno |

## Sequência de trabalho e bloqueios

1. **Inventário de hardware** — bloqueia a escolha da arquitetura e do kernel.
2. **Bootstrap do rootfs** — libc, shell, utilitários e /init; o staging atual não substitui isso.
3. **Kernel + initramfs** — compilar e testar em VM.
4. **Boot EFI de laboratório** — validar a sequência UEFI em OVMF.
5. **Imagem USB de desenvolvimento** — criar arquivo, nunca gravar automaticamente em dispositivo.
6. **Secure Boot do DATEN** — verificar a cadeia que o firmware já aceita, sem alterar chaves.
7. **Teste físico controlado** — somente após os testes anteriores e com o Windows preservado.

## Critérios de aceite do boot

- [ ] OVMF inicia o USB de desenvolvimento em modo UEFI.
- [ ] OVMF com Secure Boot de laboratório valida a cadeia de teste.
- [ ] O kernel monta o rootfs externo e inicia o OverOS.
- [ ] Console e recuperação funcionam sem interface gráfica.
- [ ] Reinicialização e desligamento não corrompem a partição persistente.
- [ ] O checksum da imagem é reproduzível ou diferenças são explicadas.
- [ ] O firmware do equipamento alvo aceita a cadeia assinada com Secure Boot ligado.
- [ ] O OverOS inicia pelo USB e o armazenamento interno permanece inalterado.

## Estado atual

O repositório contém protótipos nativos, documentação e uma árvore de staging. Ainda não contém kernel construído, initramfs, rootfs completo, carregador EFI, assinaturas aceitas pelo firmware ou imagem USB. Portanto, o próximo trabalho de código é o bootstrap mínimo e a infraestrutura de teste UEFI em VM — não um gravador de pendrive.