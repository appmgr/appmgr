#!/bin/bash

workdir=test-run

# TODO: assert that the exit code is 1 for 'usage' outputs.
exit_usage=1
exit_usage_wrong=0

echo_lines() {
  for line in "${lines[@]}"; do echo $line; done
}

APPSH=$(pwd)/app

setup() {
  rm -rf $BATS_TMPDIR/app.sh
  mkdir $BATS_TMPDIR/app.sh
  cd $BATS_TMPDIR/app.sh
  ln -s $APPSH
}

app() {
  run ./app "$@"
}
