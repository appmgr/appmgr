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
  rm -rf $BATS_TMPDIR/app.sh
  mkdir $BATS_TMPDIR/app.sh
  cd $BATS_TMPDIR/app.sh
  ln -s $APPSH
  WORK=$(cd -P $BATS_TMPDIR/app.sh; pwd)
}

mkzip() {
(
  cd $BATS_TEST_DIRNAME/data/$1
  rm -f ../$1.zip
  zip -qr ../$1.zip *
)
}

app() {
  run ./app "$@"
}
