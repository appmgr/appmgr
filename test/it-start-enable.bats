#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "start/stop, enable/disable" {
  mkzip "app-a"

  app init -d my-app/a file $APPSH_HOME/test/data/app-a.zip; echo_lines
  cd my-app/a

  # Start the application
  app start

  app disable

  # Disable will not stop the process
  check_status=no; app status
  eq '$status' 2

  # This will fail "the app is disabled"
  check_status=no; app start
  eq '$status' 1

  # This will fail "the app is disabled"
  check_status=no; app restart
  eq '$status' 1

  # Even if disabled, it can be stopped again
  app stop

  # After enabling it again, it can be started
  app enable

  app start

  check_status=no; app status
  eq '$status' 2

  app stop

  app disable
}
