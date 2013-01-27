#!/bin/bash -e

usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: $0 <command>" >&2
  echo "" >&2
  echo "Available commands:" >&2
  echo "  init" >&2
  echo "  conf" >&2
  echo "  operate" >&2
  echo "" >&2
  echo "Run $0 -h <group> for more help" >&2
  exit 1
}

PRG="$0"
while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG="`dirname "$PRG"`/$link"
  fi
done

APPSH_HOME=`dirname "$PRG"`
APPSH_HOME=`cd "$APPSH_HOME" && pwd`

. $APPSH_HOME/lib/common

echo_debug=no
while getopts "h" opt
do
  case $opt in
    h)
      usage
      ;;
    D)
      echo_debug=yes
      ;;
    \?)
      usage
      ;;
  esac
done

if [ $# -eq 0 ]
then
  usage
fi

command=$1; shift

bin=`grep_path "/app-$command$" "$APPSH_HOME/bin"`

if [ ! -x "$bin" ]
then
  echo "Unknown command: $command" 2>&1
  exit 1
fi

PATH=$APPSH_HOME/bin:$PATH

# TODO: this is probably a good place to clean up the environment
exec env \
  "APPSH_HOME=$APPSH_HOME" \
  "$bin" "$@"
