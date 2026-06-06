# eladve-cmux-browser

This repo is a Claude Code **plugin marketplace** (`eladve-claude-setup`) holding Elad's personal Claude Code setup. It currently ships two plugins.

## Plugins

### `eladve-cmux-browser` — cmux-first browsing & research

Makes **the cmux browser Claude's default tool** for interactive web work and multi-item research — instead of letting it fall back to `fetch` or WebSearch snippets, which are weaker for anything JS-heavy, login-walled, or about real people and companies. Bundles:

- **`cmux-browser` skill** — the operating manual: the cmux default loop, surface hygiene, fetch/WebSearch discipline, parallel-research patterns, the "facts about people/companies must come from cmux-loaded pages" rule, and shared-account etiquette.
- **`setup` skill** (`/eladve-cmux-browser:setup`) — a one-time interactive walkthrough: checks prerequisites, walks you through logging into LinkedIn and other research sites (logins are sticky in cmux), optionally allowlists cmux commands and adds a default-rule line to your `CLAUDE.md`, and verifies parallel browser surfaces work.
- **`canary` agent** (`eladve-cmux-browser:canary`) — a ~30-second check that parallel browser subagents work, to run before firing a large batch.
- **A `PreToolUse` hook** — a soft nudge (keep browser tabs tidy; don't fetch/WebFetch a cmux-only domain). It never blocks. (Browsing subagents are seeded with the cmux policy via the skill, not a blanket hook.)

### `eladve-theme` — Cmux Dark (optional)

A dark Claude Code theme: black background, warm-orange user turns so your messages pop. Adds **Cmux Dark** to `/theme`. (Themes are an experimental Claude Code plugin component.)

## Prerequisites

- **macOS** with **Claude Code** installed.
- **[cmux](https://cmux.com)** installed (the browser plugin drives it; it does not install it). The setup skill checks for it.
- **python3** (every recent macOS has it; the two hooks use it).
- *Optional:* the **claude-in-chrome** Chrome extension/MCP, used only as a last-resort backup browser.

## Install

```bash
# add this marketplace (one time)
claude plugin marketplace add eladve/eladve-cmux-browser

# the browser plugin (user scope = available in all your projects)
claude plugin install eladve-cmux-browser@eladve-claude-setup

# optional: the theme
claude plugin install eladve-theme@eladve-claude-setup
```

> The marketplace is named **`eladve-claude-setup`** (it's defined inside the `eladve-cmux-browser` repo) — that's why `add` uses the repo name and `install` uses the marketplace name.

**After installing, restart Claude Code (or run `/reload-plugins`)** so the new skills and agent load — otherwise the setup command won't be found yet. **Then, before you browse anything, run the one-time setup** — it logs you into your sites and writes the defaults; without it, cmux isn't logged in and you'll just hit login walls:

```
/eladve-cmux-browser:setup
```

It checks cmux, walks you through your logins, and (with your OK) makes cmux the default for web work in every session. For the theme: `/theme` → pick **Cmux Dark**.

After that, just research normally — when Claude needs a page, **a browser pane opens beside your terminal** (that's expected; Claude closes those tabs when it's done).

## Updating

```bash
claude plugin update eladve-cmux-browser
```

(Restart Claude Code to apply.)

## Uninstall

```bash
claude plugin uninstall eladve-cmux-browser
```

The plugin itself lives under `~/.claude/` and is fully removed. **But the one-time setup made changes to your global config that uninstalling does NOT revert** — undo them by hand if you want them gone:
- `~/.claude/settings.json` → remove the `Bash(cmux *)` allow rule, the three `cmux …` deny rules, and `"WebFetch"` from `deny` (if you barred it).
- `~/.claude/CLAUDE.md` → delete the `**Web/browser default (eladve-cmux-browser):**` line.

## Notes

- Self-contained and **carries no personal data** — you log into your own accounts during setup.
- It does **not** install cmux, change your shell, run background processes, or require admin rights.

## License

0BSD — public-domain-equivalent; do anything, no attribution required. See `LICENSE`.
