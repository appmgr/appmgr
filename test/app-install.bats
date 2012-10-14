#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "./app app install" {
  zip_app_a
  app app install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/app-a.zip \
    -n app-a -i prod

  echo_lines
  [ $status -eq $exit_usage ]
  [ "$output" = "Creating instance 'prod' for 'app-a'
Unpacking...
Running postinstall...
Hello World!
Postinstall completed successfully
Changing current symlink" ]
  [ ${#lines[*]} == 6 ]
}
