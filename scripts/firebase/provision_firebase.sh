#!/bin/sh
# Provision the gitignored Firebase config (Keeper/Resources/Firebase) into the
# current working tree. Idempotent: returns immediately if already present.
#
# Why this exists: the Firebase config dir is gitignored, so a fresh `git worktree`
# never gets it.
set -eu

cd "$(git rev-parse --show-toplevel)/ios"
DEST="Keeper/Resources/Firebase"
MARKER="Keeper/GoogleService-Info.plist"

# Already provisioned — nothing to do (this is the hot path on every build).
[ -f "$DEST/$MARKER" ] && exit 0

# Prefer the main working tree's copy: no network, no SSH. --git-common-dir points
# at the shared `.git`; its parent is the main working tree root.
COMMON_GIT_DIR="$(cd "$(git rev-parse --git-common-dir)" && pwd)"
MAIN_ROOT="$(dirname "$COMMON_GIT_DIR")/ios"
if [ "$MAIN_ROOT" != "$PWD" ]; then
  SRC="$MAIN_ROOT/$DEST"
  if [ -f "$SRC/$MARKER" ]; then
    echo "Provisioning Firebase config from main working tree: $SRC"
    rm -rf "$DEST"
    cp -R "$SRC" "$DEST"
    exit 0
  fi
fi

# Demo mode: Firebase is never configured, so there is no private keys repo to fetch from.
echo "Firebase config absent; not needed in demo mode."
