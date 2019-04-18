#!/usr/bin/env sh

if [[ -z $DOTFILES ]]; then
  DOTFILES="$HOME/.dotfiles"
fi

>&2 echo "[+] Hi CentOS, using dotfiles at $DOTFILES."
