<p align="center"><a href="https://protevus.com" target="_blank"><img src="https://git.protevus.com/protevus/branding/raw/branch/main/protevus-logo-bg.png"></a></p>

# Protevus Platform

[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.3.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-failing-red.svg)]()

- ***NOTE: THIS REPO IS NOT STABLE AND IS UNDER HEAVY DEVELOPMENT AND TESTING***
- ***FAST MOVING CODEBASE: NOTHING THAT YOU SEE HERE TODAY MAY BE HERE TOMMORROW***
- ***PREVIEW RELEASE: DATE TO BE DETERMINED***
- ***DISCLOSURE: EXAMPLES IN THIS DOCUMENT ARE TEMPORARY BOILERPLATE EXAMPLES***

## 📖 Overview

Protevus Platform is a high-performance, modular unified full-stack platform for Dart that combines the elegance of Laravel's API design with Dart's powerful async/await capabilities and strong typing. Built upon Angel3's foundation, it provides a comprehensive suite of tools for building scalable desktop, mobile, web, iot, edge applications, APIs, and microservices.

### 🌟 Key Features

- **High Performance**: Built on Dart's efficient runtime with support for HTTP/2 and WebSocket
- **Type Safety**: Leverages Dart's strong type system for compile-time error catching
- **Modular Architecture**: Highly extensible with independent, composable packages
- **Real-time Capabilities**: Built-in WebSocket and Server-Sent Events support
- **Developer Friendly**: Intuitive API design with extensive documentation
- **Enterprise Ready**: Built-in support for authentication, caching, and database operations

## 🏗️ Architecture

Protevus Platform uses a modular architecture where each component is a separate package, allowing for flexible composition and minimal dependencies.

### Core Components

#### � Foundation (`platform_foundation`)
The heart of the framework, providing core HTTP server functionality:

```dart
import 'package:platform_foundation/platform_foundation.dart';

void main() async {
  var app = Application();
  
  // Middleware support
  app.use((req, res) async {
    res.headers.add('X-Powered-By', 'Protevus');
    await req.next();
  });

  // Route handling
  app.get('/', (req, res) async {
    await res.render('welcome', {'message': 'Welcome to Protevus!'});
  });

  await app.startServer('localhost', 3000);
}
```

Key features:
- HTTP/1.1 and HTTP/2 support
- Middleware pipeline
- Request/Response abstraction
- File uploads with streaming
- Static file serving
- CORS support
- Error handling

#### �️ Routing (`platform_routing`)
Advanced routing system supporting both Laravel and Express styles:

```dart
// Laravel style routing with rich features
app.router.group('/api/v1', (router) {
  // Resource routes with custom configuration
  router.resource('users', UserController())
    .only(['index', 'show', 'store'])  // Limit available actions
    .names({                           // Custom route naming
      'index': 'users.list',
      'show': 'users.detail'
    })
    .middleware(['throttle:60,1']);    // Rate limiting middleware

  // Nested resources
  router.resource('users.posts', PostController())
    .shallow()                         // Generate shallow routes
    .middleware(['cache:public']);     // Cache middleware

  // Route groups with shared middleware
  router.middleware(['auth:api', 'verified'], (router) {
    // Protected document routes
    router.prefix('documents', (router) {
      router.get('/', DocumentController.index)
        .name('documents.index')
        .where('type', 'pdf|doc');     // URL constraints

      router.post('{id}/share', DocumentController.share)
        .name('documents.share')
        .where('id', '[0-9]+')         // Parameter constraints
        .middleware(['can:share,document']); // Authorization

      router.put('{id}/move', DocumentController.move)
        .middleware(['transaction']);   // Database transaction
    });

    // Admin routes with role middleware
    router.middleware(['role:admin'], (router) {
      router.prefix('admin', (router) {
        router.get('stats', AdminController.stats)
          .middleware(['cache:private,5']);
        
        router.resource('settings', SettingController())
          .except(['destroy']);
      });
    });
  });

  // API versioning
  router.prefix('v2', (router) {
    router.get('features', FeatureController.index)
      .middleware(['api.version:2']);
  });
});

// Route model binding
app.router.model('user', (id) => User.findOrFail(id));
app.router.model('document', (id) => Document.findOrFail(id));

// Named route groups
app.router.as('api.', (router) {
  router.get('health', HealthController.check)
    .name('health')  // Results in 'api.health'
    .middleware(['throttle:1000,1']);
});

// Express style
app.get('/users/:id', (req, res) async {
  var id = req.params['id'];
  var user = await userService.find(id);
  await res.json(user);
});
```

Features:
- Named routes
- Route parameters with constraints
- Route groups and prefixing
- Domain routing
- Middleware attachment
- RESTful resource routing

#### 🔐 Authentication (`platform_auth`)
Comprehensive authentication system:

```dart
// JWT Authentication
app.use('/api/*', jwtAuth(secret: 'your-secret'));

// Custom auth strategy
class ApiKeyStrategy extends AuthStrategy {
  @override
  Future<User?> authenticate(RequestContext req) async {
    var key = req.headers.value('X-API-Key');
    return await validateApiKey(key);
  }
}

// Role-based authorization
@Middleware([auth, roles(['admin'])])
class AdminController extends Controller {
  @Expose('/dashboard')
  Future<void> dashboard() async {
    // Only admins can access
  }
}
```

Features:
- JWT authentication
- Basic auth
- OAuth support
- Role-based authorization
- Policy-based authorization
- Authentication events
- Session management

#### � Database (`platform_database`)
Powerful database abstraction layer:

```dart
// Query builder
var users = await db.table('users')
  .where('active', true)
  .whereIn('role', ['admin', 'moderator'])
  .orderBy('created_at', 'desc')
  .paginate(page: 1, perPage: 20);

// Model definition
class User extends Model {
  String? name;
  String? email;
  
  @belongsTo
  User? supervisor;
  
  @hasMany
  List<Post>? posts;
}

// Transactions
await db.transaction((tx) async {
  await tx.table('accounts').decrement('balance', 100);
  await tx.table('transactions').insert({
    'type': 'withdrawal',
    'amount': 100
  });
});
```

Features:
- Query builder with type safety
- Multiple database support
- Migrations and seeders
- Model relationships
- Eager loading
- Transactions
- Connection pooling
- Query logging

#### � Events (`platform_events`)
Sophisticated event system:

```dart
// Event definition
class UserRegistered {
  final User user;
  UserRegistered(this.user);
}

// Event subscriber
class UserEventSubscriber {
  @Subscribe
  void onUserRegistered(UserRegistered event) async {
    await emailService.sendWelcomeEmail(event.user);
    await notificationService.notify('New user registered');
  }
}

// Broadcasting
await events.broadcast(
  'user.registered',
  {'id': user.id, 'email': user.email},
  ['private-admin', 'public-stats']
);
```

Features:
- Event dispatching
- Event subscribers
- Event broadcasting
- Queue support
- Real-time events
- WebSocket integration
- Dead letter queues
- Event replay

#### 🗃️ Caching (`platform_cache`)
Advanced caching system:

```dart
// Basic usage
await cache.remember('user:1', Duration(minutes: 60), () async {
  return await userService.find(1);
});

// Atomic operations
await cache.atomic((cache) async {
  var views = await cache.increment('post:123:views');
  if (views >= 1000) {
    await notifyTrendingPost(123);
  }
});

// Cache tags
await cache.tags(['users', 'roles']).put('permissions', permissions);
```

Features:
- Multiple cache drivers
- Cache tags
- Atomic operations
- Cache invalidation
- Rate limiting
- Cache warming
- Cache events

#### ✅ Validation (`platform_validation`)
Comprehensive validation system:

```dart
class CreateUserRequest extends FormRequest {
  @override
  Map<String, List<Validator>> get rules => {
    'email': [required, email, unique('users')],
    'password': [required, minLength(8), password],
    'role': [required, in(['user', 'admin'])],
  };
  
  @override
  Map<String, String> get messages => {
    'email.unique': 'This email is already registered',
    'password.min': 'Password must be at least 8 characters'
  };
}

@Validate(CreateUserRequest)
Future<void> createUser(RequestContext req) async {
  var data = await req.validate();
  await userService.create(data);
}
```

Features:
- Request validation
- Custom validators
- Validation rules
- Error messages
- Form requests
- Nested validation
- Array validation
- File validation

#### 🚌 Message Bus (`platform_bus`)
```dart
// Message bus for decoupled communication
final bus = MessageBus();

// Subscribe to messages
bus.subscribe('order.created', (message) async {
  await processOrder(message.payload);
});

// Publish messages
await bus.publish('order.created', {'orderId': '123'});
```

Features:
- Message publishing and subscribing
- Topic-based routing
- Message persistence
- Dead letter handling
- Message replay
- Middleware support
- Error handling

#### 🔄 Collections (`platform_collections`)
```dart
// Type-safe collection operations
final collection = Collection<User>([user1, user2]);
final active = collection
  .where((user) => user.isActive)
  .sortBy((user) => user.lastName);

// Higher-order collection operations
await collection.each((user) async {
  await user.recalculateStats();
});
```

Features:
- Type-safe collections
- Functional operations
- Lazy evaluation
- Collection pipelines
- Custom iterators
- Collection events
- Serialization support

#### 🔒 Encryption & Hashing (`platform_encryption`, `platform_hashing`)
```dart
// Secure encryption
final encrypted = await encrypter.encrypt(
  data,
  key: secretKey,
  options: EncryptionOptions(
    algorithm: 'aes-256-gcm',
    encoding: 'base64'
  )
);

// Password hashing
final hashedPassword = await hasher.make(
  password,
  options: HashOptions(
    algorithm: 'argon2id',
    memory: 65536,
    iterations: 4
  )
);
```

Features:
- AES-256-GCM encryption
- RSA encryption
- Argon2id hashing
- PBKDF2 support
- Key derivation
- Digital signatures
- Secure random generation

#### 📁 Filesystem (`platform_filesystem`)
```dart
// File system operations
final fs = FileSystem();

// File operations
await fs.write('config.json', jsonEncode(config));
final content = await fs.read('config.json');

// Directory operations
await fs.makeDirectory('storage/logs', recursive: true);
final files = await fs.listContents('storage', recursive: true)
  .where((entry) => entry.isFile)
  .toList();
```

Features:
- File CRUD operations
- Directory management
- File streaming
- File locking
- Path manipulation
- File watching
- Cloud storage adapters

#### 📝 Logging (`platform_log`)
```dart
// Structured logging
final logger = Logger('app');

logger.info('User logged in', {
  'userId': user.id,
  'ip': request.ip,
  'timestamp': DateTime.now()
});

// Log levels and channels
logger.channel('security').warning('Failed login attempt', {
  'ip': request.ip,
  'attempts': attempts
});
```

Features:
- Log levels
- Contextual logging
- Multiple channels
- Log rotation
- Remote logging
- Performance logging
- Error tracking

#### 🔄 Process Management (`platform_process`)
```dart
// Process management
final process = await Process.start('ffmpeg', [
  '-i', 'input.mp4',
  '-codec:v', 'libx264',
  'output.mp4'
]);

// Process monitoring
process.stdout.listen((output) {
  logger.info('Process output: $output');
});

await process.exitCode; // Wait for completion
```

Features:
- Process spawning
- Input/output streams
- Process signals
- Environment variables
- Working directory
- Process pools
- Daemon processes

#### 🧪 Testing (`platform_testing`)
```dart
// HTTP testing
final response = await testClient.post(
  '/api/users',
  body: {'name': 'John', 'email': 'john@example.com'}
);

expect(response.statusCode, equals(201));
expect(response.json['id'], isNotNull);

// Service testing
final service = await testContainer.resolve<UserService>();
final user = await service.create({'name': 'John'});

expect(user.name, equals('John'));
```

Features:
- HTTP testing
- Service testing
- Mock objects
- Test containers
- Assertions
- Coverage reporting
- Performance testing

#### 🌐 Client (`platform_client`)
```dart
// Create API client
final client = Rest('https://api.example.com');

// Service operations
final users = client.service('users');
await users.create({'name': 'John'});
await users.find('123');

// Real-time events
users.on('created').listen((data) {
  print('New user created: ${data['name']}');
});
```

Features:
- REST client
- Service pattern
- Real-time events
- Authentication
- Request interceptors
- Error handling
- Offline support

#### 🛠️ Common Utilities (`platform_common`)
```dart
// Body parsing
final parser = BodyParser();
final data = await parser.parse(request);

// HTML building
final html = HtmlBuilder()
  .doctype()
  .html()
    .head()
      .title('My Page')
    .closeHead()
    .body()
      .div()
        .text('Hello World')
      .closeDiv()
    .closeBody()
  .closeHtml();

// JSON serialization
final serializer = JsonSerializer();
final json = serializer.serialize(model);

// Pretty logging
PrettyLogger.info('Server started', {
  'port': 3000,
  'mode': 'production'
});
```

Features:
- Body parsing
- HTML building
- JSON serialization
- Pretty logging
- HTTP utilities
- Range header parsing
- Symbol table
- User agent parsing

#### ⚙️ Configuration (`platform_config`)
```dart
// Load configuration
final config = Config.load('config/app.yaml');

// Access values
final dbUrl = config.get('database.url');
final apiKey = config.env('API_KEY');

// Configuration caching
await config.cache();
```

Features:
- YAML/JSON support
- Environment variables
- Configuration caching
- Dot notation access
- Default values
- Configuration merging
- Environment detection

#### 🎯 Container (`platform_container`)
```dart
// Register services
container.singleton((c) => DatabaseService(
  c.resolve<ConfigService>()
));

// Register interfaces
container.bind<UserRepository>(
  (c) => UserRepositoryImpl(c.resolve())
);

// Resolve instances
final db = await container.resolve<DatabaseService>();
```

Features:
- Dependency injection
- Interface binding
- Singleton services
- Factory services
- Lazy loading
- Auto-wiring
- Service providers

#### 🍪 Cookie (`platform_cookie`)
```dart
// Set cookies
res.cookie('session', token, {
  httpOnly: true,
  secure: true,
  maxAge: Duration(days: 7)
});

// Read cookies
final session = req.cookies['session'];

// Cookie encryption
final encrypted = cookie.encrypt(value, key);
```

Features:
- Cookie management
- Cookie encryption
- Cookie signing
- Cookie options
- Cookie parsing
- Cookie validation
- SameSite support

#### 🔌 Drivers
```dart
// DBO driver
final db = DBO(
  driver: 'mysql',
  host: 'localhost',
  database: 'app'
);

// RethinkDB driver
final rethink = RethinkDB(
  host: 'localhost',
  db: 'app'
);
```

Features:
- MySQL driver
- PostgreSQL driver
- SQLite driver
- RethinkDB driver
- Connection pooling
- Query building
- Transactions

#### 🎭 Middleware
```dart
// CORS middleware
app.use(cors(
  allowOrigins: ['https://example.com'],
  allowMethods: ['GET', 'POST']
));

// Rate limiting
app.use(rateLimit(
  windowMs: Duration(minutes: 15),
  max: 100
));

// Request logging
app.use(requestLogger());
```

Features:
- CORS
- Rate limiting
- Request logging
- Authentication
- Compression
- Static files
- Error handling

#### 📊 Model & Pagination
```dart
// Model definition
class User extends Model {
  String? name;
  String? email;
  
  static String table = 'users';
  
  @column
  DateTime? createdAt;
}

// Pagination
final users = await User.paginate(
  page: 1,
  perPage: 20,
  where: {'active': true}
);
```

Features:
- Model attributes
- Model relationships
- Model events
- Model validation
- Pagination
- Cursor pagination
- Load more pagination

#### 🔄 Pipeline
```dart
// Create pipeline
final pipeline = Pipeline()
  .pipe(validateInput)
  .pipe(processData)
  .pipe(saveResult);

// Execute pipeline
final result = await pipeline.process(input);
```

Features:
- Pipeline pattern
- Middleware chains
- Error handling
- Pipeline stages
- Stage conditions
- Pipeline events
- Pipeline monitoring

#### 🖥️ View (`platform_view`)
```dart
// Render template
await res.render('welcome', {
  'user': user,
  'messages': messages
});

// Component rendering
@Component('user-card')
class UserCard extends ViewComponent {
  final User user;
  
  @override
  Future<String> render() async {
    return '''
      <div class="card">
        <h3>${user.name}</h3>
        <p>${user.email}</p>
      </div>
    ''';
  }
}
```

Features:
- Template rendering
- Layout system
- Component system
- Template inheritance
- Template caching
- Asset management
- View composers

#### 🔌 WebSocket
```dart
// WebSocket handler
app.ws('/chat', (socket) {
  socket.on('message', (data) async {
    await broadcast('chat', data);
  });
  
  socket.on('close', () {
    print('Client disconnected');
  });
});

// Client connection
final socket = await WebSocket.connect('/chat');
socket.listen(handleMessage);
```

Features:
- WebSocket server
- Client connections
- Message handling
- Broadcasting
- Room management
- Connection events
- Heartbeat

## 🚀 Getting Started

### Prerequisites

```bash
# Install Dart SDK (>=3.3.0)
curl -fsSL https://dart.dev/get-dart | bash

# Install Melos
dart pub global activate melos

# Clone repository
git clone https://github.com/protevus/platform.git
cd platform

# Setup project
melos bootstrap
```

### Creating a New Project

1. **Create project structure**:
```bash
dart create -t console my_app
cd my_app
```

2. **Add dependencies**:
```yaml
# pubspec.yaml
dependencies:
  platform_foundation: ^1.0.0
  platform_routing: ^1.0.0
  platform_auth: ^1.0.0
  platform_database: ^1.0.0
```

3. **Basic Application**:
```dart
import 'package:platform_foundation/platform_foundation.dart';
import 'package:platform_routing/platform_routing.dart';

void main() async {
  // Create application
  var app = Application();
  
  // Configure services
  app.configure((container) {
    container.singleton(DatabaseService());
    container.singleton(CacheService());
  });
  
  // Setup middleware
  app.use(cors());
  app.use(bodyParser());
  app.use(session());
  
  // Define routes
  app.group('/api/v1', (router) {
    router.resource('users', UserController());
    router.resource('posts', PostController());
  });
  
  // Error handling
  app.errorHandler = (e, req, res) async {
    await res.json({
      'error': e.message,
      'stack': e.stackTrace.toString()
    });
  };
  
  // Start server
  var port = int.parse(Platform.environment['PORT'] ?? '3000');
  await app.startServer('localhost', port);
  print('Server running on http://localhost:$port');
}
```

## 🛠️ Development Tools

### Melos Commands

```bash
# Development
melos run analyze     # Static analysis
melos run format      # Format code
melos run test        # Run tests
melos run coverage    # Generate coverage

# Documentation
melos run docs:generate  # Generate API docs
melos run docs:serve    # Serve docs locally

# Code Generation
melos run generate      # Run build_runner

# Project Creation
melos run create       # Create new package/app
melos run template     # Create from template
```

### VS Code Extensions

```bash
# Install recommended extensions
./helpers/install_code_extensions.sh
```

## 📚 Documentation

- [API Documentation](https://docs.protevus.com/api)
- [Guides and Tutorials](https://docs.protevus.com/guides)
- [Examples](https://docs.protevus.com/examples)
- [Best Practices](https://docs.protevus.com/best-practices)
- [Architecture Decisions](https://docs.protevus.com/architecture)
- [Contributing Guide](CONTRIBUTING.md)

## 🔧 Troubleshooting

### Common Issues

1. **Server won't start**:
   - Check port availability
   - Verify environment variables
   - Check logs in `storage/logs`

2. **Database connection issues**:
   - Verify connection string
   - Check database credentials
   - Ensure database service is running

3. **Authentication failures**:
   - Verify JWT secret
   - Check token expiration
   - Validate middleware order

### Debug Mode

```dart
// Enable debug mode
var app = Application(debug: true);

// Enable query logging
app.configure((container) {
  container.singleton(DatabaseService(
    logQueries: true,
    slowQueryThreshold: Duration(seconds: 1)
  ));
});
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Add tests for new features
- Update documentation
- Keep PRs focused and atomic

## 📄 License

Protevus Platform is open-source software licensed under the MIT license.

## 🙏 Acknowledgements

Built upon the foundation of Angel3 framework and inspired by Laravel's elegant API design. Special thanks to the creators and contributors of both frameworks for their invaluable work in advancing web development.

---

<p align="center">Built with ❤️ by the Protevus Team</p>
