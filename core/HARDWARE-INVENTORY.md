# Inventario de hardware do OverOS

O programa `overos-hardware-info` faz uma leitura de procfs e sysfs. Ele nao monta volumes, nao abre discos para escrita e nao altera configuracoes.

## Informacoes coletadas

- Arquitetura e versao do kernel.
- Nome do computador.
- Indicacao de modo UEFI quando `/sys/firmware/efi` esta presente.
- Memoria total reportada por `/proc/meminfo`.
- Nome do processador, quando disponivel em `/proc/cpuinfo`.
- Dispositivos graficos DRM e nome do driver quando o sysfs disponibiliza o link.
- Nomes de dispositivos de entrada reportados por `/proc/bus/input/devices`.
- Dispositivos de bloco, indicador removivel e tamanho em setores de 512 bytes.

## Limites

A presenca de UEFI nao confirma que o firmware confia em uma chave Secure Boot especifica. O inventario tambem nao identifica todos os componentes de um equipamento, e a ausencia de um dispositivo em procfs/sysfs nao prova que ele nao existe.

O campo `removable` e apenas uma informacao do kernel; nao deve ser usado isoladamente para decidir qual dispositivo pode ser apagado. O OverOS nao deve automatizar formatacao ou gravacao de discos.
