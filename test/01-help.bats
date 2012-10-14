#!/usr/bin/env bats
# vim: set filetype=sh :

load utils

@test "./app" {
  app; echo_lines
  [ $status -eq $exit_usage_wrong ]
  [ $(expr "${lines[0]}" : "usage: ./app .*") -ne 0 ]
}

@test "./app foo" {
  app foo; echo_lines
  [ $status -eq $exit_usage_wrong ]
  [ "${lines[0]}" = "Error: No such method group: foo" ]
  [ $(expr "${lines[1]}" : "usage: ./app .*") -ne 0 ]
}
