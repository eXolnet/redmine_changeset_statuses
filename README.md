# Redmine Changeset Statuses

[![Latest Release](https://img.shields.io/github/release/eXolnet/redmine_changeset_statuses.svg?style=flat-square)](https://github.com/eXolnet/redmine_changeset_statuses/releases)
[![Software License](https://img.shields.io/badge/license-MIT-8469ad.svg?style=flat-square)](LICENSE)
[![Build Status](https://img.shields.io/travis/eXolnet/redmine_changeset_statuses/master.svg?style=flat-square)](https://travis-ci.org/eXolnet/redmine_changeset_statuses)
[![Maintainability](https://api.codeclimate.com/v1/badges/51ebd36bafadfa0a4946/maintainability)](https://codeclimate.com/github/eXolnet/redmine_changeset_statuses/maintainability)

Allows external services to mark commits with an error, failure, pending, or success state.

## Compatibility

This plugin version is compatible only with Redmine 3.4 and later.

## Installation

1. Download the .ZIP archive, extract files and copy the plugin directory to `#{REDMINE_ROOT}/plugins/redmine_changeset_statuses`.

2. Make a backup of your database, then run the following command to update it:

    ```bash
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_changeset_statuses
    ```

3. Restart Redmine.

### Uninstall

1. Remove the plugin's folder from `#{REDMINE_ROOT}/plugins`.

2. Restart Redmine.

## Usage

Explain how to use your package.

## Testing

Run tests using the following command:

```bash
bundle exec rake redmine:plugins:test NAME=redmine_changeset_statuses RAILS_ENV=development
```

## Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md) and [CODE OF CONDUCT](CODE_OF_CONDUCT.md) for details.

## Security

If you discover any security related issues, please email security@exolnet.com instead of using the issue tracker.

## Credits

- [Alexandre D'Eschambeault](https://github.com/xel1045)
- [All Contributors](../../contributors)

## License

This code is licensed under the [MIT license](http://choosealicense.com/licenses/mit/).
Please see the [license file](LICENSE) for more information.
