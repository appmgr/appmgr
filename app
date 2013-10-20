#!/bin/bash -e

usage_text() {
  echo "usage: $usage_app <command>"
  echo ""
  echo "Available porcelain commands:"
  grep_path "/app-.*$" "$APPSH_HOME/bin" | sed "s,^.*/app-,    ,"
  echo ""
  echo "Available plumbing commands:"
  grep_path "/app-.*$" "$APPSH_HOME/libexec" | sed "s,^.*/app-,    ,"
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
while getopts ":hD:" opt
do
  case $opt in
    h)
      show_help
      ;;
    D)
      echo_debug=yes
      eval OPTIND=$((OPTIND-1))
      shift
      ;;
    *)
      break
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
  bin=`grep_path "/app-$command$" "$APPSH_HOME/libexec"`
  if [ ! -x "$bin" ]
  then
    echo "Unknown command: $command" 2>&1
    exit 1
  fi
fi

PATH=$APPSH_HOME/bin:$PATH

# TODO: this is probably a good place to clean up the environment
exec env \
  "APPSH_HOME=$APPSH_HOME" \
  "echo_debug=$echo_debug" \
  "$bin" "$@"
