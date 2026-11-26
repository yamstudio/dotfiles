# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"

# Only load plugins that are actually installed, so a fresh box does not
# print errors on startup. (setup/install.sh installs them.)
plugins=(git)
[[ -d $ZSH/custom/plugins/zsh-syntax-highlighting ]] \
  && plugins+=(zsh-syntax-highlighting)

# Reuse one ssh-agent across shells instead of spawning one per shell.
zstyle :omz:plugins:ssh-agent lazy yes
plugins+=(ssh-agent)

[[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# Paths: keep $path free of duplicates and only add directories that exist.
typeset -U path
for dir in "$HOME/.local/bin" "$HOME/.dotnet/tools"; do
  [[ -d $dir ]] && path=("$dir" $path)
done
unset dir

export EDITOR=vim
export LESS=eFRX

# Machine-specific settings that should not live in this public repo.
[[ -r $HOME/.zshrc.local ]] && source "$HOME/.zshrc.local"
