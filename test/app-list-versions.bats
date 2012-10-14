#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "./app app list-versions" {
  mkzip "app-a"
  app app install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n app-a -i env-a -v 1.0 &&
  app app install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n app-a -i env-a -v 1.1 &&
  app app install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n app-a -i env-b -v 1.0 &&
  app app install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n app-b -i env-a -v 1.0 &&
  app app install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n app-b -i env-b -v 1.0 &&
  [ $status -eq 0 ]

  app app list-versions -n app-a -i env-a; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "Available versions for app-a/env-a:
1.0
1.1" ]

  app app list-versions -n app-a -i env-a -P; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "1.0
1.1" ]
}
