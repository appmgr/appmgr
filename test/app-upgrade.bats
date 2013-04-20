#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "app-upgrade" {
  mkzip app-a
  install_artifact

  app init -d my-app maven -r "$FIXED_REPO_URL" org.example:app-a:1.0-SNAPSHOT; echo_lines
  eq    '$status' 0

  cd my-app
  app conf get maven.version
  match '${lines[0]}' "1.0-SNAPSHOT"
  maven_version="${lines[0]}" 
  describe maven_version=$maven_version

  app conf get app.version
  match '${lines[0]}' "1.0-.*"
  app_version="${lines[0]}" 
  describe app_version=$app_version

  app conf get app.resolved_version
  match '${lines[0]}' "1.0-.*"
  eq    '${lines[0]}' "$app_version"
  resolved_version="${lines[0]}" 
  describe resolved_version=$resolved_version

  install_artifact

  app upgrade; echo_lines
  eq    '$status' 0

  app conf get app.resolved_version
  match '${lines[0]}' "1.0-.*"
  new_resolved_version="${lines[0]}" 
  describe new_resolved_version=$new_resolved_version
  neq $new_resolved_version $resolved_version
}
