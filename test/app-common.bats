#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "grep_path" {
  . $APPMGR_HOME/share/appmgr/common

  x=`grep_path "app-.*" "$APPMGR_HOME/test/data/app-common:/does-not-exist"|sort|sed s,$APPMGR_HOME/,,|xargs`
  eq '$x' 'test/data/app-common/app-bar test/data/app-common/app-faz test/data/app-common/app-foo'

  x=`grep_path "app-f.*" "$APPMGR_HOME/test/data/app-common:/does-not-exist"|sort|sed s,$APPMGR_HOME/,,|xargs`
  eq '$x' 'test/data/app-common/app-faz test/data/app-common/app-foo'

  x=`grep_path "app-b.*" "$APPMGR_HOME/test/data/app-common:/does-not-exist:$APPMGR_HOME/test/data/app-common-extra"|sort|sed s,$APPMGR_HOME/,,|xargs`
  match '${x}' ".*/app-baz.*"
}
