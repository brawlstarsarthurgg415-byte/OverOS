# Teste de hardware

O Intelbras i30 é um alvo experimental. A hipótese de GPU SiS Mirage 3+ ainda não foi confirmada.

## Coletar inventário

Na pasta clonada do projeto, execute:

```sh
sh scripts/hardware-report.sh
```

O script é somente leitura, não exige root e não instala nem altera nada.

## O que verificar

- CPU: arquitetura e recursos.
- Memória: RAM total e disponível.
- GPU: IDs PCI, driver associado, dispositivos DRM e framebuffer.
- Kernel e interfaces de rede.

A saída `VESA VGA` em `/proc/fb` não identifica o modelo físico da GPU e não comprova aceleração gráfica. A ausência do comando `lspci` também não impede a leitura de informações PCI pelo sysfs.

Não escolher compositor antes de identificar a GPU e confirmar suporte real a DRM/KMS e Wayland.
