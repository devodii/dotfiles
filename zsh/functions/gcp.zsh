# Interactive commit: pick author + coauthors from git/identities, then commit.
# Identities live in $DOTFILES/git/identities as "Name|email" lines, one per line.

gcp() {
  emulate -L zsh

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
gcp - interactive git commit with author + coauthor picker

usage:
  git add <files>
  gcp

gcp replaces 'git commit', not 'git add' - stage your changes first
like normal, then run gcp instead of 'git commit'. it will:
  1. ask which identity to author the commit as
  2. ask which identities to add as Co-authored-by trailers
  3. ask for the commit message
  4. commit with those set via -c user.name/-c user.email, without
     touching your global or repo git config

identities come from $DOTFILES/git/identities (one "Name|email" per
line) - edit that file to add/remove people, no reload needed.

see $DOTFILES/git/README.md for the full setup, including how to make
a repo default to a given identity automatically.
EOF
    return 0
  fi

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "gcp: not inside a git repository" >&2
    return 1
  fi

  local idfile="$DOTFILES/git/identities"
  if [[ ! -f "$idfile" ]]; then
    echo "gcp: no identities file at $idfile" >&2
    return 1
  fi

  local -a names emails
  local n e
  while IFS='|' read -r n e; do
    [[ -z "$n" ]] && continue
    names+=("$n")
    emails+=("$e")
  done < "$idfile"

  local cur_name cur_email
  cur_name=$(git config user.name)
  cur_email=$(git config user.email)
  local default=$(( ${#names[@]} + 1 ))

  echo "Author:"
  local i
  for (( i = 1; i <= ${#names[@]}; i++ )); do
    printf "  %d) %s <%s>\n" "$i" "${names[$i]}" "${emails[$i]}"
  done
  printf "  %d) current (%s <%s>)\n" "$default" "$cur_name" "$cur_email"
  read "achoice?  select [$default]: "
  [[ -z "$achoice" ]] && achoice=$default

  local author_name author_email
  if (( achoice == default )); then
    author_name=$cur_name
    author_email=$cur_email
  else
    author_name=${names[$achoice]}
    author_email=${emails[$achoice]}
  fi

  echo "\nCoauthors (space-separated numbers, blank for none):"
  for (( i = 1; i <= ${#names[@]}; i++ )); do
    printf "  %d) %s <%s>\n" "$i" "${names[$i]}" "${emails[$i]}"
  done
  read "cchoices?  select: "

  local -a trailers
  local c
  for c in ${(s: :)cchoices}; do
    [[ -z "$c" ]] && continue
    [[ "${names[$c]}" == "$author_name" ]] && continue
    trailers+=("Co-authored-by: ${names[$c]} <${emails[$c]}>")
  done

  read "msg?\nCommit message: "
  if [[ -z "$msg" ]]; then
    echo "gcp: empty message, aborting" >&2
    return 1
  fi

  local -a args=(-c "user.name=$author_name" -c "user.email=$author_email" commit -m "$msg")
  local t
  for t in "${trailers[@]}"; do
    args+=(-m "$t")
  done

  git "${args[@]}"
}
