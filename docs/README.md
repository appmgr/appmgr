Environment
-----------

The following environment variables are set by default:

TODOs
-----

* Support installation-wide settings. Useful for shared environment
  settings etc (PATH).

* Add support for hooks in .app/hooks. Example hooks:
    * Diff config. Save a backup of the config On installtaion

* Support changing current version.

* Document app.sh
    * Concept: config. group, key and value.
    * Scriptable

* init.d support

Commands
--------

### `app`

#### `install`

#### `upgrade`

Tries to upgrade all instances where the version doesn't match the resolved version.

#### `list`

#### `list-versions`

#### `set-current`

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

