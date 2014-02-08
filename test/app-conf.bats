#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

setup_inner() {
  mkdir .app;
  echo > .app/config
  export APPSH_DEFAULT_CONFIG=/dev/null
}

@test "./app conf - happy day" {
  app conf
  echo "app.bin=bin/app-a" > .app/config
  eq '$status' 0
  eq '${#lines[*]}' 0

  app conf set g.FOO bar

  app conf
  eq '${lines[0]}' "app.bin              bin/app-a"
  eq '${lines[1]}' "g.FOO                bar"
  eq '${#lines[*]}' 2

  app conf get g.FOO
  eq '${lines[0]}' "bar"
  eq '${#lines[*]}' 1

  app conf get g.foo
  eq '${#lines[*]}' 0

  app conf delete g.FOO
  eq '${#lines[*]}' 0

  app conf
  eq '${lines[0]}' "app.bin              bin/app-a"
  eq '${#lines[*]}' 1
}

@test "./app conf - defaults to 'list'" {
  echo "app.bin=bin/app-a" > .app/config

  app conf
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "app.bin              bin/app-a"
}

@test "./app conf wat" {
  check_status=no
  app conf wat
  eq '${lines[0]}' "Unknown command: wat"
}

@test "./app conf list" {
  echo "app.bin=bin/app-a" > .app/config

  app conf
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "app.bin              bin/app-a"

  app conf list
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "app.bin              bin/app-a"

  check_status=no
  app conf list foo
  eq '$status' 1
}

@test "./app conf list - with duplicate entries" {
  echo "foo.bar=awesome" > .app/config
  echo "foo.bar=awesome" >> .app/config

  app conf list
  eq '${lines[0]}' "foo.bar              awesome"
  eq '${#lines[*]}' 1
}

@test "./app conf list in non-app dir" {
  mkdir wat
  cd wat
  app conf list
  eq '${#lines[*]}' 0
}

@test "./app conf set" {
  echo "app.bin=bin/app-a" > .app/config

  check_status=no
  app conf set group
  eq '$status' 1

  check_status=no
  app conf set group.foo
  eq '$status' 1

  check_status=no
  app conf set group.foo.wat bar
  eq '$status' 1

  app conf set group.foo bar
  eq '${#lines[*]}' 0

  app conf
  eq '${lines[0]}' "app.bin              bin/app-a"
  eq '${lines[1]}' "group.foo            bar"
  eq '${#lines[*]}' 2
}

@test "./app conf set -f" {
  echo "" > .app/config

  app conf set -f myconfig group.foo bar
  eq '${#lines[*]}' 0

  app_libexec app-cat-conf -f myconfig
  eq '${lines[0]}' "group.foo=bar"
  eq '${#lines[*]}' 1

  run cat .app/config
  eq '$status' 0
  eq '${#lines[*]}' 0

  run cat myconfig
  eq '$status' 0
  eq '${lines[0]}' "group.foo=bar"
  eq '${#lines[*]}' 1
}

@test "./app conf set - values with '=' and spaces" {
  echo > .app/config
  app conf set app.env "JAVA_OPTS=-Xmx1G -Dawesome=true"
  app_libexec app-cat-conf
  eq '${lines[0]}' "app.env=JAVA_OPTS=-Xmx1G -Dawesome=true"
  eq '${#lines[*]}' 1
  app conf get app.env
  eq '${lines[0]}' "JAVA_OPTS=-Xmx1G -Dawesome=true"
  eq '${#lines[*]}' 1
}

@test "./app conf -l app set" {
  echo > .app/config
  app conf -l app set a.x 2
  app_libexec app-cat-conf
  eq '${lines[0]}' "a.x=2"
  eq '${#lines[*]}' 1
}

@test "./app conf -l user set" {
  echo > .app/config
  app conf -l user set a.x 3
  app_libexec app-cat-conf -l user
  eq '${lines[0]}' "a.x=3"
  eq '${#lines[*]}' 1
}

@test "./app conf import" {
  echo "foo.bar=1" > .app/config
  echo "foo.baz=1" > config-b
  echo "foo.bar=2" >> config-b

  app conf import config-b
  eq '${lines[0]}' "Importing config from config-b"
  eq '${#lines[*]}' 1

  app_libexec app-cat-conf
  eq '${lines[0]}' "foo.bar=2"
  eq '${lines[1]}' "foo.baz=1"
  eq '${#lines[*]}' 2
}
