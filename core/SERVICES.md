# Servicos do OverOS — prototipo

O primeiro supervisor nativo esta em `services/overos-supervisor.cpp`.

## Configuracao

O formato inicial e simples: um caminho absoluto para um executavel por linha. Linhas vazias e comentarios iniciados por `#` sao ignorados. Nao ha interpretacao de shell, variaveis, pipes ou argumentos.

Exemplo:

```text
/usr/bin/overos-hardware-info
```

Validar um arquivo sem iniciar processos:

```sh
overos-supervisor --check-config /etc/overos/services.conf
```

Iniciar usando o arquivo padrao:

```sh
overos-supervisor
```

## Comportamento atual

- Inicia os caminhos absolutos listados.
- Verifica que o alvo e executavel.
- Reinicia um processo que termina, com intervalo de verificacao aproximado de um segundo.
- Responde a SIGTERM, SIGINT e SIGQUIT.
- Tenta encerrar processos com SIGTERM e usa SIGKILL apenas depois do periodo de espera.

## Limites e seguranca

Este e um prototipo de desenvolvimento, nao um gerenciador de servicos de producao. Ainda faltam grupos de processos, dependencias entre servicos, limites de reinicio, logs persistentes, sandboxing, credenciais por servico, notificacao de prontidao e integracao validada com PID 1.

A configuracao deve ser controlada pelo administrador do sistema. Nao execute o supervisor como root com arquivos de configuracao que possam ser alterados por usuarios nao confiaveis. O supervisor ainda nao e iniciado automaticamente pelo `overos-init`.
