# Compilar o OverOS

O OverOS usa Buildroot para construir um rootfs próprio com musl, BusyBox, kernel Linux e pacotes selecionados. O Ubuntu do GitHub Actions é somente o computador hospedeiro de compilação; não é copiado para o rootfs final.

## Build nativo e testes

```sh
bash scripts/build-core.sh
bash scripts/stage-rootfs.sh
bash scripts/test-rootfs-staging.sh
bash scripts/test-specman.sh
```

## Construir rootfs e kernel do OverOS

Em um host Linux x86_64 com as dependências de Buildroot instaladas:

```sh
bash scripts/build-buildroot-rootfs.sh
```

O script baixa Buildroot 2025.02, constrói a toolchain musl, compila os programas C/C++ do OverOS para o sysroot alvo e gera o rootfs e o kernel em `out/overos-buildroot/`.

## Gerar imagem de disco para teste

```sh
sudo bash scripts/build-bootable-img.sh
```

O arquivo de saída é `out/OverOS-Custom.img`. O script cria somente esse arquivo de imagem; não escolhe nem grava automaticamente um disco físico. A imagem deve passar no CI/QEMU e depois ser testada em USB externo antes de qualquer uso em hardware.

## Componentes presentes na primeira imagem

- Kernel Linux x86_64 e rootfs musl/BusyBox.
- Ferramentas e serviços de rede, NetworkManager e nmtui.
- OpenSSH server.
- Xfbdev, Openbox e xterm como sessão gráfica leve.
- Programas nativos OverOS compilados para o sysroot alvo.
- Specman MVP para pacotes locais com SHA-256 obrigatório.

## Limites

- O init padrão da imagem continua sendo BusyBox init. `overos-init` permanece instalado como protótipo e ainda não deve ser usado como PID 1.
- Specman ainda não tem repositório remoto assinado, resolução de dependências ou transações com rollback.
- Secure Boot não está validado.
- Compatibilidade de GPU, Wi-Fi, touch e economia de RAM ainda exige teste no equipamento físico.
