#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

setup_inner() {
  export APPMGR_DEFAULT_CONFIG=/dev/null
  cd $APPMGR_HOME/test/data/app-cat-conf
}

@test "app-cat-conf" {
  app_libexec app-cat-conf -f config-1
  eq '${lines[0]}' "baz.kiz=zap"
  eq '${lines[1]}' "baz.wat=baz"
  eq '${lines[2]}' "foo.bar=wat"
  eq '${lines[3]}' "foo.baz=kaz"
  eq '${lines[4]}' "foo.wat=foo"
  eq '${#lines[*]}' 5
}

@test "app-cat-conf -k baz.wat" {
  app_libexec app-cat-conf -f config-1 -k baz.wat
  eq '${lines[0]}' "baz.wat=baz"
  eq '${#lines[*]}' 1
}

@test "app-cat-conf -g baz" {
  app_libexec app-cat-conf -f config-1 -g baz
  eq '${lines[0]}' "baz.kiz=zap"
  eq '${lines[1]}' "baz.wat=baz"
  eq '${#lines[*]}' 2
}

@test "app-cat-conf can use stdin and multiple files" {
  x=$(cat config-3 | \
  $APPMGR_HOME/libexec/app-cat-conf -D -f - -f config-2)
  [[ $x == "foo.bar=wat
foo.wat=bar" ]]
}

@test "app-cat-conf read multiple files, last file wins" {
  app_libexec app-cat-conf \
    -f config-2 \
    -f config-4
  eq '${lines[0]}' "foo.bar=foo"
  eq '${#lines[*]}' 1
}

@test "uses \$APPMGR_DEFAULT_CONFIG" {
  APPMGR_DEFAULT_CONFIG=`pwd`/config-2
  app_libexec app-cat-conf -f /dev/null
  eq '${lines[0]}' "foo.bar=wat"
  eq '${#lines[*]}' 1
}

@test "uses \$APPMGR_DEFAULT_CONFIG, with lowest priority" {
  app_libexec app-cat-conf -f config-3
  eq '${lines[0]}' "foo.bar=baz"
  eq '${lines[1]}' "foo.wat=bar"
  eq '${#lines[*]}' 2
}

@test "app-cat-conf - read installation's and user's config when outside app" {
  HOME=`pwd`/home
  APPMGR_DEFAULT_CONFIG=config-2
  app_libexec app-cat-conf
  eq '${lines[0]}' "foo.bar=1"
  eq '${lines[1]}' "foo.foo=2"
  eq '${#lines[*]}' 2
}

@test "app-cat-conf - read \$HOME/.appconfig and .app/config when inside app" {
  HOME=`pwd`/home
  APPMGR_DEFAULT_CONFIG=`pwd`/config-2
  cd my-app
  app_libexec app-cat-conf
  eq '${lines[0]}' "foo.bar=2"
  eq '${lines[1]}' "foo.baz=3"
  eq '${lines[2]}' "foo.foo=2"
  eq '${#lines[*]}' 3
}

@test "app-cat-conf -l u - read only \$HOME/.appconfig even when in an app" {
  HOME=$APPMGR_HOME/test/data/app-cat-conf/home
  cd my-app
  app_libexec app-cat-conf -l u
  eq '${lines[0]}' "foo.bar=1"
  eq '${lines[1]}' "foo.foo=2"
  eq '${#lines[*]}' 2
}

@test "app-cat-conf; extra arguments" {
  check_status=no
  app_libexec app-cat-conf zoot
  eq '$status' 1
  eq '${#lines[*]}' 1
}
