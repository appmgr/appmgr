#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

#@test "Invalid resolver" {
#  app init -d my-app wat; echo_lines
#  eq '$status' 1
#  eq '${#lines[*]}' 1
#  eq '${lines[0]}' "No such resolver: wat"
#}

#@test "Already installed" {
#  mkdir -p my-app/.apps
#  app init -d my-app maven; echo_lines
#  eq '$status' 1
#  eq '${#lines[*]}' 1
#  match '${lines[0]}' "my-app"
#}

@test "Happy day" {
  mkzip app-a
  install_artifact

  app init -d my-app maven -r "file://$BATS_TMPDIR/repo" org.example:app-a:1.0-SNAPSHOT; echo_lines
  eq    '$status' 0
  eq    '${lines[0]}' "Resolving Maven version 1.0-SNAPSHOT..."
  match '${lines[1]}' "Resolved version to 1.0-*"
  match '${lines[2]}' "Downloading org.example:app-a:1.0-*"
  eq    '${lines[3]}' "Unpacking..."
  match '${lines[4]}' "Importing config from versions/1.0-*"
  match '${lines[5]}' "Creating current symlink for version 1.0-*"
  eq    '${lines[6]}' "Post install"
  eq    '${#lines[*]}' 7

  is_directory "my-app/.app"
  # Created by post-install
  is_directory "my-app/logs"
}

@test "Install release artifact" {
  mkzip app-a
  install_artifact 1.0

  app init -d my-app maven -r "file://$BATS_TMPDIR/repo" org.example:app-a:1.0; echo_lines
  eq    '$status' 0
  match '${lines[0]}' "Resolved version to 1.0"
  match '${lines[1]}' "Downloading org.example:app-a:1.0-*"
  eq    '${lines[2]}' "Unpacking..."
  match '${lines[3]}' "Importing config from versions/1.0-*"
  match '${lines[4]}' "Creating current symlink for version 1.0-*"
  eq    '${lines[5]}' "Post install"
  eq    '${#lines[*]}' 6

  is_directory "my-app/.app"
  # Created by post-install
  is_directory "my-app/logs"
}
