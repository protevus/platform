# Belatuk Merge Map

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/platform_merge_map?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![License](https://img.shields.io/github/license/dart-backend/belatuk-common-utilities)](https://github.com/dart-backend/belatuk-common-utilities/blob/main/packages/merge_map/LICENSE)

**Replacement of `package:merge_map` with breaking changes to support NNBD.**

Combine multiple Maps into one. Equivalent to
[Object.assign](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign) in JS.

## Example

```dart
import "package:platform_merge_map/platform_merge_map.dart";

void main() {
    Map map1 = {'hello': 'world'};
    Map map2 = {'foo': {'bar': 'baz', 'this': 'will be overwritten'}};
    Map map3 = {'foo': {'john': 'doe', 'this': 'overrides previous maps'}};
    Map merged = mergeMap(map1, map2, map3);

    // {hello: world, foo: {bar: baz, john: doe, this: overrides previous maps}}
}
```
