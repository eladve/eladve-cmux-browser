# Parallel + Serial Research Workflow

**Purpose:** A reusable pattern for collecting information about multiple items using parallel agents, with iterative refinement and serial follow-up. Companion to the `cmux-browser` skill.

**Use when:** You need to gather similar information about multiple items (people, companies, repos, etc.) and want to maximize efficiency while maintaining quality.

## Contents
When to use this workflow · visual flowchart · executable checklist · module details (parallel / serial / consolidate) · learnings log · file-structure template · decision-criteria summary · working-files-vs-canonical-data · anti-patterns · worked example

---

## When to Use This Workflow

- Researching N items where N > 2
- Each item needs similar types of information
- Some work is broad fan-out (parallel-friendly)
- Some work needs interactive browsing or judgment (serial)
- Results need to be persisted and consolidated

**Subagents and the browser:** parallel subagents **can** drive the cmux browser — they have Bash, so `cmux browser …` works inside a subagent (give each its own surface; the main agent cleans the surfaces up afterward). They **cannot** reach the claude-in-chrome MCP. So: cmux work parallelizes across subagents; claude-in-chrome work does not.

---

## Visual Flowchart

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 0: PLAN                                              │
│  • Define task (what data?)                                 │
│  • Select items (which ones?)                               │
│  • Define success criteria (what's "done"?)                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  MAIN LOOP                                                  │
│                                                             │
│    ┌──────────────────────────────────────────────────┐    │
│    │ Decision: Run PARALLEL?                           │    │
│    │ (same search per item, no cross-deps)             │    │
│    └──────────────────────────────────────────────────┘    │
│              │                         │                    │
│             YES                       NO                    │
│              ▼                         ▼                    │
│    ┌──────────────────┐    ┌────────────────────────┐      │
│    │ PARALLEL MODULE  │    │ Decision: Run SERIAL?  │      │
│    │ • Launch agents  │    │ (verify, judgment,     │      │
│    │ • Persist results│    │  cross-deps)           │      │
│    │ • Log learnings  │    └────────────────────────┘      │
│    └──────────────────┘           │            │           │
│              │                    YES          NO           │
│              │                    ▼            ▼            │
│              │         ┌──────────────┐  ┌──────────┐      │
│              │         │SERIAL MODULE │  │EXIT LOOP │      │
│              │         │• Do 1 item   │  └──────────┘      │
│              │         │• Persist     │       │            │
│              │         └──────────────┘       │            │
│              └────────────┬───────────┘       │            │
│                           ▼                   │            │
│                   [Back to Decision]          │            │
└─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
┌─────────────────────────────────────────────────────────────┐
│  CONSOLIDATE                                                │
│  • Review working files                                     │
│  • Update canonical data (CSV, database, etc.)              │
│  • Summarize findings + learnings                           │
│  • Archive working files                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Executable Checklist

### PHASE 0: PLAN

```
□ Define the task:
  - What data am I collecting?
  - What fields/properties need filling?

□ Select items:
  - All items? Subset?
  - List them explicitly

□ Define success criteria:
  - What counts as "done" for an item?

□ Create working files:
  - Index file: w_[task]-index.md (tracks status, learnings)
  - Per-item files: w_[task]-raw-[item].md (raw findings)
```

### MAIN LOOP DECISIONS

**Decision 1: Should I run PARALLEL?**

Run parallel when ALL true:
- [ ] Multiple items need the same type of search
- [ ] No dependencies between searches
- [ ] Haven't hit diminishing returns (<10% new per round)

→ If YES: Execute Parallel Module, then return to Decision 1

**Decision 2: Should I run SERIAL?**

Run serial when ANY true:
- [ ] Need careful interactive browsing (JS-heavy / login-required pages best done one at a time)
- [ ] Need to verify/cross-check findings
- [ ] Requires judgment or context from earlier findings
- [ ] Following up on specific leads

→ If YES: Execute Serial Module, then return to Decision 1

**Decision 3: Should I EXIT?**

Exit when ANY true:
- [ ] All items meet success criteria
- [ ] Diminishing returns (multiple rounds with <10% new)
- [ ] No more parallel OR serial work identified

→ If YES: Go to CONSOLIDATE

---

## Module Details

### Parallel Module

```
1. Launch parallel agents (one per item)
   - Give each agent: item details, what to search for, its own cmux surface if it browses
   - Agents return structured findings

2. Collect all results

3. Persist immediately (per-item files):
   - Create/update: w_[task]-raw-[item].md
   - Include: findings, "not found" items, sources checked

4. Update index file:
   - Mark items searched
   - Note what queries worked/failed
   - Log learnings

5. Close any surfaces the subagents opened. Return to Main Loop.
```

**Reporting cadence for a parallel batch:** stay silent until the whole batch returns (then one consolidated summary), or until something is wrong (a FAIL/anomaly), or one hangs well past expected. No per-completion status messages. Persist to disk each round regardless.

### Serial Module

```
1. Pick ONE item to work on
   - Prioritize: highest value, or blocking other work

2. Do the work:
   - Use cmux browser for JS-heavy / login pages
   - Verify uncertain findings
   - Make judgment calls

3. Persist immediately:
   - Update w_[task]-raw-[item].md

4. Update index:
   - Mark progress
   - Note any learnings

5. Return to Main Loop
```

### Consolidate

**This is the ONLY phase where canonical data gets updated.**

```
1. Review all w_[task]-raw-*.md files
   - Cross-check findings across items
   - Resolve any contradictions

2. Update canonical data (CSV, database, etc.):
   ⚠️ THIS IS THE FIRST TIME YOU TOUCH CANONICAL DATA
   - Only include verified/high-confidence data
   - Mark uncertain items appropriately

3. Create summary:
   - What found per item
   - What NOT found (searched but empty)
   - Key learnings for future

4. Archive working files:
   - Move to archived/ or delete
   - Keep index if learnings are valuable
```

---

## Learnings Log

**After each parallel round, note:** what worked (queries/platforms/patterns that returned good results), what failed (searches that returned nothing), patterns discovered (naming conventions, URL patterns), and serial follow-up needed (items needing interactive verification). Log to the task index file, and to a permanent learnings file if broadly applicable.

---

## File Structure Template

```
project/
├── w_[task]-index.md           # Status + learnings for this task
├── w_[task]-raw-[item1].md     # Raw findings per item
├── w_[task]-raw-[item2].md
├── ...
├── canonical-data.csv          # Final consolidated data
└── archived/                   # Completed working files
```

---

## Decision Criteria Summary

| Condition | → Action |
|-----------|----------|
| Multiple items + same broad search | **Parallel** |
| Need interactive browsing, verification, or judgment | **Serial** |
| <10% new findings last round | Consider **stopping** |
| All success criteria met | **Stop → Consolidate** |
| Stuck or unclear | **Ask user** |

---

## ⚠️ CRITICAL: Working Files vs. Canonical Data

**During iteration (parallel/serial phases):**
- Write ALL findings to working files (`w_*.md`)
- **NEVER** update canonical data (CSV, database, final output files)

**During consolidation (after exit decision):**
- Review working files
- **ONLY THEN** update canonical data

**Why this matters:** Canonical data is the source of truth. Writing preliminary results to it (1) creates false confidence (looks "done" but isn't verified), (2) makes it hard to distinguish verified vs. preliminary findings, (3) pollutes the output if later rounds contradict earlier ones.

**The rule:** Working files are scratch paper. Canonical data is the final answer. Don't mix them.

---

## Anti-Patterns

**Don't:**
- **Never** write to canonical data (CSV, database) until CONSOLIDATE phase
- **Never** hold findings in memory across multiple items (context can compress)
- **Never** skip the persist step after parallel rounds
- **Never** continue parallel indefinitely (diminishing returns)

**Do:**
- Persist to WORKING FILES after every module execution
- Log learnings to improve future rounds
- Be willing to stop when returns diminish
- Use serial for verification even if it's slower
- Wait until CONSOLIDATE to touch canonical data

---

## Example

**Task:** Collect socials, websites, videos for 6 people

| Round | Type | Action | Result |
|-------|------|--------|--------|
| 1 | Parallel | Search all 6 for Twitter, YouTube, Google Scholar | Found: 3 Twitter, 5 Scholar, 1 video |
| 2 | Parallel | Refined video searches based on R1 learnings | Found: 2 more videos |
| 3 | Serial | cmux to verify talks (login required) | Confirmed 2 sessions |
| 4 | Serial | Verify uncertain Twitter handles | 1 was the wrong person |
| — | Exit | Diminishing returns | — |
| Final | Consolidate | Update CSV, summarize | 4/6 have videos, all have Scholar |
