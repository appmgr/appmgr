#!/usr/bin/env bats
# vim: set filetype=sh :

load utils

@test "./app app" {
  app app; echo_lines
  [ $status -eq $exit_usage_wrong ]
  [ $(expr "${lines[0]}" : "usage: ./app app .*") -ne 0 ]
  [ ${#lines[*]} == 6 ]
}

@test "./app app install" {
  app app install; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: install .*") -ne 0 ]
  [ ${#lines[*]} == 6 ]
}

@test "./app app list" {
  app app list; echo_lines
  [ $status -eq 0 ]
  [ ${#lines[*]} == 0 ]
}

@test "./app app list-versions" {
  app app list-versions; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: list-versions .*") -ne 0 ]
  [ ${#lines[*]} == 2 ]
}

@test "./app app set-current" {
  app app "set-current"; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: set-current .*") -ne 0 ]
  [ ${#lines[*]} == 1 ]
}
