#!/usr/bin/env sh

echo "[*] Setting up dotfiles..."

GIT=$(which git)
if [[ -z $GIT ]]; then
  echo "  [-] Please install git first!"
  exit 1
fi

ZSH=$(which zsh)
if [[ -z $ZSH ]]; then
  echo "  [-] Please install zsh first!"
  exit 1
fi

# changes shell 
if [[ $(basename $SHELL) != "zsh" ]]; then
  echo "  [*] Changing shell to $ZSH..."
  chsh -s $ZSH
else
  echo "  [+] $ZSH is the default shell."
fi

function _get_git()
{
  dir=$1
  name=$2
  repo=$3
  echo "  [*] Getting $name..."
  if [[ -e $dir ]]; then
    echo "    [+] $dir already exists!"
  else
    echo "    [*] $name will be fetched from $repo into $dir."
    $GIT clone "$repo" "$dir"
  fi
}

# gets .dotfiles
DOTFILES=$HOME/.dotfiles
_get_git $DOTFILES "dotfiles" "git@github.com:yamstudio/dotfiles.git"

# gets .oh-my-zsh
OH_MY_ZSH=$HOME/.oh-my-zsh
_get_git $OH_MY_ZSH "oh-my-zsh" "git@github.com:robbyrussell/oh-my-zsh.git"

# gets zsh-syntax-highlighting
ZSH_SYNTAX=$OH_MY_ZSH/custom/plugins/zsh-syntax-highlighting
_get_git $ZSH_SYNTAX "zsh-syntax-highlighting" "git@github.com:zsh-users/zsh-syntax-highlighting.git"

function _link_file()
{
  source=$1
  target=$2
  BACKUP_DIR=$DOTFILES/backup
  do_link=1
  echo "  [*] Handling $source..."
  if [[ -e $target ]]; then
    echo "    [*] $target already exists. Overwrite [y/n]?"
    do_link=0
    okay=0
    while [ $okay = 0 ]; do
      okay=1
      read yn
      case $yn in
        y | yes | Y | YES )
          backup="$BACKUP_DIR/$(basename $target).old"
          echo "    [+] Okay, old $target will be moved to $backup."
          mkdir -p $BACKUP_DIR
          mv "$target" "$backup"
          do_link=1
          ;;
        n | no | N | NO )
          echo "    [+] $source is skipped."
          do_link=0
          ;;
        *)
          okay=0
          echo "    [-] Invalid response! Overwrite [y/n]?"
          ;;
      esac
    done
  fi
  if [[ $do_link = 1 ]]; then
    echo "    [*] Linking $source to $target..."
    ln -s "$source" "$target"
  fi
}

# links .vimrc
_link_file "$DOTFILES/.vimrc" "$HOME/.vimrc"

# links .zshrc
_link_file "$DOTFILES/.vimrc" "$HOME/.vimrc"

# links .gitconfig
_link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# TODO: invoke OS-setup here?
