#!/bin/bash

set -e

if [ -z "$BASEDIR" ]
then
  BASEDIR=`dirname $0`
  BASEDIR=`cd $BASEDIR; pwd`
fi
export BASEDIR

mkdir -p $BASEDIR/.app/var/pid
mkdir -p $BASEDIR/.app/var/download

method_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: $0 [-n name] [-i instance] <method group>" >&2
  echo "" >&2
  echo "Available method groups:" >&2
  echo "  app" >&2
  echo "  conf" >&2
  echo "  operate" >&2
  echo "" >&2
  echo "Run $0 -h <group> for more help" >&2
}

. $BASEDIR/.app/lib/app-common
. $BASEDIR/.app/lib/app-app
. $BASEDIR/.app/lib/app-conf
. $BASEDIR/.app/lib/app-operate

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
            app)
              method_app_usage
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
    app)           method_app     "$name" "$instance" "$@" ;;
    conf)          method_conf    "$name" "$instance" "$@" ;;
    operate)       method_operate "$name" "$instance" "$@" ;;
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
