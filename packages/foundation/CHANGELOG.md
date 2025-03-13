## 0.5.1-dev.0+1

 - **REFACTOR**: integrating container. ([f409d670](https://github.com/protevus/platform/commit/f409d6703fc05045fd57ae7d21a615a5c1640b67))
 - **REFACTOR**: foundation package. ([945be7e4](https://github.com/protevus/platform/commit/945be7e444d610e4764a43a258ba2e9f6fd8f7ef))
 - **REFACTOR**: finished foundation package. ([49dabd82](https://github.com/protevus/platform/commit/49dabd82a061ffd85d5db8a172a4df9e2522d622))
 - **REFACTOR**: foundation package. ([736023ec](https://github.com/protevus/platform/commit/736023ec061f26bbe54561a3d718429dbe07bd24))
 - **REFACTOR**: foundation package. ([13e4f18e](https://github.com/protevus/platform/commit/13e4f18ec49c8199d9ee9cb6e20a6dc9419a08f6))
 - **REFACTOR**: foundation package. ([abbefbdb](https://github.com/protevus/platform/commit/abbefbdbc33f9ce70ccccb4e7e484f210ab81f23))
 - **REFACTOR**: finished, removing annotation package. ([9ee1d98e](https://github.com/protevus/platform/commit/9ee1d98e6b19d1bca8522eb4112fc29375dc6a4c))
 - **REFACTOR**: http package. ([0e081104](https://github.com/protevus/platform/commit/0e0811040df30c5ff071dfaa8040fa07edfa86d3))
 - **REFACTOR**: foundation package. ([6aed35d8](https://github.com/protevus/platform/commit/6aed35d8f530eece7cabf5344120eb8441d26262))
 - **REFACTOR**: foundation package. ([e1507a4f](https://github.com/protevus/platform/commit/e1507a4fdc6678eb8fea9b3a1ee272089eb34295))
 - **REFACTOR**: container package. ([42a48af9](https://github.com/protevus/platform/commit/42a48af9db25272bdc11f92fdfdc8e21a669ef86))
 - **REFACTOR**: http package. ([11db1719](https://github.com/protevus/platform/commit/11db1719cef4e3a6ac4ceb203ed1f6bb6fc69dc1))
 - **REFACTOR**: foundation package. ([701849d7](https://github.com/protevus/platform/commit/701849d78f84e77a4fd7245721c5911a3dd40458))
 - **REFACTOR**: config package. ([1ee4eedf](https://github.com/protevus/platform/commit/1ee4eedffbd4a7a8c5f7d673df449ecb8b45dce2))
 - **REFACTOR**: support package. ([5c6215a2](https://github.com/protevus/platform/commit/5c6215a2abea72c6873b16047ecd28404373411b))
 - **REFACTOR**: log package. ([0df8a623](https://github.com/protevus/platform/commit/0df8a623e91dd5ba278c96464d414de468429d88))
 - **REFACTOR**: foundation package. ([27e0b3b2](https://github.com/protevus/platform/commit/27e0b3b205dc3ffd03ec4fe049cf707b722cc4fc))
 - **REFACTOR**: contracts package. ([b5f49ba9](https://github.com/protevus/platform/commit/b5f49ba93b620812e721eb0cc8a58ca305717ce1))
 - **REFACTOR**: validation package. ([ff1ab721](https://github.com/protevus/platform/commit/ff1ab721117bbf11b496105750981091b21fbb13))
 - **REFACTOR**: routing package. ([ee31e7aa](https://github.com/protevus/platform/commit/ee31e7aacbf46b34caf9b54eeb263f2d69381cbb))
 - **REFACTOR**: foundation package. ([55492fcf](https://github.com/protevus/platform/commit/55492fcf9c90c6b45c2970c3876ebb318780a3c8))
 - **REFACTOR**: re-branding. ([4a624b69](https://github.com/protevus/platform/commit/4a624b69a577d25a7dd339128c02c45351faf4e8))
 - **REFACTOR**: re-branding. ([943fa95b](https://github.com/protevus/platform/commit/943fa95b8b4e265044f8d77eff1d421e4c0d1c57))
 - **REFACTOR**(add): initial new core commit. ([a70e2f53](https://github.com/protevus/platform/commit/a70e2f53945d5eda87c08ee5514acaa26e52ce87))
 - **REFACTOR**(zero): completed angel3 core integration implementing new core. ([c87e3899](https://github.com/protevus/platform/commit/c87e389945b79bfdc0a3d3cf61f2040e2ce8f607))
 - **REFACTOR**: refactoring common utils, routes > routing, db drivers. ([e25f672a](https://github.com/protevus/platform/commit/e25f672a407bc6bb1cc68cc027abba4c119a2537))
 - **REFACTOR**: refactored core package to foundation package. ([2258f301](https://github.com/protevus/platform/commit/2258f301e82b28e6f372120262d7aeec4ece1aad))
 - **FIX**: fixing imports file clean up. ([d0a4d31c](https://github.com/protevus/platform/commit/d0a4d31ca86e48b17fc8d313af66736bcb7a1f69))

# version 2.0.0

- Change validation {attribute} to {field}
- Restructure response handler and middleware
- Restructure app configuration
- Extract websocket as separate package `dox-websocket`
- Type improvement on usage of auth package
- Bug fix on multithread with services
- Support storage class for file storage
- Add more unit/integration test coverage
- Fix bug for websocket running on multiple isolates
- Update cache config setting on app config
- Added support for multi-thread http server which is 10x faster on concurrency request
- Added support for services (i.e database, redis) to run on each isolate/multi-thread
- Added cache class that run file driver as default 
- Added support for custom cache drivers, i.e redis, memcached
- Added `JSON.stringify()` and `JSON.parse()` that support DateTime to encode
- Added support for DateTime object on http response/return data
- Added support of size and bytes information on uploaded `RequestFile`
- Bug fixed on multipart form data file store
- Removed database config option in app config.
- Moved ioc container from `Global.ioc` to `Application().ioc`
- Improvement on routes
- Rename Handler interface to ResponseHandlerInterface

# version 1.0.6

- Remove third party dot env package and replace with own `Env` class

# version 1.0.5

- Modify request auth getter to function to support type injection

# version 1.0.4

- Added interfaces/classes for authentication
- Bug fixed on router prefix
- Bug fixed on cookie return type `String?`

# version 1.0.3

- Ignore error on missing method of resource route
- Added single quote rule in linter

# version 1.0.2

- Bug fixed method not found on resource route

# version 1.0.1

- Added missing types on functions and arguments
- Added linter rules

# version 1.0.0

- First stable release

# version 1.0.0-alpha.2

- Support domain routing
- Improvement group routing
- Support middleware routing
- Added app level middleware support 
- Added function's self documentation
- Websocket improvement and support multiple path
- Support serializer

# version 1.0.0-alpha.1

- Added support for validation
- Added support for form data for file uploading
- Improve error handling

# version 1.0.0-alpha.0

- Refactor the code
- Added test cases
- Added support for global middleware
- Added support to throw error exception in response and add support to handle via response handler
- Rename BaseHttpException to HttpException
- Bug fixed on cookie response

# version 0.0.17

- Separate Query builder from core

# version 0.0.16

- Replace with dox query builder
- Added feature to auto encode List<Model> response
- Added resource routes
- Added `req.input()` in DoxRequest
- Added support CORS
- Added More Response options on DoxResponse
- Added `Hash.make('password')` for password encryption
- Added Support websocket
