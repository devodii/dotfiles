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

## what per-repo identity does NOT do

setting `user.name`/`user.email` only changes commit metadata. it has
no effect on which github account you push/authenticate as - that's a
separate layer (ssh key, or `gh`'s credential helper - see sections
2 and 3 below).

## 2. pushing/signing as a second github account

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

note: this ssh-alias approach is one way to authenticate as a second
account. for `clone`/`push`/`pull` specifically, switching `gh`'s
active account (section 3) is usually simpler, since it needs no
per-repo url rewriting - see the note at the end of section 3.

## 3. `ghid` - switch which account `gh` (GitHub CLI) uses, incl. git auth

`gh` (`gh pr`, `gh repo create`, `gh api`, etc.) has its own login,
separate from section 1's commit metadata and section 2's ssh keys.

`gh` supports being logged into multiple accounts at once
(`gh auth login`, once per account - browser flow, do this yourself,
never paste a token into a chat/agent), but only one is "active" per
host at a time, and that's global for the whole machine - unlike
git's `includeIf`, there's no per-directory auto-switching for `gh`.

`zsh/functions/ghid.zsh` is a small fzf picker over whatever accounts
`gh auth status` reports, so you don't have to remember account names
or the raw `gh auth switch` flags:

    ghid

run `ghid --help` for the same summary from the shell. under the hood
it just runs:

    gh auth switch --hostname github.com --user <picked>

after that, every `gh` command acts as that account until you run
`ghid` again (or `gh auth status` to check without switching).

**this also covers plain `git clone`/`push`/`pull` over https**, no ssh
alias needed: `~/.gitconfig` has

    [credential "https://github.com"]
        helper = !gh auth git-credential

so any git operation that needs an https credential for github.com
shells out to `gh`, which hands over a token for whichever account
`gh auth switch` (or `ghid`) last made active. workflow for cloning as
a second account:

    ghid                                              # pick the account
    gh repo clone <owner>/<repo>                      # or: git clone https://github.com/<owner>/<repo>.git

(`gh repo clone` reads `gh config get git_protocol` to decide
http vs ssh - `https` here, so it always goes through the credential
helper above.) this only affects the *transport auth* for
clone/push/pull; commit author metadata still comes from section 1's
`includeIf`, and if the account also signs commits, section 2's ssh
key + `config-<name>` setup still applies for that.

this has been verified end to end: switched to `odii-spirittech`,
created a repo in its org with `gh repo create`, cloned it into
`~/Desktop/work/spirit-technologies/` (picks up the `includeIf`
identity from section 1 automatically), committed, and confirmed on
github that the commit shows `odii-spirittech` as author.
