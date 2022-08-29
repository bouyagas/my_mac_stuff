#  _              _                        __ _ _
# | |__  __ _ ___| |__    _ __  _ __ ___  / _(_) | ___
# | '_ \ / _` / __| '_ \  | '_ \| '__/ _ \| |_| | |/ _ \
# | |_) | (_| \__ \ | | | | |_) | | | (_) |  _| | |  __/
# |_.__/ \__,_|___/_| |_| | .__/|_|  \___/|_| |_|_|\___|
#                         |_|

# When Bash starts, it executes the commands in this script
# http://en.wikipedia.org/wiki/Bash_(Unix_shell)

# Written by Philip Lamplugh, Instructor General Assembly (2013-2015)
# Updated by PJ Hughes, Instructor General Assembly (2013-2015)
# Updated by Keyan Bagheri, Instructor General Assembly (2015)

# =====================
# Resources
# =====================

# http://cli.learncodethehardway.org/bash_cheat_sheet.pdf
# http://ss64.com/bash/syntax-prompt.html
# https://dougbarton.us/Bash/Bash-prompts.html
# http://sage.ucsc.edu/xtal/iterm_tab_customization.html

# ================= b===
# TOC
# ====================
# --------------------
# System Settings
# --------------------
#  Path
#  Settings
#  History
#  Aliases
#  Change System Settings
# --------------------
# Application Settings
# --------------------
#  Application Aliases
#  rbenv
#  nvm
# --------------------
# Other Settings
# --------------------
#  Functions
#  Sourced Files
#  Environmental Variables and API Keys

# =================
# Path
# =================

# A list of all directories in which to look for commands,
# scripts and programs
PATH="$HOME/.rbenv/bin:$PATH"                              # RBENV
PATH="/usr/local/share/npm/bin:$PATH"                      # NPM
PATH="/usr/local/bin:/usr/local/sbin:$PATH"                # Homebrew
PATH="/usr/local/heroku/bin:$PATH"                         # Heroku Toolbelt

# Uncomment to use GNU versions of core utils by default.
#   See scripts/mac/homebrew_install_core_utils.sh in the Installfest.
#   In essence, Mac OS X is in BSD userland, while Linux et al are in
#   GNU. GNU utils tend towards current POSIX compliance and are more
#   feature-rich; thus they are aliased below to add color, clean output
#   etc. BSD tools are more stable. Mac has also added some Mac-specific
#   abilities to its set of BSD-like coreutils, however: check
#   `man chmod`, eg.
# PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"       # Coreutils
# MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH" # Manual pages

# =================
# Settings
# =================

# Prefer US English
export LC_ALL="en_US.UTF-8"
# use UTF-8
export LANG="en_US"

# # Adds colors to LS!!!!
# export CLICOLOR=1
# # http://geoff.greer.fm/lscolors/
# # Describes what color to use for which attribute (files, folders etc.)
# export LSCOLORS=exfxcxdxbxegedabagacad # PJ: turned off
# export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"

# =================
# History
# =================

# http://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/
# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE

# don't put duplicate lines in the history.
export HISTCONTROL=ignoredups

# ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# Make some commands not show up in history
export HISTIGNORE="h"

# Mongodb
export MONGO_PATH=../../usr/local/mongodb
export PATH=$PATH:$MONGO_PATH/bin

# ====================
# Aliases
# ====================


## 'ls' lists information about files.
# By default, show slashes for directories.
alias ls='gls -F'

# Enhanced ls, grouping directories and using colors.
alias lg='gls --color -h --group-directories-first -F'

# Long list format including hidden files and file information.
alias lls='gls --color -h --group-directories-first -Fla'

# List ACLs (finer-grained permissions that can be inherited).
# ACLs are a necessary part of OSX fs since 11.6; see
# - ACLs on OSX: https://goo.gl/PhkcA2
# - OSX chmod manpage: https://goo.gl/vJqgZ9
#
# Note: The default ls on 10.7+ OSX is the GNU coreutils version at:
# /usr/local/opt/coreutils/libexec/gnubin/ls; in order to see the
# ACL permissions, we must use the BSD version available at: /bin/ls
alias lacl='/bin/ls -GFlae'

# Go back one directory
alias b='cd ..'
alias bb='cd ../..'
alias bbb='cd ../../..'

# Clear the terminal
alias c='clear'

# Current directory
alias d='pwd'

# Go to the home directory
alias home='cd ~'

# History lists your previously entered commands
alias h='history'


# If we make a change to our bash profile we need to reload it
alias reload="clear; source ~/.bash_profile"

# Execute verbosely
alias cp='gcp -v'
alias mv='gmv -v'
alias rm='grm -v'
alias mkdir='gmkdir -pv'

# =================
# Change System Settings
# =================

# Hide/show all desktop icons (useful when presenting)
alias hide_desktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias show_desktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Hide/show hidden files in Finder
alias hide_files="defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"
alias show_files="defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"

# ================
# Application Aliases
# ================

# Sublime should be symlinked. Otherwise use one of these
# alias subl='open -a "Sublime Text"'
# alias subl='open -a "Sublime Text 2"'
alias chrome='open -a "Google Chrome"'

#webstrom IDE
alias ws='open -a /Applications/WebStorm.app'

#vscode IDE
alias vs='open $@ -a "Visual Studio Code"'
# =================
# rbenv
# =================

# start rbenv (our Ruby environment and version manager) on open
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# =================
# nvm (load io.js as node)
# =================

export NVM_DIR=~/.nvm
source ~/.nvm/nvm.sh
# nvm use stable > /dev/null # PJ: using .nvmrc to set this... uncomment if not working

# =================
# Functions
# =================

#######################################
# Quick Jump To Today's WDI Folder
# See the script for usage.
#######################################

if [ -f ~/.bash_wdi_command.sh ]; then
  source ~/.bash_wdi_command.sh
fi

#######################################
# Set ACL permissions to inherit and
# allow read, write and update actions.
#
# Arguments:
#   1. Group Name
#   2. Directory Path
#######################################

allow_group() {
  local GROUP_NAME="$1"
  local TARGET_DIR="$2"
  local PERMISSIONS="read,write,delete,add_file,add_subdirectory"
  local INHERITANCE="file_inherit,directory_inherit"

  sudo mkdir -p "$TARGET_DIR"
  sudo /bin/chmod -R -N "$TARGET_DIR"
  sudo /bin/chmod -R +a "group:$GROUP_NAME:allow $PERMISSIONS,$INHERITANCE" "$TARGET_DIR"
}

#######################################
# Start an HTTP server from a directory
# Arguments:
#  Port (optional)
#######################################

server() {
  local port="${1:-8000}"
  (sleep 2 && open "http://localhost:${port}/")&

  # Simple Pythong Server:
  # python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"

  # Simple Ruby Webrick Server:
  ruby -e "require 'webrick';server = WEBrick::HTTPServer.new(:Port=>${port},:DocumentRoot=>Dir::pwd );trap('INT'){ server.shutdown };server.start"
}

#######################################
# List any open internet sockets on
# several popular ports. Useful if a
# rogue server is running.
# - http://www.akadia.com/services/lsof_intro.html
# - http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
#
# No Arguments.
#######################################

rogue() {
  # add or remove ports to check here!
  local PORTS="3000 4567 6379 8000 8888 27017"
  local MESSAGE="> Checking for processes on ports"
  local COMMAND="lsof"

  for PORT in $PORTS; do
    MESSAGE="${MESSAGE} ${PORT},"
    COMMAND="${COMMAND} -i TCP:${PORT}"
  done

  echo "${MESSAGE%?}..."
  local OUTPUT="$(${COMMAND})"

  if [ -z "$OUTPUT" ]; then
    echo "> Nothing running!"
  else
    echo "> Processes found:"
    printf "\n$OUTPUT\n\n"
    echo "> Use the 'kill' command with the 'PID' of any process you want to quit."
    echo
  fi
}

# =================
# Tab Improvements
# =================

## PJ: Might not need?

## Tab improvements
# bind 'set completion-ignore-case on'
# # make completions appear immediately after pressing TAB once
# bind 'set show-all-if-ambiguous on'
# bind 'TAB: menu-complete'

# =================
# Sourced Scripts
# =================

# Builds the prompt with git branch notifications.
if [ -f ~/.bash_prompt.sh ]; then
  source ~/.bash_prompt.sh
fi

# A welcome prompt with stats for sanity checks
if [ -f ~/.welcome_prompt.sh ]; then
  source ~/.welcome_prompt.sh
fi

# # bash/zsh completion support for core Git.
# if [ -f ~/.git-completion.bash ]; then
#   source ~/.git-completion.bash
# fi


# # bash-completion
# if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
#   . /opt/local/etc/profile.d/bash_completion.sh
# fi



reasonReactApp () {
  local appName=$1
  "npx create-react-app ${appName} --scripts-version reason-scripts"
}

# ====================================
# Environmental Variables and API Keys
# ====================================

# Below here is an area for other commands added by outside programs or
# commands. Attempt to reserve this area for their use!
##########################################################################

export HOMEBREW_EDITOR=nano
export EDITOR="nvim"
export NODE_REPL_HISTORY_FILE=~/.node_repl_history
export PATH=~/.npm-global/bin:$PATH
export PATH=$HOME/tools/nvim:$PATH
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
export ANDROID_HOME=${HOME}/Library/Android/sdk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
export PATH=/Applications/Postgres93.app/Contents/MacOS/bin/:$PATH


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
# added by Anaconda3 2019.10 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/Users/mohamedbgassama/opt/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/Users/mohamedbgassama/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/mohamedbgassama/opt/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/Users/mohamedbgassama/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<

export PATH="$HOME/.cargo/bin:$PATH"
