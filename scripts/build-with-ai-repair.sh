#!/usr/bin/env bash
set -Eeuo pipefail
max_attempts=3
attempt=1
while (( attempt <= max_attempts )); do
  echo "::group::OverOS build attempt $attempt/$max_attempts"
  if bash scripts/build-fedora-iso.sh; then
    echo "Build completed successfully."
    echo "::endgroup::"
    exit 0
  else
    status=$?
  fi
  echo "::endgroup::"
  echo "::warning::Build attempt $attempt failed (exit $status)."
  if (( attempt == max_attempts )); then
    echo "::error::Automatic repair limit reached ($max_attempts attempts)."
    exit "$status"
  fi
  if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    echo "::error::OPENAI_API_KEY secret is missing. Add it in GitHub Actions secrets to enable AI repair."
    exit "$status"
  fi
  if ! python3 scripts/ai_package_repair.py --log out/build.log --kickstart fedora/touch-live.ks; then
    echo "::error::AI repair did not produce a safe, applicable package-list change."
    exit "$status"
  fi
  attempt=$((attempt + 1))
done
exit 1
