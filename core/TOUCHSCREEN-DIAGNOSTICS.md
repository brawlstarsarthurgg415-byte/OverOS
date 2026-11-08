# Diagnóstico de touchscreen

O script `scripts/check-touchscreen.sh` coleta informações de entrada em Linux sem escrever em discos, alterar firmware, calibrar o digitizer ou ler o conteúdo dos eventos de teclado/toque.

## Executar

Na raiz do repositório:

```sh
bash scripts/check-touchscreen.sh
```

Se disponíveis, usa `libinput list-devices` e `udevadm` para identificar a classificação `ID_INPUT_TOUCHSCREEN=1`. Sem essas ferramentas, apresenta os nomes dos dispositivos de entrada encontrados em sysfs e pode indicar nomes sugestivos apenas como heurística.

## Interpretar

- **TOUCHSCREEN (udev):** o Linux/udev classificou o dispositivo como touchscreen. Ainda é necessário testar toques reais no compositor e na interface.
- **Possível touchscreen (heurística):** o nome parece indicar um digitizer, mas não confirma suporte.
- **Nenhum dispositivo ou sem classificação:** não prova defeito do painel. Pode faltar driver, firmware, permissões ou suporte do ambiente.

## Limites

Este script é apenas inventário. Não carrega módulos, não instala pacotes, não abre `/dev/input/event*`, não simula toques e não modifica o tablet. A confirmação final exige iniciar um Linux compatível e testar a tela na sessão gráfica. A BIOS/UEFI pode continuar sem suporte ao toque mesmo quando o Windows ou o Linux o reconhece depois da inicialização.
