# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
function _add_to_path() {
  dir=$1
  if [[ -z $dir ]]; then
      echo "_add_to_path parameter is empty!"
      return 1
  fi

  if [[ ! -e $dir ]]; then
      echo "$dir does not exist!"
      return 1
  fi

  if [[ ! -d $dir ]]; then
      echo "$dir is not a directory!"
      return 1
  fi

  if [[ $PATH =~ $dir ]]; then
      echo "$dir is already in \$PATH."
  else
      echo "Adding $dir to \$PATH..."
      export PATH="$dir:$PATH"
  fi
}

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  brew
  pip
  python
  zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

# User configuration
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
BROWN_SSH=$(echo @ssh.cs.brown.edu | sed "s/^/yqin/")
CCV_SSH=$(echo @ssh.ccv.brown.edu | sed "s/^/guest382/")
alias ssh_yqin="/usr/bin/ssh -t $BROWN_SSH verbose"
alias sftp_yqin="/usr/bin/sftp $BROWN_SSH"
alias syp="ssh_yqin host=poundcake"
alias syq="ssh_yqin host=quartz"
alias sy6="ssh_yqin host=cslab6e"
alias ssh_ccv="/usr/bin/ssh -t $CCV_SSH"
alias sftp_ccv="/usr/bin/sftp $CCV_SSH"

# Machine specific configuration
case `uname` in
  Darwin)
    echo "Applying macOS configuration..."
    # adds MATLAB to $PATH (newest version if multiple are present)
    matlab_path=$(find "/Applications" -maxdepth 1 -type d -name "MATLAB_R*.app" 2>/dev/null | sort -r | head -n 1)
    if [[ ! -z $matlab_path ]]; then
      _add_to_path "$matlab_path/bin"
    fi

    # adds CUDA Toolkit to $PATH
    cuda_path=$(find "/Developer/NVIDIA" -maxdepth 1 -type d -name "CUDA-*" 2>/dev/null | sort -r | head -n 1)
    if [[ ! -z $cuda_path ]]; then
      _add_to_path "$cuda_path/bin"
    fi

    # adds cross compiler to $PATH
    _add_to_path "/usr/local/cross/bin"

    # adds Homebrew executables to $PATH
    _add_to_path "/usr/local/sbin"

    # sets JAVA_HOME
    export JAVA_HOME=$(/usr/libexec/java_home)

    # activates thefuck
    eval $(thefuck --alias)
    ;;
  Linux)
    echo "Applying Linux configuration..."
    SSHAGENT=/usr/bin/ssh-agent
    SSHAGENTARGS="-s"
    if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
      eval `$SSHAGENT $SSHAGENTARGS`
	  trap "kill $SSH_AGENT_PID" 0
    fi

    export LESS=eFRX

    # TODO: find a better way to determine which machine I'm on
    case `awk -F= '$1=="ID" { print $2 ;}' /etc/os-release` in
      debian|\"debian\")
        echo "Applying Brown CS configuration..."

        alias sourcetf="source /course/cs146/public/cs146-env/bin/activate"
        alias sourcetfg="source /course/cs146/public/cs146-gpu-env/bin/activate"
        CS146_BASE_DIR="$HOME/course/cs146"
        if [[ -d $CS146_BASE_DIR ]]; then
          CS146_BRANCH="$(git --git-dir $CS146_BASE_DIR/.git branch | grep \* | cut -d ' ' -f2)"
          CS146_PROJECT_DIR="$CS146_BASE_DIR/$CS146_BRANCH"
          if [[ -d $CS146_PROJECT_DIR ]]; then
            echo "CS146 project directory is $CS146_PROJECT_DIR."
            alias cd146="cd $CS146_PROJECT_DIR; sourcetf"
            alias cd146g="cd $CS146_PROJECT_DIR; sourcetfg"
          fi
        fi
        ;;
      rhel|\"rhel\")
        echo "Applying CCV configuration..."
        module load mpi clang tmux cuda/9.0.176 cudnn/7.0 python/3.5.2 tensorflow/1.5.0_gpu_py3
        ;;
      centos|\"centos\")
        echo "Applying Azure configuration..."
        ;;
      arch|\"arch\")
        echo "Applying WSL configuration..."
        _add_to_path "/usr/local/cross/bin"
      esac
    ;;
esac

# Cleanup
unset -f _add_to_path
