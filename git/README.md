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

## 2. `gcid` - interactive author + coauthor picker

a zsh function in `zsh/functions/gcid.zsh`, auto-loaded by the dotfiles
bootstrap. works in any git repo, not just the ones with an `includeIf`
block above.

workflow:

    git add <files>
    gcid

`gcid` replaces `git commit`, not `git add` - stage your changes first
like normal, then run `gcid` instead of `git commit`. it will:
  1. list identities and ask which one to author the commit as
     (defaults to whatever `git config user.name`/`user.email` already
     resolve to - so inside stellar-docs that's `payroutes` by default)
  2. ask which identities (if any) to add as `Co-authored-by:` trailers
  3. ask for the commit message
  4. run the commit with `-c user.name=... -c user.email=...` so it
     never touches your global/repo git config

run `gcid --help` for this same summary from the shell.

identities live in `git/identities`, one `Name|email` per line. edit
that file directly to add/remove people - no reload needed, `gcid`
re-reads it every run.

## what identity + `gcid` does NOT do

setting `user.name`/`user.email` only changes commit metadata. it has
no effect on which github account you push/authenticate as - that's
determined by the ssh key used for the remote. pushing as a different
github account needs a separate ssh key + ssh config host alias, plus
the remote url pointed at that host alias instead of `github.com`. see
below for the worked example.

## 3. pushing/signing as a second github account

worked example: `~/Desktop/work/spirit-technologies/` pushes and signs
as the `odii-spirittech` github account, separate from the personal
account used everywhere else.

what's involved, end to end:

1. a dedicated ssh key: `~/.ssh/id_ed25519_spirittech`
2. a host alias in `~/.ssh/config` so git can pick that key without
   touching the default `github.com` entry:

       Host github-spirittech
           HostName github.com
           User git
           IdentityFile ~/.ssh/id_ed25519_spirittech
           IdentitiesOnly yes

3. every remote under that folder uses the alias instead of
   `github.com`, e.g.:

       git@github-spirittech:spirit-technologies-oy/poc-web-testing.git

   (`git remote set-url origin ...` on existing clones, or clone new
   ones directly with the alias in the url)
4. the usual `includeIf` block (see section 1) additionally sets
   commit signing, since this account signs commits:

       [user]
           name = odii-spirittech
           email = emmanuel.odii@spiritech.io
           signingkey = ~/.ssh/id_ed25519_spirittech.pub
       [gpg]
           format = ssh
       [commit]
           gpgsign = true

5. one-time, on github.com, under the `odii-spirittech` account ->
   Settings -> SSH and GPG keys -> New SSH key: paste
   `~/.ssh/id_ed25519_spirittech.pub` twice, once as key type
   "Authentication Key" (needed to push at all) and once as
   "Signing Key" (needed for the verified badge). also make sure that
   account is actually a member with write access to whatever org the
   repo belongs to - a valid key alone doesn't grant access.

to set this up for a third account later, repeat steps 1-5 with a new
key name, host alias, folder, and `config-<name>` file.
