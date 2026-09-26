# dotfiles

Personal dev setup.

## Install (new machine)

```bash
git clone https://github.com/devodii/dotfiles.git ~/Desktop/dotfiles
cd ~/Desktop/dotfiles && ./install.sh
```

This adds one bootstrap line to `~/.zshrc` that sources dotfiles. Everything else lives in this repo.

## How tools are registered

| Location            | What goes there                      | How it works                                |
| ------------------- | ------------------------------------- | -------------------------------------------- |
| `bin/`              | CLI scripts                          | Auto on PATH, no `.zshrc` edits needed       |
| `zsh/functions/`    | Shell functions that must be sourced | Auto sourced via `dotfiles.zsh`              |
| `zsh/dotfiles.zsh`  | Bootstrap (PATH, auto-load)          | Single source of truth                       |
| `.claude/skills/`   | Claude Code skills                   | Symlinked into `~/.claude/skills/` on install |

Add a new CLI tool: drop an executable in `bin/`. Done.

Add a shell function: create `zsh/functions/myfunc.zsh`. Done.

Add a Claude Code skill: create `.claude/skills/<name>/SKILL.md`, then run `./install.sh`. It shows up in every project on this machine.

`~/.claude/skills/` is global to the whole machine, not per-project, so `./install.sh` takes an optional comma-separated filter for setups that shouldn't get every skill (e.g. a freelance/client machine that shouldn't see personal-only skills):

```bash
./install.sh                    # link every skill (default)
./install.sh commit-style       # link only commit-style, unlink anything else this script previously linked
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
