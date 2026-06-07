---
name: setup
description: Sets up the eladve-cmux-browser plugin on first use — checks cmux + python3, guides the user through logging into the sites they research through in the cmux browser (logins are sticky), optionally allowlists cmux commands and adds the cmux-default rule to the user's CLAUDE.md, and optionally verifies parallel browser surfaces. Run once after installing, when the user runs /eladve-cmux-browser:setup or asks to set up cmux browsing.
disable-model-invocation: true
---

# cmux Browser — One-Time Setup

You are running an **interactive** onboarding for the person who just installed this plugin. Goal: get cmux browsing working as their default research tool, with their own logins in place. Be brief and concrete. Follow these steps in order.

> ⚠️ Batch the questions. Ask the **config choices in Step 2 all at once** (one message), and give the **logins in Step 4 as one list** (one message). Do not drip-feed one prompt at a time.

## Step 1 — Prerequisites (no questions; just check and report)

Run:
- `cmux --version` — if not found, STOP and tell the user: "cmux isn't on your PATH. Install the cmux app first (https://cmux.com), then re-run `/eladve-cmux-browser:setup`." Do not continue.
- `printf '%s' "$CMUX_WORKSPACE_ID"` (or `cmux identify`) — confirms Claude Code is running **inside a cmux terminal**. If it's empty/unset, WARN: "Claude Code isn't running inside cmux — the browser-pane-beside-your-terminal experience needs that. Best: open a cmux terminal, run Claude Code there, and re-run setup. (cmux browser may still work, but panes won't appear beside this terminal.)" Then ask whether to continue anyway.
- `python3 --version` — the plugin's `browser-policy.py` hook is Python. If missing, tell the user to install it (`xcode-select --install` on macOS) but you can continue setup; the hook just won't fire until it's present.
- `cmux browser open about:blank` — confirms the browser subsystem responds; note the returned `surface:N`. If this errors, report the error and ask whether to continue or troubleshoot.

Report a one-line status for each.

## Step 2 — Config choices (surface every file change; ask once, batched)

Setup can modify two of the user's files: `~/.claude/settings.json` and `~/.claude/CLAUDE.md`. **Surface every proposed change with its exact content and get approval before writing — never modify her files silently, even when a change is obviously good.** Present ALL of the following in ONE message. Tell the user they can reply **`all recommended`** to accept every default, or customize per item (e.g. `3B` to keep WebFetch, or "all recommended except 3B"). Then wait for their answer:

1. **Allowlist cmux** — add `"Bash(cmux *)"` to `permissions.allow` in `~/.claude/settings.json` (otherwise every `cmux` call prompts).
   - **A. Add it (recommended).**  B. I'll press `a` at the first prompt instead.  C. Skip.
2. **Safety deny-rules** — add to `permissions.deny` in `~/.claude/settings.json`: `Bash(cmux close-window:*)`, `Bash(cmux close-workspace:*)`, `Bash(cmux browser open-split:*)` (stops a runaway command from closing your terminal; deny beats allow; `close-surface` stays allowed).
   - **A. Add (recommended).**  B. Skip.
3. **Bar WebFetch?** — add `"WebFetch"` to `permissions.deny`. WebFetch returns an AI *summary* (not verbatim), so barring it enforces cmux / raw-fetch sourcing. **Note: this is global — it disables WebFetch for ALL your Claude work, not just research.**
   - **A. Bar it (recommended for sourcing discipline).**  B. Keep it (the skill still treats its output as non-verbatim).
4. **CLAUDE.md default rule (GLOBAL — say so out loud).** Append the line below to `~/.claude/CLAUDE.md`. **It applies to ALL your projects, every session** (not just research) — it's what makes cmux the default even when the skill doesn't auto-trigger. **If you skip it (B):** cmux is the default only when the `cmux-browser` skill happens to trigger on a task (less reliable), and you can paste the line into your CLAUDE.md yourself anytime later.
   > **Web/browser default (eladve-cmux-browser):** For any interactive web work or multi-item research, default to the cmux browser via the `cmux-browser` skill. Use a fetch tool only for known static, robots-open, no-login reads (`WebFetch` output is AI-summarized — not verbatim); WebSearch for discovery only (no `site:`); never silently fall back. Facts about real people or companies must come from cmux-loaded pages.
   - **A. Append it (recommended).**  B. Skip — rely on the skill triggering on its own (add the line yourself later if you change your mind).
5. **(Advanced) Verify parallel research with the canary?** Only useful if you'll fan out multiple browser subagents at once — runs a ~30s parallel-surface check. **A. Skip (default).**  B. Run it.

**Then apply ONLY the approved changes, safely (never clobber):**
- **`settings.json`:** read it (create `{}` if absent); **parse the JSON and MERGE** — add only the missing entries into the existing `permissions.allow` / `permissions.deny` arrays (create the arrays / `permissions` object only if absent), **preserving every other key and existing entry**. NEVER rewrite the file wholesale. If it isn't valid JSON (e.g. comments/JSONC), STOP and show the user exactly what to add by hand.
- **`CLAUDE.md`:** create the file if absent; **append** the approved line (never overwrite); skip if an identical line is already present. If the file already has a conflicting web/browser-tool rule, surface that to the user before appending (don't create contradictory guidance).
- **Show the before→after diff of each file you touched** and confirm it matches what they approved. If any change would drop or alter existing content, STOP and ask before writing.
- If they chose 5B (the advanced canary), remember to run Step 5c at the end.

## Step 3 — (applying changes is covered in Step 2)

## Step 4 — Log in (one batched instruction)

First, figure out which sites the user researches through (ask if it's not obvious from their work). If they name a primary one, open it in cmux + `get text --selector body` (first ~400 chars) to see whether they're already logged in.

Then send **one** message telling the user to log in to everything now. Phrase it like:

> I've opened a cmux **browser pane beside your terminal**. **Click into it and log in to each site the normal way** (enter credentials, complete any 2FA) — cmux keeps you logged in afterward (sticky profile), so you only do this once. Now's the time; please log into **the sites you research through**, for example:
> - **Whatever's central to your work** — e.g. LinkedIn (people/company), GitHub (code), a data provider / journal / internal dashboard / news site. [If your pre-check showed a primary site walled: "you're not logged into <site> yet — please log in now."] [If already logged in: "✅ already logged into <site>."]
> - **A throwaway Google account** — optional but recommended; logged-in Google sessions hit far fewer "verify you're human" walls during searches.
> - **Anything else** you'll research through.
>
> Tell me when you're done and I'll verify.

Wait for them. Do **not** loop site-by-site.

## Step 5 — Verify

- **5a (always):** re-open the primary site they logged into (whatever they named — e.g. `linkedin.com/feed/`, a GitHub page, their dashboard) in cmux, `get text --selector body`, confirm it's authenticated (shows their content/name, not a login wall). Report ✅/❌. If still walled, ask them to complete login and retry once.
- **5b (always) — show it working:** do ONE quick real lookup via cmux so they *see* the value — e.g. open a site they just logged into and confirm it shows them signed in, or read one fact off a page in their domain (a profile, a repo, a dashboard, an article). Report what you found. This confirms the pipeline end-to-end and demonstrates what they'll get day-to-day.
- **5c (only if they chose 5B — the advanced canary):** allocate 2 browser surfaces and fire the `eladve-cmux-browser:canary` subagent (`subagent_type: eladve-cmux-browser:canary`) on each with sums "1+1" and "2+2". If both return OK, parallel browsing works. If the agent type isn't found, tell them to restart Claude Code (custom agents load at session start) and re-run setup. **If the canary reports a CAPTCHA / "verify you're human" wall on Google, that's a Google-session issue (log into a Google account and retry), NOT a cmux failure — note it and proceed.**
- Close any surfaces you opened for verification (`cmux close-surface`), but leave the user's login pane alone.

## Step 6 — Done

Summarize: what's configured (allowlist? CLAUDE.md rule? canary result?), which sites are logged in, and how to use it from here: **"Just browse and research normally — if you appended the CLAUDE.md rule, Claude now defaults to the cmux browser for web work; otherwise it uses cmux whenever the `cmux-browser` skill triggers on a task. The `cmux-browser` skill has the full playbook. Update the plugin later with `claude plugin update eladve-cmux-browser`."** Then tell them where the global changes live so they can undo them: `~/.claude/settings.json` (allowlist / deny-rules / WebFetch bar) and `~/.claude/CLAUDE.md` (the default-rule line) — e.g. to re-enable WebFetch later, remove `"WebFetch"` from `permissions.deny`.
