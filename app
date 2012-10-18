#!/bin/bash

set -e

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

# Not sure this is useful
#if [ -z "$APPSH_APPS" ]
#then
#  apps=`dirname $0`
#  apps=`cd $apps; pwd`
#fi

apps=`dirname $0`
apps=`cd $apps; pwd`

# Ideally this should just do "cd /" to ensure that all paths are useful.
cd $apps

mkdir -p $apps/.app/var/pid
mkdir -p $apps/.app/var/download

method_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: $0 [-n name] [-i instance] <method group>" >&2
  echo "" >&2
  echo "Available method groups:" >&2
  echo "  instance" >&2
  echo "  conf" >&2
  echo "  operate" >&2
  echo "" >&2
  echo "Run $0 -h <group> for more help" >&2
}

. $APPSH_HOME/.app/lib/app-common
. $APPSH_HOME/.app/lib/app-instance
. $APPSH_HOME/.app/lib/app-conf
. $APPSH_HOME/.app/lib/app-operate

main() {
  local method
  local name="$APPSH_NAME"
  local instance="$APPSH_INSTANCE"

  while getopts "n:i:h" opt
  do
    case $opt in
      n)
        name=$OPTARG
        shift 2
        OPTIND=1
        ;;
      i)
        instance=$OPTARG
        shift 2
        OPTIND=1
        ;;
      h)
        shift
        OPTIND=1
        h="$1"

        if [ -z "$h" ]
        then
          method_usage
        else
          case "$h" in
            instance)
              method_instance_usage
              ;;
            conf)
              method_conf_usage
              ;;
            operate)
              method_operate_usage
              ;;
            *)
              echo "No such method group: $h"
              ;;
          esac
        fi
        exit 1
        ;;
      \?)
        echo "Invalid option: $OPTARG" 
        ;;
    esac
  done

  local method=$1
  if [ $# -gt 0 ]
  then
    shift
  fi

  case "$method" in
    instance)      method_instance "$name" "$instance" "$@" ;;
    conf)          method_conf     "$name" "$instance" "$@" ;;
    operate)       method_operate  "$name" "$instance" "$@" ;;
    *)             
      if [ -z "$method" ]
      then
        method_usage
      else
        method_usage "No such method group: $method"
      fi
      ;;
  esac
  exit $?
}

main "$@"
