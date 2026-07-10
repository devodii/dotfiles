# Cleans up local branches that have been merged into main

gbclean() {
  git branch --merged | grep -v '\*\|main\|master' | xargs git branch -d
}