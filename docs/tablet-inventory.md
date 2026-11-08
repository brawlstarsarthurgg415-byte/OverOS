# Coleta segura de hardware do tablet DATEN (Windows)

Use este procedimento antes de preparar uma imagem USB. O script consulta apenas dados do Windows e do firmware; não altera Secure Boot, partições, discos, BCD ou arquivos.

## Executar

1. No Windows, abra o menu Iniciar e procure **Windows PowerShell**.
2. Abra o PowerShell normalmente. Se a consulta do Secure Boot falhar, abra como administrador e execute novamente.
3. Baixe o arquivo `scripts/tablet-inventory.ps1` deste repositório ou copie seu conteúdo para um arquivo com esse nome.
4. Na pasta onde salvou o arquivo, execute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tablet-inventory.ps1
```

O comando usa uma política de execução temporária para esse processo; não muda a política permanente do Windows.

## Dados necessários

- Modelo exato e fabricante.
- CPU e arquitetura x86/x64/ARM.
- RAM instalada.
- Versão do firmware e modo BIOS/UEFI.
- Estado de Secure Boot.
- Adaptador de vídeo e versão do driver.
- Modelo e capacidade do armazenamento (apenas identificação).

Você pode colar o relatório aqui. Antes de compartilhar, remova números de série ou identificadores que não queira divulgar.

## O que ainda não fazer

- Não desativar Secure Boot.
- Não alterar chaves UEFI/PK/KEK/db.
- Não apagar ou redimensionar partições do Windows.
- Não executar comandos de instalação no disco interno.
- Não gravar imagem em um pendrive que contenha arquivos importantes.

## Próxima etapa técnica

Com o relatório, verificar se o firmware é UEFI de 64 bits ou 32 bits, se confia na Microsoft Third-Party UEFI CA, e qual cadeia assinada pode iniciar com Secure Boot ativo. A presença de Secure Boot ativo não garante que qualquer pendrive Linux seja aceito. O teste será feito em mídia USB separada, sem tocar no armazenamento interno.
