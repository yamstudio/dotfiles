#!/usr/bin/env bash
# Sets up dotfiles on Ubuntu (including WSL). Safe to re-run.
# Run it from wherever this repo is checked out; it links files from there.
set -euo pipefail

log() { echo "$@" >&2; }

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKUP_DIR=$HOME/.dotfiles-backup
log "[*] Setting up dotfiles from $DOTFILES..."

for cmd in git zsh vim; do
  if ! command -v "$cmd" >/dev/null; then
    log "  [-] Please install $cmd first (sudo apt install $cmd)."
    exit 1
  fi
done

# Default shell
zsh_path=$(command -v zsh)
if [[ $(basename "${SHELL:-}") != zsh ]]; then
  log "  [*] Changing shell to $zsh_path..."
  chsh -s "$zsh_path"
fi

# Clones a repo unless the target directory already exists.
get_git() {
  local dir=$1 repo=$2
  if [[ -e $dir ]]; then
    log "  [+] $dir already exists."
  else
    log "  [*] Cloning $repo into $dir..."
    git clone --depth 1 "$repo" "$dir"
  fi
}

OH_MY_ZSH=$HOME/.oh-my-zsh
get_git "$OH_MY_ZSH" https://github.com/ohmyzsh/ohmyzsh.git
get_git "$OH_MY_ZSH/custom/plugins/zsh-syntax-highlighting" \
  https://github.com/zsh-users/zsh-syntax-highlighting.git

# Links source to target. An existing file is moved to $BACKUP_DIR first.
link_file() {
  local source=$1 target=$2
  if [[ -L $target && $(readlink -f "$target") == "$(readlink -f "$source")" ]]; then
    log "  [+] $target is already linked."
    return
  fi
  if [[ -e $target || -L $target ]]; then
    mkdir -p "$BACKUP_DIR"
    local backup="$BACKUP_DIR/$(basename "$target").$(date +%Y%m%d%H%M%S)"
    log "  [*] Moving existing $target to $backup."
    mv "$target" "$backup"
  fi
  mkdir -p "$(dirname "$target")"
  log "  [*] Linking $target -> $source"
  ln -s "$source" "$target"
}

link_file "$DOTFILES/.vimrc" "$HOME/.vimrc"
link_file "$DOTFILES/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# VS Code settings for remote (WSL/SSH) sessions, only if VS Code Server exists.
if [[ -d $HOME/.vscode-server/data/Machine ]]; then
  link_file "$DOTFILES/settings.json" \
    "$HOME/.vscode-server/data/Machine/settings.json"
fi

log "[+] Done. Put anything machine-specific or private in ~/.zshrc.local."
