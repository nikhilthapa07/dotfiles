# make commands like git, python,node installed by homebrew to be available by the shell
eval "$(/opt/homebrew/bin/brew shellenv)"
# brew shellenv prepends unconditionally AND /etc/paths.d/homebrew makes
# path_helper inject /opt/homebrew/bin again — keep a single copy (first wins).
typeset -U path
