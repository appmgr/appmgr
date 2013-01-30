Style Guide
-----------

Basic
=====

* Indent: two spaces. Spaces >> tabs.

Creating `usage()`
==================

* Always echo to `stderr`.
* Exit with code 1.
* Enclose required arguments in angle brackets: `-v <version>`
* Enclose optional arguments in square brackets: `[-h hook]`

    usage() {
      echo "usage: $0 -v <version> [-h hook]"
      exit 1
    }

Executing Commands
==================

* http://unix.stackexchange.com/q/23026

Resources
---------

* Parameter expansion: <http://wiki.bash-hackers.org/syntax/pe>
