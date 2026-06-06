#!/usr/bin/env python3
"""PreToolUse hook — intentionally LIGHT; soft context only, NEVER blocks.

Fires ONLY on fetch / WebFetch (NOT on every Bash — surface hygiene lives in the cmux-browser skill §3,
so there's no per-Bash process spawn). If a fetch/WebFetch targets a cmux-only domain (LinkedIn etc.),
warn that it'll robots-block / only AI-summarize — use cmux instead. Always fails open. Registered via
the eladve-cmux-browser plugin's hooks/hooks.json (PreToolUse matcher: mcp__fetch__.*|WebFetch)."""
import sys
import json

GUIDE = "the `cmux-browser` skill (reference/browser-guide.md §1–§2)"


def emit(msg):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "additionalContext": msg,
    }}))


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return  # fail open

    tool = data.get("tool_name", "") or ""
    if not (tool.startswith("mcp__fetch__") or tool == "WebFetch"):
        return
    ti = data.get("tool_input", {}) or {}
    url = (ti.get("url", "") or "").lower()
    cmux_only = ("linkedin.com", "researchgate.net", "orcid.org",
                 "crunchbase.com", "patents.google.com")
    if any(d in url for d in cmux_only):
        emit("⚠️ fetch/WebFetch on a cmux-only domain — it will robots-block or JS-fail (and WebFetch only "
             f"AI-summarizes). Use cmux instead. See {GUIDE}.")


if __name__ == "__main__":
    main()
