#!/usr/bin/env bash
set -Eeuo pipefail

MAX_ATTEMPTS=5
RUN_ID="${GITHUB_RUN_ID:-local-$(date +%s)}"
BRANCH="${GITHUB_REF_NAME:-main}"
CHECKPOINT="recovery/overos-${RUN_ID}"
HISTORY="/tmp/overos-repair-history-${RUN_ID}.txt"
DIAG_ROOT="/tmp/overos-diagnostics-${RUN_ID}"

# The workflow restores these two cache directories before the build starts.
dirty="$(git status --porcelain | grep -vE '^[?][?] (downloads|cache)/?$' || true)"
if [[ -n "$dirty" ]]; then
  echo "::error::Checkout is not clean; refusing an unsafe recovery point."
  printf '%s\n' "$dirty"
  exit 1
fi

BASE_SHA="$(git rev-parse HEAD)"
git config user.name "OverOS AI Repair"
git config user.email "overos-ai-repair@users.noreply.github.com"
: > "$HISTORY"

# Stage only project changes. Ignored build output (notably lmc-result/) must
# never be passed explicitly to git add, because Git treats that as an attempt
# to add an ignored path and aborts the whole recovery/build-success path.
stage_project_changes() {
  git add -u -- .
  while IFS= read -r -d '' path; do
    case "$path" in
      out/*|downloads/*|cache/*|lmc-result/*|*.img)
        continue
        ;;
    esac
    git add -- "$path"
  done < <(git ls-files --others --exclude-standard -z)
}

# Keep expensive reusable downloads/caches across AI rollback attempts.
restore_checkpoint() {
  git reset --hard "$BASE_SHA"
  git clean -fdx -e downloads/ -e cache/
}

capture_diagnostics() {
  local attempt="$1"
  local dest="$DIAG_ROOT/attempt-$attempt"
  mkdir -p "$dest"
  cp -a out/. "$dest/" 2>/dev/null || true

  local combined="/tmp/overos-build-$RUN_ID-$attempt.log"
  : > "$combined"
  while IFS= read -r -d "" file; do
    {
      printf '\n===== %s =====\n' "$file"
      tail -c 150000 "$file"
      printf '\n'
    } >> "$combined"
  done < <(find "$dest" -type f -name '*.log' -print0)

  if [[ ! -s "$combined" ]]; then
    printf 'No log files were generated for attempt %s.\n' "$attempt" > "$combined"
  fi
}

publish_diagnostics() {
  mkdir -p out/diagnostics
  if [[ -d "$DIAG_ROOT" ]]; then
    cp -a "$DIAG_ROOT/." out/diagnostics/
  fi
  cp "$HISTORY" out/repair-history.txt 2>/dev/null || true
}

create_recovery_point() {
  local tag="$1"
  git tag -f "$tag" "$BASE_SHA" >/dev/null
  echo "::notice::Local recovery checkpoint created: $tag"
}

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
  echo "::group::Build attempt $attempt/$MAX_ATTEMPTS"
  create_recovery_point "$CHECKPOINT/attempt-$attempt"

  if bash scripts/build-fedora-iso.sh; then
    echo "ISO build and validation succeeded."
    echo "::endgroup::"
    stage_project_changes
    if ! git diff --cached --quiet; then
      git diff --cached --check
      git commit -m "AI repair: validated OverOS build [skip ci]"
      if [[ -n "${GITHUB_TOKEN:-}" && -n "${GITHUB_REPOSITORY:-}" ]]; then
        local_encoded="$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 -w0)"
        if git -c "http.extraheader=AUTHORIZATION: basic $local_encoded" push origin "HEAD:$BRANCH"; then
          echo "Validated AI repair was committed to $BRANCH."
        else
          echo "::warning::Build passed, but GitHub rejected the automatic push. ISO will still be uploaded."
        fi
        unset local_encoded
      else
        echo "::warning::No GitHub token available to persist the validated repair."
      fi
    fi
    exit 0
  else
    status=$?
  fi

  echo "::endgroup::"
  echo "::warning::Build attempt $attempt failed (exit $status)."
  capture_diagnostics "$attempt"

  if (( attempt == MAX_ATTEMPTS )); then
    restore_checkpoint
    publish_diagnostics
    echo "::error::Repair limit reached. Repository restored to checkpoint $BASE_SHA."
    exit "$status"
  fi

  mkdir -p out
  stage_project_changes
  if git diff --cached --quiet; then
    printf '\nAttempt %s: build failed without a working-tree patch.\n' "$attempt" >> "$HISTORY"
  else
    {
      printf '\n===== FAILED PATCH FROM ATTEMPT %s (rolled back) =====\n' "$attempt"
      git diff --cached --no-ext-diff
    } >> "$HISTORY"
  fi

  if [[ -f "/tmp/overos-build-$RUN_ID-$attempt.log" ]]; then
    {
      printf '\n===== BUILD LOG ATTEMPT %s =====\n' "$attempt"
      tail -c 50000 "/tmp/overos-build-$RUN_ID-$attempt.log"
    } >> "$HISTORY"
  fi

  restore_checkpoint

  if [[ -z "${GROQ_API_KEY:-}" && -z "${OPENAI_API_KEY:-}" ]]; then
    echo "::error::Neither GROQ_API_KEY nor OPENAI_API_KEY secret is configured. Repository remains at checkpoint."
    exit "$status"
  fi

  if ! python3 scripts/ai_repo_repair.py \
    --log "/tmp/overos-build-$RUN_ID-$attempt.log" \
    --history "$HISTORY" \
    --output "/tmp/overos-repair-$RUN_ID.patch"; then
    echo "::error::AI repair could not return a patch. Stopping instead of repeating the same expensive build."
    printf '\nAttempt %s: AI repair unavailable; diagnostics preserved.\n' "$attempt" >> "$HISTORY"
    publish_diagnostics
    exit "$status"
  fi

  if ! git apply --check "/tmp/overos-repair-$RUN_ID.patch"; then
    echo "::warning::Patch failed validation; checkpoint restored."
    printf '\nAttempt %s: git apply --check rejected the patch.\n' "$attempt" >> "$HISTORY"
    continue
  fi

  if ! git apply "/tmp/overos-repair-$RUN_ID.patch"; then
    restore_checkpoint
    printf '\nAttempt %s: patch application failed and was rolled back.\n' "$attempt" >> "$HISTORY"
    continue
  fi

  if ! git diff --check ||
     ! find scripts -type f -name '*.sh' -print0 | xargs -0 -r -n1 bash -n ||
     ! python3 -c 'import ast,pathlib; [ast.parse(p.read_text()) for p in pathlib.Path("scripts").rglob("*.py")]; print("Python syntax OK")'; then
    echo "::warning::Static validation failed; reverting the entire AI change."
    git diff --no-ext-diff >> "$HISTORY" || true
    restore_checkpoint
    printf '\nAttempt %s: static validation failed; patch rolled back.\n' "$attempt" >> "$HISTORY"
    continue
  fi

  echo "AI patch applied after checkpoint. Next iteration tests it."
done

restore_checkpoint
exit 1
