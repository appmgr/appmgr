Installation
------------

    git clone http://.../app.sh.git

    mkdir /opt/apps
    cd /opt/apps
    ln -s .../app.sh.git/app.sh app.sh

NOTE: The bash completion is not perfect yet.

    echo 'source .../app.sh.git/app_completion' >> ~/.bashrc

Or was it `~/.bash_profile`? hmm

Environment
-----------

The following environment variables are set by default:

TODOs
-----

* Support installation-wide settings. Useful for shared environment
  settings etc (PATH).

* Add support for hooks in .app/hooks. Example hooks:
    * Diff config. Save a backup of the config on installtaion.
    * Copy the configuration from the previous installation.

* Support changing current version.

* Document app.sh
    * Concept: config. group, key and value.
    * Scriptable

* init.d support

* Support -h for all applicable methods to show the help/usage.

* Rename "scripts/" to handlers or something similar. Perhaps just
  remove it entirely.

Commands
--------

### `instance`

#### `install`

#### `upgrade`

Tries to upgrade all instances where the version doesn't match the resolved version.

#### `list`

#### `list-versions`

#### `set-current`

#### `remove`

Not implemented

### `conf`

#### `get`

    ./app -n $n -i $i conf get

#### `set`

    ./app -n $n -i $i conf set group.key value

#### `delete`

    ./app -n $n -i $i conf delete group.key

### `operate`

The operate sub-methods are provided by the application.

#### Supported methods by `pid-method`

#### `start`

#### `stop`

#### `status`

### `foreach`

Runs the given command for each of the selected instances.

Method Contract
---------------

### Environment variables you can depend on

* `APPSH_NAME`
* `APPSH_INSTANCE`
* `APPSH_METHOD`

Unclassified:

* `APPSH_HOME`
* `BASEDIR`

Directory Hierarchy
-------------------

### Current

App.sh is installed through cloning the git repository and/or
unpacking a tarball from the git repository. The directory that
contains app is known as $APPSH_HOME

App.sh related:

    ./         The root of an application set. Known as $APPSH_APPS
    ./app      The app script, symlinked from your git clone directory
    ./.app/lib bash libraries used by app.sh and methods
    ./.app/var runtime data

Applications:

    ./<name>/<instance>/  - Known as $APPSH_INSTANCE_HOME
        current           - symlink to the currently installed app
        versions/         - collection with all installed versions
          1.0/            - A installed version. The zip file is unzipped here.
                            The current directory for scripts executing from scripts/
            root/
            scripts/
          1.1/
          2.0/
