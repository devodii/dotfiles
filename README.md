# dotfiles

Personal dev setup.

## Install (new machine)

```bash
git clone https://github.com/devodii/dotfiles.git ~/Desktop/dotfiles
cd ~/Desktop/dotfiles && ./install.sh
```

This adds one bootstrap line to `~/.zshrc` that sources dotfiles (which puts `bin/` on PATH) and runs the `dotfiles` command once. Everything else lives in this repo.

After the first install, open a new shell and use `dotfiles` directly from anywhere, no path needed.

## How tools are registered

| Location            | What goes there                      | How it works                                |
| ------------------- | ------------------------------------- | -------------------------------------------- |
| `bin/`              | CLI scripts                          | Auto on PATH, no `.zshrc` edits needed       |
| `zsh/functions/`    | Shell functions that must be sourced | Auto sourced via `dotfiles.zsh`              |
| `zsh/dotfiles.zsh`  | Bootstrap (PATH, auto-load)          | Single source of truth                       |
| `.claude/skills/`   | Claude Code skills                   | Symlinked into `~/.claude/skills/` on install |
| `.claude/hooks/`    | Claude Code hooks                    | Symlinked into `~/.claude/hooks/` and registered in `~/.claude/settings.json` on install |

Add a new CLI tool: drop an executable in `bin/`. Done.

Add a shell function: create `zsh/functions/myfunc.zsh`. Done.

Add a Claude Code skill: create `.claude/skills/<name>/SKILL.md`, then run `dotfiles`. It shows up in every project on this machine.

`~/.claude/skills/` is global to the whole machine, not per-project, so `dotfiles` takes an optional comma-separated filter for setups that shouldn't get every skill (e.g. a freelance/client machine that shouldn't see personal-only skills):

```bash
dotfiles                    # link every skill (default)
dotfiles commit-style       # link only commit-style, unlink anything else it previously linked
```

## Tools

### context — dump codebase for LLMs

Preview:
context -r /path/to/project

Save:
context --save -r /path/to/project -o codebase_context.txt

Options:
-e ts,tsx,js extensions
-o FILE output file
-r DIR project root
-s write to disk
-x files/folders to omit.

### slow commands — find what eats Claude Code's time

Every Bash command Claude Code runs for 15 seconds or more is logged to `tmp/claude-slow-commands/` in the project it ran in, one file per hour:

```
tmp/claude-slow-commands/2026-10-27_14.log
```

Each entry has the time, how long it took, its description, the folder and the command. `tmp/` is added to the repo's local git exclude, so the logs are never committed. Installed by `dotfiles` (needs `python3`). Turn it off from `/hooks` in Claude Code.
