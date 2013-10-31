#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "plain init" {
  mkdir .app
  app resolver-maven init my-group:my-artifact:1.0-SNAPSHOT
  app cat-conf
  eq    '${lines[0]}' "app.version=1.0-SNAPSHOT"
  eq    '${lines[1]}' "maven.artifact_id=my-artifact"
  eq    '${lines[2]}' "maven.group_id=my-group"
  eq    '${lines[3]}' "maven.repo=http://repo1.maven.org"
  eq    '${#lines[*]}' 4
}

@test "init with classifier" {
  mkdir .app
  app resolver-maven init my-group:my-artifact:app:1.0-SNAPSHOT
  app cat-conf
  eq    '${lines[0]}' "app.version=1.0-SNAPSHOT"
  eq    '${lines[1]}' "maven.artifact_id=my-artifact"
  eq    '${lines[2]}' "maven.classifier=app"
  eq    '${lines[3]}' "maven.group_id=my-group"
  eq    '${lines[4]}' "maven.repo=http://repo1.maven.org"
  eq    '${#lines[*]}' 5
}
