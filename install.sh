#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
MARKER="# dotfiles bootstrap"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
SKILLS_FILTER="${1:-}"

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

CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$CLAUDE_SKILLS_DIR"

wanted() {
  local name="$1"
  [ -z "$SKILLS_FILTER" ] && return 0
  case ",$SKILLS_FILTER," in
    *",$name,"*) return 0 ;;
    *) return 1 ;;
  esac
}

for skill in "$DOTFILES"/.claude/skills/*/; do
  [ -d "$skill" ] || continue
  skill="${skill%/}"
  name="$(basename "$skill")"
  target="$CLAUDE_SKILLS_DIR/$name"
  if ! wanted "$name"; then
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$skill" ]; then
      rm -f "$target"
      echo "Unlinked skill: $name"
    fi
    continue
  fi
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$skill" ]; then
    continue
  fi
  rm -rf "$target"
  ln -s "$skill" "$target"
  echo "Linked skill: $name"
done

echo "Dotfiles installed from $DOTFILES"
echo "Restart shell or run: source \"$ZSHRC\""
