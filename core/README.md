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
6. Gerenciador de pacotes: integração com libalpm/Pacman será feita depois que glibc, libarchive, curl, openssl, zstd e o formato de pacotes estiverem definidos e testados. Não declarar Pacman operacional antes disso.

## Código inicial e staging

O workflow de CI foi configurado para compilar os programas, executar os testes CTest e preparar uma árvore temporária em `out/rootfs-staging/`. Essa árvore contém somente os programas nativos e metadados de identificação. Ela **não é inicializável** e não deve ser gravada em um pendrive.

## Código inicial

- `init/overos-init.c`: primeiro processo do espaço de usuário (PID 1), com montagem básica e fallback para console.
- `services/hardware-info.cpp`: utilitário C++ para inventário de hardware sem modificar o sistema.
- `services/overos-supervisor.cpp`: supervisor experimental com validação de configuração e reinício básico de processos.
- `CMakeLists.txt`: build nativo dos componentes iniciais.

## Boot USB prioritário

O plano técnico de boot, UEFI, Secure Boot, imagem externa e critérios de teste está em [`BOOT-IMPLEMENTATION-PLAN.md`](BOOT-IMPLEMENTATION-PLAN.md). Ele separa o boot de laboratório em VM da validação de confiança no firmware real; nenhum deles está concluído ainda.

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
