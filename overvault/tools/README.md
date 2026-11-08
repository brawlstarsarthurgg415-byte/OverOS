# OverVault tools

`publish-repo.sh` signs each `.pkg.tar.zst` archive and updates/signs the Pacman repository database with `repo-add`.

Requirements:

- Pacman tools providing `repo-add`
- GnuPG
- A verified OverVault signing key available to the current maintainer account

Example:

```sh
export OVERVAULT_SIGNING_KEY=YOUR_VERIFIED_KEY_ID
./overvault/tools/publish-repo.sh ./build/fastfetch-1.0-1-x86_64.pkg.tar.zst
```

The helper does not upload files. Hosting and automated publishing will be configured after the first OverOS package is built and the public signing key is verified.
