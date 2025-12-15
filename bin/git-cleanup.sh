
#!/usr/bin/env bash
# git branch | grep -v "main" | grep -v "^\*" | xargs -r git branch -D && git fetch --prune && git branch -a

set -euo pipefail

# Default protected branch
KEEP_BRANCH="main"
DRY_RUN=0
PRUNE=1

usage() {
  cat <<EOF
Usage: git-cleanup [--main|--master|--keep <branch>] [--dry-run] [--no-prune]

Deletes all local branches except:
  - the protected branch (default: main)
  - the currently checked-out branch

Options:
  --main            Keep 'main' (default)
  --master          Keep 'master'
  --keep <branch>   Keep a specific branch name
  --dry-run         Show what would be deleted, but don't delete
  --no-prune        Skip 'git fetch --prune'
  -h, --help        Show this help
EOF
}

# ---- Parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --main)
      KEEP_BRANCH="main"
      shift
      ;;
    --master)
      KEEP_BRANCH="master"
      shift
      ;;
    --keep)
      [[ $# -ge 2 ]] || { echo "Error: --keep requires a branch name"; exit 1; }
      KEEP_BRANCH="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-prune)
      PRUNE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo
      usage
      exit 1
      ;;
  esac
done

# ---- Safety checks ----
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository."
  exit 1
}

CURRENT_BRANCH="$(git branch --show-current || true)"

if [[ -z "$CURRENT_BRANCH" ]]; then
  echo "Warning: You are in detached HEAD state."
  echo "Will protect only: '$KEEP_BRANCH' (if it exists)."
fi

echo "Protected branch: $KEEP_BRANCH"
[[ -n "$CURRENT_BRANCH" ]] && echo "Current branch:   $CURRENT_BRANCH"
echo

# ---- Collect deletable branches ----
# List local branches reliably
# refs/heads only (local branches)
mapfile -t LOCAL_BRANCHES < <(git for-each-ref refs/heads --format='%(refname:short)' | sort)

TO_DELETE=()
for b in "${LOCAL_BRANCHES[@]}"; do
  # Skip protected and current branch
  if [[ "$b" == "$KEEP_BRANCH" ]]; then
    continue
  fi
  if [[ -n "$CURRENT_BRANCH" && "$b" == "$CURRENT_BRANCH" ]]; then
    continue
  fi
  TO_DELETE+=("$b")
done

if [[ ${#TO_DELETE[@]} -eq 0 ]]; then
  echo "No local branches to delete."
else
  echo "Branches to delete:"
  printf '  - %s\n' "${TO_DELETE[@]}"
  echo

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] Skipping deletion."
  else
    for b in "${TO_DELETE[@]}"; do
      git branch -D "$b"
    done
  fi
fi

# ---- Prune and list ----
if [[ "$PRUNE" -eq 1 ]]; then
  echo
  echo "Fetching & pruning remote-tracking branches..."
  git fetch --prune
fi

echo
echo "Remaining local branches:"
git branch -al
