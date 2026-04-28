#!/usr/bin/env bash
#
# .metis/scripts/pick-task.sh
#
# Lists pickable tasks in priority order, plus in-flight, blocked
# counts, and a suggested next task. Pure read-only — writes nothing.
#
# Exits non-zero with a recovery pointer if no task surface exists.
# Output goes to stdout in a human-readable format.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PWD}"

# -- detect task surface -----------------------------------------------------

has_flat=0
if [[ -d "tasks" ]]; then
  count=$(find tasks -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  [[ $count -gt 0 ]] && has_flat=1
fi

has_epic=0
if [[ -d "epics" ]]; then
  count=$(find epics -path 'epics/*/tasks/*.md' 2>/dev/null | wc -l | tr -d ' ')
  [[ $count -gt 0 ]] && has_epic=1
fi

if [[ $has_flat -eq 0 && $has_epic -eq 0 ]]; then
  cat >&2 <<'EOF'
error: no tasks on disk to pick from.

If this project has not generated tasks yet, run:
  /metis:generate-tasks          (flat layout)
  /metis:generate-tasks <epic>   (epic layout)

If work is meant to be done ad hoc outside Metis, /metis:log-work
reconciles it after the fact.
EOF
  exit 1
fi

# -- enumerate, filter, sort, and render via Python --------------------------

python3 - <<'PYEOF'
import os, re
from pathlib import Path
from collections import defaultdict


def parse_frontmatter(text):
    m = re.match(r'^---\n(.*?)\n---', text, re.DOTALL)
    if not m:
        return {}
    out = {}
    for line in m.group(1).split('\n'):
        if ':' not in line:
            continue
        k, _, v = line.partition(':')
        k = k.strip()
        v = v.strip().strip('"').strip("'")
        out[k] = v
    return out


def parse_id_list(value):
    if not value:
        return []
    return re.findall(r'[0-9]{4}', value)


# Enumerate task files (flat + epic layout)
tasks = []
for root in ('tasks', 'epics'):
    if not os.path.isdir(root):
        continue
    for dirpath, _, filenames in os.walk(root):
        for fn in filenames:
            if not fn.endswith('.md') or fn == 'EPIC.md':
                continue
            path = os.path.join(dirpath, fn)
            # epic layout: file must be under epics/*/tasks/
            if root == 'epics' and '/tasks/' not in path:
                continue
            try:
                text = open(path).read()
            except OSError:
                continue
            fm = parse_frontmatter(text)
            if not fm.get('id'):
                continue
            try:
                priority = int(fm.get('priority', '3'))
            except ValueError:
                priority = 3
            tasks.append({
                'path': path,
                'id': fm.get('id', ''),
                'title': fm.get('title', ''),
                'status': fm.get('status', ''),
                'priority': priority,
                'estimate': fm.get('estimate', ''),
                'epic': fm.get('epic', ''),
                'depends_on': parse_id_list(fm.get('depends_on', '')),
            })

by_id = {t['id']: t for t in tasks}

# Fan-out: count of other tasks depending on each task
fan_out = defaultdict(int)
for t in tasks:
    for dep in t['depends_on']:
        fan_out[dep] += 1


def parent_epic_status(task):
    if not task['epic']:
        return None
    epic_file = f"epics/{task['epic']}/EPIC.md"
    if not os.path.isfile(epic_file):
        return None
    fm = parse_frontmatter(open(epic_file).read())
    return fm.get('status', '')


# Classify
pickable = []
in_flight = []
blocked_by_deps = []  # (task, list of unresolved dep ids)

for t in tasks:
    s = t['status']
    if s in ('in-progress', 'in-review'):
        in_flight.append(t)
        continue
    if s == 'done':
        continue
    unresolved = [d for d in t['depends_on']
                  if by_id.get(d, {}).get('status') != 'done']
    if unresolved:
        blocked_by_deps.append((t, unresolved))
        continue
    if t['epic'] and parent_epic_status(t) == 'done':
        continue
    if s in ('pending', 'blocked'):
        pickable.append(t)

pickable.sort(key=lambda t: (t['priority'], -fan_out[t['id']], t['id']))


# -- render ----------------------------------------------------------------

def line_for_task(t, *, include_status=False):
    parts = [f"{t['id']}", t['title'] or '(untitled)', f"p{t['priority']}"]
    if include_status:
        parts.append(t['status'])
    if t['estimate']:
        parts.append(t['estimate'])
    if t['epic']:
        parts.append(t['epic'])
    return "  " + " · ".join(parts)


print("Pickable (top 5):")
if pickable:
    for t in pickable[:5]:
        print(line_for_task(t))
    if len(pickable) > 5:
        print(f"  ... ({len(pickable) - 5} more)")
else:
    print("  (none)")

print()
print(f"In flight: {len(in_flight)}")
for t in in_flight:
    print(line_for_task(t, include_status=True))

print()
print(f"Blocked: {len(blocked_by_deps)}")
if blocked_by_deps:
    blocker_count = defaultdict(int)
    for _, unres in blocked_by_deps:
        for b in unres:
            blocker_count[b] += 1
    top_id, top_n = max(blocker_count.items(), key=lambda x: x[1])
    top_title = by_id.get(top_id, {}).get('title', top_id)
    print(f"  Most common blocker: {top_id} · {top_title} (blocks {top_n})")

print()
if pickable:
    top = pickable[0]
    reasons = []
    if fan_out[top['id']] > 0:
        reasons.append(f"unblocks {fan_out[top['id']]} task(s)")
    if top['priority'] <= 2:
        reasons.append(f"priority {top['priority']}")
    reason = ", ".join(reasons) if reasons else "first pickable by id"
    print(f"Suggested next: {top['id']} ({reason})")
else:
    print("Suggested next: (none — all tasks are in flight, blocked, or done)")
PYEOF
