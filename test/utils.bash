#!/bin/bash

workdir=test-run

# TODO: assert that the exit code is 1 for 'usage' outputs.
exit_usage=1
exit_usage_wrong=0

echo_lines() {
  for line in "${lines[@]}"; do echo $line; done
  echo status=$status
}

APPSH=$(pwd)/app

setup() {
  APPSH_APPS=$BATS_TMPDIR/app.sh
  APPSH_HOME=$(cd $BATS_TEST_DIRNAME/../..; echo `pwd`/app.sh)
  APPSH_APPS_CANONICAL=$(cd -P $APPSH_APPS; pwd)
  rm -rf $BATS_TMPDIR/app.sh
  mkdir $BATS_TMPDIR/app.sh
  cd $BATS_TMPDIR/app.sh
  ln -s $APPSH
}

mkzip() {
(
  cd $BATS_TEST_DIRNAME/data/$1
  rm -f ../$1.zip
  zip -qr ../$1.zip *
)
}

app() {
  echo ./app $@
  run ./app $@
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
