<p align="center"><a href="https://protevus.com" target="_blank"><img src="https://git.protevus.com/protevus/branding/raw/branch/main/protevus-logo-bg.png"></a></p>

# protevus_openapi

Reads and writes OpenAPI (Swagger) specifications.

conduit_open_api supports both v2 and v3 of the open_api specification.

To use v2 import:

```dart
import 'package:conduit_open_api/v2.dart';
```

To use v3 import:

```dart
import 'package:conduit_open_api/v3.dart';
```

You can us v2 and v3 within a single project.


Example
---

```dart
import 'package:conduit_open_api/v3.dart';


final file = File("test/specs/kubernetes.json");
final contents = await file.readAsString();
final doc = APIDocument.fromJSON(contents);

final output = JSON.encode(doc.asMap());
```

