#!/bin/bash

workdir=test-run

# TODO: assert that the exit code is 1 for 'usage' outputs.
exit_usage=0

setup() {
  rm -rf $workdir
}

echo_lines() {
  for line in "${lines[@]}"; do echo $line; done
}

@test "./app" {
  run ./app; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: ./app .*") -ne 0 ]
}

@test "./app foo" {
  run ./app foo; echo_lines
  [ $status -eq $exit_usage ]
  [ "${lines[0]}" = "Error: No such method group: foo" ]
  [ $(expr "${lines[1]}" : "usage: ./app .*") -ne 0 ]
}

@test "./app app" {
  run ./app app; echo_lines
  [ $status -eq $exit_usage ]
  [ $(expr "${lines[0]}" : "usage: ./app app .*") -ne 0 ]
}
