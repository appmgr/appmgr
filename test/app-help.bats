#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "./app instance" {
  app instance; echo_lines
  [ $status -eq $exit_usage_wrong ]
  [ $(expr "${lines[0]}" : "usage: ./app instance .*") -ne 0 ]
  [ ${#lines[*]} == 6 ]
}

@test "./app instance install" {
  app instance install; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: install .*") -ne 0 ]
  [ ${#lines[*]} == 6 ]
}

@test "./app instance list" {
  app instance list; echo_lines
  [ $status -eq 0 ]
  [ ${#lines[*]} == 0 ]
}

@test "./app instance list-versions" {
  app instance list-versions; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: list-versions .*") -ne 0 ]
  [ ${#lines[*]} == 1 ]
}

@test "./app instance set-current" {
  app instance "set-current"; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: set-current .*") -ne 0 ]
  [ ${#lines[*]} == 1 ]
}
