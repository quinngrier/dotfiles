#
# The authors of this file have waived all copyright and
# related or neighboring rights to the extent permitted by
# law as described by the CC0 1.0 Universal Public Domain
# Dedication. You should have received a copy of the full
# dedication along with this file, typically as a file
# named <CC0-1.0.txt>. If not, it may be available at
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#

function pause_and_exit {
  read -p 'Press enter to close this window...'
  exit
}

x=$(cygpath -- "$1") || pause_and_exit
cd -- "$x" || pause_and_exit
shift

xs=()
for x; do
  if [[ "$x" == [A-Z]:[\\/]* || "$x" == '\\'* ]]; then
    x=$(cygpath -- "$x") || pause_and_exit
  fi
  xs+=("$x")
done

vim "${xs[@]}" || pause_and_exit
