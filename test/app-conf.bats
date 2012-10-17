#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "./app conf - happy day" {
  i=env-a
  n=app-a

  mkzip "app-a"
  app instance install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n $n -i $i -v 1.0
  [ $status -eq 0 ]

  app -n $n -i $i conf; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "app.bin              bin/app-a           " ]

  app -n $n -i $i conf set group.foo bar; echo_lines
  [ $status -eq 0 ]

  app -n $n -i $i conf; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "app.bin              bin/app-a           
group.foo            bar                 " ]

  app -n $n -i $i conf delete group.foo; echo_lines
  [ $status -eq 0 ]

  app -n $n -i $i conf; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "app.bin              bin/app-a           " ]
}

@test "./app conf list" {
  i=env-a
  n=app-a

  mkzip "app-a"
  app instance install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n $n -i $i -v 1.0
  [ $status -eq 0 ]

  app -n $n -i $i conf; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "app.bin              bin/app-a           " ]

  app -n $n -i $i conf list; echo_lines
  [ $status -eq 0 ]
  [ "$output" = "app.bin              bin/app-a           " ]

  app -n $n -i $i conf list foo; echo_lines
  [ $status -eq 1 ]
}

@test "./app conf set" {
  i=env-a
  n=app-a

  mkzip "app-a"
  app instance install -r file -u $BATS_TEST_DIRNAME/data/app-a.zip -n $n -i $i -v 1.0
  [ $status -eq 0 ]

  app -n $n -i $i conf set group; echo_lines
  [ $status -eq 1 ]

  app -n $n -i $i conf set group.foo; echo_lines
  [ $status -eq 1 ]

  app -n $n -i $i conf set group.foo bar; echo_lines
  [ $status -eq 0 ]
}
