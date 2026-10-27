#!/usr/bin/env python3
"""Logs Bash commands that ran 15s or longer to <project>/tmp/claude-slow-commands/YYYY-MM-DD_HH.log."""
import json
import os
import subprocess
import sys
import time

SLOW_S = 15
STARTS = '/tmp/claude-cmd-times'


def main() -> None:
    event = json.load(sys.stdin)
    tool = event.get('tool_use_id')
    if not tool:
        return
    os.makedirs(STARTS, exist_ok=True)
    start = os.path.join(STARTS, tool)
    if sys.argv[1:] == ['start']:
        with open(start, 'w') as f:
            f.write(str(time.time()))
        return
    if not os.path.exists(start):
        return
    with open(start) as f:
        seconds = time.time() - float(f.read())
    os.remove(start)
    if seconds < SLOW_S:
        return
    root = os.environ.get('CLAUDE_PROJECT_DIR') or event.get('cwd') or ''
    if not os.path.isdir(root):
        return
    logs = os.path.join(root, 'tmp', 'claude-slow-commands')
    os.makedirs(logs, exist_ok=True)
    keep_out_of_git(root)
    entry = event.get('tool_input', {})
    command = ' '.join(entry.get('command', '').split())[:400]
    background = ' (background)' if entry.get('run_in_background') else ''
    with open(os.path.join(logs, time.strftime('%Y-%m-%d_%H.log')), 'a') as f:
        f.write(
            f"{time.strftime('%H:%M:%S')}  {seconds:6.1f}s  {entry.get('description', '')}{background}\n"
            f"    cwd: {event.get('cwd', '')}\n    cmd: {command}\n\n"
        )


def keep_out_of_git(root: str) -> None:
    found = subprocess.run(
        ['git', '-C', root, 'rev-parse', '--git-path', 'info/exclude'],
        capture_output=True,
        text=True,
    )
    if found.returncode:
        return
    exclude = found.stdout.strip()
    exclude = exclude if os.path.isabs(exclude) else os.path.join(root, exclude)
    lines = open(exclude).read().splitlines() if os.path.exists(exclude) else []
    if '/tmp/' in lines:
        return
    os.makedirs(os.path.dirname(exclude), exist_ok=True)
    with open(exclude, 'a') as f:
        f.write('/tmp/\n')


if __name__ == '__main__':
    try:
        main()
    except Exception:
        pass
