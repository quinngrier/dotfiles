#
# The authors of this file have waived all copyright and
# related or neighboring rights to the extent permitted by
# law as described by the CC0 1.0 Universal Public Domain
# Dedication. You should have received a copy of the full
# dedication along with this file, typically as a file
# named <CC0-1.0.txt>. If not, it may be available at
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
#-----------------------------------------------------------------------
#
# This file (~/.bash_profile) holds the code that should be run at the
# start of every login session.
#
# By default, ~/.bash_profile is run for login sessions and ~/.bashrc is
# run for interactive non-login sessions:
#
#                           Default behavior
#
#            Interactive  Login  ~/.bash_profile  ~/.bashrc
#                No        No          No            No
#                No        Yes         Yes           No
#                Yes       No          No            Yes
#                Yes       Yes         Yes           No
#
# It's not very useful for interactive login sessions to skip ~/.bashrc,
# so we make ~/.bash_profile run ~/.bashrc as its last step if the
# session is interactive:
#
#                           Modified behavior
#
#            Interactive  Login  ~/.bash_profile  ~/.bashrc
#                No        No          No            No
#                No        Yes         Yes           No
#                Yes       No          No            Yes
#                Yes       Yes         Yes           Yes
#
# This way, ~/.bash_profile is run for login sessions and ~/.bashrc is
# run for interactive sessions. When both are run, i.e., if the session
# is both login and interactive, ~/.bash_profile is what runs ~/.bashrc
# as its last step, so ~/.bash_profile is run "first".
#
# One way to think about it is that ~/.bash_profile contains the code
# that should only be run for the root node of a tree of sessions, and
# ~/.bashrc contains the code that should be run for every node of the
# tree. For example, appending or prepending to PATH should be done in
# ~/.bash_profile (because PATH is exported), while setting PS1 should
# be done in ~/.bashrc (because PS1 is not exported).
#
# If the system provides a default ~/.bash_profile file, the master copy
# can sometimes be found at one of the following locations:
#
#       /etc/defaults/etc/skel/.bash_profile
#       /etc/skel/.bash_profile
#

#-----------------------------------------------------------------------

unset LC_ALL
LC_ALL=C
export LC_ALL
unset x
x=$(
  set -e -o pipefail
  locale -a | grep -i '^c\..*utf.*8$' | head -n 1
)
if [[ $? == 0 ]]; then
  LC_ALL=$x
fi
unset x

#-----------------------------------------------------------------------

. ~/.profile

#-----------------------------------------------------------------------

if VISUAL=$(command -v vim); then
  export VISUAL
elif VISUAL=$(command -v vi); then
  export VISUAL
elif VISUAL=$(command -v nano); then
  export VISUAL
else
  unset VISUAL
fi

#-----------------------------------------------------------------------
# Make Docker show plain output by default
#-----------------------------------------------------------------------

BUILDKIT_PROGRESS=plain
export BUILDKIT_PROGRESS

#-----------------------------------------------------------------------
# Run ~/.bashrc for interactive sessions
#-----------------------------------------------------------------------
#
# It's important that this is the last thing that ~/.bash_profile does.
# For more information, see the discussion at the top of this file.
#

if [[ "$-" == *i* && -f "$HOME/.bashrc" ]]; then
  . "$HOME/.bashrc"
fi
