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
  usage=$1
  name=$2
  instance=$3

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

  if [ ! -e $name/$instance/current ]
  then
    echo "Missing 'current' link." >&2
    exit 1
  fi

}

install_usage() {
  if [ -n "$1" ]
  then
    echo "Error:" $@ >&2
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
  else
    zip_file=$file

    if [ -z "$version" ]
    then
      resolved_version=`TZ=UTC date +"%Y%m%d-%H%M%S"`
    else
      resolved_version=$version
    fi
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

  download_artifact

  mkdir -p $name/$instance/versions/$resolved_version

  echo "Unpacking..."
  unzip -q -d $name/$instance/versions/$resolved_version $zip_file

  (
    cd $name/$instance/versions/$resolved_version
    find scripts | xargs chmod +x

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
  rm -f $name/$instance/current
  ln -s versions/$resolved_version/root $name/$instance/current

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
    echo "Error:" $@ >&2
  fi

  echo "usage: $0 start -n name -i instance" >&2
  exit 1
}

# TODO: set ulimit
# TODO: set umask
# TODO: change group newgrp/sg
method_start() {
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
        start_usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done

  assert_is_instance start_usage "$name" "$instance"

  (
    cd $name/$instance/current

    bin=`get_conf app.start`

    if [ -z "$bin" ]
    then
      bin=`find bin -type f`

      if [ ! -x "$bin" ]
      then
        echo "No app.start configured, couldn't detect an executable file to execute." >&2
        exit 1
      fi
    elif [ ! -x "$bin" ]
    then
      echo "Invalid executable: $bin" >&2
      exit 1
    fi

    e=`get_conf_in_group env`

    env -i $e \
      $bin &
    set -x
    PID=$!
    echo $PID > $BASEDIR/.app/var/pid/$name-$instance.pid
  )
}

method_stop() {
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
        start_usage "Invalid option: -$OPTARG" 
        ;;
    esac
  done

  assert_is_instance stop_usage "$name" "$instance"

  (
    cd $name/$instance/current

    bin=`get_conf app.stop`

    if [ -z "$bin" ]
    then
      PID=`cat $BASEDIR/.app/var/pid/$name-$instance.pid`
      echo "Sending TERM to $PID"
      bin="kill $PID"
    elif [ ! -x "$bin" ]
    then
      echo "Invalid executable: $bin" >&2
      exit 1
    fi

    e=`get_conf_in_group env`

    env -i $e \
      PID=$PID \
      $bin &
  )
}


method_list() {
  local mode="pretty"

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
        install_usage "Invalid option: -$OPTARG" 
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
  fi

  sort $BASEDIR/.app/var/list | while read line
  do
    echo $line | (IFS=:; while read name instance version
    do
      if [ "$filter_name" != "" -a "$filter_name" != "$name" ]
      then
        continue
      fi

      if [ $mode = "pretty" ]
      then
        printf "%-20s %-20s %-20s\n" "$name" "$instance" "$version"
      else
        line=""
        IFS=" "; for var in $vars
        do
          eval v=\$$var
          if [ -z "$line" ]
          then
            line="$line$v"
          else
            line="$line:$v"
          fi
        done
        echo $line
      fi
    done)
  done
}

method_usage() {
  echo "usage: $0 <method>" >&2
  echo "" >&2
  echo "Available methods:" >&2
  echo "  install - Installs an application" >&2
  echo "  list    - List all installed applications" >&2
  echo "  start   - Starts an applications" >&2
  echo "  stop    - Stops an applications" >&2
  echo "  conf    - Application configuration management" >&2
  echo "" >&2
  echo "Run '$0 <method>' to get more help" >&2
}

. $BASEDIR/.app/lib/app-conf

if [ $# -gt 0 ]
then
  method=$1
  shift
fi

case "$method" in
  install)
    method_install $@
    ;;
  start)
    method_start $@
    ;;
  stop)
    method_stop $@
    ;;
  list)
    method_list $@
    ;;
  conf)
    method_conf $@
    ;;
  *)
    method_usage $@
    ;;
esac
exit $?
