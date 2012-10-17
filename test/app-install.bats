#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

# TODO: Add test for installing duplicate version

@test "./app instance install app-a" {
  mkzip "app-a"
  app instance install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/app-a.zip \
    -n app-a -i prod

  echo_lines
  [ $status -eq 0 ]
  [ "$output" = "Creating instance 'prod' for 'app-a'
Unpacking...
Running postinstall...
Hello World!
Postinstall completed successfully
Changing current symlink" ]
  [ ${#lines[*]} == 6 ]
}

@test "./app instance install install-test-env" {
  mkzip "install-test-env"
  app instance install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/install-test-env.zip \
    -n install-test-env -i prod -v 1.0
  echo_lines
  [ $status -eq 0 ]
  [ "$output" = "Creating instance 'prod' for 'install-test-env'
Unpacking...
Running postinstall...
APPSH_APPS=$APPSH_APPS
APPSH_HOME=$APPSH_HOME
APPSH_INSTANCE=prod
APPSH_NAME=install-test-env
APPSH_VERSION=1.0
PATH=/bin:/usr/bin
PWD=$APPSH_APPS_CANONICAL/install-test-env/prod/versions/1.0
SHLVL=1
_=/usr/bin/env
Postinstall completed successfully
Changing current symlink" ]
  [ ${#lines[*]} == 14 ]
}
