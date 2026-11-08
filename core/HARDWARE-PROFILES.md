# Matriz de perfis de hardware OverOS

Cada equipamento é um alvo separado. Não selecionar arquitetura, kernel, firmware ou interface com base apenas no nome comercial.

| Perfil | Identificação | Arquitetura | Estado |
|---|---|---|---|
| Intelbras i30 | Modelo e revisão exatos pendentes | Coletar CPU e arquitetura do firmware | Aguardando inventário |
| Tablet DATEN | Modelo exato pendente | Coletar CPU e arquitetura UEFI | Aguardando inventário |

## Dados mínimos por perfil

- fabricante, modelo e revisão;
- CPU, arquitetura e recursos de instrução;
- RAM total;
- arquitetura do firmware UEFI e modo de boot;
- estado de Secure Boot e autoridades confiáveis;
- GPU, driver e resolução;
- armazenamento e controladores;
- Wi-Fi, Ethernet e firmware necessário;
- áudio, teclado, touchpad, touchscreen e câmeras;
- suspensão, bateria e gerenciamento térmico.

## Política do tablet DATEN

- Inicialização exclusivamente externa por USB.
- Secure Boot permanece ativado.
- Windows 10, partições e dados internos permanecem intactos.
- Não apagar nem substituir chaves UEFI.
- Não criar partições nem instalar carregador no disco interno.
- Se a cadeia EFI assinada não for aceita pelo firmware, interromper o teste e documentar a incompatibilidade.

## Política do Intelbras i30

- Começar com inventário somente leitura.
- Selecionar kernel e drivers após confirmar GPU, rede, áudio e armazenamento.
- Manter uma sessão de console funcional mesmo se a interface gráfica não tiver aceleração.
- Não presumir que o equipamento usa SiS Mirage 3+ sem evidência do inventário.

## Critério para declarar suporte

Um perfil só pode ser marcado como suportado depois de completar boot, console, vídeo, rede, áudio, entrada, armazenamento, suspensão/retomada e recuperação, com logs anexados ao teste.
