# OverVault package recipes

Package recipes and build helpers live here. The first package is Fastfetch.

Packages must be built against the OverOS musl toolchain and tested against the matching OverOS root filesystem. Do not copy prebuilt Arch Linux packages into this repository.

The CI build creates the initial Fastfetch archive at `out/overvault/x86_64/` as an artifact. It is not automatically published to a remote repository until signing and hosting are configured.
