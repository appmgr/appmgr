#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "app-operate" {
  mkzip app-a

  app init -d my-app file $APPSH_HOME/test/data/app-a.zip

  cd my-app
  check_status=no
  app status
  eq    '$status' 3
  eq    '${lines[0]}' "Not running"
  eq    '${#lines[*]}' 1

  app start
  pid=`cat .app/pid`
  match '${lines[0]}' "Application launched as $pid"
  eq    '${#lines[*]}' 1

  app stop
  match '${lines[0]}' "Sending TERM to $pid, waiting for shutdown.*"
  eq    '${#lines[*]}' 1

  echo wat > .app/pid
  check_status=no
  app stop
  eq '$status' 1
  match '${lines[0]}' "The application crashed. Was running as wat"
  eq    '${#lines[*]}' 1
}
