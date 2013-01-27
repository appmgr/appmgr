Style Guide
-----------

Usage
=====

* Always echo to `stderr`.
* Exit with code 1.
* Enclose required arguments in angle brackets: `-v <version>`
* Enclose optional arguments in square brackets: `[-h hook]`

    usage() {
      echo "usage: $0 -v <version> [-h hook]"
      exit 1
    }


