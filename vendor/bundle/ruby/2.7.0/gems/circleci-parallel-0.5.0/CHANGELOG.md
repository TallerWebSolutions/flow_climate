# Changelog

## Development

## v0.5.0

* Add improved hook configuration APIs.
    * `config.on_every_node.before_sync`
    * `config.on_every_node.after_sync`
    * `config.on_master_node.before_sync`
    * `config.on_master_node.after_sync`
    * `config.on_master_node.before_download`
    * `config.on_master_node.after_download`
    * `config.on_each_slave_node.before_sync`
    * `config.on_each_slave_node.after_sync`
* Deprecate `#before_join`, `#after_join`, and `#after_download` in `Configuration`.
* Add `Parallel.sync` and deprecate `Parallel.join`.

## v0.4.1

* Tweak UI messsages.

## v0.4.0

* Print "Done." when sync is complete.

## v0.3.0

* Add `Node#name`.

## v0.2.0

* Add mock mode for easier testing in other libraries using circleci-parallel.

## v0.1.0

* Initial release.
