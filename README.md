# eladve-cmux-browser

Claude Code plugins that make the **cmux browser** Claude's default for web research — so it reads real, logged-in, JS-rendered pages instead of weak `fetch` / WebSearch snippets. (Plus an optional dark theme.) This is Elad's personal setup, packaged to share.

## Quickstart

**Before you start, you'll need:**
- **macOS** with **Claude Code**.
- **[cmux](https://cmux.com)** installed — and **run Claude Code from inside a cmux terminal** (the plugin opens browser panes beside it; setup checks this).
- **python3** (every recent macOS has it; one hook uses it). *Optional:* the **claude-in-chrome** extension, used only as a last-resort backup browser.

**1. Install** — paste into Claude Code:
```bash
claude plugin marketplace add eladve/eladve-cmux-browser
claude plugin install eladve-cmux-browser@eladve-claude-setup
claude plugin install eladve-theme@eladve-claude-setup   # optional theme
```
*(You `add` the repo `eladve/eladve-cmux-browser`, then `install` from the marketplace it defines, `eladve-claude-setup` — that's why the two names differ.)*

**2. Restart Claude Code** (or run `/reload-plugins`) so the new skills load — otherwise the next step won't be found yet.

**3. Run the one-time setup:**
```
/eladve-cmux-browser:setup
```
It checks cmux, walks you through logging into the sites you research through (cmux keeps you logged in afterward), and — with your approval — makes cmux the default for web work. **Do this before you browse anything**, or cmux won't be logged in and you'll just hit login walls.

**4. (optional) Theme:** `/theme` → pick **Cmux Dark**.

**That's it.** Research normally — when Claude needs a page, a browser pane opens beside your terminal (that's expected; Claude tidies its tabs when done).

## What you get

**`eladve-cmux-browser`** — makes the cmux browser Claude's default for interactive web work and multi-item research (instead of `fetch` / WebSearch snippets, which are weaker for anything JS-heavy, login-walled, or about real people and companies). It bundles:
- **`cmux-browser` skill** — the operating manual: the cmux loop, surface hygiene, fetch/WebSearch discipline, parallel-research patterns, the "facts you rely on come from cmux-loaded pages, not snippets" rule, and shared-account etiquette.
- **`setup` skill** (`/eladve-cmux-browser:setup`) — the one-time walkthrough from the Quickstart.
- **`canary` agent** (`eladve-cmux-browser:canary`) — a ~30-second check that parallel browser subagents work, to run before firing a large batch.
- **a `PreToolUse` hook** — a soft, never-blocking nudge (keep browser tabs tidy; don't `fetch`/`WebFetch` a cmux-only domain).

**`eladve-theme`** *(optional)* — a dark Claude Code theme: black background, warm-orange user turns so your messages pop. Adds **Cmux Dark** to `/theme`. (Themes are an experimental plugin component.)

## Updating

```bash
claude plugin update eladve-cmux-browser
```
(Restart Claude Code to apply.)

## Uninstall

```bash
claude plugin uninstall eladve-cmux-browser
```
The plugin is fully removed — **but the one-time setup changed your global config, and uninstall does NOT revert that.** Undo by hand if you want it gone:
- `~/.claude/settings.json` → remove the `Bash(cmux *)` allow rule, the `cmux` deny rules (`close-window` / `close-workspace` / `browser open-split`), and `"WebFetch"` from `deny` (if you barred it).
- `~/.claude/CLAUDE.md` → delete the `**Web/browser default (eladve-cmux-browser):**` line.

## Notes

- **Carries no personal data** — you log into your own accounts during setup.
- Does **not** install cmux, change your shell, run background processes, or require admin rights.

## License

0BSD — public-domain-equivalent; do anything, no attribution required. See `LICENSE`.
