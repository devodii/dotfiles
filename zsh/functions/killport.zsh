# killport 3000

killport() {
  lsof -ti ":$1" | xargs kill -9
}