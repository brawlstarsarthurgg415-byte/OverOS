# Toolchain e construcao do rootfs

## Principio

O sistema instalado no pendrive sera montado a partir de componentes individuais compilados e empacotados para o OverOS. Uma distribuicao Linux pode ser usada como ambiente hospedeiro de desenvolvimento, mas nao sera copiada como rootfs final.

## Camadas

1. **Host de build**: fornece compilador, CMake, Make/Ninja, assembler e ferramentas de empacotamento.
2. **Toolchain alvo**: compilador e linker configurados para a arquitetura do OverOS.
3. **Sysroot**: headers e bibliotecas do alvo, isolados do host.
4. **Base do sistema**: kernel Linux, libc, shell e utilitarios essenciais.
5. **Servicos OverOS**: init, supervisao, logs, dispositivos, rede e sessao.
6. **Aplicacoes**: ferramentas de diagnostico e interface.
7. **Pacotes**: metadados, assinaturas e repositorio.

## Linguagens

- C11 para init, servicos pequenos e componentes de baixo nivel.
- C++20 para ferramentas e servicos com estruturas mais complexas.
- Assembly apenas onde a ABI, o boot ou uma rotina de baixo nivel exigir.
- GLSL para shaders; SVG para icones e vetores; PNG/WebP para imagens raster.
- Python pode ser usado como ferramenta auxiliar de build, nunca como requisito para iniciar o sistema.

## Reprodutibilidade

Cada componente precisa fixar:
- URL ou origem oficial;
- versao ou commit;
- hash de origem;
- patches aplicados;
- flags de compilacao;
- dependencias;
- destino no sysroot.

O pipeline deve compilar primeiro para um sysroot temporario, executar testes e somente depois copiar artefatos aprovados para a arvore de rootfs.

## Ordem de bootstrap

1. Preparar toolchain e sysroot para a arquitetura confirmada.
2. Construir binutils e compilador alvo quando o bootstrap exigir.
3. Construir libc e headers de kernel.
4. Construir utilitarios essenciais e shell.
5. Construir kernel e modulos para o hardware selecionado.
6. Construir init e servicos do OverOS.
7. Integrar libalpm e repositorio assinado.
8. Construir sessao grafica com fallback de console.
9. Montar imagem USB e validar boot.

## Estado atual

O repositorio ja compila prototipos C/C++ com a toolchain do host. Isso nao equivale a uma toolchain independente nem a um rootfs inicializavel. O build atual ainda nao produz kernel, libc, initramfs, pacote assinado ou imagem USB.
