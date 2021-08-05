@REM
@REM The authors of this file have waived all copyright and
@REM related or neighboring rights to the extent permitted by
@REM law as described by the CC0 1.0 Universal Public Domain
@REM Dedication. You should have received a copy of the full
@REM dedication along with this file, typically as a file
@REM named <CC0-1.0.txt>. If not, it may be available at
@REM <https://creativecommons.org/publicdomain/zero/1.0/>.
@REM
@REM See the corresponding .bash script for more information about this
@REM script.
@REM

@ECHO OFF

START "" "%~dp0..\..\..\bin\mintty.exe" ^
  /bin/bash -l start/vim.bash "%CD%" %*
