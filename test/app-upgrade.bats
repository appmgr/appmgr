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
