# Boot UEFI e imagem USB do OverOS

## Objetivo

Entregar uma imagem inicializavel a partir de um pendrive, com persistencia opcional, sem instalador e sem alterar o armazenamento interno do computador.

## Layout planejado do dispositivo USB

- Particao EFI: FAT32, com carregador EFI e configuracao de boot.
- Particao de sistema: imagem raiz do OverOS, inicialmente somente leitura.
- Particao de dados: configuracao e arquivos pessoais persistentes, se o dispositivo tiver espaco.

O layout e uma especificacao, nao um gravador pronto. Nenhum script deste repositorio deve escolher automaticamente um disco fisico.

## Secure Boot

O firmware do tablet DATEN precisa continuar com Secure Boot ativado. Antes de selecionar o carregador, e necessario obter o modelo exato do equipamento e confirmar quais autoridades de certificacao UEFI o firmware aceita.

A cadeia pretendida e:

1. Firmware valida o primeiro executavel EFI.
2. Primeiro executavel valida o proximo estagio.
3. Kernel e initramfs sao verificados conforme a cadeia suportada.
4. O sistema valida os componentes assinados conforme a politica OverOS.

Nao presumir que qualquer firmware confia em qualquer chave. Nao solicitar que o usuario desative Secure Boot, apague chaves ou altere a configuracao de seguranca do firmware. Se a cadeia confiavel nao puder ser estabelecida, o suporte a esse equipamento fica pendente.

## Preservacao do Windows

O modo USB deve ser externo e independente. O processo de build nao deve formatar, particionar, montar para escrita ou instalar bootloader no disco interno.

A primeira versao deve ser testada em maquina virtual e em pendrive separado. O teste no tablet so comeca depois de identificar CPU, memoria, arquitetura UEFI, GPU, Wi-Fi e controladores.

## Requisitos do futuro criador de imagem

- Gerar um arquivo de imagem em caminho de saida informado explicitamente.
- Validar tamanho e checksum do artefato.
- Exibir o layout planejado antes de qualquer operacao de gravacao.
- Separar criacao de imagem de gravacao fisica do pendrive.
- Nunca conter um destino padrao como /dev/sda.
- Nao oferecer formatacao automatica de discos internos.
- Produzir log de build e manifesto de versoes.

## Criterios de aceite

- [ ] Imagem inicia em UEFI numa VM.
- [ ] Modo de recuperacao funciona.
- [ ] Persistencia sobrevive a reinicializacao.
- [ ] Secure Boot permanece habilitado no equipamento alvo.
- [ ] Windows e particoes internas permanecem inalterados.
- [ ] Teclado, touch, audio, video e rede sao testados individualmente.
