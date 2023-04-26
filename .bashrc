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
# Error handling
#-----------------------------------------------------------------------
#
# The e alias enables error handling. For example:
#
#       (e; xs=$(git grep -l foo); sed -i 's/foo/bar/g' $xs)
#
# Do not use the e alias outside of a subshell! Doing so may interfere
# with your environment.
#

alias e='{ set -E -e -u -o pipefail || exit $?; trap exit ERR; }'

#-----------------------------------------------------------------------
# Nested SSH
#-----------------------------------------------------------------------
#
# The nested_ssh alias enables error handling and defines variables for
# making nested calls to ssh. For example:
#
#       (
#         nested_ssh
#         ssh foo bash -l -c "$begin1"'
#           echo Hello from foo.
#           ssh bar bash -l -c '"$begin2"'
#             echo Hello from bar.
#             ssh baz bash -l -c '"$begin3"'
#               echo Hello from baz.
#             '"$end3"'
#           '"$end2"'
#         '"$end1"
#       )
#
# Inside each block, all code can be written normally except for single
# quote characters, which must always be written like '"$q1"'. The index
# in the variable names should always be incremented and decremented to
# match the nesting depth. Note that the syntax for begin1 and end1 is
# slightly different for i = 1 than i > 1.
#
# Do not use the nested_ssh alias outside of a subshell! Doing so may
# interfere with your environment.
#

alias nested_ssh='{
  eh=${eh-'\''set -E -e -u -o pipefail || exit $?; trap exit ERR;'\''}
  eval " $eh"
  q0=\'\''
  begin1=$q0$eh; end1=$q0; q1=$q0\\$q0$q0
  begin2=\\$q1$q1$eh; end2=$q1\\$q1; q2=$q1\\$q1\\\\\\$q1\\$q1$q1
  begin3=\\$q2$q2$eh; end3=$q2\\$q2; q3=$q2\\$q2\\\\\\$q2\\$q2$q2
  begin4=\\$q3$q3$eh; end4=$q3\\$q3; q4=$q3\\$q3\\\\\\$q3\\$q3$q3
  begin5=\\$q4$q4$eh; end5=$q4\\$q4; q5=$q4\\$q4\\\\\\$q4\\$q4$q4
  begin6=\\$q5$q5$eh; end6=$q5\\$q5; q6=$q5\\$q5\\\\\\$q5\\$q5$q5
  begin7=\\$q6$q6$eh; end7=$q6\\$q6; q7=$q6\\$q6\\\\\\$q6\\$q6$q6
  begin8=\\$q7$q7$eh; end8=$q7\\$q7; q8=$q7\\$q7\\\\\\$q7\\$q7$q7
  begin9=\\$q8$q8$eh; end9=$q8\\$q8; q9=$q8\\$q8\\\\\\$q8\\$q8$q8
}'

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

HISTCONTROL=ignorespace
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
# yield "[0|1]". Each zero exit status will be colored green, and each
# nonzero exit status will be colored red.
#
# The first line of the prompt string is underlined all the way to the
# edge of the window for visual distinction.
#
# The window title looks like this:
#
#       user@host:/current/working/directory
#
# The user's home directory will never be abbreviated to "~" in the
# current working directory display. For example, my window title and
# prompt currently say "/home/quinn", not "~". This makes the display
# more robust for copy-pasting into other contexts.
#
# Note that we cannot use Bash's prompting escapes inside PS1_function,
# as they are only interpreted directly inside the prompting variables.
# We use the following alternatives instead:
#
#       \[ is \001
#       \] is \002
#       \a is \007
#       \e is \033
#       \u is $USER
#       \H is $HOSTNAME
#

PS1_function() {

  declare -r e=$'\001\033'
  declare -r m=$'m\002'
  declare -r a=$'\007\002'
  declare -r u="$USER"
  declare -r H="$HOSTNAME"
  declare -r f='                                                  '
  declare s=
  declare n=$COLUMNS
  declare p=
  declare x

  s+="$e[0$m"

  s+="$e]0;$u@$H:$PWD$a"

  s+="$e[4$m"

  s+="["
  n=$((n - 1))

  for x; do
    s+="$p$e[$((x == 0 ? 32 : 31))$m$x$e[39$m"
    n=$((n - ${#p} - ${#x}))
    p='|'
  done

  s+="]"
  n=$((n - 1))

  x="[$u@$H:$PWD]"
  s+="$x"
  n=$((n - ${#x}))

  while ((n > ${#f})); do
    s+="$f"
    n=$((n - ${#f}))
  done
  if ((n > 0)); then
    s+="${f:0:n}"
    n=0
  fi

  s+="$e[0$m"

  s+=$'\n$ '

  printf '%s' "$s"

}

PS1='$(PS1_function "${PIPESTATUS[@]}")'

#-----------------------------------------------------------------------
# Start or inherit gpg-agent and ssh-agent
#-----------------------------------------------------------------------

eval " $(
  if x=$(ps xo comm,pid); then
    if [[ "$x" != $'\ngpg-agent ' ]]; then
      gpg-agent --daemon
    fi
    if [[ "${SSH_AGENT_PID-}" == "" ]]; then
      r=1
      if [[ "$x" == $'\nssh-agent ' && -f ~/.ssh-agent.sh ]]; then
        y=${x##*$'\nssh-agent'}
        y=${y%%$'\n'*}
        y=${y// /}
        eval " $(cat ~/.ssh-agent.sh)"
        if [[ "$y" == "${SSH_AGENT_PID-}" ]]; then
          r=0
        fi
      fi
      if ((r)); then
        y=$(ssh-agent -s)
        printf '%s\n' "$y"
        printf '%s\n' "$y" >~/.ssh-agent.sh
      fi
      cat ~/.ssh-agent.sh
    fi
  fi
)" >/dev/null

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
