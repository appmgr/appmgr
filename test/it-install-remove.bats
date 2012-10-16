#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "install remove roundtrip" {
  mkzip "app-a"
  a="-n app-a -i prod"
  app instance install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/app-a.zip \
    $a

  [ ! -r .app/var/pid/$name-$instance.pid ]
  app $a operate start; echo_lines
  [ -r .app/var/pid/$name-$instance.pid ]

  app $a operate stop; echo_lines
  [ ! -r .app/var/pid/$name-$instance.pid ]

#  app instance install \
#    -r file \
#    -u $HOME/.m2/repository/io/trygvis/appsh/examples/jenkins/1.0-SNAPSHOT/jenkins-1.0-SNAPSHOT.zip \
#    -n jenkins -i env-a
}
