# Interactive commit: pick author + coauthors from git/identities via fzf, then commit.
# Identities live in $DOTFILES/git/identities as "Name|email" lines, one per line.
# Requires fzf (brew install fzf).

gcid() {
  emulate -L zsh

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
gcid - interactive git commit with author + coauthor picker

usage:
  git add <files>
  gcid

gcid replaces 'git commit', not 'git add' - stage your changes first
like normal, then run gcid instead of 'git commit'. it will:
  1. let you pick which identity to author the commit as
     (arrow keys + enter, fzf menu)
  2. let you pick which identities to add as Co-authored-by trailers
     (arrow keys + tab to mark, enter to confirm, esc for none)
  3. ask for the commit message
  4. commit with those set via -c user.name/-c user.email, without
     touching your global or repo git config

identities come from $DOTFILES/git/identities (one "Name|email" per
line) - edit that file to add/remove people, no reload needed.

requires fzf (brew install fzf).

see $DOTFILES/git/README.md for the full setup, including how to make
a repo default to a given identity automatically.
EOF
    return 0
  fi

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "gcid: not inside a git repository" >&2
    return 1
  fi

  if ! command -v fzf &>/dev/null; then
    echo "gcid: requires fzf (brew install fzf)" >&2
    return 1
  fi

  local idfile="$DOTFILES/git/identities"
  if [[ ! -f "$idfile" ]]; then
    echo "gcid: no identities file at $idfile" >&2
    return 1
  fi

  local cur_name cur_email
  cur_name=$(git config user.name)
  cur_email=$(git config user.email)

  local -a disp_order
  local -A disp2name disp2email
  local name email disp
  while IFS='|' read -r name email; do
    [[ -z "$name" ]] && continue
    disp="$name <$email>"
    disp_order+=("$disp")
    disp2name[$disp]=$name
    disp2email[$disp]=$email
  done < "$idfile"

  local cur_disp="$cur_name <$cur_email>  (current)"
  disp2name[$cur_disp]=$cur_name
  disp2email[$cur_disp]=$cur_email

  local author_disp
  author_disp=$(print -l -- "$cur_disp" "${disp_order[@]}" \
    | fzf --prompt="author> " --height=~50% --reverse --header="pick commit author")
  if [[ -z "$author_disp" ]]; then
    echo "gcid: no author selected, aborting" >&2
    return 1
  fi
  local author_name=${disp2name[$author_disp]}
  local author_email=${disp2email[$author_disp]}

  local -a coauthor_candidates
  local d
  for d in "${disp_order[@]}"; do
    [[ "${disp2name[$d]}" == "$author_name" ]] && continue
    coauthor_candidates+=("$d")
  done

  local -a coauthor_picks
  if (( ${#coauthor_candidates[@]} > 0 )); then
    coauthor_picks=("${(@f)$(print -l -- "${coauthor_candidates[@]}" \
      | fzf -m --prompt="coauthors> " --height=~50% --reverse \
          --header="tab to mark coauthors, enter to confirm, esc/ctrl-c for none")}")
  fi

  local -a trailers
  local pick
  for pick in "${coauthor_picks[@]}"; do
    [[ -z "$pick" ]] && continue
    trailers+=("Co-authored-by: ${disp2name[$pick]} <${disp2email[$pick]}>")
  done

  local msg
  read "msg?Commit message: "
  if [[ -z "$msg" ]]; then
    echo "gcid: empty message, aborting" >&2
    return 1
  fi

  local -a args=(-c "user.name=$author_name" -c "user.email=$author_email" commit -m "$msg")
  local t
  for t in "${trailers[@]}"; do
    args+=(-m "$t")
  done

  git "${args[@]}"
}
