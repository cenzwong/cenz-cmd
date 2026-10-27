#!/bin/zsh
set -euo pipefail

# Inline instructions, stored in a temporary file
INSTRUCTIONS_FILE=$(mktemp /tmp/codex-hi.XXXXXX)
trap 'rm -f "$INSTRUCTIONS_FILE"' EXIT

cat > "$INSTRUCTIONS_FILE" <<'EOF'
You are a minimal text responder.
Reply exactly: Hi
Do not use tools or execute commands.
EOF

# Minimal Codex execution
codex exec \
  --ignore-user-config \
  --ephemeral \
  --skip-git-repo-check \
  -C /tmp \
  --model gpt-6-luna \
  -c model_reasoning_effort=none \
  -c model_verbosity=low \
  -c "model_instructions_file=$INSTRUCTIONS_FILE" \
  -c features.apps=false \
  -c features.plugins=false \
  -c features.shell_tool=false \
  -c skills.include_instructions=false \
  -c memories.use_memories=false \
  -c tools.view_image=false \
  -c tools.web_search=false \
  --sandbox read-only \
  --json \
  "Reply exactly: Hi" \
  | jq -c 'select(.type=="turn.completed") | .usage'
