#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "Invalid resolver" {
  check_status=no
  app init -d my-app wat
  eq '$status' 1
  eq '${#lines[*]}' 1
  eq '${lines[0]}' "No such resolver: wat"
}

@test "Already installed" {
  mkdir -p my-app/.app
  check_status=no
  app init -d my-app maven
  eq '$status' 1
  eq '${#lines[*]}' 1
  match '${lines[0]}' "my-app"
}

@test "Happy day" {
  mkzip app-a
  install_artifact

  app init -d my-app maven -r "file://$BATS_TMPDIR/repo" org.example:app-a:1.0-SNAPSHOT
  eq    '$status' 0
  eq    '${lines[0]}' "Resolving Maven version 1.0-SNAPSHOT..."
  match '${lines[1]}' "Resolved version to 1.0-*"
  match '${lines[2]}' "Downloading org.example:app-a:1.0-*"
  eq    '${lines[3]}' "Unpacking..."
  match '${lines[4]}' "Importing config from versions/1.0-*"
  eq    '${lines[5]}' "pre-install"
  match '${lines[6]}' "Creating current symlink for version 1.0-*"
  eq    '${lines[7]}' "post-install"
  eq    '${#lines[*]}' 8

  is_directory "my-app/.app"
  # Created by post-install
  is_directory "my-app/logs"
}

@test "Install release artifact" {
  mkzip app-a
  install_artifact 1.0

  app conf -l user set maven.repo "file://$BATS_TMPDIR/repo"
  app init -d my-app maven org.example:app-a:1.0
  match '${lines[0]}' "Resolved version to 1.0"
  match '${lines[1]}' "Downloading org.example:app-a:1.0-*"
  eq    '${lines[2]}' "Unpacking..."
  match '${lines[3]}' "Importing config from versions/1.0-*"
  eq    '${lines[4]}' "pre-install"
  match '${lines[5]}' "Creating current symlink for version 1.0-*"
  eq    '${lines[6]}' "post-install"
  eq    '${#lines[*]}' 7

  is_directory "my-app/.app"
  # Created by post-install
  is_directory "my-app/logs"
}

@test "Install 1.0-SNAPSHOT, upgrade to 1.0" {
  mkzip app-a
  install_artifact
  app conf -l user set maven.repo "file://$BATS_TMPDIR/repo"
  app init -d my-app maven org.example:app-a:1.0-SNAPSHOT

  cd my-app
  app conf set app.version 1.0

  install_artifact 1.0
  app upgrade
  cd current
  run pwd -P

  match '${lines[0]}' ".*/versions/1.0/root$"
  eq    '${#lines[*]}' 1
}

@test "app-init: Can pass configuration variables" {
  mkzip app-a
  app init -d my-app \
    -s "foo.bar=awesome" \
    -s "foo.baz=i love space" \
    -s "foo.wat=2+2=5" file $APPMGR_HOME/test/data/app-a.zip
  cd my-app
  app cat-conf -g foo
  match '${lines[0]}' "foo.bar=awesome"
  match '${lines[1]}' "foo.baz=i love space"
  match '${lines[2]}' "foo.wat=2\+2=5"
  eq '${#lines[*]}' 3
}
