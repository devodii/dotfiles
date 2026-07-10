#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Symlink configs
ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

# Adds bin to PATH (once)
grep -q 'dotfiles/bin' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'EOF'

# dotfiles
export PATH="$HOME/dotfiles/bin:$PATH"
EOF

echo "Done. Restart shell or: source ~/.zshrc"