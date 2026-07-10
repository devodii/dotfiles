# Dotfiles bootstrap — sourced from ~/.zshrc
# CLI tools: drop executables in bin/ (auto on PATH)
# Shell functions: add *.zsh files in zsh/functions/ (auto sourced)

export DOTFILES="${DOTFILES:-$(cd "${${(%):-%x}:A:h}/.." && pwd)}"
export PATH="$DOTFILES/bin:$PATH"

for _df in "$DOTFILES"/zsh/functions/*.zsh(N); do
  source "$_df"
done
unset _df
