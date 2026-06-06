---
name: cmux-browser
description: Drives the browser via the cmux CLI (`cmux browser ...` over Bash) as the default for interactive web work and multi-item research, instead of fetch/WebFetch/WebSearch. Covers the cmux loop, surface hygiene, fetch/WebSearch discipline, parallel-research patterns, and sourcing any fact you'll rely on from a real loaded page (not snippets).
when_to_use: When opening or reading a web page, logging into a site, scraping or extracting page content, looking up or verifying any fact on a real page (a person, company, product, paper, dataset, or docs — anything), running a site:-filtered search, or researching several items in parallel — and whenever a fetch, WebFetch, or WebSearch returned a robots-block, JS wall, paywall, or truncated snippet.
---

# cmux Browser & Web-Research

This skill makes **cmux browser the default tool** for interactive web work and research. cmux runs each browser surface in its own WKWebView (isolated from your real Chrome), driven from the shell as `cmux browser ...`. First time? Run `/eladve-cmux-browser:setup` once. (If cmux shows a login wall or keeps prompting for permission, the user hasn't run setup — point them to it.) Deep reference: `reference/browser-guide.md` (+ `reference/parallel-workflow-guide.md`, `reference/research-guide.md`).

## §0 — The priority ladder (memorize)

1. **cmux browser = DEFAULT** for all interactive web work. Drive via Bash (`cmux browser …`).
2. **fetch = the EXCEPTION** — a *known URL* that is robots-open + static + no-JS + no-login only (Scholar, arXiv, GitHub, Wikipedia, plain pages, non-paywalled PDFs). **State why in one sentence.** A fetch wall ⇒ *fall back to cmux*, never "NOT FOUND." **"fetch" = a fetch MCP (returns raw markdown) OR the built-in `WebFetch` tool — but `WebFetch` returns an AI *summary*, not verbatim text, so treat its output like a WebSearch snippet: discovery/rough only, never a source for facts. When fidelity matters, prefer cmux (or a raw fetch MCP).**
3. **claude-in-chrome MCP = last-resort backup** — only when cmux genuinely can't (WebKit-blocked site, your real Chrome profile/extensions, CDP-only features). **State the reason.**
4. **WebSearch = discovery-only** and **ignores `site:`** silently. Never treat snippets as verbatim. For `site:`, use cmux + `google.com/search?q=…`.

**Any fact you'll rely on REQUIRES a loaded page — cmux** (or claude-in-chrome) — never a WebSearch/WebFetch snippet or a pattern-guess. (Most critical for login-walled, JS-heavy, paywalled, or person/company sources.) **Never silently fall back** between tools: if the default can't do it, say so and ask. When unsure → cmux.

## §1 — The cmux core loop

```
cmux --json browser open <url>            # returns surface:N
cmux browser surface:N get url
cmux browser surface:N wait --load-state complete --timeout-ms 15000
cmux browser surface:N snapshot --interactive     # element refs e1, e2, …
cmux --json browser surface:N click e3 --snapshot-after
```
Keep one `surface:N` per task. Use `--json` when parsing. `--snapshot-after` on click/fill/select/scroll returns a fresh ref tree.

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

**Auth / sticky logins:** all cmux surfaces share one WKWebView profile — cookies persist across surfaces and close/reopen. **Log in once per site** (do it in `/eladve-cmux-browser:setup`); no `state save` dance needed. (`state save` `js_error`s on hardened sites like LinkedIn — it's optional backup only.) **Expired login:** if a site you should be signed into shows a login wall, the session has lapsed — STOP, tell the user, and ask them to re-login in the cmux pane. Never fabricate the data or mark it "NOT FOUND."

### Worked example — read a fact off a real page
```
cmux --json browser open <url>                          # → surface:N
cmux browser surface:N wait --load-state complete --timeout-ms 15000
cmux browser surface:N get text --selector body         # read the relevant text
cmux browser surface:N navigate <deeper-url>            # follow a link for more detail
cmux browser surface:N get text --selector <css>
cmux close-surface --surface surface:N                  # clean up when done
```
This is the spine for anything fidelity-critical, and the *only* path for login-walled / JS-heavy / robots-blocked / paywalled sources (e.g. LinkedIn, internal dashboards, SPAs) — where fetch/WebFetch return a wall or an AI summary, not the real page. (On React sites, `scroll` js_errors → navigate to a deeper URL instead.)

## §2 — Traps & fixes (don't retry the same broken call)

| Trap | Fix |
|---|---|
| `get text` alone → "requires a selector" | always `get text --selector body` (or a CSS selector) |
| `eval --script` `js_error` on quotes/backticks/templates | use `snapshot --max-depth N` / `get text --selector` / `find` instead; avoid `eval` for anything non-trivial |
| `scroll --dy` / `press PageDown` `js_error` on React sites (e.g. LinkedIn) | use the site's deeper subpage URLs (LinkedIn: `/details/<section>/`); or `input mouse` scroll; or navigate to a deeper URL |
| `js_error` on `snapshot`/`eval`/`find`/`state save` (hardened anti-bot) | fallback chain that always works on a loaded page: `get url`, `get title`, `get text --selector body`, `get html --selector body` (covers ~90% of needs) |
| Guessed-URL 404s | navigate to the site root → `snapshot`/extract real links → navigate to those. **Don't manufacture URLs or guess capitalization.** |
| Publisher article URL lands on the wrong paper | use canonical `https://doi.org/<doi>` — redirects reliably |
| Stale refs after navigation | re-`snapshot` before the next action |

**Rule: if a cmux subcommand fails twice, switch subcommand — don't retry harder.** (Commands/flags can vary by cmux version — if one's rejected outright, check `cmux browser --help`.)

## §3 — Surface hygiene

- **Open research surfaces in a DEDICATED browser pane in the current workspace** (`cmux new-pane --type browser` once; add more tabs with `cmux new-surface --type browser --pane <pane>`). cmux nesting: *window* ⊃ *workspace* ⊃ *pane* ⊃ *surface* (tab).
- **First pane = heads-up:** the first time you open a browser pane in a session, give the user a one-line heads-up ("opening a cmux browser pane beside your terminal") so the split layout doesn't surprise them.
- **Never put browser surfaces as tabs in the working terminal's pane**, and **never `cmux close-surface` on anything sharing the focused terminal's pane** — it makes the terminal look closed/lost.
- **Clean up by closing browser tabs one at a time with `cmux close-surface`.** NEVER `close-workspace` / `close-window` as "cleanup" — that destroys the whole workspace, including any terminal in it.
- **Subagents don't clean up their own surfaces** — the main agent closes them.
- **Parallel surfaces:** one browser pane, the rest as tabs (`new-surface --type browser --pane <pane>`); each tab navigates independently by `surface_id` regardless of which is visible.

## §4 — Parallel & serial research

For researching N similar items (people, companies, repos), use the parallel+serial loop (full version: `reference/parallel-workflow-guide.md`):

- **Parallel** when items need the same search and there are no cross-dependencies. Subagents **can** drive cmux browser (they have Bash) — unlike the claude-in-chrome MCP, which subagents can't reach. Fan out, give each its own surface. **Seed each browsing subagent's prompt with the cmux policy** — cmux is the default; person/company facts come from cmux-loaded pages (not snippets); it must NOT run `cmux close-*` / `open-split` or create panes (you allocate + clean up its surfaces). A fresh subagent has none of this otherwise.
- **Serial** for verification, judgment, or anything depending on earlier findings.
- **Persist after every round** to a working file (running tally + resume point) so a crash/compaction never loses progress. Touch canonical/output data **only** at the final consolidate step.
- **Subagents are for systematic repetition, not n-of-1 research.** A novel, single problem you're *solving* → do it yourself in main context, from primary sources. A subagent's return is a **lead to verify**, not an authoritative fact (the primary text evaporates with its context). See `reference/research-guide.md`.
- **Before a large parallel browser batch, fire the `eladve-cmux-browser:canary`** subagent on each allocated surface — cheap insurance that the parallel pipeline works end-to-end.

**Running a parallel batch — reporting cadence:** give the **consolidated result when the batch finishes**, and flag anything wrong or stuck along the way. A **brief one-line progress note on a long run is fine** — just don't spam per-item "2/5 done" updates. Keep working through a long task rather than stopping for "continue?" checkpoints, but a short "still going" heads-up is welcome. Persist to disk each round regardless.

## §5 — Discovery vs. verification (WebSearch epistemology)

- WebSearch is for **discovery** ("does X exist / where is it"). **Loading the page** (cmux or fetch) is for **verification**.
- WebSearch **snippets are not verbatim** — never quote them as exact text, count words from them, or build quantitative arguments on them.
- **`WebFetch` output is AI-summarized too** — same rule as WebSearch snippets: discovery/rough only, never verbatim, never a source for person/company facts. Use cmux (or a raw fetch MCP) to verify.
- WebSearch **does not support `site:`** — it's silently ignored. Use cmux + `google.com/search?q=…` for `site:`.

## §6 — Accounts & etiquette

- Your cmux browser is logged into **your own** accounts (set up in `/eladve-cmux-browser:setup`). Normal research-driven activity there is fine.
- **Shared / colleague accounts:** if any site is logged in under someone else's identity (a teammate's shared login), default to **read-only research** — pause and ask before any *visible, attributable, or persistent* action (posting, saving, liking, commenting, following/connecting, messaging, RSVP'ing). Browsing and extracting data is always fine; only the visible actions need the pause.

## §7 — Safety (hard rules)

- **Never `pkill`/`kill` a user-facing browser** (chrome/chromium/safari/firefox) to fix a tooling error — it's shared infrastructure and destroys the user's session/unsaved work. Before any `pkill`/`kill -9`, ask whether the process is user-facing.
- **Never silently fall back** between tools (§0).
- **Never trigger browser dialogs** (alert/confirm/prompt/modal) — they block automation. If one fires, ask the user to dismiss it.
- For scrape/download jobs, present quality-vs-effort options up front and prefer one automated script over many manual iterations.
- **`computer-use` (desktop pixel control) is NOT a web-reading tool** — use cmux (or claude-in-chrome) for pages. computer-use is for native apps / pixel-level tasks, outside this skill's scope.

## §8 — Bot-walls & CAPTCHAs

If a page shows a CAPTCHA / "verify you're human" / Cloudflare "just a moment" / bot-wall: **don't interrupt the user** (no pings — notifications are noise). Append the URL to a `## Blocked — revisit` list in your working file, keep going, and **report a tally at the end** ("hit N bot-walls — see the blocked-revisit list"). Never fabricate or guess the blocked page's content. **Don't try to solve image/interactive CAPTCHAs** — they're designed to defeat automation and you can't reliably pass them (at most, click a single "I'm not a robot" checkbox once, then move on). The real mitigations are already set up: the logged-in profile + staggered requests + a throwaway-Google login reduce how often walls appear.
