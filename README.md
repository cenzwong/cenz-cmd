# cenz-cmd

**Utility for alias bash commands** — a lightweight “command loader” that lets you run small shell utilities from a single entrypoint. [\[github.com\]](https://github.com/cenzwong/cenz-cmd)

The idea is simple:

*   You run: `cenz <script-name> [args...]`
*   `cenz` downloads `bin/<script-name>.sh` from this GitHub repo and executes it
*   **All flags/args are passed through** to the remote script

Repo structure includes `bin/`, `install.sh`, and this README. [\[github.com\]](https://github.com/cenzwong/cenz-cmd)

***

## Features

*   ✅ One command (`cenz`) to run many scripts
*   ✅ Scripts live in `bin/*.sh`
*   ✅ Pass-through arguments: `cenz foo --bar 1` → runs `foo.sh` with `--bar 1`
*   ✅ Easy to add new commands: just add a new `bin/<name>.sh`

***

## Quick Start (macOS)

### 1) Put `cenz` somewhere on your PATH

The most common personal location on macOS is:

*   `~/bin` (simple and user-owned), or
*   `~/.local/bin` (also common)

Example using `~/bin`:

```bash
mkdir -p ~/bin
```

Add it to PATH (zsh is default on modern macOS):

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

> If you use bash, replace `~/.zshrc` with `~/.bashrc`.

### 2) Create the `cenz` runner script

Create `~/bin/cenz`:

```bash
cat > ~/bin/cenz <<'EOF'
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

curl -fsSL "$URL" | bash -s -- "$@"
EOF

chmod +x ~/bin/cenz
```

Now you can run:

```bash
cenz git-cleanup
cenz czls -a --long
```

***

## Usage

### Basic

```bash
cenz <script-name> [args...]
```

Examples:

```bash
cenz git-cleanup
cenz git-cleanup --master
cenz czls --help
```

***

## Add a New Command

1.  Create a new file in this repo:

<!---->

    bin/<name>.sh

2.  Make sure it’s a bash script and accepts flags normally, e.g.:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Hello from <name>.sh"
echo "Args: $*"
```

3.  Commit & push.

Now it becomes available via:

```bash
cenz <name> [args...]
```

***

## Optional: Run commands without typing `cenz` (wrappers)

If you want to run `git-cleanup` directly (instead of `cenz git-cleanup`), create a small wrapper script locally:

```bash
cat > ~/bin/git-cleanup <<'EOF'
#!/usr/bin/env bash
exec cenz git-cleanup "$@"
EOF

chmod +x ~/bin/git-cleanup
```

Now:

```bash
git-cleanup --master
```

> This avoids editing shell rc files for every command—you only add wrappers when you want a shortcut.

***

## Avoid “cached” downloads (force fresh fetch)

`curl` itself doesn’t cache, but CDNs/proxies can. To force a fresh fetch, you can add a cache-busting query string:

```bash
URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/bin/${NAME}.sh?cb=$(date +%s)-$RANDOM"
curl -fsSL "$URL" | bash -s -- "$@"
```

You can also send no-cache headers:

```bash
curl -fsSL \
  -H 'Cache-Control: no-cache, no-store, max-age=0' \
  -H 'Pragma: no-cache' \
  "$URL" | bash -s -- "$@"
```

**Best**: do both.

***

## Security Notes

Running scripts via `curl | bash` is convenient, but it means you execute whatever is currently at that URL.

Recommendations:

*   Prefer pinning to a tag or commit SHA for critical scripts
*   Or download scripts locally, inspect them, then run

***

## Troubleshooting

### “command not found: cenz”

*   Ensure `~/bin` is in your `PATH`
*   Restart terminal or run: `source ~/.zshrc`
*   Check: `which cenz`

### Script not found (404)

*   Confirm the script exists at: `bin/<name>.sh`
*   Confirm your `REPO` + `BRANCH` values match your GitHub branch naming

***

## Repository Layout

*   `bin/` — runnable command scripts (`*.sh`) [\[github.com\]](https://github.com/cenzwong/cenz-cmd)
*   `install.sh` — installer script (optional) [\[github.com\]](https://github.com/cenzwong/cenz-cmd)
*   `README.md` — documentation [\[github.com\]](https://github.com/cenzwong/cenz-cmd)

***

## License

Add a license file if you want others to reuse your scripts easily (MIT is a common choice).

***

If you want, paste the content of your current `install.sh` here and I can:

*   update the README to match *exactly* what your installer does, and
*   add a one-line install command like `curl ... | bash` that installs `cenz` + PATH cleanly on macOS.
