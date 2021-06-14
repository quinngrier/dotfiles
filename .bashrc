#
# This file (~/.bashrc) holds the code that should be run at the start
# of every interactive session.
#
# ~/.bash_profile is run for login sessions and ~/.bashrc is run for
# interactive sessions. When both are run, i.e., if the session is both
# login and interactive, ~/.bash_profile is what runs ~/.bashrc as its
# last step, so ~/.bash_profile is run "first". For more information,
# see the discussion at the top of ~/.bash_profile.
#
# One way to think about it is that ~/.bash_profile contains the code
# that should only be run for the root node of a tree of sessions, and
# ~/.bashrc contains the code that should be run for every node of the
# tree. For example, appending or prepending to PATH should be done in
# ~/.bash_profile (because PATH is exported), while setting PS1 should
# be done in ~/.bashrc (because PS1 is not exported).
#
# If the system provides a default ~/.bashrc file, the master copy can
# sometimes be found at one of the following locations:
#
#       /etc/defaults/etc/skel/.bashrc
#       /etc/skel/.bashrc
#

#-----------------------------------------------------------------------
# Don't do anything if the session isn't interactive
#-----------------------------------------------------------------------

if [[ "$-" != *i* ]]; then
  return
fi

#-----------------------------------------------------------------------
# Shell options
#-----------------------------------------------------------------------

set \
  -o vi \
;

shopt -s \
  checkjobs \
  checkwinsize \
  cmdhist \
  dotglob \
  extglob \
  globasciiranges \
  globstar \
  histappend \
  histreedit \
  histverify \
  interactive_comments \
  lithist \
  nullglob \
  shift_verbose \
;

set \
  +o histexpand \
;

shopt -u \
  compat31 \
;

#-----------------------------------------------------------------------
# The dr alias
#-----------------------------------------------------------------------

alias dr='docker run --rm -i -t'

#-----------------------------------------------------------------------
# The e alias
#-----------------------------------------------------------------------
#
# The e alias can be used to enable error handling when writing ad-hoc
# subshell scripts. For example:
#
#       (e; xs=$(git grep -l foo); sed -i 's/foo/bar/g' $xs)
#
# Do not use the e alias outside of a subshell! Doing so will enable
# error handling for all commands you type, which is probably not what
# you want, as this will make your shell exit upon any command failing.
# If you do it by accident, you can use the ee alias to undo it.
#

alias e='{ set -E -e -u -o pipefail || exit; trap exit ERR; }'
alias ee='{ set +E +e +u +o pipefail; trap - ERR; }'

#-----------------------------------------------------------------------
# The grep alias
#-----------------------------------------------------------------------

if grep --color=auto x <<<x &>/dev/null; then
  alias grep='grep --color=auto'
fi

#-----------------------------------------------------------------------
# The s alias
#-----------------------------------------------------------------------
#
# The s alias goes along with the ~/bin/s script. The problem is that we
# want the script to show the output of the jobs command, but if we run
# the jobs command in the script, it will show the jobs of the script's
# shell instance, not the jobs of our interactive shell instance. The
# solution is to use the s alias to run the jobs command and pass the
# output to the script. We also pass an extra "token" argument so the
# script can detect if it was accidentally run without the alias.
#

alias s='(s_alias_jobs=$(jobs -l) && s s_alias_jobs "$s_alias_jobs")'

#-----------------------------------------------------------------------

HISTFILESIZE=100000
HISTSIZE=$HISTFILESIZE

#-----------------------------------------------------------------------
# Primary prompt string and window title
#-----------------------------------------------------------------------
#
# The primary prompt string looks like this:
#
#       [0][user@host:/current/working/directory]
#       $
#
# The "[0]" part is the exit status of the last command. If the command
# was a pipeline, the exit status of every command in the pipeline will
# appear, separated by "|" characters. For example, "true | false" will
# yield "[0|1]". The first line of the prompt string is underlined all
# the way to the edge of the window for visual distinction.
#
# The window title looks like this:
#
#       [user@host:/current/working/directory]
#

function print_ps1 {
  local -r e=$'\001\033'
  local -r m=$'m\002'
  local -r a=$'\007\002'
  local -r u="$1"
  local -r H="$2"
  local -r w="$3"
  shift 3
  local s=
  local n=$COLUMNS
  local x
  local y
  s+="$e[0$m"
  s+="$e]0;[$u@$H:$w]$a"
  s+="$e[4$m"
  s+="["
  n=$((n - 1))
  x=
  for y; do
    if [[ "$x" != "" ]]; then
      x+="|"
      n=$((n - 1))
    fi
    x+="$e[$((y ? 31 : 32))$m$y$e[39$m"
    n=$((n - ${#y}))
  done
  s+="$x"
  x="][$u@$H:$w]"
  s+="$x"
  n=$((n - ${#x}))
  for ((; n > 0; --n)); do
    s+=" "
  done
  s+="$e[0$m"$'\n$ '
  printf '%s' "$s"
}

PS1="\$(print_ps1 '\\u' '\\H' '\\w' \"\${PIPESTATUS[@]}\")"

#-----------------------------------------------------------------------
# gpg-agent and ssh-agent
#-----------------------------------------------------------------------
#
# The idea here is to create a string $boot that represents the system
# boot time and store the agent hookup commands in some files in $HOME
# whose names include $boot. We can then check whether the files exist
# to decide whether the agents are already running. If the files exist,
# we'll eval them to hook ourselves to the already running agents, and
# if not, we'll start the agents and create the files first.
#

eval " $(
  case $(uname) in
    (*CYGWIN*)
      x='WMIC OS GET LastBootUpTime'
      boot=$($x | tr -d '\t\r ' | sed -n 2p) || exit
    ;;
    (*)
      boot=$(who -b | sed 's/.*boot//') || exit
      boot=$(date -d "$boot" '+%s') || exit
    ;;
  esac
  start_or_inherit() {
    local x="$HOME/.bashrc-$1"
    if [[ ! -f "$x-$boot" ]]; then
      rm -f "$x-"*
      eval "$@" >"$x-$boot.$$" || return
      mv -f "$x-$boot.$$" "$x-$boot" || return
    fi
    x=$(cat "$x-$boot") || return
    printf '%s\n' "$x" || return
  }
  start_or_inherit gpg-agent --daemon
  start_or_inherit ssh-agent
)"

if GPG_TTY=$(tty); then
  export GPG_TTY
else
  unset GPG_TTY
fi

#-----------------------------------------------------------------------

#
# Free up Ctrl-s and Ctrl-q by disabling XON/XOFF flow control.
#

stty -ixon

#-----------------------------------------------------------------------

#
# The authors of this file have waived all copyright and
# related or neighboring rights to the extent permitted by
# law as described by the CC0 1.0 Universal Public Domain
# Dedication. You should have received a copy of the full
# dedication along with this file, typically as a file
# named <CC0-1.0.txt>. If not, it may be available at
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
