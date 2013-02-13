# This file is part of the jump project
#
# Copyright (C) 2010 Flavio Castelli <flavio@castelli.name>
#
# jump is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# jump is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Keep; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

_jump()
{
  local user_input
  read -cA user_input
  local cur prev
  reply=()

  cur="${user_input[$#user_input]}"
  if [[ $#user_input -gt 2 ]]; then
    prev="${user_input[$#user_input-1]}"
  fi

  if [[ ${prev} = "-d" || ${prev} = "--del" ]] ; then
    # complete the del command with a list of the available bookmarks
    reply=( $(jump-bin --complete) )
    return 0
  fi

  if [[ ${cur[0,1]} = "-" ]]; then
    reply=( --help -h --add -a --del -d --list -l )
    return 0
  else
    reply=( $(jump-bin --complete ${cur}) )
    return 0
  fi
}

function jump {
  local args dest
  args=$*
  #echo "jump called with |$args|"
  if [[ $#args -lt 1 ]]; then
    jump-bin --help
  elif [[ ${args[0,1]} = "-" ]]; then
    jump-bin $*
  else
    dest="$(jump-bin $*)" && cd "$dest"
  fi
}

compctl -K _jump -S '' jump

# vim: ft=zsh et sw=2 ts=2 sts=2
