# Secure Boot do OverOS

> Status: arquitetura definida para desenvolvimento; integração e compatibilidade com hardware ainda não implementadas nem testadas.

## Objetivo

Permitir que o firmware UEFI valide a cadeia de inicialização do OverOS com Secure Boot ligado. A implementação não pode exigir desativar a proteção, apagar chaves existentes, alterar o Windows ou escrever no armazenamento interno.

## Modelo de confiança

Secure Boot não é uma opção que o sistema operacional simplesmente liga depois de iniciar. O firmware decide quais executáveis EFI podem iniciar, com base nas bases de confiança e revogação UEFI. O OverOS precisa fornecer uma cadeia de assinaturas verificável desde o primeiro executável.

### Caminho técnico a investigar

1. Usar um primeiro estágio EFI assinado por uma autoridade que o firmware do equipamento já confie (por exemplo, um shim oficial assinado pela Microsoft, caso a autoridade Microsoft Third-Party UEFI CA esteja habilitada e o binário não esteja revogado).
2. Fazer o primeiro estágio validar o próximo carregador e o kernel, sem aceitar binários não assinados.
3. Assinar os artefatos do OverOS com uma chave de lançamento mantida offline e protegida; nunca guardar chave privada no Git, CI, pendrive de distribuição ou repositório.
4. Manter manifesto de versões, hashes, certificados, SBAT quando aplicável e política de revogação.
5. Testar a cadeia em OVMF com Secure Boot de laboratório antes de testar qualquer hardware.

**Limite importante:** um shim assinado pela Microsoft não torna automaticamente confiáveis os binários personalizados do OverOS. Normalmente é necessária uma chave/certificado aceito pelo shim (por exemplo, MOK) ou uma cadeia de fornecedor já confiável. Como o requisito atual do DATEN é não alterar chaves nem cadastrar MOK, o suporte nesse tablet só poderá ser declarado se o firmware e a cadeia já confiável aceitarem todos os estágios sem esse cadastro. Se não aceitarem, não existe um atalho seguro que permita afirmar compatibilidade mantendo essas restrições.

## Perfis de assinatura

### Desenvolvimento
- Chaves de teste exclusivas da VM, nunca reutilizadas em produção.
- OVMF com Secure Boot e variáveis NVRAM descartáveis da VM.
- Testar rejeição de binário alterado e de binário sem assinatura.
- Não importar chaves de laboratório para computadores reais.

### Lançamento
- Chave privada offline, com acesso restrito e cópia de recuperação protegida.
- Certificado público e fingerprints publicados no manifesto de release.
- Assinar somente artefatos reproduzíveis e aprovados.
- Verificar assinatura após assinar e antes de montar a imagem USB.
- Procedimento de rotação/revogação documentado antes de distribuir atualizações.

## Ferramentas previstas

- `sbsigntool` / `sbverify`: assinar e verificar executáveis EFI PE/COFF.
- `mokutil`: apenas consultar estado MOK quando disponível; não executar enrollment automaticamente.
- `pesign` ou ferramenta equivalente: inspeção/assinatura conforme o formato adotado.
- OVMF + QEMU: teste UEFI e Secure Boot em VM isolada.
- `ukify`/systemd-stub: opção futura para Unified Kernel Image, após confirmar a cadeia de confiança e dependências.

Ferramentas ausentes devem ser reportadas; o script de preflight não instala pacotes, não cria chaves e não altera firmware.

## Segurança das chaves

- Não versionar arquivos `.key`, `.pem` privados, `.p12`, `.pfx` ou tokens de assinatura.
- Não colocar chave privada no GitHub Actions, mesmo como arquivo do repositório.
- Segredos de release, se usados, precisam de armazenamento de assinatura dedicado e acesso mínimo; preferir assinatura offline.
- A chave pública pode ser distribuída para verificação, mas isso não a torna confiável pelo firmware por si só.
- Não usar `--force`, apagar `db/dbx/KEK/PK` ou mudar Secure Boot para fazer um teste passar.

## Testes obrigatórios

- [ ] Executável EFI assinado é aceito pela VM com Secure Boot ativado.
- [ ] Executável sem assinatura é recusado.
- [ ] Executável alterado após assinatura é recusado.
- [ ] Kernel e initramfs pertencem à cadeia verificada.
- [ ] Falha de verificação interrompe o boot com mensagem compreensível.
- [ ] Recuperação não executa componentes não verificados.
- [ ] Firmware do DATEN confia na cadeia sem desativar Secure Boot nem cadastrar chaves.
- [ ] Windows e armazenamento interno permanecem intactos.

## Estado atual

Este documento define a política. O OverOS ainda não inclui carregador EFI, kernel assinado, chaves de desenvolvimento, ferramenta de assinatura integrada ou teste OVMF aprovado. Não gerar nem publicar chaves privadas no repositório.