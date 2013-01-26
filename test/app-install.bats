#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

# TODO: Add test for installing duplicate version

@test "./app install app-a" {
  mkzip "app-a"
  app install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/app-a.zip

  echo_lines
  [ $status -eq 0 ]
  [ "$output" = "Creating instance 'prod' for 'app-a'
Unpacking...
Changing current symlink
Running postinstall...
Hello World!
Creating logs directory
Postinstall completed successfully" ]
  [ ${#lines[*]} == 7 ]
}

@test "./app instance install install-test-env" {
  mkzip "install-test-env"
  app instance install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/install-test-env.zip \
    -v 1.0
  echo_lines
  [ $status -eq 0 ]
  [ "$output" = "Creating instance 'prod' for 'install-test-env'
Unpacking...
Changing current symlink
Running postinstall...
APPSH_APPS=$APPSH_APPS
APPSH_HOME=$APPSH_HOME
APPSH_INSTANCE=prod
APPSH_NAME=install-test-env
APPSH_VERSION=1.0
PATH=/bin:/usr/bin
PWD=$APPSH_APPS_CANONICAL/install-test-env/prod/versions/1.0/root
SHLVL=1
_=/usr/bin/env
Postinstall completed successfully" ]
  [ ${#lines[*]} == 14 ]
# PWD=$APPSH_APPS_CANONICAL/install-test-env/prod/versions/1.0
}
