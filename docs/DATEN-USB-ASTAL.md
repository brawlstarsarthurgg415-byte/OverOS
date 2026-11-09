# Perfil DATEN — OverOS USB + Astal

Estado: plano de implementação. Este documento não declara uma imagem pronta nem compatibilidade confirmada com o tablet.

## Objetivo do usuário

- Iniciar o OverOS diretamente de um pendrive, sem instalador.
- Não formatar, particionar, montar para escrita nem instalar bootloader no SSD/eMMC interno.
- Preservar o Windows 11 existente.
- Manter Secure Boot ativado; não apagar chaves, não cadastrar chaves novas e não desativar a proteção como atalho.
- Integrar o visual OverOS já mantido em `rice/` a uma sessão touchscreen baseada em Astal, se as dependências e o desempenho do hardware permitirem.

## O que já existe no repositório

- Buildroot x86_64, kernel Linux e rootfs BusyBox/musl em desenvolvimento.
- Script `scripts/build-bootable-img.sh` que cria um arquivo raw em `out/`; ele não deve gravar em um dispositivo físico.
- Protótipo visual GTK4/Astal e folhas `rice/astal.css` e `rice/components.css`.
- Perfil touch e documentação de componentes.

Esses itens são bases de desenvolvimento, não prova de boot físico. O script atual usa GRUB sem uma cadeia de assinatura configurada; portanto, não se pode afirmar que a imagem atual inicializará com Secure Boot ligado. O fluxo atual também declara Openbox/Xfbdev como desktop, não Astal integrado.

## Etapas obrigatórias

### 1. Identificar o tablet sem alterar nada

Registrar modelo exato, CPU, RAM, arquitetura do firmware UEFI (x64 ou IA32), GPU, armazenamento, Wi-Fi, controlador touch e estado de Secure Boot. A informação de que o equipamento executa Windows 11 não substitui esse inventário.

### 2. Corrigir e validar a base de build

- Confirmar que o overlay indicado em `buildroot/overos_x86_64_defconfig` corresponde à árvore real do repositório.
- Fazer o Buildroot concluir sem erros.
- Produzir rootfs, kernel, initramfs quando necessário e logs/versionamento reproduzíveis.
- Testar primeiro em QEMU/OVMF; validar console e recuperação antes do desktop.

### 3. Construir a imagem USB externa

- A saída inicial é um arquivo de imagem, nunca um dispositivo `/dev/*`.
- Separar a criação da imagem da gravação manual do pendrive.
- Validar partições, checksum e conteúdo antes de qualquer teste físico.
- Começar sem persistência; adicionar partição persistente somente depois de o boot básico estar estável.
- Nenhuma etapa pode tocar no disco interno do tablet.

### 4. Astal e identidade visual

- Reutilizar os tokens e componentes de `rice/astal.css` e `rice/components.css`.
- Integrar um shell Astal/GTK4 real ao rootfs; CSS sozinho não é um desktop.
- Verificar disponibilidade e tamanho das dependências no Buildroot (GTK4, bindings/runtime usados pelo Astal, bibliotecas e serviços).
- Criar um perfil touchscreen com alvos de toque grandes, painel, launcher, status e configurações.
- Manter animações e transparências opcionais, com modo econômico.
- Se Astal não couber no hardware ou na cadeia de dependências, manter o console de recuperação e só então avaliar um shell GTK4 mínimo alternativo; não substituir silenciosamente o requisito visual.

### 5. Secure Boot e teste físico

O firmware precisa confiar no primeiro executável EFI e na cadeia subsequente. A imagem de desenvolvimento atual não tem essa cadeia configurada. Primeiro identificar, sem alterar, as autoridades de confiança do firmware e investigar uma cadeia legítima já aceita. Se não houver cadeia utilizável sem mudar as configurações/chaves, parar o teste físico com Secure Boot e registrar a limitação; não pedir ao usuário para desativá-lo.

## Critérios para considerar a primeira versão testável

- [ ] Build completo no CI.
- [ ] Boot UEFI e recuperação aprovados em QEMU/OVMF.
- [ ] Imagem raw gerada em arquivo e checksum publicado.
- [ ] Cadeia Secure Boot verificada para o firmware alvo, sem alterar suas chaves.
- [ ] Boot pelo pendrive confirmado no tablet.
- [ ] Windows 11 e armazenamento interno permanecem inalterados.
- [ ] Touch, vídeo, Wi-Fi, áudio e suspensão avaliados separadamente.
- [ ] Astal inicia como sessão gráfica real e o modo econômico funciona.

Até todos os critérios aplicáveis serem verificados, o artefato deve ser identificado como imagem experimental, não como sistema pronto.
