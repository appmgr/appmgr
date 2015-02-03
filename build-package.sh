#!/bin/bash
# Might be needed --git-pristine-tar --git-pristine-tar-commit
gbp buildpackage --git-upstream-tag='v%(version)s' --git-upstream-branch=master --git-submodules --git-debian-branch=debian/sid --git-builder=debuild -S -sa
