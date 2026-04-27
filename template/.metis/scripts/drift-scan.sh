#!/usr/bin/env bash
#
# .metis/scripts/drift-scan.sh
#
# Mechanical drift detector. Compares each task and epic's stored
# baseline (doc_hashes, spec_version) against the current state of
# docs/ and BUILD.md, plus structural inconsistencies (missing
# docs_refs paths, orphan epic refs, ambiguous layout).
#
# Used by /metis:rebaseline (read-only report) and /metis:sync
# (cascade walker) so the drift logic lives in one place.
#
# Output: structured stdout — one section per drift kind, plus a
# Project state header and a Summary footer.
# Exit:   0 on success regardless of drift; 1 if BUILD.md is missing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

if [[ ! -f "BUILD.md" ]]; then
  cat >&2 <<'ERR'
error: BUILD.md not found — not a Metis project (or BUILD.md was removed).
Run /metis:init for a new project, or /metis:build-spec to regenerate.
ERR
  exit 1
fi

python3 - <<'PYEOF'
import os, re, sys, hashlib
from pathlib import Path
from collections import defaultdict


def parse_frontmatter(text):
    """YAML frontmatter parser for the shapes used by Metis task and
    epic files: scalars, inline lists [a, b], multi-line lists, and
    one level of mapping (used by doc_hashes)."""
    m = re.match(r'^---\n(.*?)\n---', text, re.DOTALL)
    if not m:
        return {}
    body = m.group(1)
    lines = body.split('\n')
    out = {}
    i = 0
    while i < len(lines):
        line = lines[i]
        if not line.strip() or line.lstrip().startswith('#'):
            i += 1
            continue
        mm = re.match(r'^([A-Za-z_][A-Za-z0-9_]*?):\s*(.*)$', line)
        if not mm:
            i += 1
            continue
        key = mm.group(1).strip()
        val = mm.group(2).strip()
        if val == '':
            j = i + 1
            sub = []
            while j < len(lines):
                s = lines[j]
                if s.strip() == '':
                    j += 1
                    continue
                if not s.startswith('  '):
                    break
                sub.append(s)
                j += 1
            if sub and sub[0].lstrip().startswith('- '):
                out[key] = [
                    s.strip().lstrip('-').strip().strip('"').strip("'")
                    for s in sub
                ]
            else:
                d = {}
                for s in sub:
                    sm = re.match(r'^\s+([^:]+):\s*(.*)$', s)
                    if sm:
                        d[sm.group(1).strip()] = sm.group(2).strip().strip('"').strip("'")
                out[key] = d
            i = j
        elif val.startswith('[') and val.endswith(']'):
            items = [
                x.strip().strip('"').strip("'")
                for x in val[1:-1].split(',')
                if x.strip()
            ]
            out[key] = items
            i += 1
        else:
            out[key] = val.strip('"').strip("'")
            i += 1
    return out


def file_hash(path):
    h = hashlib.sha256()
    try:
        with open(path, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                h.update(chunk)
    except OSError:
        return None
    return h.hexdigest()[:12]


def file_id(path):
    name = Path(path).name
    m = re.match(r'^(\d+)', name)
    return m.group(1) if m else name


def project_spec_version():
    cfg = Path('.metis/config.yaml')
    if not cfg.exists():
        return '1'
    for line in cfg.read_text().splitlines():
        m = re.match(r'^spec_version:\s*(.+)$', line.strip())
        if m:
            return m.group(1).strip().strip('"').strip("'")
    return '1'


# -- enumerate tasks & epics -------------------------------------------------

task_files = []
epic_files = []

if os.path.isdir('tasks'):
    for fn in sorted(os.listdir('tasks')):
        p = os.path.join('tasks', fn)
        if os.path.isfile(p) and fn.endswith('.md'):
            task_files.append(p)

if os.path.isdir('epics'):
    for ed in sorted(os.listdir('epics')):
        epic_dir = os.path.join('epics', ed)
        if not os.path.isdir(epic_dir):
            continue
        epic_md = os.path.join(epic_dir, 'EPIC.md')
        if os.path.isfile(epic_md):
            epic_files.append(epic_md)
        tasks_dir = os.path.join(epic_dir, 'tasks')
        if os.path.isdir(tasks_dir):
            for fn in sorted(os.listdir(tasks_dir)):
                p = os.path.join(tasks_dir, fn)
                if os.path.isfile(p) and fn.endswith('.md'):
                    task_files.append(p)

flat_count = sum(1 for p in task_files if not p.startswith('epics/'))
artifact_count = len(task_files) + len(epic_files)
project_sv = project_spec_version()
epic_dir_names = {Path(p).parent.name for p in epic_files}

layout = 'none'
if flat_count > 0 and len(epic_files) > 0:
    layout = 'ambiguous'
elif flat_count > 0:
    layout = 'flat'
elif len(epic_files) > 0:
    layout = 'epic'

print('=== Project state ===')
print(f'layout={layout}')
print(f'tasks={len(task_files)}')
print(f'epics={len(epic_files)}')
print(f'project_spec_version={project_sv}')
print()

if artifact_count == 0:
    print('=== Doc drift ===')
    print('(none)')
    print()
    print('=== Spec drift ===')
    print('(none)')
    print()
    print('=== Filesystem drift ===')
    print('(none)')
    print()
    print('=== Summary ===')
    print('doc=0 spec=0 fs=0 total=0')
    print('status=no-artifacts')
    sys.exit(0)


# -- compare baselines -------------------------------------------------------

doc_drift_by_doc = defaultdict(list)
spec_drift = []
fs_drift = []
hash_cache = {}


def get_hash(path):
    if path in hash_cache:
        return hash_cache[path]
    h = file_hash(path)
    hash_cache[path] = h
    return h


def process(path, kind):
    text = open(path).read()
    fm = parse_frontmatter(text)
    aid = file_id(path) if kind == 'task' else Path(path).parent.name
    status = fm.get('status', 'unknown')

    task_sv = fm.get('spec_version')
    if task_sv and str(task_sv) != str(project_sv):
        spec_drift.append((aid, status, str(task_sv)))

    refs = fm.get('docs_refs') or []
    if isinstance(refs, str):
        refs = [refs]
    hashes = fm.get('doc_hashes') or {}
    if not isinstance(hashes, dict):
        hashes = {}

    for ref in refs:
        ref_path = ref.split('#', 1)[0]
        if not Path(ref_path).exists():
            fs_drift.append((aid, 'missing-doc', ref))
            continue
        stored = hashes.get(ref_path) or hashes.get(ref)
        if not stored:
            continue
        current = get_hash(ref_path)
        if current and current != stored:
            doc_drift_by_doc[ref_path].append((aid, status))

    if kind == 'task':
        epic_ref = fm.get('epic')
        if epic_ref and epic_dir_names and epic_ref not in epic_dir_names:
            fs_drift.append((aid, 'orphan-epic', epic_ref))


for tf in task_files:
    process(tf, 'task')
for ef in epic_files:
    process(ef, 'epic')

if layout == 'ambiguous':
    fs_drift.append(('layout', 'ambiguous-layout',
                     f'flat={flat_count} epics={len(epic_files)}'))


# -- render ------------------------------------------------------------------

print('=== Doc drift ===')
if doc_drift_by_doc:
    for doc, items in sorted(doc_drift_by_doc.items()):
        print(doc)
        for aid, status in sorted(items):
            print(f'  - {aid} (status: {status})')
else:
    print('(none)')
print()

print('=== Spec drift ===')
if spec_drift:
    for aid, status, task_sv in sorted(spec_drift):
        print(f'  - {aid} (status: {status}) — task spec_version={task_sv}, project={project_sv}')
else:
    print('(none)')
print()

print('=== Filesystem drift ===')
if fs_drift:
    for aid, kind, detail in sorted(fs_drift):
        if kind == 'missing-doc':
            print(f'  - {aid} — docs_refs cites missing path: {detail}')
        elif kind == 'orphan-epic':
            print(f'  - {aid} — epic frontmatter points at non-existent: {detail}')
        elif kind == 'ambiguous-layout':
            print(f'  - layout — both tasks/ and epics/ populated ({detail})')
else:
    print('(none)')
print()

doc_count = sum(len(v) for v in doc_drift_by_doc.values())
spec_count = len(spec_drift)
fs_count = len(fs_drift)
total = doc_count + spec_count + fs_count
print('=== Summary ===')
print(f'doc={doc_count} spec={spec_count} fs={fs_count} total={total}')
print(f'status={"drift" if total > 0 else "clean"}')
PYEOF
