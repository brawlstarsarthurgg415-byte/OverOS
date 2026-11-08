# OverVault

**Official package repository for OverOS.**

OverVault stores packages built specifically for OverOS. The initial target is **x86_64 + musl**.

## Repository layout

- `x86_64/`: signed package archives and Pacman repository database.
- `keys/`: public signing-key documentation and exported public keys.
- `tools/`: scripts for validating, signing, and publishing repository metadata.
- `pacman.conf.example`: client-side Pacman configuration template.

## Package compatibility

Do not publish Arch Linux binary packages here. Standard Arch packages target glibc and are not compatible with the musl-based OverOS root filesystem.

Packages must be built against the OverOS toolchain/sysroot and must declare their runtime dependencies. Package archives use Pacman's `.pkg.tar.zst` format.

## Security model

- Repository databases must be signed.
- Package archives must have detached signatures.
- Client configuration must require package and database signatures.
- The public key must be distributed through a trusted OverOS release, not downloaded from an untrusted package mirror.
- Never commit private signing keys, passphrases, or secret material.

The development repository is not yet a live package server. A hosting endpoint and a trusted OverOS signing key must be configured before clients can install packages remotely.

## First package targets

1. Fastfetch (already built as part of the OverOS image; package recipe still needed).
2. OverOS terminal utilities.
3. OverOS desktop components.

## Publishing (maintainer workflow)

The helper in `tools/publish-repo.sh` signs package archives, updates the Pacman database with `repo-add`, and signs the database. Run it only in a trusted release environment with the OverVault private signing key available.

See `keys/README.md` before creating or distributing signing keys.
