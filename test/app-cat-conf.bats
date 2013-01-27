#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

setup_inner() {
  export APPSH_DEFAULT_CONFIG=/dev/null
}

@test "app-cat-conf" {
  app_libexec app-cat-conf -f $APPSH_HOME/test/data/app-cat-conf/config-1
  echo_lines
  eq '${lines[0]}' "baz.kiz=zap"
  eq '${lines[1]}' "baz.wat=baz"
  eq '${lines[2]}' "foo.bar=wat"
  eq '${lines[3]}' "foo.baz=kaz"
  eq '${lines[4]}' "foo.wat=foo"
  eq '${#lines[*]}' 5
}

@test "app-cat-conf -g baz" {
  app_libexec app-cat-conf -f $APPSH_HOME/test/data/app-cat-conf/config-1 -n "baz\..*"
  echo_lines
  eq '${lines[0]}' "baz.kiz=zap"
  eq '${lines[1]}' "baz.wat=baz"
  eq '${#lines[*]}' 2
}

@test "app-cat-conf -k wat" {
  app_libexec app-cat-conf -f $APPSH_HOME/test/data/app-cat-conf/config-1 -n ".*\.wat"
  echo_lines
  eq '${lines[0]}' "baz.wat=baz"
  eq '${lines[1]}' "foo.wat=foo"
  eq '${#lines[*]}' 2
}

@test "app-cat-conf -g baz -k wat" {
  app_libexec app-cat-conf -f $APPSH_HOME/test/data/app-cat-conf/config-1 -n "baz\.wat"
  echo_lines
  eq '${lines[0]}' "baz.wat=baz"
  eq '${#lines[*]}' 1
}

@test "app-cat-conf can use stdin and multiple files" {
  x=$(cat $APPSH_HOME/test/data/app-cat-conf/config-3 | \
  $APPSH_HOME/libexec/app-cat-conf -D -f $APPSH_HOME/test/data/app-cat-conf/config-2 -f -)
  [[ $x == "foo.bar=wat
foo.wat=bar" ]]
}

@test "uses \$APPSH_DEFAULT_CONFIG" {
  APPSH_DEFAULT_CONFIG=$APPSH_HOME/test/data/app-cat-conf/config-2
  app_libexec app-cat-conf -f /dev/null
  echo_lines
  eq '${lines[0]}' "foo.bar=wat"
  eq '${#lines[*]}' 1

  app_libexec app-cat-conf -f $APPSH_HOME/test/data/app-cat-conf/config-3
  echo_lines
  eq '${lines[0]}' "foo.bar=baz"
  eq '${lines[1]}' "foo.wat=bar"
  eq '${#lines[*]}' 2
}
