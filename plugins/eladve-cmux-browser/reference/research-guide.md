# Research & Investigation Guide — Primary Sources First

**When useful:** Any time you're gathering information to ANSWER a question or SOLVE a problem — specifically the decision of *who* does the research (you in main context vs. a subagent) and *what source* you trust. Companion to the `cmux-browser` skill.

**What it's for:** The upstream "who researches, from what source" decision. For the *mechanics* of running many subagents once you've decided to delegate a reproducible task, see `parallel-workflow-guide.md`. For *which web tool* to use, see `browser-guide.md`.

---

## The core decision: main context vs. subagent

**A novel, single-session, n-of-1 problem you're SOLVING → do it yourself, in MAIN context, from PRIMARY SOURCES. Never split it across subagents.**
- A large context window is plenty — **context economy is NOT a reason to delegate.**
- Primary sources = the actual binary (`grep`/`strings`), the tool's own `--help`/CLI, the config/bundle/source files, the actual page — not a summary of any of these.
- Why: you can verify *how* a conclusion follows, reuse the detail later without re-fetching, and avoid laundering errors. Splitting an n-of-1 investigation across subagents is actively bad — the primary text evaporates into the subagent's context and you're left with an unverifiable summary.

**Reproducible / systematic work done N times (50, 700, …) → subagents are the right tool.**
- The same understood operation repeated over many items (per-person briefs, repo sweeps) is exactly what subagents/parallelism are for → `parallel-workflow-guide.md`.
- Also fine: genuinely bulky fan-out where you only need "which one / does it exist," not the underlying text.

**Rule of thumb:** subagents are for doing understood things *systematically*, not for figuring out an unknown thing *once*.

---

## Subagent output is a LEAD, not a fact

A subagent returns only a summary; the primary-source text stays in its context and is gone. Treat every subagent finding as a **lead to verify against the primary source** — never quote it verbatim or build on it as authoritative.

> Observed cost: a research subagent once hallucinated a CLI command that doesn't exist, built a config-token list from an unreliable third-party gist, and asserted unverified behavior — all corrected only by reading the actual binary / CLI / app bundle directly, in main context.

---

## Tool priority when researching in main context

(Full policy: the `cmux-browser` skill + `browser-guide.md`, surfaced by the `PreToolUse` hook.)

1. **Local primary sources** — `Read`/`Bash`/`grep`/`strings` on binaries, CLIs, bundle & config files. No web tool needed; use these first when the answer is on the machine.
2. **cmux browser** — default for interactive web.
3. **fetch MCP** — static, robots-open, no-JS, no-login pages only; state why in one line.
4. **claude-in-chrome** — backup (WebKit-blocked / logged-in profile / CDP-only).
5. **WebSearch** — discovery only, never verbatim, no `site:`.
