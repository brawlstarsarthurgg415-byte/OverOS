# Gerenciamento de pacotes do OverOS

## Decisao de arquitetura

O objetivo do projeto e usar **Pacman/libalpm** como gerenciador principal, sem transformar o OverOS em uma distribuicao Arch. O formato de pacotes e a biblioteca de transacoes podem ser reutilizados; a identidade do sistema, a selecao de componentes, a configuracao, os repositorios e o processo de montagem do rootfs continuam sob controle do OverOS.

Nao existe ainda um gerenciador funcional nesta branch. Este documento define os requisitos antes de integrar libalpm.

## Componentes

1. **libalpm**: resolucao de dependencias, verificacao de conflitos, banco local e transacoes.
2. **overos-repo**: ferramenta de manutencao do indice do repositorio e metadados.
3. **overosctl package**: interface de administracao, inicialmente somente consulta.
4. **Chaves de assinatura**: pacotes e bases assinados; chave publica incorporada na imagem oficial.
5. **Cache**: downloads em /var/cache/overos/packages.
6. **Banco local**: /var/lib/pacman, mantendo compatibilidade com libalpm.

## Regras de seguranca

- Nunca executar instalacao, remocao ou atualizacao sem mostrar previamente o plano da transacao.
- Verificar assinatura e integridade antes de instalar qualquer pacote.
- Recusar downgrade ou substituicao de arquivos de sistema sem uma transacao valida.
- Nao executar scripts de pacote como root durante testes de CI.
- Manter cache e banco no filesystem persistente do pendrive, sem tocar no disco interno do computador.
- Oferecer modo somente leitura para listar pacotes, repositorios e atualizacoes.
- Nao distribuir chaves privadas no repositorio.

## Formato de manifesto OverOS

Cada pacote do sistema tera metadados versionados e reproduziveis:

- nome e versao;
- arquitetura alvo;
- descricao;
- dependencias e conflitos;
- origem e hash SHA-256 do artefato;
- identificador da chave que assinou o pacote;
- lista de arquivos;
- scripts de instalacao explicitamente declarados.

A fonte do pacote deve ser fixada em uma versao ou commit. Builds oficiais devem registrar compiler, flags e dependencias utilizadas.

## Etapas de implementacao

- [ ] Compilar libalpm e suas dependencias para o sysroot do OverOS.
- [ ] Criar repositorio de teste assinado com chave descartavel.
- [ ] Integrar consultas de pacotes em overosctl.
- [ ] Testar instalacao em rootfs temporario e descartavel.
- [ ] Testar rollback e interrupcao de transacao.
- [ ] Criar repositorio oficial e politica de rotacao de chaves.
- [ ] Habilitar operacoes de escrita somente depois dos testes anteriores.

## Estado atual

Somente a arquitetura esta documentada. O binario overosctl atual nao instala nem remove pacotes. A presenca de Pacman/libalpm no sistema final ainda nao foi implementada nem validada.
