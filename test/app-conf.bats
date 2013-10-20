#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

setup_inner() {
  mkdir .app;
  echo > .app/config
  export APPSH_DEFAULT_CONFIG=/dev/null
}

@test "./app conf - happy day" {
  app conf; echo_lines
  echo "app.bin=bin/app-a" > .app/config
  eq '$status' 0
  eq '${#lines[*]}' 0

  app conf set g.FOO bar; echo_lines
  eq '$status' 0

  app conf; echo_lines
  eq '$status' 0
  eq '${lines[0]}' "app.bin              bin/app-a           " 
  eq '${lines[1]}' "g.FOO                bar                 " 
  eq '${#lines[*]}' 2

  app conf get g.FOO; echo_lines
  eq '$status' 0
  eq '${lines[0]}' "bar" 
  eq '${#lines[*]}' 1

  app conf get g.foo; echo_lines
  eq '$status' 0
  eq '${#lines[*]}' 0

  app conf delete g.FOO; echo_lines
  eq '$status' 0

  app conf; echo_lines
  eq '$status' 0
  eq '${lines[0]}' "app.bin              bin/app-a           " 
  eq '${#lines[*]}' 1
}

@test "./app conf - defaults to 'list'" {
  echo "app.bin=bin/app-a" > .app/config

  app conf; echo_lines
  eq '$status' 0
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "app.bin              bin/app-a           " 
}

@test "./app conf wat" {
  app conf wat; echo_lines
  eq '$status' 1
  eq '${lines[0]}' "Unknown command: wat" 
}

@test "./app conf list" {
  echo "app.bin=bin/app-a" > .app/config

  app conf; echo_lines
  eq '$status' 0
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "app.bin              bin/app-a           " 

  app conf list; echo_lines
  eq '$status' 0
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "app.bin              bin/app-a           " 

  app conf list foo; echo_lines
  eq '$status' 1
}

#@test "./app conf list-group" {
#  app conf set mygroup a 1
#  eq '$status' 0
#  app conf set mygroup b 1
#  eq '$status' 0
#  app conf set mygroup c 2
#  eq '$status' 0
#  app conf set othergroup a 1
#  eq '$status' 0
#
#  app conf list; echo_lines
#  eq '$status' 0
#  app conf list-group mygroup; echo_lines
#  eq '$status' 0
#  eq '${lines[0]}' "mygroup.a            1                   " 
#  eq '${lines[1]}' "mygroup.b            1                   " 
#  eq '${lines[2]}' "mygroup.c            2                   " 
#  eq '${#lines[*]}' 3
#}

@test "./app conf set" {
  echo "app.bin=bin/app-a" > .app/config

  app conf set group; echo_lines
  eq '$status' 1

  app conf set group.foo; echo_lines
  eq '$status' 1

  app conf set group.foo bar; echo_lines
  eq '$status' 0
  eq '${#lines[*]}' 0

  app conf; echo_lines
  eq '$status' 0
  eq '${lines[0]}' "app.bin              bin/app-a           " 
  eq '${lines[1]}' "group.foo            bar                 " 
  eq '${#lines[*]}' 2
}

@test "./app conf list - with duplicate entries" {
  echo "foo.bar=awesome" > .app/config
  echo "foo.bar=awesome" >> .app/config

  app conf list; echo_lines
  eq '$status' 0
  eq '${lines[0]}' "foo.bar              awesome             " 
  eq '${#lines[*]}' 1
}

@test "./app conf import" {
  echo "foo.bar=1" > .app/config
  echo "foo.baz=1" > config-b
  echo "foo.bar=2" >> config-b

  app conf import config-b; echo_lines
  eq '$status' 0
  eq '${lines[0]}' "Importing config from config-b" 
  eq '${#lines[*]}' 1

  app_libexec app-cat-conf
  eq '${lines[0]}' "foo.bar=2" 
  eq '${lines[1]}' "foo.baz=1" 
  eq '${#lines[*]}' 2
}
