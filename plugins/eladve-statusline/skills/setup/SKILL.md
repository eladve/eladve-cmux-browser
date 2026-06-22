---
name: setup
description: Installs the eladve-statusline status line — checks for jq, copies the bundled statusline.sh into ~/.claude/, and registers it in the user's ~/.claude/settings.json (merging, never clobbering; backs up first). Run once after installing the plugin, when the user runs /eladve-statusline:setup or asks to set up / install the status line.
disable-model-invocation: true
---

# Status line — One-Time Setup

You are installing a custom Claude Code status line for the person who just installed this plugin. Be brief and concrete. The bundled installer does the work; your job is to run it, surface the one file change it makes, and confirm it took effect.

## Step 1 — Prerequisite (check and report, no questions)

Run `command -v jq`.
- If **missing**, STOP and tell the user: the status line parses JSON with `jq`. Install it (`brew install jq` on macOS, `sudo apt-get install jq` on Debian/Ubuntu, otherwise https://jqlang.github.io/jq/download/), then re-run `/eladve-statusline:setup`. Do not continue.
- If present, report `✓ jq found` and continue.

## Step 2 — Install (surface the change, then run)

The installer makes exactly two changes, both under `~/.claude/`:
1. copies `statusline.sh` → `~/.claude/statusline.sh` (executable)
2. sets the `statusLine` key in `~/.claude/settings.json` to `{"type":"command","command":"bash ~/.claude/statusline.sh"}` — **merging** into the existing file (every other setting preserved), after backing it up to `~/.claude/settings.json.bak`.

Tell the user those two changes in one line, then run the bundled installer:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/install.sh"
```

If `${CLAUDE_PLUGIN_ROOT}` is empty in your shell, find this plugin's directory (it contains `install.sh` next to `statusline.sh`) and run that `install.sh` — do not hand-roll the steps.

It's idempotent — safe to re-run. If it exits non-zero (e.g. jq missing, or `settings.json` isn't valid JSON), report the exact error and stop; for invalid JSON, show the user the one key to add by hand rather than overwriting their file.

## Step 3 — Show what changed

After it runs, show the user the before→after of their settings by diffing the backup against the new file:

```bash
diff <(jq -S . ~/.claude/settings.json.bak) <(jq -S . ~/.claude/settings.json) || true
```

Confirm the only addition is the `statusLine` key (everything else unchanged).

## Step 4 — Activate and confirm

The status line is set in `settings.json`, which Claude Code re-reads on reload. Tell the user:

> Run **`/reload-plugins`** (or restart Claude Code) and the status line appears at the bottom.

Then summarize, briefly: what the line shows (location · model/effort/style · git · ctx% · session · 5h/wk usage, colored green/yellow/red by threshold), and how to undo it — remove the `statusLine` key from `~/.claude/settings.json` (or restore `~/.claude/settings.json.bak`) and delete `~/.claude/statusline.sh`.

Optionally, render a quick preview so they see it before reloading:

```bash
printf '%s' '{"cwd":"/x/proj","workspace":{"project_dir":"/x/proj","added_dirs":[]},"model":{"display_name":"Opus 4.8 (1M context)"},"effort":{"level":"high"},"fast_mode":false,"thinking":{"enabled":true},"context_window":{"used_percentage":42},"rate_limits":{"five_hour":{"used_percentage":63},"seven_day":{"used_percentage":28}},"output_style":{"name":"default"},"session_name":"preview","transcript_path":"","agent":{"name":""},"pr":{"number":"","review_state":""}}' | bash ~/.claude/statusline.sh; echo
```
