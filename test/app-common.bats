#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "grep_path" {
  . $APPMGR_HOME/lib/common

  x=`grep_path "app-.*" "$APPMGR_HOME/test/data/app-common:/does-not-exist"|sort|sed s,$APPMGR_HOME/,,|xargs`
  [[ $x == "test/data/app-common/app-bar test/data/app-common/app-faz test/data/app-common/app-foo"  ]]

  x=`grep_path "app-f.*" "$APPMGR_HOME/test/data/app-common:/does-not-exist"|sort|sed s,$APPMGR_HOME/,,|xargs`
  [[ $x == "test/data/app-common/app-faz test/data/app-common/app-foo"  ]]
}
