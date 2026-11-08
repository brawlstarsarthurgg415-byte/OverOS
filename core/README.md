# OverOS Core

Este diretório inicia a implementação nativa do OverOS. O objetivo é construir um sistema próprio a partir de componentes upstream, sem copiar uma rootfs pronta de Debian, Ubuntu ou Arch.

## Linguagens e responsabilidades

- **C:** processo PID 1 mínimo, montagem inicial de pseudo-filesystems e recuperação.
- **C++20:** serviços do sistema, inventário de hardware, integração de dispositivos e ferramentas gráficas.
- **Assembly:** somente trechos específicos de baixo nível quando necessários; o kernel Linux continua responsável pelo hardware.
- **GLSL:** shaders opcionais para efeitos gráficos; nunca obrigatórios no perfil econômico.
- **Python:** permitido apenas como ferramenta auxiliar de build/teste, não como dependência obrigatória do sistema em execução.

## Plano de camadas

1. Kernel Linux upstream, configurado para os dispositivos identificados.
2. Toolchain e bibliotecas compiladas para o alvo.
3. Root filesystem próprio, com init e serviços do OverOS.
4. Rede, áudio, armazenamento, firmware e entrada.
5. Sessão gráfica modular: compositor e shell escolhidos após testes de GPU.
6. Gerenciador de pacotes próprio Specman; o MVP local já cria, instala e remove pacotes isolados com verificação SHA-256, sem scripts de pacote.

## Código inicial e staging

O workflow de CI foi configurado para compilar os programas, executar os testes CTest e preparar uma árvore temporária em `out/rootfs-staging/`. Essa árvore contém somente os programas nativos e metadados de identificação. Ela **não é inicializável** e não deve ser gravada em um pendrive.

## Código inicial

- `init/overos-init.c`: primeiro processo do espaço de usuário (PID 1), com montagem básica e fallback para console.
- `services/hardware-info.cpp`: utilitário C++ para inventário de hardware sem modificar o sistema.
- `services/overos-supervisor.cpp`: supervisor experimental com validação de configuração e reinício básico de processos.
- `CMakeLists.txt`: build nativo dos componentes iniciais.

## Boot USB prioritário

O plano técnico de boot, UEFI, Secure Boot, imagem externa e critérios de teste está em [`BOOT-IMPLEMENTATION-PLAN.md`](BOOT-IMPLEMENTATION-PLAN.md). Ele separa o boot de laboratório em VM da validação de confiança no firmware real; nenhum deles está concluído ainda.

## Secure Boot

A política de confiança, assinatura, proteção das chaves e testes está em [`SECURE-BOOT.md`](SECURE-BOOT.md). O preflight de ferramentas é somente leitura: `bash scripts/check-secure-boot-tools.sh`. Isso não instala ferramentas, não cria chaves e não ativa Secure Boot no hardware.

## Interface gráfica leve\n\nA primeira imagem Buildroot inclui Xfbdev, Openbox, xterm e o comando `overos-gui`, com fallback para console. NetworkManager/nmtui é apresentado no primeiro login do tty1. A compatibilidade de vídeo e rede ainda precisa ser testada no hardware real.\n\n## Interface inicial GTK4

Foi adicionado o protótipo nativo `overos-desktop` em C++20/GTK4. A tela inicial possui um botão **Personalizar interface**, que abre o editor para cor de destaque, escala, alto contraste e redução de animações; as preferências são salvas no diretório de configuração do usuário. O alvo é opcional: builds sem GTK4 continuam com o console. O protótipo ainda não está conectado a um compositor/display manager, não inicia automaticamente no boot e depende das bibliotecas GTK4 no sistema de execução. Não declarar sessão gráfica completa até integrar compositor, login e entrada touch real.

## Próximas etapas

- `BOOTSTRAP-ROADMAP.md`: sequência de construção e critérios de aceite.
- `SOURCE-MANIFEST.md`: política de versões, origens e hashes.
- `HARDWARE-PROFILES.md`: matriz separada para i30 e tablet DATEN.
- `TOUCH-AND-KEYBOARD.md`: arquitetura do teclado virtual e compatibilidade touch.

## Build de desenvolvimento

Em uma máquina Linux com compilador C/C++ e CMake:

```sh
cmake -S core -B core/build -DCMAKE_BUILD_TYPE=Release
cmake --build core/build --parallel
```

Os binários resultantes são protótipos de componentes; ainda não formam uma imagem inicializável. Não instalar em disco interno. A imagem USB só será preparada depois de fechar o boot UEFI/Secure Boot e os testes de hardware.
