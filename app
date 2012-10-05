#!/bin/bash

set -e

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
  mkdir -p downloads
  metadata=downloads/$groupId-$artifactId-$version-metadata.xml
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
  zip_file=downloads/$groupId-$artifactId-$resolved_version.zip
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

get_config() {
  key=$1

  file=$name/$instance/latest/etc/app.conf
  value=`sed -n "s,^${key}[ ]*=[ ]*\(.*\)$,\1,p" $file`
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

  echo "Changing latest symlink"
  rm -f $name/$instance/latest
  ln -s versions/$resolved_version/root $name/$instance/latest

  (
    cd $name/$instance/latest
    find bin | xargs chmod +x
  )

  if [ -r apps.list ]
  then
    sed "/^$name:$instance/d" apps.list > apps.list.new
  fi
  echo "$name:$instance:$version" >> apps.list.new
  mv apps.list.new apps.list
}

method_start() {
# TODO: set ulimit, newgrp/sg
  (
    cd $name/$instance/latest
    find bin | xargs chmod +x
  )
}

method_list() {
  printf "%20s %20s %20s\n" "instance" "name" "version"
 
  if [ ! -r apps.list ]
  then
    return
  fi

  cat apps.list | (export IFS=:; while read instance name version
  do
    printf "%20s %20s %20s\n" "$instance" "$name" "$version"
  done)
}

method_list_config() {
  name=$1
  instance=$2
  default=$3

  conf=$name/$instance/etc/app.conf

  if [ ! -r $conf ]
  then
    echo $default
  fi

  get_value port
}

method_usage() {
  echo "usage: $0 <method>" >&2
  echo "" >&2
  echo "Available methods:" >&2
  echo "  install - Installs an application" >&2
  echo "  list    - List all installed applications" >&2
  echo "" >&2
  echo "Run '$0 <method>' to get more help" >&2
}

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
  list)
    method_list $@
    ;;
  list-config)
    method_list_config $@
    ;;
  *)
    method_usage $@
    ;;
esac
exit $?
