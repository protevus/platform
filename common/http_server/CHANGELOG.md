# Change Log

## 4.5.1

* Fixed linter warnings

## 4.5.0

* Require Dart >= 3.5
* Updated `lints` to 5.0.0
* Updated `mime` to 2.0.0

## 4.4.0

* Updated `lints` to 4.0.0

## 4.3.0

* Require Dart >= 3.3

## 4.2.0

* Upgraded `lints` to 3.0.0

## 4.1.2

* Fixed `_VirtualDirectoryFileStream` class due to change in Dart 3.0.3

## 4.1.1

* Updated README

## 4.1.0

* Upgraded `test_api` to 0.6.0

## 4.0.0

* Require Dart >= 3.0

## 4.0.0-beta.1

* Require Dart >= 3.0
* Fixed linter warnings

## 3.0.0

* Require Dart >= 2.17
* Fixed analyzer warnings

## 2.1.0

* Updated linter to `package:lints`

## 2.0.2

* Transfered repository to `dart-backend`

## 2.0.1

* Added example

## 2.0.0

* Migrated to `platform_http_server`

## 1.0.0

* Migrate to null safety.
* Allow multipart form data with specified encodings that don't require
  decoding.

## 0.9.8+3

* Prepare for `HttpClientResponse` SDK change (implements `Stream<Uint8List>`
  rather than `Stream<List<int>>`).

## 0.9.8+2

* Prepare for `File.openRead()` SDK change in signature.

## 0.9.8+1

* Fix a Dart 2 type issue.

## 0.9.8

* Updates to support Dart 2 constants.

## 0.9.7

* Updates to support Dart 2.0 core library changes (wave
  2.2). See [issue 31847][sdk#31847] for details.

  [sdk#31847]: https://github.com/dart-lang/sdk/issues/31847

## 0.9.6

* Updated the secure networking code to the SDKs version 1.15 SecurityContext api

## 0.9.5+1

* Updated the layout of package contents.

## 0.9.5

* Removed the decoding of HTML entity values (in the form &#xxxxx;) for
  values when parsing multipart/form-post requests.

## 0.9.4

* Fixed bugs in the handling of the Range header
