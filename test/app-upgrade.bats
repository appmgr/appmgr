#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "app-upgrade" {
  mkzip app-a
  install_artifact

  app init -d my-app maven -r "$FIXED_REPO_URL" org.example:app-a:1.0-SNAPSHOT

  cd my-app

  app conf get app.version
  eq    '${lines[0]}' "1.0-SNAPSHOT"
  app_version="${lines[0]}"
  describe app_version = $app_version

  app conf get app.resolved_version
  match '${lines[0]}' "1.0-.*"
  resolved_version="${lines[0]}"
  describe resolved_version = $resolved_version

  app conf get app.installed_version
  match '${lines[0]}' "1.0-.*"
  installed_version="${lines[0]}"
  describe installed_version = $installed_version

  eq    '$installed_version' "$resolved_version"

  install_artifact

  app upgrade

  app conf get app.resolved_version
  match '${lines[0]}' "1.0-.*"
  new_resolved_version="${lines[0]}"
  describe new_resolved_version = $new_resolved_version
  neq   $new_resolved_version $resolved_version
}

@test "app-upgrade - when pre-install fails the first run" {
  mkzip app-a
  file=$APPSH_HOME/test/data/app-a.zip
  touch -d '@1000000000' $file

  app init -d my-app file $file

  cd my-app

  # A new version is available, but make sure pre-install fails.
  touch -d '@2000000000' $file
  touch fail-pre-install
  check_status=no
  app upgrade
  eq '${status}' 1

  # Try to reinstall the same file
  rm fail-pre-install
  app upgrade
  eq '${lines[0]}' "Resolving version "
  eq '${lines[1]}' "Resolved version to 2000000000"
  eq '${lines[2]}' "Version 2000000000 is already unpacked"
  eq '${lines[3]}' "Importing config from versions/2000000000/app.config"
  eq '${lines[4]}' "pre-install"
  eq '${lines[5]}' "Changing current symlink from 1000000000 to 2000000000"
  eq '${lines[6]}' "post-install"
  eq '${#lines[*]}' 7
}
