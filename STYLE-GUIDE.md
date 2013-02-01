Style Guide
-----------

Basic
=====

* Indent: two spaces. Spaces >> tabs.

Creating `usage()` and `help()`
===============================

The general semantics
---------------------

When the user requests help through `-h` or no arguments,
`show_help()` should be used. This will output the info on stdout
because the user explicitly requested so. If the user gives some form
of invalid argument or there is any other error the usage should go to
stderr because the user might be using pipes.


How app.sh does it
------------------

Each command should implement `usage_text`. The command should call
`show_help()` and `usage()` as appropriate. These functions are
defined in `lib/common` and will both call `usage_app()` to get the
usage info. `usage()` will send the info to stderr.

* `show_help()` will exit with 0, while `usage()` will exit with code 1.

Formatting of usage output
--------------------------

* Enclose required arguments in angle brackets: `-v <version>`
* Enclose optional arguments in square brackets: `[-h hook]`

    usage_text() {
      echo "usage: $0 -v <version> [-h hook]"
    }

Executing Commands
==================

* http://unix.stackexchange.com/q/23026

Resources
---------

* Parameter expansion: <http://wiki.bash-hackers.org/syntax/pe>
