{ pkgs, ... }:

pkgs.writeScriptBin "ec" ''
  #!${pkgs.stdenv.shell}

  socket_file=$(lsof -c emacs | grep server | tr -s " " | cut -d' ' -f8 | head -n 1)

  if [ "$1" = '-s' ]; then
      shift
      if [[ $socket_file == "" ]]; then
          exec emacsclient -c -a "" "$@" > /dev/null 2>&1
      else
          exec emacsclient -c -s "$socket_file" -a "" "$@" > /dev/null 2>&1
      fi
  else
      if [[ $socket_file == "" ]]; then
          exec emacsclient -c -a "" "$@"
      else
          exec emacsclient -c -s "$socket_file" -a "" "$@"
      fi
  fi
''
