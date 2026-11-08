# OverOS em tablets Windows — inicialização por USB

## Objetivo

Preparar um perfil do OverOS para tablets x86 que inicialize diretamente de um pendrive, mantendo intacto o Windows e o armazenamento interno do tablet.

O primeiro equipamento de referência é um tablet DATEN mostrado em fotos pelo usuário. O modelo exato, CPU, RAM, arquitetura UEFI e controlador Wi-Fi ainda não foram identificados.

## Regras de segurança

1. O modo padrão é **USB live**, sem instalador.
2. O processo de build e os scripts de inicialização não podem particionar, formatar ou montar para escrita o armazenamento interno.
3. Não executar instalação automática nem oferecer comandos que apaguem discos.
4. O pendrive deve ser identificado pelo usuário antes de qualquer gravação; escrever uma imagem em USB apaga o conteúdo daquele pendrive.
5. O Windows deve permanecer como opção de inicialização independente.

## Secure Boot

O equipamento foi descrito como tendo Secure Boot ativado e sem opção aparente para desativá-lo. Portanto, não presumir que um carregador EFI comum será aceito.

Para suporte real será necessário:
- confirmar se o firmware é UEFI x86_64 ou UEFI de 32 bits;
- escolher uma cadeia de boot assinada e compatível com as chaves aceitas pelo firmware;
- validar assinatura do carregador e do kernel;
- testar a inicialização com Secure Boot ligado;
- documentar claramente qualquer etapa de inscrição de chave exigida.

Não desativar Secure Boot nem alterar as chaves do firmware como solução automática. Se o firmware não confiar em uma cadeia de boot disponível, registrar a limitação em vez de prometer compatibilidade.

## Perfil gráfico tablet

- Interface com alvos de toque de pelo menos 48 × 48 px.
- Teclado virtual opcional, sem iniciar automaticamente em dispositivos sem tela touch confirmada.
- Rotação e resolução devem ser detectadas em tempo de execução.
- Efeitos, transparência e animações devem poder ser reduzidos.
- Manter caminho de recuperação por teclado/TTY quando disponível.

## Inventário necessário

Antes de declarar compatibilidade, registrar:
- modelo completo da etiqueta;
- CPU e arquitetura;
- RAM;
- versão e arquitetura do firmware UEFI;
- estado e autoridade de Secure Boot;
- IDs PCI/USB de vídeo, Wi-Fi, Bluetooth e touch;
- capacidade do pendrive de teste.

## Critério de aceite

O perfil só será considerado compatível quando iniciar pelo USB com Secure Boot no estado original, detectar tela e toque, oferecer rede funcional e não modificar o armazenamento interno. Até lá, é um alvo experimental.

## Coleta de dados no Windows

Antes de escolher o carregador EFI, use o procedimento somente de leitura em [tablet-inventory.md](tablet-inventory.md) e o script [../scripts/tablet-inventory.ps1](../scripts/tablet-inventory.ps1). Ele consulta modelo, CPU, RAM, firmware, Secure Boot, vídeo e discos sem alterar configurações.

O ponto decisivo para Secure Boot é saber se o firmware confia na Microsoft Third-Party UEFI CA e se permite iniciar a cadeia assinada escolhida. Não presumir que sim apenas porque o Windows inicia normalmente.
