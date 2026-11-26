#!/usr/bin/env zsh
#
# Sets up dotfiles on Arch Linux (WSL) or Ubuntu. Safe to re-run.
# Requires git, zsh and vim to be installed already.
#
# Usage: setup/install.sh [-n] [-h]
#   -n  dry run: print what would change without changing anything
#   -h  show this help

emulate -L zsh
setopt err_exit no_unset pipe_fail

readonly OH_MY_ZSH_REPO=https://github.com/ohmyzsh/ohmyzsh.git
readonly SYNTAX_HL_REPO=https://github.com/zsh-users/zsh-syntax-highlighting.git

# ${(%):-%x} is the path of this file; :A makes it absolute and resolves links.
readonly SCRIPT=${${(%):-%x}:A}
readonly DOTFILES=${SCRIPT:h:h}
readonly BACKUP_DIR=$HOME/.dotfiles-backup
integer DRY_RUN=0

log() { print -u2 -r -- "$@" }
die() { log "  [-] $*"; exit 1 }

# Runs a command, or just prints it in dry-run mode.
run() {
  if (( DRY_RUN )); then
    log "  [dry-run] $*"
  else
    "$@"
  fi
}

usage() {
  sed -n '3,9p' $SCRIPT | sed 's/^# \{0,1\}//' >&2
}

check_prerequisites() {
  local cmd install_cmd
  if (( $+commands[pacman] )); then
    install_cmd="sudo pacman -S"
  else
    install_cmd="sudo apt install"
  fi
  for cmd in git zsh vim; do
    (( $+commands[$cmd] )) || die "Please install $cmd first ($install_cmd $cmd)."
  done
}

# Makes zsh the login shell. Reads the real login shell from the passwd
# database because $SHELL may be stale or overridden.
ensure_login_shell() {
  local zsh_path=$commands[zsh] current
  current=${$(getent passwd $USER)##*:}
  # Compare resolved paths: /bin/zsh and /usr/sbin/zsh can be the same binary.
  if [[ ${current:A} == ${zsh_path:A} ]]; then
    log "  [+] Login shell is already $zsh_path."
  else
    log "  [*] Changing login shell from $current to $zsh_path..."
    run chsh -s $zsh_path
  fi
}

# Shallow-clones a repo unless the target directory already exists.
get_git() {
  local dir=$1 repo=$2
  if [[ -e $dir ]]; then
    log "  [+] $dir already exists."
  else
    log "  [*] Cloning $repo into $dir..."
    run git clone --quiet --depth 1 $repo $dir
  fi
}

# Symlinks target -> src. A pre-existing file is moved into $BACKUP_DIR
# rather than overwritten.
link_file() {
  local src=$1 target=$2
  if [[ -L $target && ${target:A} == ${src:A} ]]; then
    log "  [+] $target is already linked."
    return
  fi
  if [[ -e $target || -L $target ]]; then
    local backup=$BACKUP_DIR/${target:t}.$(date +%Y%m%d%H%M%S)
    log "  [*] Moving existing $target to $backup."
    run mkdir -p -- $BACKUP_DIR
    run mv -- $target $backup
  fi
  log "  [*] Linking $target -> $src"
  run mkdir -p -- ${target:h}
  run ln -s -- $src $target
}

main() {
  local -a opt_n opt_h
  zparseopts -D -E -- n=opt_n h=opt_h || { usage; exit 2 }
  (( $#opt_h )) && { usage; exit 0 }
  (( $#opt_n )) && DRY_RUN=1

  log "[*] Setting up dotfiles from $DOTFILES..."
  check_prerequisites
  ensure_login_shell

  local omz=$HOME/.oh-my-zsh
  get_git $omz $OH_MY_ZSH_REPO
  get_git $omz/custom/plugins/zsh-syntax-highlighting $SYNTAX_HL_REPO

  link_file $DOTFILES/.vimrc $HOME/.vimrc
  link_file $DOTFILES/.zshrc $HOME/.zshrc
  link_file $DOTFILES/.gitconfig $HOME/.gitconfig

  # VS Code settings for remote (WSL/SSH) sessions, if VS Code Server exists.
  if [[ -d $HOME/.vscode-server/data/Machine ]]; then
    link_file $DOTFILES/settings.json \
      $HOME/.vscode-server/data/Machine/settings.json
  fi

  log "[+] Done. Put machine-specific or private settings in ~/.zshrc.local."
}

main "$@"
