#!/bin/bash

set -e

BASEDIR=`dirname $0`
BASEDIR=`cd $BASEDIR; pwd`
export BASEDIR

mkdir -p $BASEDIR/.app/var/pid
mkdir -p $BASEDIR/.app/var/download

if [ -n "$APPSH_REPO" ]
then
  repo="$APPSH_REPO"
else
  repo="http://repo1.maven.org"
fi

# TODO: support file:// repositories
# TODO: look in the local repository first
# TODO: assert that we got a 200 OK
get() { 
  local exit

  curl -o $2 $1 -D curl.tmp

  exit=`grep "^HTTP/[0-9]\.[0-9] 200 .*" curl.tmp >/dev/null; echo $?`
  head=`head -n 1 curl.tmp`
  rm curl.tmp
  if [ "$exit" != 0 ]
  then
    echo "Unable to download $1: $head"
    exit 1
  fi
}

resolved_version=
resolve_snapshot() {
  local base_url
  local metadata

  echo "Resolving version $version..."
  metadata=$BASEDIR/.app/var/download/$groupId-$artifactId-$version-metadata.xml
  base_url=$repo/$(echo $groupId | sed "s,\.,/,g")/$artifactId/$version
  get $base_url/maven-metadata.xml $metadata
  resolved_version=`xmlstarlet sel -t -m '//snapshotVersion[extension[text()="zip"]]' -v value $metadata`

  if [ -z "$resolved_version" ]
  then
    echo "Unable to resolve version."
    exit 1
  fi
  echo "Resolved version $version to $resolved_version"
}

zip_file=
download_artifact() {
  zip_file=$BASEDIR/.app/var/download/$groupId-$artifactId-$resolved_version.zip
  if [ -r $zip_file ]
  then
    echo "Artifact already downloaded."
    return 0
  fi
  echo "Downloading artifact"
  base_url=$repo/$(echo $groupId | sed "s,\.,/,g")/$artifactId/$version
  get $base_url/$artifactId-$resolved_version.zip $zip_file

  # TODO: download checksum. bash is too shady to trust
}

assert_is_instance() {
  local usage=$1
  local name=$2
  local instance=$3
  local check_link=$4

  if [ -z "$name" ]
  then
    $usage "Missing required option -n."
  fi

  if [ -z "$instance" ]
  then
    $usage "Missing required option -i."
  fi

  if [ ! -d $name/$instance ]
  then
    echo "No such application/instance: $name/$instance."  >&2
    exit 1
  fi

  if [ "$check_link" != "no" ]
  then
    if [ ! -e $name/$instance/current ]
    then
      echo "Missing 'current' link." >&2
      exit 1
    fi
  fi
}

install_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage:" >&2
  echo ""
  echo "Install Maven artifact from repo:" >&2
  echo "  $0 install -m groupId:artifactId [-n name] -i instance [-v version]" >&2
  echo "Name defaults to artifactId." >&2
  echo ""
  echo "Install zip file:" >&2
  echo "  $0 install -f file -n name -i instance [-v version]" >&2
  echo "The version defaults to the current timestamp" >&2
  exit 1
}

method_install() {
  local m

  while getopts "m:n:i:v:f:" opt
  do
    case $opt in
      m)
        m=$OPTARG
        groupId=`echo $OPTARG | cut -s -f 1 -d :`
        artifactId=`echo $OPTARG | cut -s -f 2 -d :`
        if [ -z "$groupId" -o -z "$artifactId" ]
        then
          install_usage "Invalid -m value."
        fi
        ;;
      n)
        name=$OPTARG
        ;;
      i)
        instance=$OPTARG
        ;;
      v)
        version=$OPTARG
        ;;
      f)
        file=$OPTARG
        ;;
      \?)
        install_usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done

  if [ -z "$file" -a -z "$m" ]
  then
    install_usage "Either -f or -m has to be specified." 
  fi

  if [ -n "$file" -a -n "$m" ]
  then
    install_usage "Only one of -f or -m can specified." 
  fi

  if [ -z "$instance" ]
  then
    install_usage "Missing required argument: -i instance."
  fi

  if [ -z "version" ]
  then
    install_usage "Missing required argument: -v version."
  fi

  if [ -n "$m" ]
  then
    if [ -z "$name" ]
    then
      name=$artifactId
    fi

    resolve_snapshot

    download_artifact
  else
    zip_file=$file

    if [ -z "$version" ]
    then
      version=`TZ=UTC date +"%Y%m%d-%H%M%S"`
    fi

    resolved_version=$version
  fi

  if [ ! -d $name/$instance ]
  then
    echo "Creating instance '$instance' for $name"
    mkdir -p $name/$instance
  fi

  if [ -d $name/$instance/versions/$resolved_version ]
  then
    echo "Version $resolved_version is already installed"
    exit 1
  fi

  mkdir -p $name/$instance/versions/$resolved_version

  echo "Unpacking..."
  unzip -q -d $name/$instance/versions/$resolved_version $zip_file

  (
    cd $name/$instance/versions/$resolved_version
    if [ -d scripts ]
    then
      find scripts | xargs chmod +x
    fi

    if [ -x scripts/postinstall ]
    then
      echo "Running postinstall..."
      set +e
      env -i \
        PATH=$PATH \
        scripts/postinstall
      set -e
      ret=`echo $?`
      if [ "$ret" != 0 ]
      then
        echo "Postinstall failed!"
        exit 1
      fi
      echo "Postinstall completed successfully"
    fi
  )

  echo "Changing current symlink"
  rm -f $BASEDIR/$name/$instance/current
  ln -s versions/$resolved_version/root $BASEDIR/$name/$instance/current

  (
    cd $name/$instance/current
    find bin -type f | xargs chmod +x
  )

  if [ -r $BASEDIR/.app/var/list ]
  then
    sed "/^$name:$instance/d" $BASEDIR/.app/var/list > $BASEDIR/.app/var/list.new
  fi
  echo "$name:$instance:$version" >> $BASEDIR/.app/var/list.new
  mv $BASEDIR/.app/var/list.new $BASEDIR/.app/var/list
}

start_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: $0 start -n name -i instance" >&2
  exit 1
}

stop_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: $0 stop -n name -i instance" >&2
  exit 1
}

# TODO: set ulimit
# TODO: set umask
# TODO: change group newgrp/sg
method_start() {
  run_control start_usage "start" "$@"
}

method_stop() {
  run_control stop_usage "stop" "$@"
}

run_control() {
  local usage=$0; shift
  local method=$1; shift
  local name
  local instance

  while getopts "n:i:" opt
  do
    case $opt in
      n)
        name=$OPTARG
        ;;
      i)
        instance=$OPTARG
        ;;
      \?)
        $usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done

  assert_is_instance $usage "$name" "$instance"

  (
    cd $name/$instance/current

    bin=`get_conf $BASEDIR $name $instance app.method`

    if [ -z "$bin" ]
    then
      bin=$BASEDIR/.app/lib/default-method
    fi

    if [ ! -x "$bin" ]
    then
      echo "Invalid executable: $bin" >&2
      exit 1
    fi

    e="`get_conf_in_group $BASEDIR $name $instance env`"

    # Set a default PATH which can be overridden by the application's settings
    set +e
    env -i \
      PATH=/bin:/usr/bin \
      $e \
      APPSH_METHOD=$method \
      APPSH_BASEDIR=$BASEDIR \
      APPSH_NAME=$name \
      APPSH_INSTANCE=$instance \
      $bin
    local ret=$?
    set +x
    set -e

    case $ret in
      0)
        echo "Application ${method}ed"
        ;;
      *)
        echo "Error starting $name/$instance"
        ;;
    esac
  )
}

list_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: list [-n name] [-P field]" >&2
  echo ""
  echo "List all installed applications" >&2
  echo "  $0 list" >&2
  echo ""
  echo "List all applications in an parseable format:" >&2
  echo "  $0 -P instance -P version -n foo" >&2
  exit 1
}

find_current_version() {
  name=$1
  instance=$2

  if [ ! -L $BASEDIR/$name/$instance/current ]
  then
    return 0
  fi

  (
    cd $BASEDIR/$name/$instance
    ls -l current | sed -n "s,.* current -> versions/\(.*\)/root,\1,p"
  )
}

find_versions() {
  name=$1
  instance=$2

  if [ ! -d $BASEDIR/$name/$instance/versions ]
  then
    return 0
  fi

  (
    cd $BASEDIR/$name/$instance/versions
    ls -1d *
  )
}

list_apps() {
  filter_name=$1
  shift
  vars="$@"

  sort $BASEDIR/.app/var/list | while read line
  do
    echo $line | (IFS=:; while read name instance version junk
    do
      if [ -n "$filter_name" -a "$filter_name" != "$name" ]
      then
        continue
      fi

      local line=""
      IFS=" "; for var in $vars
      do
        case $var in
          name) x=$name;;
          instance) x=$instance;;
          version) x=$version;;
          current_version) x=`find_current_version $name $instance`;;
          *) x="";;
        esac

        if [ -z "$line" ]
        then
          line="$line$x"
        else
          line="$line:$x"
        fi
      done
      echo $line
    done)
  done
}

method_list() {
  local mode="pretty"
  local vars
  local filter_name

  while getopts "P:n:" opt
  do
    case $opt in
      P)
        mode="parseable"
        vars="$vars $OPTARG"
        ;;
      n)
        filter_name=$OPTARG
        ;;
      \?)
        list_usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done
 
  if [ ! -r $BASEDIR/.app/var/list ]
  then
    return
  fi

  if [ $mode = "pretty" ]
  then
    printf "%-20s %-20s %-20s\n" "Name" "Instance" "Version"
    list_apps "$filter_name" name instance version | (IFS=:; while read name instance version
    do
      printf "%-20s %-20s %-20s\n" "$name" "$instance" "$version"
    done)
  else
    list_apps "$filter_name" $vars
  fi
}

list_versions_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: list-versions -n name -i instance [-P]" >&2
  echo "  -P - parseable output" >&2
  exit 1
}

method_list_versions() {
  local name
  local instance
  local version
  local mode="pretty"

  while getopts "n:i:P" opt
  do
    case $opt in
      n)
        name=$OPTARG
        ;;
      i)
        instance=$OPTARG
        ;;
      v)
        version=$OPTARG
        ;;
      P)
        mode="parseable"
        ;;
      \?)
        list_versions_usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done

  assert_is_instance list_versions_usage "$name" "$instance" "no"

  if [ $mode = "pretty" ]
  then
    echo "Available versions for $name/$instance:"
  fi

  find_versions $name $instance

  return 0
}

set_current_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" "$@" >&2
  fi

  echo "usage: set-current -n name -i instance -v version" >&2
  exit 1
}

method_set_current() {
  local name
  local instance
  local version

  while getopts "n:i:v:" opt
  do
    case $opt in
      n)
        name=$OPTARG
        ;;
      i)
        instance=$OPTARG
        ;;
      v)
        version=$OPTARG
        ;;
      \?)
        set_current_usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done

  if [ -z "$version" ]
  then
    echo "Missing required option -v version." >&2
    exit 1
  fi

  assert_is_instance set_current_usage "$name" "$instance" "no"

  if [ ! -d $BASEDIR/$name/$instance/versions/$version ]
  then
    echo "Invalid version: $version."
    exit 1
  fi

  rm -f $BASEDIR/$name/$instance/current
  ln -s versions/$version/root $BASEDIR/$name/$instance/current

  return 0
}

method_usage() {
  echo "usage: $0 <method>" >&2
  echo "" >&2
  echo "Available methods:" >&2
  echo "  conf          - Application configuration management" >&2
  echo "  install       - Installs an application" >&2
  echo "  list          - List all installed applications" >&2
  echo "  list-versions - List all available versions for a single application" >&2
  echo "  set-current   - Set the current version" >&2
  echo "  start         - Starts an applications" >&2
  echo "  stop          - Stops an applications" >&2
  echo "" >&2
  echo "Run '$0 <method>' to get more help" >&2
}

. $BASEDIR/.app/lib/app-conf

main() {
  local method=""
  local first

  while getopts "n:i:" opt
  do
    case $opt in
      n)
        name=$OPTARG
        first="$first -n $name"
        shift
        shift
        OPTIND=1
        ;;
      i)
        instance=$OPTARG
        first="$first -i $instance"
        shift
        shift
        OPTIND=1
        ;;
      \?)
        echo "Invalid option: $OPTARG" 
        ;;
    esac
  done

  method=$1
  shift

  case "$method" in
    conf)          method_conf $first "$@" ;;
    install)       method_install $first "$@" ;;
    list)          method_list $first "$@" ;;
    list-versions) method_list_versions $first "$@" ;;
    set-current)   method_set_current $first "$@" ;;
    start)         method_start $first "$@" ;;
    stop)          method_stop $first "$@" ;;
    *)             method_usage "$@" ;;
  esac
  exit $?
}

main "$@"
