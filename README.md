# dotfiles

Personal dev setup.

## Install (new machine)

git clone https://github.com/devodii/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh

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
