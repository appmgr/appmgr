#!/bin/bash

workdir=test-run

# TODO: assert that the exit code is 1 for 'usage' outputs.
exit_usage=1
exit_usage_wrong=0

setup() {
  find test/data -name \*.zip | xargs rm -f
  APPSH_HOME=$(cd $BATS_TEST_DIRNAME/..; echo `pwd`)
  ORIG_PATH=$PATH
  PATH=/bin:/usr/bin:/usr/local/bin
  PATH=$PATH:$APPSH_HOME

  rm -rf $BATS_TMPDIR/app.sh
  mkdir $BATS_TMPDIR/app.sh

  HOME=$BATS_TMPDIR/app.sh-home
  rm -rf $HOME
  cp -rp test/data/user-home $HOME
  rm -f $HOME/.appconfig

  cd $BATS_TMPDIR/app.sh

  REPO=$BATS_TMPDIR/repo
  REPO_URL="file://$REPO"
  FIXED_REPO_URL="file://`fix_path $REPO`"

  if [ "`declare -f setup_inner >/dev/null; echo $?`" = 0 ]
  then
    setup_inner
  fi
}

echo_lines() {
  echo lines:
  for line in "${lines[@]}"; do echo $line; done
  echo status=$status
}

mkzip() {
  local name=$1; shift
  pushd .
  cd $BATS_TEST_DIRNAME/data/$name
  rm -f ../$name.zip
  zip -qr ../$name.zip *
  popd
}

install_artifact() {
  local version=${1-1.0-SNAPSHOT}
  local v
  local groupId=org.example
  local artifactId=app-a

  if [[ ${version} =~ '-SNAPSHOT' ]]
  then
    local now=$(date +%Y%m%d.%H%M%S)
    local cnt=`ls $p/*.zip 2>/dev/null|wc -l`
    local build_number=$((cnt+1))
    v=${version%%-SNAPSHOT}-$now-$build_number
  else
    v=$version
  fi

  local p=$REPO/${groupId/./\//}/${artifactId}
  local pv=$p/$version

  mkdir -p $pv
  cp "$APPSH_HOME/test/data/app-a.zip" "$pv/app-a-$v.zip"
  if [[ $OSTYPE = darwin* ]]; then
    /sbin/md5 -r "$pv/app-a-$v.zip" > "$pv/app-a-$v.zip.md5"
  else
    md5sum "$pv/app-a-$v.zip" > "$pv/app-a-$v.zip.md5"
  fi

  cat > $pv/maven-metadata.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<metadata modelVersion="1.1.0">
  <groupId>${groupId}</groupId>
  <artifactId>${artifactId}</artifactId>
  <version>${version}</version>
  <versioning>
    <snapshot>
      <timestamp>${now}</timestamp>
      <buildNumber>${build_number}</buildNumber>
    </snapshot>
<!-- app.sh doesn't need this part
    <lastUpdated>20140610193134</lastUpdated>
-->
<!-- app.sh doesn't need this part
    <snapshotVersions>
      <snapshotVersion>
        <extension>zip</extension>
        <value>1.0-20140610.193134-2</value>
        <updated>20140610193134</updated>
      </snapshotVersion>
      <snapshotVersion>
        <extension>pom</extension>
        <value>1.0-20140610.193134-2</value>
        <updated>20140610193134</updated>
      </snapshotVersion>
    </snapshotVersions>
-->
  </versioning>
</metadata>
EOF
}

check_status=yes

app() {
  echo app $@
  run $APPSH_HOME/app "$@"
  echo_lines

  if [ "$check_status" = yes ]
  then
    eq '$status' 0
  fi

  check_status=yes
}

app_libexec() {
  local x=`PATH=$APPSH_HOME/libexec:/bin:/usr/bin which $1`

  echo libexec/$@
  shift
  run "$x" "$@"

  echo_lines

  if [ "$check_status" = yes ]
  then
    eq '$status' 0
  fi

  check_status=yes
}

fix_path_uname=`uname -s`
fix_path() {
  case $fix_path_uname in
    CYGWIN_NT*)
      cygpath -wa $1
      ;;
    *)
      echo $1
      ;;
  esac
}

describe() {
  echo "# " $@ >&3
}

can_read() {
  if [ -r "$1" ]
  then
    return 0
  else
    echo "Can't read $1"
    return 1
  fi
}

can_not_read() {
  if [ ! -r "$1" ]
  then
    return 0
  else
    echo "Can read $1"
    return 1
  fi
}

is_directory() {
  if [ ! -d "$1" ]
  then
    echo "Not a directory: $1" 2>&1
    return 1
  fi
}

touch_time() {
  if [[ $OSTYPE = darwin* ]]; then
    FORMAT=$(date -j -r $1 +%Y%m%d%H%M.%S)
    touch -t $FORMAT $2
  else
    touch -d "@$1" $2
  fi
}

eq() {
  local ex="$1"
  local e="$2"
  local a="`eval echo $ex`"

  if [[ $e == $a ]]
  then
    return 0
  fi

  echo "Assertion failed: $ex"
  echo "Expected: $e"
  echo "Actual:   $a"
  exit 1
}

neq() {
  local ex="$1"
  local e="$2"
  local a="`eval echo $ex`"

  if [[ $e != $a ]]
  then
    return 0
  fi

  echo "Not-equal assertion failed: $ex"
  echo "Expected: $e"
  echo "Actual:   $a"
  exit 1
}

match() {
  local ex="$1"
  local regex="$2"
  local a="`eval echo $ex`"

  if [[ $a =~ $regex ]]
  then
    return 0
  fi

  echo "Match failed: $ex =~ $regex"
  echo "Value:    $a"
  exit 1
}
