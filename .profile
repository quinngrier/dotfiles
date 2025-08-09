#
# The authors of this file have waived all copyright and
# related or neighboring rights to the extent permitted by
# law as described by the CC0 1.0 Universal Public Domain
# Dedication. You should have received a copy of the full
# dedication along with this file, typically as a file
# named <CC0-1.0.txt>. If not, it may be available at
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#

if command -v vim >/dev/null 2>/dev/null; then
  EDITOR=vim
  EDITOR_BOTTOM=+
  export EDITOR
  export EDITOR_BOTTOM
else
  unset EDITOR
  unset EDITOR_BOTTOM
fi

if ${EDITOR+:} false; then
  VISUAL=${EDITOR?}
  VISUAL_BOTTOM=${EDITOR_BOTTOM?}
  export VISUAL
  export VISUAL_BOTTOM
else
  unset VISUAL
  unset VISUAL_BOTTOM
fi

unset GREP_COLORS
GREP_COLORS='mt=45'
export GREP_COLORS

PATH=\
$HOME/bin:\
$HOME/.cargo/bin:\
$HOME/.local/bin:\
$PATH

if test -f ~/.profile.private; then
  . ~/.profile.private
fi
