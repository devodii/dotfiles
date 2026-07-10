#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
MARKER="# dotfiles bootstrap"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"

touch "$ZSHRC"

if grep -q "$MARKER" "$ZSHRC"; then
  # Update path in case repo was moved
  sed -i '' "s|source \".*/zsh/dotfiles.zsh\"|source \"$DOTFILES/zsh/dotfiles.zsh\"|" "$ZSHRC"
else
  cat >> "$ZSHRC" <<EOF

$MARKER
[[ -f "$DOTFILES/zsh/dotfiles.zsh" ]] && source "$DOTFILES/zsh/dotfiles.zsh"
EOF
fi

chmod +x "$DOTFILES"/bin/* 2>/dev/null || true

echo "Dotfiles installed from $DOTFILES"
echo "Restart shell or run: source \"$ZSHRC\""
