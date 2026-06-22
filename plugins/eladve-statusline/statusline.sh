#!/bin/bash
# Claude Code status line. Field schema: code.claude.com/docs/en/statusline (+ live 2.1.169 capture).
# Layout (left → right):
#   <loc> │ <model·effort·style [@agent ⚡]> │ <git: ⎇branch wt pr ✱ ⟳ ↑> │ ctx N% │ <session> │ 5h N%·wk N%
#
# loc      : where we are inside the project — explicit `cd` (cyan) or, at the repo
#            root, the active subdir INFERRED from the last touched file (dim).
#            "claude-code/" prefix and "projects/" segments are stripped (wasted space).
# settings : the things we change a lot — model, effort, output style — in PURE WHITE.
#            (+ @agent when running an agent, ⚡ when fast mode, think:off when thinking is off)
# git      : branch, worktree, open PR (+review state), uncommitted count, time since
#            last commit (scoped to this project), unpushed count.
# ctx/5h/wk: context-window %, then 5-hour and 7-day usage allowances.
#            green <50, yellow 50–74, red ≥75 (true 256-colors so green reads green on black).
# session  : session name (truncated).

input="$(cat)"

RESET=$'\033[0m'; DIM=$'\033[2m'
WHITE=$'\033[97m'        # changeable settings (model, effort, style, agent)
CYAN=$'\033[36m'         # location (real cwd)
LGRAY=$'\033[38;5;250m'  # session name (low priority)
GRN=$'\033[38;5;46m'     # true green (the bright-green ANSI looked yellow on black)
YEL=$'\033[38;5;226m'    # true yellow
RED=$'\033[38;5;196m'    # true red

# Read one field per line (robust to empty fields — a tab-split read would
# collapse consecutive tabs and shift every field after an empty one).
{
  IFS= read -r cwd
  IFS= read -r project_dir
  IFS= read -r model
  IFS= read -r effort
  IFS= read -r fast
  IFS= read -r thinking
  IFS= read -r ctx
  IFS= read -r five_h
  IFS= read -r seven_d
  IFS= read -r style
  IFS= read -r session
  IFS= read -r transcript
  IFS= read -r worktree
  IFS= read -r agent
  IFS= read -r pr_num
  IFS= read -r pr_review
  IFS= read -r added
} < <(
  printf '%s' "$input" | jq -r '
    [ (.cwd // ""),
      (.workspace.project_dir // .cwd // ""),
      (.model.display_name // "?"),
      (.effort.level // ""),
      (if .fast_mode == true then "true" else "false" end),
      (if .thinking.enabled == false then "false" else "true" end),
      (.context_window.used_percentage // 0 | floor | tostring),
      (.rate_limits.five_hour.used_percentage // -1 | floor | tostring),
      (.rate_limits.seven_day.used_percentage // -1 | floor | tostring),
      (.output_style.name // ""),
      (.session_name // ""),
      (.transcript_path // ""),
      (.workspace.git_worktree // ""),
      (.agent.name // ""),
      (.pr.number // "" | tostring),
      (.pr.review_state // ""),
      (.workspace.added_dirs // [] | length | tostring)
    ] | .[]'
)

model="${model/1M context/1M}"   # "Opus 4.8 (1M context)" -> "Opus 4.8 (1M)"

# --- output style display name ---
case "$style" in
  noncoding-writing)  style_disp="writing"  ;;
  noncoding-research) style_disp="research" ;;
  default)            style_disp="coding"   ;;
  "")                 style_disp=""         ;;
  *)                  style_disp="$style"   ;;
esac

# --- location: subdir only, claude-code & projects/ stripped ---
rel="${cwd#"$project_dir"}"; rel="${rel#/}"
sub=""; inferred=0
if [ -n "$rel" ]; then
  sub="$rel"
elif [ -n "$transcript" ] && [ -f "$transcript" ]; then
  lastf=$(tail -c 400000 "$transcript" 2>/dev/null \
    | grep -oE '"file_path":"[^"]+"' \
    | sed 's/.*"file_path":"//; s/"$//' \
    | grep -F "$project_dir/" | tail -1)
  if [ -n "$lastf" ]; then
    s="${lastf#"$project_dir"/}"
    case "$s" in */*) sub="${s%/*}"; inferred=1;; esac
  fi
fi
sub="${sub//projects\//}"
loc_seg=""
if [ -n "$sub" ]; then
  if [ "$inferred" = "1" ]; then loc_seg="${DIM}${sub}${RESET}"; else loc_seg="${CYAN}${sub}${RESET}"; fi
fi
if [ "${added:-0}" -gt 0 ] 2>/dev/null; then
  [ -n "$loc_seg" ] && loc_seg+=" "
  loc_seg+="${DIM}+${added}dir${RESET}"
fi

# --- settings cluster (pure white = changeable) ---
set_seg="${WHITE}${model}${RESET}"
[ -n "$effort" ]     && set_seg+="${DIM}·${RESET}${WHITE}${effort}${RESET}"
[ -n "$style_disp" ] && set_seg+="${DIM}·${RESET}${WHITE}${style_disp}${RESET}"
[ -n "$agent" ]      && set_seg+="${DIM}·${RESET}${WHITE}@${agent}${RESET}"
[ "$fast" = "true" ] && set_seg+=" ${WHITE}⚡${RESET}"
[ "$thinking" = "false" ] && set_seg+=" ${DIM}think:off${RESET}"

# --- percent → threshold color (green <50, yellow 50–74, red ≥75) ---
pct_color() { local p=$1
  if   [ "$p" -lt 0 ];  then printf '%s' "$DIM"
  elif [ "$p" -ge 75 ]; then printf '%s' "$RED"
  elif [ "$p" -ge 50 ]; then printf '%s' "$YEL"
  else                       printf '%s' "$GRN"; fi
}

# --- git cluster ---
# Nudge numbers stay HIDDEN until they cross an actionable threshold, so the
# line stays quiet when there's nothing to act on. Thresholds (tweak freely):
#   uncommitted files ≥ 10  → commit;   last commit ≥ 2d stale;   unpushed ≥ 3 → push.
# Branch label hides on the default branch (main/master/trunk) — only shown when notable.
git_seg=""
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  add() { git_seg="${git_seg:+$git_seg }$1"; }

  case "$branch" in
    main|master|trunk) ;;                            # default branch — not notable, hide
    HEAD) add "${GRN}⎇ detached${RESET}" ;;
    *)    add "${GRN}⎇ ${branch}${RESET}" ;;
  esac
  [ -n "$worktree" ] && add "${DIM}wt:${worktree}${RESET}"
  if [ -n "$pr_num" ]; then
    case "$pr_review" in
      approved) pc=$GRN ;; changes_requested) pc=$RED ;; pending) pc=$YEL ;; *) pc=$DIM ;;
    esac
    add "${pc}PR#${pr_num}${RESET}"
  fi

  nchg=$(git -C "$cwd" status --porcelain 2>/dev/null | grep -c .)
  if [ "${nchg:-0}" -ge 10 ]; then
    [ "$nchg" -ge 30 ] && cc=$RED || cc=$YEL
    add "${cc}✱${nchg}${RESET}"
  fi
  lct=$(git -C "$project_dir" log -1 --format=%ct -- . 2>/dev/null)
  if [ -n "$lct" ]; then
    now=$(date +%s); age=$((now - lct))
    if [ "$age" -ge 172800 ]; then                   # ≥ 2 days stale
      [ "$age" -ge 604800 ] && ac=$RED || ac=$YEL    # red ≥ 7d
      add "${ac}⟳$((age/86400))d${RESET}"
    fi
  fi
  ahead=$(git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null)
  [ -n "$ahead" ] && [ "$ahead" -ge 3 ] && add "${YEL}↑${ahead}${RESET}"
fi

# --- context + usage ---
cc=$(pct_color "$ctx"); ctx_seg="${DIM}ctx${RESET} ${cc}${ctx}%${RESET}"
use_seg=""
if [ "$five_h" -ge 0 ] 2>/dev/null; then
  c=$(pct_color "$five_h"); use_seg="${DIM}5h${RESET} ${c}${five_h}%${RESET}"
fi
if [ "$seven_d" -ge 0 ] 2>/dev/null; then
  c=$(pct_color "$seven_d")
  [ -n "$use_seg" ] && use_seg+="${DIM}·${RESET}"
  use_seg+="${DIM}wk${RESET} ${c}${seven_d}%${RESET}"
fi

# --- session name ---
sess_seg=""
if [ -n "$session" ]; then
  max=30
  [ ${#session} -gt $max ] && session="${session:0:$((max-1))}…"
  sess_seg="${LGRAY}${session}${RESET}"
fi

# --- join non-empty groups: loc | settings | git | ctx | session | usage(quotas) ---
sep=" ${DIM}│${RESET} "
out=""
for g in "$loc_seg" "$set_seg" "$git_seg" "$ctx_seg" "$sess_seg" "$use_seg"; do
  [ -n "$g" ] || continue
  if [ -n "$out" ]; then out="${out}${sep}${g}"; else out="$g"; fi
done
printf '%s' "$out"
