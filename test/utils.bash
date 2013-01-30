#!/bin/bash

workdir=test-run

# TODO: assert that the exit code is 1 for 'usage' outputs.
exit_usage=1
exit_usage_wrong=0

setup() {
  find test/data -name \*.zip | xargs rm -f
  PATH=/bin:/usr/bin
  PATH=$PATH:$APPSH_HOME
  APPSH_HOME=$(cd $BATS_TEST_DIRNAME/..; echo `pwd`)

  rm -rf $BATS_TMPDIR/app.sh
  mkdir $BATS_TMPDIR/app.sh
  cd $BATS_TMPDIR/app.sh

  REPO=$BATS_TMPDIR/repo
  REPO_URL="file://$REPO"

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
(
  cd $BATS_TEST_DIRNAME/data/$1
  rm -f ../$1.zip
  zip -qr ../$1.zip *
)
}

install_artifact() {
  if [ ! -f $REPO/org/example/app-a/1.0-SNAPSHOT/maven-metadata.xml ]
  then
    mvn deploy:deploy-file -Durl=$REPO_URL \
      -Dfile=`echo $APPSH_HOME/test/data/app-a.zip` -DgeneratePom \
      -DgroupId=org.example -DartifactId=app-a -Dversion=1.0-SNAPSHOT -Dpackaging=zip
  fi
}

app() {
  echo app $@
  run $APPSH_HOME/app $@
}

app_libexec() {
  local x=`PATH=$APPSH_HOME/libexec:/bin:/usr/bin which $1`

  echo libexec/$@
  shift
  run "$x" $@
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

match() {
  local ex="$1"
  local regex="$2"
  local a="`eval echo $ex`"

  if [[ $a =~ $regex ]]
  then
	return 0
  fi

  echo "Assertion failed: $ex =~ $a"
  echo "Expected: $e"
  echo "Actual:   $a"
  exit 1
}
