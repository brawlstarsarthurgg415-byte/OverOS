# OverVault signing keys

OverVault uses OpenPGP signatures for package archives and repository databases.

## Key handling

1. Create a dedicated OverVault release-signing key in a trusted maintainer environment.
2. Keep the private key offline or in a protected CI secret store.
3. Export only the public key into this directory after verifying its fingerprint through an independent channel.
4. Include the verified public key in an OverOS release/keyring package.
5. Require signatures in client Pacman configuration.

Never commit a private key, revocation secret, passphrase, or CI secret to Git.

No public key is configured yet. Until a key is created, fingerprint-verified, and shipped with OverOS, this repository must not be treated as a trusted live package source.
