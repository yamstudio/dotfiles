# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"

# Only load plugins that are actually installed, so a fresh box does not
# print errors on startup. (setup/install.sh installs them.)
plugins=(git)
if [[ -d $ZSH/custom/plugins/zsh-syntax-highlighting ]]; then
  plugins+=(zsh-syntax-highlighting)
fi

# Reuse one ssh-agent across shells instead of spawning one per shell.
if [[ -d $HOME/.ssh ]]; then
  zstyle :omz:plugins:ssh-agent lazy yes
  plugins+=(ssh-agent)
fi

if [[ -r $ZSH/oh-my-zsh.sh ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Paths: keep $path free of duplicates and only add directories that exist.
typeset -U path
for dir in "$HOME/.local/bin" "$HOME/.dotnet/tools"; do
  if [[ -d $dir ]]; then
    path=("$dir" $path)
  fi
done
unset dir

export EDITOR=vim
export LESS=eFRX

# Machine-specific settings that should not live in this public repo.
if [[ -r $HOME/.zshrc.local ]]; then
  source "$HOME/.zshrc.local"
fi
