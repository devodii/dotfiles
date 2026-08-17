# git identity setup

Two independent pieces live here.

## 1. automatic per-repo identity (`user.name`/`user.email`)

`~/.gitconfig` has one `includeIf "gitdir:..."` block per repo (or repo
tree) that should default to a non-personal identity. Each block points
at a `git/config-<name>` file in this repo.

example (already set up for stellar-docs):

    [includeIf "gitdir:~/Desktop/freedom/stellar-ecosystem/stellar-docs/"]
        path = ~/Desktop/dotfiles/git/config-stellar-docs

`git/config-stellar-docs` just sets `[user] name/email`. plain
`git commit` inside that directory tree picks this up automatically,
nothing else to do.

to add another repo:
  1. create `git/config-<name>` with the `[user]` block you want
  2. add a matching `includeIf` block to `~/.gitconfig`, pointed at that
     directory (trailing slash matters)

## 2. `gcp` - interactive author + coauthor picker

a zsh function in `zsh/functions/gcp.zsh`, auto-loaded by the dotfiles
bootstrap. works in any git repo, not just the ones with an `includeIf`
block above.

workflow:

    git add <files>
    gcp

`gcp` replaces `git commit`, not `git add` - stage your changes first
like normal, then run `gcp` instead of `git commit`. it will:
  1. list identities and ask which one to author the commit as
     (defaults to whatever `git config user.name`/`user.email` already
     resolve to - so inside stellar-docs that's `payroutes` by default)
  2. ask which identities (if any) to add as `Co-authored-by:` trailers
  3. ask for the commit message
  4. run the commit with `-c user.name=... -c user.email=...` so it
     never touches your global/repo git config

run `gcp --help` for this same summary from the shell.

identities live in `git/identities`, one `Name|email` per line. edit
that file directly to add/remove people - no reload needed, `gcp`
re-reads it every run.

## what this does NOT do

setting `user.name`/`user.email` only changes commit metadata. it has
no effect on which github account you push/authenticate as - that's
determined by the ssh key used for the `git@github.com` remote. pushing
as a different github account (e.g. a second company account) needs a
separate ssh key + ssh config host alias, not covered by the identity
switch above.
