#!/bin/bash -e

usage_text() {
  echo "usage: $usage_app <command>"
  echo ""
  echo "Available porcelain commands:"
  grep_path "/app-.*$" "$APPMGR_HOME/bin" | \
    sed "s,^.*/app-,    ," | \
    sort -n
  echo ""
  echo "Available plumbing commands:"
  grep_path "/app-.*$" "$APPMGR_HOME/libexec" | \
    sed "s,^.*/app-,    ," | \
    sort -n
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

APPMGR_HOME=`dirname "$PRG"`
APPMGR_HOME=`cd "$APPMGR_HOME" && pwd`

. $APPMGR_HOME/lib/common

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

bin=`grep_path "/app-$command$" "$APPMGR_HOME/bin"`

if [ ! -x "$bin" ]
then
  bin=`grep_path "/app-$command$" "$APPMGR_HOME/libexec"`
  if [ ! -x "$bin" ]
  then
    echo "Unknown command: $command" 2>&1
    exit 1
  fi
fi

PATH=$APPMGR_HOME/bin:$PATH

# TODO: this is probably a good place to clean up the environment
exec env \
  "APPMGR_HOME=$APPMGR_HOME" \
  "echo_debug=$echo_debug" \
  "$bin" "$@"
