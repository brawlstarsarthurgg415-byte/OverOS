# Specman — gerenciador de pacotes do OverOS

## Decisão

O gerenciador de pacotes do OverOS chama-se **Specman**. Ele é um componente próprio do projeto e não é Pacman/libalpm, nem transforma o sistema em Arch Linux.

## Implementação disponível

O primeiro MVP está em `board/overos/rootfs-overlay/usr/bin/specman` e é instalado como `/usr/bin/specman`.

Comandos:
- `specman version` e `specman help`: versão e ajuda.
- `specman create DIRETORIO ARQUIVO.spkg`: empacota uma pasta com `.PKGINFO` e `payload/`.
- `specman install ARQUIVO.spkg SHA256`: valida o SHA-256 informado, verifica caminhos e tipos de arquivo e instala em área isolada.
- `specman list` e `specman info NOME`: consulta o banco local.
- `specman remove NOME`: remove o pacote instalado e os atalhos que ele criou.

Exemplo de manifesto:

```ini
name=hello-overos
version=1.0.0
arch=x86_64
description=Exemplo de pacote OverOS
bin=hello-overos
```

A pasta do pacote contém `.PKGINFO` e `payload/usr/bin/hello-overos`. O Specman instala payloads em `/opt/specman/packages/` e cria atalhos declarados em `/usr/local/bin/`.

## Proteções do MVP

- SHA-256 obrigatório para instalação.
- Recusa caminhos absolutos, componentes `..`, links simbólicos, hardlinks e tipos especiais no arquivo.
- Não executa scripts de instalação ou remoção.
- Mantém os payloads isolados em `/opt/specman/packages`.
- Instalação e remoção exigem root no sistema real.
- Testes automatizados cobrem criação, instalação, consulta, execução, remoção e hash incorreto.

## O que ainda falta antes de ser um gerenciador completo

- Índice de repositório remoto e sincronização.
- Assinatura criptográfica do índice e dos pacotes com chave pública confiável.
- Resolução de dependências, conflitos e atualização transacional.
- Rollback após falha e recuperação de energia/interrupção.
- Migração de pacotes do diretório isolado para integração controlada com o sistema.

Até essas etapas passarem por testes, o Specman deve ser tratado como MVP local de desenvolvimento. Não distribua pacotes sem hash confiável e não habilite repositórios remotos não autenticados.
