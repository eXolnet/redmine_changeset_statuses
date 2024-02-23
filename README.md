# Redmine Changeset Statuses

[![Latest Release](https://img.shields.io/github/release/eXolnet/redmine_changeset_statuses.svg?style=flat-square)](https://github.com/eXolnet/redmine_changeset_statuses/releases)
[![Redmine Compatibility](https://img.shields.io/static/v1?label=redmine&message=4.2.x-5.1.x&color=blue&style=flat-square)](https://www.redmine.org/plugins/redmine_changeset_statuses)
[![Software License](https://img.shields.io/badge/license-MIT-8469ad.svg?style=flat-square)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/eXolnet/redmine_changeset_statuses/tests.yml?label=tests&style=flat-square)](https://github.com/eXolnet/redmine_changeset_statuses/actions?query=workflow%3Atests)
[![Maintainability](https://api.codeclimate.com/v1/badges/51ebd36bafadfa0a4946/maintainability)](https://codeclimate.com/github/eXolnet/redmine_changeset_statuses/maintainability)

Allows external services to set a state on revisions to consult it directly in Redmine. This plugin is highly based on [Github's Commit Status API](https://developer.github.com/v3/repos/statuses/).

## Compatibility

This plugin version is compatible only with Redmine 4.2 and later.

## Installation

1. Download the .ZIP archive, extract files and copy the plugin directory to `#{REDMINE_ROOT}/plugins/redmine_changeset_statuses`.

2. Make a backup of your database, then run the following command to update it:

    ```bash
    bundle exec rake redmine:plugins:migrate NAME=redmine_changeset_statuses RAILS_ENV=production
    ```

3. Restart Redmine.

### Uninstall

1. Make a backup of your database, then rollback the migrations:

    ```bash
    bundle exec rake redmine:plugins:migrate NAME=redmine_changeset_statuses VERSION=0 RAILS_ENV=production
    ```

2. Remove the plugin's folder from `#{REDMINE_ROOT}/plugins`.

3. Restart Redmine.

## Usage

By using the endpoints described below, you can add a status to a revision. This status will then be displayed in Redmine on associated revisions to an issue.

A common use cases is to add statuses from a continuous integration system like Jenkins. Then, you'll be able to see the build status and access it directly from Redmine.

### Create a status

Users with permission "Commit access" to a repository can create commit statuses for a given revision.C

```
POST /projects/:project/repository/statuses/:revision.json
```

#### Parameters

|      Name     |   Type   |    Description   |
|---------------|----------|------------------|
| `context`     | `string` | **Required.** A string label to differentiate this status from the status of other systems. |
| `state`       | `string` | **Required.** The state of the status. Can be one of `error`, `failure`, `pending`, or `success`. |
| `target_url`  | `string` | The target URL to associate with this status. |
| `description` | `string` | A short description of the status. |

#### Example

```json
{
  "context": "continuous-integration/jenkins",
  "state": "success",
  "target_url": "https://example.com/build/status",
  "description": "The build succeeded!"
}
```

### List statuses of a revision

Users with permission "View changesets" to a repository can retrieve all statuses for a specific revision. Statuses are displayed in reverse chronological order.

```
GET /projects/:project/repository/statuses/:revision.json
```

#### Response

```json
{
    "statuses": [
        {
            "id": 2,
            "context": "continuous-integration/jenkins",
            "state": "success",
            "target_url": "https://example.com/build/status",
            "description": "The build succeeded!",
            "created_on": "2019-02-26T18:02:27Z"
        }
    ],
    "total_count": 1,
    "offset": 0,
    "limit": 25
}
```

### Get the combined status for a revision

Users with permission "View changesets" to a repository can retrieve all statuses for a specific revision. For a combined status, only the last status for each context is displayed in reverse chronological order. Additionally, a combined `state` is returned.

```
GET /projects/:project/repository/revisions/:revision/status.json
```

#### Response

```json
{
    "statuses": [
        {
            "id": 2,
            "context": "continuous-integration/jenkins",
            "state": "success",
            "target_url": "https://example.com/build/status",
            "description": "The build succeeded!",
            "created_on": "2019-02-26T18:02:27Z"
        }
    ],
    "state": "success",
    "total_count": 1,
    "offset": 0,
    "limit": 25
}
```

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
