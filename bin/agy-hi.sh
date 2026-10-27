#!/bin/zsh
set -euo pipefail

# Include common macOS CLI installation locations
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Avoid loading context from a project repository
cd /tmp

if ! command -v agy >/dev/null 2>&1; then
  echo "Antigravity CLI (agy) not found" >&2
  exit 1
fi

# One-off, low-effort request
result=$(agy \
  -p "Reply exactly: Hi. Do not use tools or access files." \
  --model gemini-3.8-flash-low \
  --effort low \
  --disable-slash-commands \
  --print-timeout 2m \
  --output-format json)

# Verify successful completion
status=$(echo "$result" | jq -r '.status // "UNKNOWN"')

if [[ "$status" != "SUCCESS" ]]; then
  echo "$result" >&2
  exit 1
fi

echo "$result" | jq -c '{status, response, usage}'
