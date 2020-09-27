#
# If a default ~/.bash_profile file exists, the master copy can
# sometimes be found at one of the following locations:
#
#       /etc/defaults/etc/skel/.bash_profile
#       /etc/skel/.bash_profile
#

PATH=$HOME/bin:$PATH
export PATH

if [[ "$-" == *i* && -f "$HOME/.bashrc" ]]; then
  . "$HOME/.bashrc"
fi

#
# The authors of this file have waived all copyright and
# related or neighboring rights to the extent permitted by
# law as described by the CC0 1.0 Universal Public Domain
# Dedication. You should have received a copy of the full
# dedication along with this file, typically as a file
# named <CC0-1.0.txt>. If not, it may be available at
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
