#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "install remove roundtrip" {
  mkzip "app-a"
  name="app-a"
  instance="prod"
  a="-n $name -i $instance"

  describe "Installing $name/$instance"
  app instance install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/app-a.zip \
    -n $name -i $instance

#  set -x
  can_not_read ".app/var/pid/$name-$instance.pid"

  describe "Starting $name/$instance"
  app -n $name -i $instance operate start
  echo_lines
  can_read .app/var/pid/$name-$instance.pid

  describe "Stopping $name/$instance"
  app -n $name -i $instance operate stop
  echo_lines
  can_not_read .app/var/pid/$name-$instance.pid

#  app instance install \
#    -r file \
#    -u $HOME/.m2/repository/io/trygvis/appsh/examples/jenkins/1.0-SNAPSHOT/jenkins-1.0-SNAPSHOT.zip \
#    -n jenkins -i env-a
}
