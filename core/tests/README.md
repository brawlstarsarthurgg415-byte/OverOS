# Fixtures de teste

- `services.conf.example`: configuracao sintaticamente valida usada pelo teste de validacao.
- `services.conf.invalid-relative`: deve ser rejeitada porque nao usa caminho absoluto.
- `services.conf.invalid-duplicate`: deve ser rejeitada por repetir o mesmo executavel.

Os testes usam `--check-config`, portanto nao iniciam os servicos listados.

- `services.conf.empty`: deve ser rejeitada porque nao declara nenhum servico.
- O CTest tambem confirma que `overosctl` retorna erro para comandos desconhecidos.
