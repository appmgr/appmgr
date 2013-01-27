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

  REPO=$BATS_TMPDIR/repo

  if [ ! -f $REPO/org/example/app-a/1.0-SNAPSHOT/maven-metadata.xml ]
  then
    mvn deploy:deploy-file -Durl=file://$REPO \
      -Dfile=`echo $APPSH_HOME/test/data/app-a.zip` -DgeneratePom \
      -DgroupId=org.example -DartifactId=app-a -Dversion=1.0-SNAPSHOT -Dpackaging=zip
  fi

  app init -d my-app maven -r "file://$BATS_TMPDIR/repo" org.example:app-a:1.0-SNAPSHOT; echo_lines
  eq    '$status' 0
  eq    '${lines[0]}' "Resolving version 1.0-SNAPSHOT..."
  match '${lines[1]}' "Resolved version to 1.0-.*"
  match '${lines[2]}' "Downloading org.example:app-a:1.0-.*"
  eq    '${lines[3]}' "Unpacking..."
  match '${lines[4]}' "Creating current symlink for version 1.0-.*"
  eq    '${lines[5]}' "Running hook: post-install"
  eq    '${lines[6]}' "Post install"
  eq '${#lines[*]}' 7

  is_directory "my-app/.app"
}
