# Interactive `gh` account switcher: pick which logged-in GitHub account
# is "active" for gh commands (gh pr, gh repo create, gh api, etc.) via fzf.
#
# gh stores every account you've run `gh auth login` for in
# ~/.config/gh/hosts.yml, but only one is "active" per host at a time -
# that's the account gh uses for API calls. Switching is global for the
# whole machine, not per-directory like git's identity setup (see
# $DOTFILES/git/README.md) - there's no gh equivalent of includeIf, so
# you switch explicitly before running gh commands against a given
# account/org, same as picking a different SSH key by hand.
#
# Requires fzf (brew install fzf) and being logged into 2+ accounts
# already (gh auth login, once per account).

ghid() {
  emulate -L zsh

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
ghid - interactive switcher for the active gh (GitHub CLI) account

usage:
  ghid

lists every account you're logged into (gh auth login) and lets you
pick one (arrow keys + enter, fzf menu). picking one runs:

  gh auth switch --hostname github.com --user <picked>

after that, gh pr / gh repo create / gh api / etc. all act as that
account until you run ghid again. this only changes gh's active
account - it has no effect on git commit identity (that's gcid) or
which SSH key git uses to push (that's ~/.ssh/config).

to add another account: gh auth login (repeat per account).
to check what's active without switching: gh auth status.
EOF
    return 0
  fi

  if ! command -v gh &>/dev/null; then
    echo "ghid: requires gh (brew install gh)" >&2
    return 1
  fi

  if ! command -v fzf &>/dev/null; then
    echo "ghid: requires fzf (brew install fzf)" >&2
    return 1
  fi

  local -a accounts
  accounts=("${(@f)$(gh auth status 2>&1 | awk '/Logged in to github.com account/ {print $7}')}")

  if (( ${#accounts[@]} == 0 )); then
    echo "ghid: no gh accounts found, run 'gh auth login' first" >&2
    return 1
  fi

  if (( ${#accounts[@]} == 1 )); then
    echo "ghid: only one account logged in (${accounts[1]}), nothing to switch" >&2
    return 0
  fi

  local pick
  pick=$(print -l -- "${accounts[@]}" \
    | fzf --prompt="gh account> " --height=~40% --reverse --header="pick active gh account")
  if [[ -z "$pick" ]]; then
    echo "ghid: no account selected, aborting" >&2
    return 1
  fi

  gh auth switch --hostname github.com --user "$pick"
}
