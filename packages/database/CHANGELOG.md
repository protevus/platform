## 0.5.1-dev.0+1

 - **REFACTOR**: finished, removing annotation package. ([9ee1d98e](https://github.com/protevus/platform/commit/9ee1d98e6b19d1bca8522eb4112fc29375dc6a4c))
 - **REFACTOR**: database package. ([3eb77df4](https://github.com/protevus/platform/commit/3eb77df48227d6b84b768b9e456fc7c81574361f))
 - **REFACTOR**: re-branding. ([40ccdcaa](https://github.com/protevus/platform/commit/40ccdcaa071134ddeb8e6de17bcfe3ea36177d4a))
 - **REFACTOR**: re-branding. ([943fa95b](https://github.com/protevus/platform/commit/943fa95b8b4e265044f8d77eff1d421e4c0d1c57))
 - **REFACTOR**(add): initial new core commit. ([a70e2f53](https://github.com/protevus/platform/commit/a70e2f53945d5eda87c08ee5514acaa26e52ce87))
 - **REFACTOR**(zero): completed angel3 core integration implementing new core. ([c87e3899](https://github.com/protevus/platform/commit/c87e389945b79bfdc0a3d3cf61f2040e2ce8f607))
 - **REFACTOR**: renaming PDO to DBO. ([7448e712](https://github.com/protevus/platform/commit/7448e7129597aa08c0822dfd1a78c5be71aed37e))

## 2.1.0

- Added support for MYSQL driver

## 2.0.0

- Support postgres driver v3

## 1.1.16

- Bug fixed on save
- Change `newQuery` to `query()` and deprecate `newQuery`

## 1.1.15

- Bug fixed on toMap

## 1.1.14

- Bug fixed on eager/preload data missing in `toMap` response.
- Bug fixed on `deleted_at` column conflict.
- Support for `withTrash` chain on any query builder function.

## 1.1.13

- Update readme
- bug fixed on count() with order by

## 1.1.12

- Add support for paginate() function
- Add support for query printer, file printer, consoler printer and pretty printer.

## 1.1.11

- Add missing types on function and arguments
- Bug fixed on count, custom query

## 1.1.10

- Remove hidden fields on toJson

## 1.1.9

- Bug fixed on jsonEncode(Model)

## 1.1.8

- Update readme

## 1.1.7

- Add option in `toMap()` to remove hidden fields

## 1.1.6

- Create own annotation and builder
- Added belongsTo support
- Added hasOne support
- Added hasMany support
- Added manyToMany support
- Added eager loading support

## 1.0.11

- Bug fixed id null on save

## 1.0.10

- Bug fixed on debug option in model
- Bug fixed on debug query param missing
- Support Postgres Pool
- Support hidden fields in model

## 1.0.1

- Update documentation

## 1.0.0

- Initial release
