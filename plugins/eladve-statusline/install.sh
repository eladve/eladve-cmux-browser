#!/bin/bash
# Installs the Claude Code status line:
#   1. copies statusline.sh -> ~/.claude/statusline.sh (+x)
#   2. registers it in ~/.claude/settings.json under "statusLine"
# Idempotent: safe to re-run. Backs up settings.json before editing.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/statusline.sh"
claude_dir="$HOME/.claude"
dest="$claude_dir/statusline.sh"
settings="$claude_dir/settings.json"

# --- dependency check: the script parses JSON with jq ---
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required but not installed." >&2
  echo "  macOS:  brew install jq" >&2
  echo "  Debian/Ubuntu:  sudo apt-get install jq" >&2
  echo "  Other:  https://jqlang.github.io/jq/download/" >&2
  exit 1
fi

[ -f "$src" ] || { echo "ERROR: statusline.sh not found next to install.sh" >&2; exit 1; }

mkdir -p "$claude_dir"

# --- 1. install the script ---
cp "$src" "$dest"
chmod +x "$dest"
echo "✓ installed $dest"

# --- 2. register it in settings.json (create if missing, back up if present) ---
[ -f "$settings" ] || echo '{}' > "$settings"

# back up the existing settings before touching them
backup="$settings.bak"
cp "$settings" "$backup"

tmp="$(mktemp)"
jq '.statusLine = {"type":"command","command":"bash ~/.claude/statusline.sh"}' "$settings" > "$tmp"
mv "$tmp" "$settings"
echo "✓ registered statusLine in $settings  (backup: $backup)"

echo
echo "Done. Restart Claude Code (or it'll pick up the status line on the next render)."
