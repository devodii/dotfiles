# dotfiles

Personal dev setup.

## Install (new machine)

```bash
git clone https://github.com/devodii/dotfiles.git ~/Desktop/dotfiles
cd ~/Desktop/dotfiles && ./install.sh
```

This adds one bootstrap line to `~/.zshrc` that sources dotfiles. Everything else lives in this repo.

## How tools are registered

| Location           | What goes there                      | How it works                            |
| ------------------ | ------------------------------------ | --------------------------------------- |
| `bin/`             | CLI scripts                          | Auto on PATH — no `.zshrc` edits needed |
| `zsh/functions/`   | Shell functions that must be sourced | Auto sourced via `dotfiles.zsh`         |
| `zsh/dotfiles.zsh` | Bootstrap (PATH, auto-load)          | Single source of truth                  |

Add a new CLI tool: drop an executable in `bin/`. Done.

Add a shell function: create `zsh/functions/myfunc.zsh`. Done.

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
