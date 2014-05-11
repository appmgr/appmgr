#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

install_maven() {
  mkzip "app-a"
  install_artifact
}

install_file() {
  mkzip "app-a"
}

do_test() {
  install="$1"; shift
  init_args="$1"; shift

  $install

  describe "Installing app"
  app init -d my-app/prod $init_args; echo_lines
  eq '$status' 0

  is_directory "my-app/prod/.app"
  cd my-app/prod

  describe "Setting property"
  app conf set env.TEST_PROPERTY awesome; echo_lines
  eq '$status' 0

  describe "Starting"
  app start; echo_lines
  eq '$status' 0
  can_read .app/pid

  describe "Stopping"
  app stop
  eq '$status' 0
  echo_lines
  can_not_read .app/pid

  can_read "logs/app-a.log"
  can_read "logs/app-a.env"
  [ "`cat logs/app-a.env`" = "TEST_PROPERTY=awesome" ]

  can_read "current/foo.conf"
  [ "`cat current/foo.conf`" = "hello" ]

  app conf get mark.pre-install
  eq '${lines[0]}' "done"

  app conf get mark.post-install
  eq '${lines[0]}' "done"
}

@test "install+upgrade; resolver=maven" {
#  do_test install_maven "maven -r $REPO_URL org.example:app-a:1.0-SNAPSHOT"
}

@test "install+upgrade; resolver=file" {
  do_test install_file "file $APPSH_HOME/test/data/app-a.zip"
}
