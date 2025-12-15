#!/usr/bin/env bash
set -euo pipefail

REPO="cenzwong/cenz-cmd"
BRANCH="master"

if [[ $# -lt 1 ]]; then
  echo "Usage: cenz <script-name> [args...]"
  exit 1
fi

NAME="$1"; shift
URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/bin/${NAME}.sh"

# curl -fsSL "$URL" | bash -s -- "$@"

curl -fsSL \
  -H 'Cache-Control: no-cache, no-store, max-age=0' \
  -H 'Pragma: no-cache' \
  "$URL" | bash -s -- "$@"