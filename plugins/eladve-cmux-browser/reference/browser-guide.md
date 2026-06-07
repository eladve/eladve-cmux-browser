# Browser & Web-Access Guide (cmux-first) — deep reference

The full reference behind the **`cmux-browser`** skill. The skill is the short, always-on version; open this when you need the detail. A `PreToolUse` hook surfaces a one-line reminder when you create a browser surface or fetch a cmux-only domain.

---

## Contents
§0 short version · §1 tool decision table · §2 fetch discipline · §3 priority order · §4 surface hygiene · §5 cmux loop + cheatsheet · §6 cmux traps · §7 claude-in-chrome backup · §8 WebSearch · §9 accounts & shared-login etiquette · §10 caching · §11 rate limits · §12 domain notes · §13 safety · §14 per-step routing

---

## §0 — The short version (memorize this)

- **cmux browser is the DEFAULT** for all interactive web work. Drive it via Bash (`cmux browser …`).
- **fetch is the EXCEPTION**, not a default — use it ONLY for a *known URL* that is robots-open + static + no-JS + no-login (Scholar profiles, arXiv, GitHub, Wikipedia, plain pages, non-paywalled PDFs). **State why in one sentence** when you use it. A fetch robots-block = *fall back to cmux*, NOT "NOT FOUND."
- **claude-in-chrome MCP is last-resort backup** — only when cmux genuinely can't (WebKit-blocked site, your real Chrome profile/extensions, CDP-only features). **State the specific reason.**
- **WebSearch is discovery-only** and **does not support `site:`** (silently ignored). Never treat snippets as verbatim. For `site:` searches, use cmux + `google.com/search?q=…`.
- **Facts about a real person/company (briefs, dossiers) REQUIRE cmux** (or claude-in-chrome). Never from WebSearch snippets or pattern-guessing.
- **Surface hygiene:** open research/browser surfaces in a **dedicated pane** (or workspace) — never as tabs in the terminal's pane; **NEVER `close-surface` on anything sharing the focused terminal's pane** (it makes the terminal look closed/lost).
- **Never silently fall back** between tools — if the default can't do it, say so and ask. **Never `pkill` a browser** (chrome/chromium/safari/firefox) to fix a tooling error.

---

## §1 — Tool decision table (task → tool)

| Task | Tool | Notes |
|---|---|---|
| JS-heavy page / SPA / login-walled / social media / any interaction / **anything you're unsure about** | **`cmux browser`** | the default / spine |
| Facts about a real **person or company** (briefs, dossiers, profiles) | **`cmux`** (or claude-in-chrome) — **REQUIRED** | never snippets/guesses |
| **LinkedIn** (any) | **`cmux` ALWAYS** | log in once (see setup); use `/details/` subpages |
| Read a **known URL** that is robots-open + static + no-JS + no-login | **`fetch`** (a fetch MCP — raw markdown) — say why | Scholar profile, arXiv, GitHub, Wikipedia, plain pages, non-paywalled PDFs |
| Same read, but only the built-in **`WebFetch`** tool is available | **`WebFetch`** — but its output is an AI *summary*, not verbatim | rough/discovery read only; for facts use cmux |
| Reading a web page via desktop **`computer-use`** | **don't** — use cmux/claude-in-chrome | computer-use is for native apps / pixel tasks, not web reading |
| **Discovery / "does X exist"** search (no `site:`) | **`WebSearch`** | snippets only — discovery, never verbatim |
| **`site:`-filtered** search | **`cmux` + `google.com/search?q=…`** | WebSearch silently ignores `site:` |
| GitHub user/repo **discovery** | **`fetch`** GitHub API (`api.github.com/search/users?q=`) | beats Google for GitHub |
| Needs your real Chrome profile / extensions / 1Password / CDP-only | **`claude-in-chrome`** (state reason) | last-resort backup |
| Local record / JSON / file checks | no web tool — Read/Grep/Bash | |

**When unsure → cmux.** Never sacrifice a verbatim source for speed.

---

## §2 — fetch discipline (fixes over-use)

fetch is fast and tempting, so it gets over-used. The rule:

**fetch works iff (robots-open) AND (static, no JS) AND (no login).** Empirically:
- ✅ fetch-friendly: Google Scholar `/citations?user=`, arXiv `/abs/` + PDFs, GitHub + `api.github.com`, Wikipedia, plain academic/personal/conference pages, non-paywalled publisher PDFs.
- ❌ cmux-only (fetch robots-blocked or JS/login): **LinkedIn** (hard-blocked), ResearchGate, ORCID (API + pages), Crunchbase, Google Patents *search* (but `/patent/<id>` direct pages are fetch-OK), DBLP *search* (but `/pid/`,`/pers/`,`/rec/` direct pages OK), Medium-paywalled, anything behind JS/login.

**Rules:**
1. fetch is the *exception*, cmux is the *default*. Reach for fetch only when the read is a known robots-open static URL **and** isn't fidelity-critical.
2. **State why in one sentence** when you use fetch (e.g., "Using fetch — arXiv abstract renders as plain markdown").
3. A fetch **robots-block or empty render = fall back to cmux**, never "NOT FOUND."
4. Search/discovery is NOT a fetch job (most search endpoints robots-block fetch + fetch can't `site:`). Discovery = WebSearch (no `site:`) or cmux+Google (`site:`).
5. **`WebFetch` (built-in) ≠ a raw fetch** — it returns a model *summary*, not verbatim text. Treat it like a WebSearch snippet (discovery/rough only); never quote it or source facts from it; prefer a raw fetch MCP or cmux. Consider barring it (`permissions.deny: ["WebFetch"]`) for sourcing discipline.

---

## §3 — Priority order (and never-silent-fallback)

1. **cmux browser** — default for all interactive web work.
2. **fetch** (a fetch MCP, or the built-in `WebFetch` — but WebFetch is AI-summarized, not verbatim) — robots-open static reads only (per §2).
3. **claude-in-chrome MCP** — backup only; state the specific reason (WebKit-blocked / your Chrome profile / CDP-only).
4. **WebSearch** — discovery only, no `site:`, never verbatim.

**Never silently fall back.** If the default tool can't do the job, say so and ask before substituting. (This is a hard rule: WebSearch-based person/company "facts" tend to reassert pattern-guessed and discriminatory shortcuts that real page-loads would have avoided.)

---

## §4 — Surface hygiene

- **Open research/browser surfaces in a DEDICATED PANE** (`cmux new-pane --type browser` — side-by-side with the terminal, same workspace; a separate workspace also works), **never as tabs in the working-terminal's pane.** A separate pane is preferred (you see terminal + browser together). cmux nesting: *window* ⊃ *workspace* (the tabs you scroll) ⊃ *pane* (splits) ⊃ *surface* (tabs in a pane).
- **NEVER `cmux close-surface` on anything sharing the focused terminal's pane.** Closing tabs in the terminal's pane makes the terminal's tab strip drop tabs and *look* closed/lost (alarming; erodes trust).
- **Clean up by closing browser tabs one at a time with `cmux close-surface --surface <id>`** — ALWAYS pass `--surface`; a bare/positional `cmux close-surface` closes the CURRENT pane (the terminal). NEVER `close-workspace` / `close-window` as "cleanup" — that destroys the whole workspace, including any terminal in it (this has killed a live session before).
- **Subagents that open surfaces** don't clean up after themselves — the main agent must close their surfaces.
- **Parallel surfaces:** open ONE browser pane, add the rest as TABS (`cmux new-surface --type browser --pane <pane>`) — single-pane footprint; tabs navigate independently by `surface_id`.

---

## §5 — cmux core loop + cheatsheet

```
cmux --json browser open <url>          # returns surface:N
cmux browser surface:N get url
cmux browser surface:N wait --load-state complete --timeout-ms 15000
cmux browser surface:N snapshot --interactive
cmux --json browser surface:N click e3 --snapshot-after
```
Keep one `surface:N` per task. Use `--json` when parsing. `--snapshot-after` on click/fill/select/scroll gives a fresh ref tree.

| Task | cmux command |
|---|---|
| Open / navigate / back / reload | `browser open <url>` · `surface:N navigate <url>` / `back` / `reload` |
| Tabs (list/switch/close) | `surface:N tab list` / `switch <i>` / `close` |
| Snapshot DOM w/ refs | `surface:N snapshot --interactive` |
| Find element | `surface:N find role/text/label/placeholder/testid <value>` |
| Click / type / fill / press / select | `surface:N click <ref>` / `type` / `fill` / `press` / `select <ref> <value>` |
| Wait | `surface:N wait --selector/--text/--url-contains/--load-state/--function …` |
| **Read text / html** | `surface:N get text --selector body` / `get html --selector <css>` |
| Screenshot (visual only) | `surface:N screenshot --out <path>` |
| Cookies / storage / state | `surface:N cookies …` / `storage …` / `state save/load <abs-path>` |
| Recover lost context | `cmux identify --json` |

**Auth:** all cmux surfaces share one WKWebView profile — cookies persist across surfaces + close/reopen. Log in once per site; no `state save` dance needed. (`state save` `js_error`s on hardened sites like LinkedIn — it's optional backup only; use absolute paths + `ls -la` to verify.)

_cmux's CLI evolves — if a subcommand or flag is rejected, run `cmux browser --help` / `cmux --help`; this cheatsheet reflects a recent version._

---

## §6 — cmux traps & fixes (don't retry the same broken call)

| Trap | Fix |
|---|---|
| `get text` alone → "requires a selector" | always `get text --selector body` (or a CSS selector) |
| `eval --script` `js_error` on quotes/backticks/templates | use `snapshot --max-depth N` / `get text --selector` / `find` instead; avoid `eval` for anything non-trivial |
| `scroll --dy` / `press PageDown` `js_error` on React sites (LinkedIn) | use LinkedIn `/details/<section>/` subpage URLs; or `input mouse` scroll; or navigate to a deeper URL |
| `js_error` on `snapshot`/`eval`/`find`/`state save` (hardened anti-bot) | fallback chain: `get url`, `get title`, `get text --selector body`, `get html --selector body` (never fail on a loaded page; cover ~90% of needs) |
| Guessed-URL 404s | navigate to site root → `snapshot`/extract real links → navigate to those. **Don't manufacture URLs / guess capitalization.** |
| Publisher article URL lands on wrong paper | use canonical `https://doi.org/<doi>` — redirects reliably |
| Empty `get url` / `about:blank` | navigate first instead of waiting on load |
| Stale refs after navigation | re-`snapshot` before next action |

**Rule:** if a cmux subcommand fails twice, switch subcommand — don't retry harder.

---

## §7 — claude-in-chrome (backup only)

Optional — requires the claude-in-chrome Chrome extension/MCP. Use ONLY when cmux genuinely can't, and **state the reason**:
- Site is WebKit-blocked (bot-shielded SPA rejects WKWebView).
- Need your real Chrome profile/extensions (1Password autofill, already-signed-in session).
- Need CDP-only features cmux flags `not_supported` (network interception/mocking, viewport/offline emulation, trace/screencast).

When using it:
- **Speed over screenshots** — `get_page_text` / `read_page` / `find` before any `screenshot`. Screenshots ONLY for visual layout/images/charts/coordinate-clicks/GIFs. Never screenshot just to read text.
- `tabs_context_mcp` first; create new tabs (don't hijack the user's); **never reuse tab IDs across sessions**.
- **Batch up to ~10 tabs** per `browser_batch` (create + navigate), one `wait`, then batched `get_page_text` — so the user sees one cluster of permission prompts, not many serial ones. Close only tabs you opened. Never batch destructive actions.
- **"Permission denied" ≈ a timeout (user AFK), not a refusal.** Don't record "user denied X"; surface it ("permission for <URL> timed out — back at the computer? retrying"), retry, ask once if several time out, never silently drop a queued URL.
- **Never trigger alerts/confirms/prompts/modal dialogs** — they block the extension. If one fires, tell the user to dismiss it.

---

## §8 — WebSearch rules

- **Discovery only** (finding whether a page/profile exists). Loading the page (cmux or fetch) is for verification.
- **No `site:`** — silently ignored, returns generic results. For `site:` use cmux + `google.com/search?q=…`, or drop `site:` and use the platform name as a keyword.
- **Snippets are not verbatim** — never quote them as exact text, count words from them, or build quantitative arguments on them.

---

## §9 — Accounts & attribution (shared-login etiquette)

Your cmux browser uses one WKWebView profile, logged into **your own** accounts (set them up via `/eladve-cmux-browser:setup`). Normal research-driven activity on your own accounts is fine without per-action approval.

**If any site is logged in under someone else's identity** (e.g. a shared/colleague account on Crunchbase, Facebook, etc.):
- **Read-only by default.** Browsing, snapshotting, and extracting data is always fine.
- **Pause and ask before any visible / attributable / persistent action** — posting, saving a company or list, liking, commenting, sharing, following / friend-requesting / connecting, messaging, RSVP'ing, or anything that shows up to the account owner or consumes their shared quota.
- Profile views can appear in "who viewed your profile" lists — assume page views are logged under that identity.
- **To check who you're signed in as:** open the site in cmux, `get text --selector body | head -c 400`, look for the greeting/username.

---

## §10 — Page caching (optional)

If a research run re-reads the same expensive pages, cache them locally to avoid re-fetches and rate limits — this is your own convention, not required by the tooling. Worth caching: LinkedIn and other social profiles, login-required pages, and anything that rate-limit-warned. Note freshness (profiles/companies stale after ~7d, news after ~1d) and refetch when stale.

---

## §11 — Rate limits

| Domain | Min interval | Notes |
|---|---|---|
| linkedin.com | 10s | very aggressive blocking; cache everything |
| twitter.com / x.com | 10s | |
| github.com | 5s | permissive |
| others | 2–5s | judgment |

On a rate-limit warning: stop and tell the user; use cache.

---

## §12 — Domain notes

**linkedin.com:** use `/in/<slug>/details/experience/` · `/details/education/` · `/details/skills/` subpages (work for 3rd+ connections; `/details/contact-info/` 404s for 3rd+). Main page `get text --selector body` gives header + activity. `scroll`/`PageDown` `js_error` → use subpages. About-section visibility is per-profile (privacy), not just connection degree — check the main page, don't assume. Skill count is itself a signal (0–5 = inactive; 20+ = curated).

---

## §13 — Safety (hard rules)

- **Never `pkill`/`kill` a user-facing browser** (chrome/chromium/safari/firefox) to fix a tooling error — it's shared infrastructure; destroys the user's session/unsaved work. Before any `pkill`/`kill -9`, ask if the process is user-facing.
- **Never silently fall back** between tools (§3).
- **Never trigger browser dialogs** (§7).
- **Don't touch the user's real Chrome** for scraping (use cmux). For scrape/download jobs: present quality-vs-effort options up front, prefer one automated script over N iterations.

---

## §14 — Per-step routing (research workflows)

Two-mode summary for any multi-step research flow:
- **Discovery** → cmux + `google.com/search?q=…` (or the GitHub API via fetch for GitHub).
- **Read a known URL** → fetch if robots-open + static + no-login, else cmux.
- **LinkedIn / people / companies** → cmux always.
- **Unsure** → cmux.
