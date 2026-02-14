#!/bin/bash
# Kickoff one-liner installer
# Usage: curl -sfL https://raw.githubusercontent.com/kifbv/kickoff/main/scripts/install.sh | bash -s <target-dir> [project-name]
set -e

TARGET_DIR="$1"
PROJECT_NAME="${2:-$(basename "$TARGET_DIR")}"

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: bash install.sh <target-directory> [project-name]"
  echo "  curl -sfL https://raw.githubusercontent.com/kifbv/kickoff/main/scripts/install.sh | bash -s ~/Projects/my-app \"My App\""
  exit 1
fi

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "Downloading kickoff..."
git clone --depth 1 https://github.com/kifbv/kickoff.git "$TMPDIR/kickoff" 2>/dev/null

"$TMPDIR/kickoff/scripts/scaffold.sh" "$TARGET_DIR" "$PROJECT_NAME"
