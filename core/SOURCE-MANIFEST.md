# Registro de fontes do OverOS

Este registro define o que precisa ser fixado antes de um build oficial. Não preencher versões ou hashes por suposição: cada valor deve ser confirmado na origem oficial e verificado antes da compilação.

## Campos obrigatórios por componente

| Campo | Regra |
|---|---|
| Nome | Nome canônico do projeto upstream |
| Origem | URL oficial HTTPS ou repositório oficial |
| Versão/commit | Tag estável ou commit imutável |
| SHA-256 | Hash do arquivo-fonte efetivamente baixado |
| Assinatura | Assinatura upstream, quando publicada |
| Licença | Licença e avisos de redistribuição |
| Patches | Lista ordenada e hash de cada patch |
| Dependências | Dependências e versões fixadas |
| Configuração | Flags, opções e triplet de destino |
| Saída | Caminho e bibliotecas instaladas no sysroot |

## Componentes que precisam de registro

| Camada | Componente | Decisão pendente |
|---|---|---|
| Kernel | Linux | Versão LTS e configuração por hardware |
| Headers | Linux UAPI | Mesma série do kernel escolhido |
| Binutils | GNU Binutils | Versão compatível com o compilador |
| Compilador | GCC ou LLVM/Clang | Toolchain e runtime C/C++ |
| libc | glibc ou musl | Escolher uma ABI para cada perfil |
| Shell/utilitários | BusyBox ou componentes separados | Política de applets e licenças |
| Init/serviços | OverOS | Código do repositório |
| Pacotes | libalpm e dependências | ABI, licença e política de assinatura |
| Gráficos | Cairo/Pango e compositor | Somente após identificar GPU/driver |
| Firmware | Firmware upstream | Apenas arquivos necessários e redistribuíveis |

## Regras

1. Não usar branches móveis como fonte de build de release.
2. Não aceitar hash vazio, placeholder ou hash calculado sobre um arquivo diferente do que será compilado.
3. Validar assinatura upstream quando disponível; SHA-256 sozinho confirma integridade do arquivo obtido, não sua autoria.
4. Registrar patches e flags em controle de versão.
5. Repetir o build em ambiente limpo e comparar os manifestos.
6. Não copiar bibliotecas do host para o rootfs do alvo.
7. Não publicar artefato se uma dependência obrigatória estiver sem origem, versão ou hash verificado.

## Estado

Ainda não há uma lista de fontes com versões e hashes aprovada. Por isso, o bootstrap de toolchain não deve baixar versões arbitrárias nem produzir uma imagem de release.
