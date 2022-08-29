# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/mohamedbgassama/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# TMUX
# Automatically start tmux
ZSH_TMUX_AUTOSTART=false

# Automatically connect to a previous session if it exists
ZSH_TMUX_AUTOCONNECT=true

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Setting rg as the default source for fzf
export FZF_DEFAULT_COMMAND='rg --files'

# Apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ssh
 export SSH_KEY_PATH="~/.ssh/rsa_id"

# Load Zsh tools for syntax highlighting and autosuggestions
HOMEBREW_FOLDER="/usr/local/share"
source "$HOMEBREW_FOLDER/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOMEBREW_FOLDER/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOMEBREW_FOLDER/zsh-autosuggestions/zsh-autosuggestions.zsh"

autoload -U compinit && compinit
zmodload -i zsh/complist
#Configuring Completions in zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# Brew
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Set location of z installation
. /usr/local/etc/profile.d/z.sh

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# vi mode
bindkey -v

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

export KEYTIMEOUT=1

## FZF FUNCTIONS ##
#

# fo [FUZZY PATTERN] - Open the selected file with the default editor - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fo() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fh [FUZZY PATTERN] - Search in command history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fbr [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# tm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `tm` will let you fuzzy-find a session mame
# Passing an argument to `ftm` will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
# tm [SESSIO:checkhealth providerN_NAME | FUZZY PATTERN] - delete tmux session Running `tm` will let you fuzzy-find a session mame to delete
# Passing an argument to `ftm` will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}

# fuzzy grep via rg and open in vim with line number
fgr() {
  local file
  local line

  read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     vim $file +$line
  fi
}


# Until .agrc exists...
# (https://github.com/ggreer/the_silver_searcher/pull/709)
function ag() {
  emulate -L zsh

  # italic blue paths, pink line numbers, underlined purple matches
  command ag --pager="less -iFMRSX" --color-path=34\;3 --color-line-number=35 --color-match=35\;1\;4 "$@"
}

# fd - "find directory"
# From: https://github.com/junegunn/fzf/wiki/examples#changing-directory
function fd() {
  local DIR
  DIR=$(bfs ${1:-.} -type d -nohidden 2> /dev/null | fzf +m) && cd "$DIR"
}

# fda -"find directory (all, including hidden directories)"
function fda() {
  local DIR
  DIR=$(bfs ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$DIR"
}

# fh - "find [in] history"
# From: https://github.com/junegunn/fzf/wiki/examples#command-history
function fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

function history() {
  emulate -L zsh
  # This is a function because Zsh aliases can't take arguments.
  local DEFAULT=-1000
  builtin history ${1:-$DEFAULT}
}


function ssh() {
  emulate -L zsh

  if [[ -z "$@" ]]; then
    # common case: getting to my workstation
    command ssh dev
  else
    local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
    env TERM=$LOCAL_TERM command ssh "$@"
  fi
}

function tmux() {
  emulate -L zsh

  # Make sure even pre-existing tmux sessions use the latest SSH_AUTH_SOCK.
  # (Inspired by: https://gist.github.com/lann/6771001)
  local SOCK_SYMLINK=~/.ssh/ssh_auth_sock
  if [ -r "$SSH_AUTH_SOCK" -a ! -L "$SSH_AUTH_SOCK" ]; then
    ln -sf "$SSH_AUTH_SOCK" $SOCK_SYMLINK
  fi

  # If provided with args, pass them through.
  if [[ -n "$@" ]]; then
    env SSH_AUTH_SOCK=$SOCK_SYMLINK tmux "$@"
    return
  fi

  # Check for .tmux file (poor man's Tmuxinator).
  if [ -x .tmux ]; then
    # Prompt the first time we see a given .tmux file before running it.
    local DIGEST="$(openssl sha -sha512 .tmux)"
    if ! grep -q "$DIGEST" ~/..tmux.digests 2> /dev/null; then
      cat .tmux
      read -k 1 -r \
        'REPLY?Trust (and run) this .tmux file? (t = trust, otherwise = skip) '
      echo
      if [[ $REPLY =~ ^[Tt]$ ]]; then
        echo "$DIGEST" >> ~/..tmux.digests
        ./.tmux
        return
      fi
    else
      ./.tmux
      return
    fi
  fi

  # Attach to existing session, or create one, based on current directory.
  # the:
  SESSION_NAME=$(basename "${$(pwd)//[.:]/_}")
  env SSH_AUTH_SOCK=$SOCK_SYMLINK tmux new -A -s "$SESSION_NAME"
}

# Bounce the Dock icon, if iTerm does not have focus.
function bounce() {
  if [ -n "$TMUX" ]; then
    print -Pn "\ePtmux;\e\e]1337;RequestAttention=1\a\e\\"
  else
    print -Pn "\e]1337;RequestAttention=1\a"
  fi
}

# regmv = regex + mv (mv with regex parameter specification)
#   example: regmv '/\.tif$/.tiff/' *
#   replaces .tif with .tiff for all files in current dir
#   must quote the regex otherwise "\." becomes "."
# limitations: ? doesn't seem to work in the regex, nor *
regmv() {
  if [ $# -lt 2 ]; then
    echo "  Usage: regmv 'regex' file(s)"
    echo "  Where:       'regex' should be of the format '/find/replace/'"
    echo "Example: regmv '/\.tif\$/.tiff/' *"
    echo "   Note: Must quote/escape the regex otherwise \"\.\" becomes \".\""
    return 1
  fi
  regex="$1"
  shift
  while [ -n "$1" ]
  do
    newname=$(echo "$1" | sed "s${regex}g")
    if [ "${newname}" != "$1" ]; then
      mv -i -v "$1" "$newname"
    fi
    shift
  done
}

# Convenience function for jumping to hashed directory aliases
# (ie. `j rn` -> `jump rn` -> `cd ~rn`).
function jjump() {
  emulate -L zsh

  if [ $# -eq 0 ]; then
    cd -
  elif [ $# -gt 1 ]; then
    echo "jump: single argument required, got $#"
    return 1
  else
    if [ $(hash -d|cut -d= -f1|grep -c "^$1\$") = 0 ]; then
      # Not in `hash -d`: assume it's just a dir.
      cd $1
    else
      cd ~$1
    fi
  fi
}

function _jump_complete() {
  emulate -L zsh
  local word completions
  word="$1"
  completions="$(hash -d|cut -d= -f1)"
  reply=( "${(ps:\n:)completions}" )
}

# Complete filenames and `hash -d` entries.
compctl -f -K _jump_complete jump


# "[t]ime[w]arp" by setting GIT_AUTHOR_DATE and GIT_COMMITTER_DATE.
function tw() {
  local TS=$(ts "$@")
  echo "Spawning subshell with timestamp: $TS"
  env GIT_AUTHOR_DATE="$TS" GIT_COMMITTER_DATE="$TS" zsh
}

# "tick" by incrementing GIT_AUTHOR_DATE and GIT_COMMITTER_DATE.
function tick() {
  if [ -z "$GIT_AUTHOR_DATE" -o -z "$GIT_COMMITTER_DATE" ]; then
    echo 'Expected $GIT_AUTHOR_DATE and $GIT_COMMITTER_DATE to be set.'
    echo 'Did you forget to timewarp with `tw`?'
  else
    # Fragile assumption: dates are in format produced by `tw`/`ts`.
    local TS=$(expr \
      $(echo $GIT_AUTHOR_DATE | cut -d ' ' -f 1) \
      $(parseoffset "$@") \
    )
    local TZ=$(date +%z)
    echo "Bumping timestamp to: $TS $TZ"
    export GIT_AUTHOR_DATE="$TS $TZ"
    export GIT_COMMITTER_DATE="$TS $TZ"
  fi
}

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

bindkey -s '^o' 'lfcd\n'  # zsh

reqtest() {
 ab -n $1 -k -c 30 -q  $2
}


# Set default editor to nvim
export EDITOR='nvim'

# Enabled true color support for terminals
export NVIM_TUI_ENABLE_TRUE_COLOR=1

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
 CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
 DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
 ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
 COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
 DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git node brew tmux)

source $ZSH/oh-my-zsh.sh

# Bash source file
source ~/.bashrc

# User configuration

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Aliases

# ssh
alias addkey='ssh-add ~/.ssh/id_ed25519_do'

# Remote workstation
alias rws='ssh kaky-camassa@157.245.9.70'

# Mongod Server Starter
alias mngs='mongod --dbpath ~/data/db'

# add ssh key and redirect to the remote working station
alias ex='addkey && rws'

# add ssh-agent
alias sag='eval `ssh-agent`'

# Nvim
alias n='nvim'
alias nn='nvim .'

# Emacs
alias e='emacs'
alias ee='emacs .'

# Quit
alias q='exit'

alias vtop='vtop --theme=wizard'
alias ls='colorls -lA --sd'

# Change Directory
alias /='cd ..'

# Doom Emacs Edit
alias dei="~/.emacs.d/bin/doom install"
alias deu="~/.emacs.d/bin/doom upgrade"
alias des="~/.emacs.d/bin/doom sync"
alias ded="~/.emacs.d/bin/doom doctor"
alias denv="~/.emacs.d/bin/doom env"
alias deb="~/.emacs.d//bin/doom build"

# List Directory
alias el='exa'
alias elc='exa --classify'
alias elg='exa --grid'
alias ela='exa --across'
alias ellg='exa --long --grid'
alias elt='exa --tree --level=2'
alias eltl='exa --tree --level=2 --long'
alias elgit='exa --long --git'
alias ell='exa --all --all'
alias elll='exa -d --header --group --long'
alias ellll='exa --accessed --modified --created'

# Quick edit
alias nz='nvim .zshrc'
alias nb='nvim .bash_profile'
alias nv='nvim .config/nvim/init.vim'
alias nvp='nvim .config/nvim/plugins.vim'
alias ntm='nvim .tmux.conf'

# Python
alias pyenvs='python3 -m venv env'
alias pyenva='source env/bin/activate'
alias host_file='python3 -m http.server'
alias python='python3'

# Node commands
alias ni='npm install'
alias nii='npm init'
alias nis='npm install -S'
alias nid='npm install -D'
alias nuds='npm update -S'
alias nudd='npm update -D'
alias no='npm outdated'
alias nl='npm ls --depth 0'
alias nus='npm uninstall -S'
alias nud='npm uninstall -D'
alias nt='npm test'
alias nit='npm install && npm test'
alias nk='npm link'
alias nr='npm run'
alias ns='npm start'
alias nf='npm cache clean && rm -rf node_modules && npm install'
alias nlg='npm list --global --depth=0'
alias nig='npm install --global'
alias nug='npm uninstall --global'
alias nug='npm update -g'
alias nog='npm outdated -g --depth=0'
alias npku='ncu --upgrade && ni'

# Yarn commands
alias yi='yarn install'
alias yii='yarn init'
alias yas='yarn add'
alias yad='yarn add --dsev'
alias yr= 'yarn remove'
alias yug='yarn upgrade'
alias yl='yarn list --depth=0'
alias yod='yarn outdated'
alias yg='yarn global'
alias yru='yarn run'
alias yt='yarn test'
alias yof=
alias ygu='yarn global upgrade'
alias ypku='ncu --upgrade && yi'

# Git commands
alias gi='git init'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gb='git branch'
alias gbd="git branch -d"
alias gco='git checkout'
alias gm='git merge'
alias gr='git reset'
alias gpum='git pull upstream master'
alias grv='git remote -v'
alias grro='git remote rm origin'
alias grao='git remote add origin'
alias grru='git remote rm upstream'
alias grau='git remote add upstream'
alias gcl='git clone'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gs='git status'
alias gd='git diff'
alias gsl='git shortlog'
alias gk='gitk --all&'
alias gx='gitx --all'
alias got='git '
alias get='git'
alias=gmf='git rm -f '

# File commands
alias work='cd code'
alias com='cd Company '
alias key='ssh-add'


# Docker commands
alias d='docker'
alias di='docker inspect'
alias dre='docker run -e'
alias da='docker attach'
alias de='docker exec -it'
alias drv='docker run -v'
alias dht='docker history'
alias dr='docker run'
alias drd='docker run -d'
alias dh='docker help'
alias dn='docker new'
alias dpl='docker pull'
alias dls='docker logs'
alias dli='docker login'
alias dlo='docker logout'
alias drm='docker rm'
alias drmi='docker rmi'
alias dp='docker ps'
alias dpa='docker ps -a'
alias dsp='docker stop'
alias dst='docker stats'
alias dstr='docker start'
alias dup='docker update'
alias dimg='docker images'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcstr='docker-compose start'
alias dcstp='docker-compose stop'
alias dai='docker rmi - $(docker images -q)'
alias dspn='docker system prune' # Will delete all images and container

# Rust
alias rtu='rustup update'
alias rttl='rustup target list'
alias rts='rustup show'
alias rtth='rustup toolchain help'
alias rtmc='rustup man cargo'
alias rtta='rustup target add'
alias rttr='rustup target remove'
alias rd='rustup default'

# Cargo
alias cr='cargo run'
alias cnb='cargo new --bin'
alias cnl='cargo new --lib'
alias cb='cargo build'
alias cbx='cargo xbuild'
alias cc='cargo check'
alias ci='cargo install'
alias cun='cargo uninstall'
alias ca='cargo add'
alias cre='cargo remove'
alias cu='cargo update'
alias cmu='cargo multi update'
alias cmb='cargo multi build'
alias cmt='cargo multi test'
alias cg='cargo generate --git'
alias cwb='cargo web build'
alias cwbtw='cargo web build --target=wasm32-unknown-unknown'
alias cwc='cargo web check'
alias cwt='cargo web tst'
alias cws='cargo web start'
alias cwd='cargo web deploy'

# WebAssembly
alias wpn='wasm-pack new'
alias wpb='wasm-pack build'
alias wpp='wasm-pack publish'
alias wpl='wasm-pack login'

# Home
alias ,='cd ~'

# heroku commands
alias hlo='heroku login'
alias hc= 'heroku create'
alias hpm='git push heroku master'
alias hp='heroku ps:scale web=1'
alias ho='heroku open'
alias hla='heroku local web'
alias hacp='heroku addons:create papertrail'
alias ha='heroku addons'
alias haop='heroku addons:open papertrail'
alias hrb='heroku run bash'
alias hacbd='heroku addons:create heroku-postgresql:hobby-dev'
alias hpsql='heroku pg:psql'
alias hl='heroku logs --tail'

# Tmux
alias t='tmux attach || tmux new-session'
alias th='tmux attach || tmux new-session\; split-window -h'
alias ta='tmux attach -t'
alias tn='tmux new-session'
alias tl='tmux list-sessions'
alias tks='tmux kill-session -t'
alias tks='tmux kill-server'

# opam configuration
test -r /Users/mohamedbgassama/.opam/opam-init/init.zsh && . /Users/mohamedbgassama/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PATH="/usr/local/opt/texinfo/bin:$PATH"
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/usr/local/opt/bison/bin:$PATH"
export PATH="/usr/local/opt/expat/bin:$PATH"
export PATH="/usr/local/opt/sphinx-doc/bin:$PATH"
export PATH="/usr/local/opt/bison/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/usr/local/opt/qt/bin:$PATH"
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export PATH="/usr/local/opt/expat/bin:$PATH"
export PATH="/usr/local/opt/krb5/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH"
eval "$(starship init zsh)"
export PATH="/usr/local/opt/ruby/bin:$PATH"
