# Broadcasting Package

A Dart implementation of Laravel's broadcasting system, providing real-time event broadcasting capabilities using various drivers.

## Features

- Full Laravel Broadcasting API compatibility
- Support for public, private, and presence channels
- Pusher driver implementation
- Channel authentication and authorization
- WebSocket-based real-time communication
- Pattern-based channel authorization

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  protevus_broadcasting: ^0.0.1
```

## Usage

### Basic Setup

```dart
import 'package:protevus_broadcasting/broadcasting.dart';

// Create a Pusher broadcaster instance
final broadcaster = await PusherFactory.create(
  key: 'your-pusher-key',
  secret: 'your-pusher-secret',
  cluster: 'your-pusher-cluster',
);

// Register it with the broadcast manager
final manager = BroadcastManager();
await manager.registerDriver('pusher', (config) => broadcaster);
manager.defaultDriver = 'pusher';
```

### Channel Types

The package supports three types of channels:

```dart
// Public channels
final publicChannel = Channel('my-channel');

// Private channels (require authentication)
final privateChannel = PrivateChannel('user-updates');

// Presence channels (for user presence features)
final presenceChannel = PresenceChannel('chat-room');

// Encrypted private channels
final encryptedChannel = EncryptedPrivateChannel('secure-updates');
```

### Broadcasting Events

```dart
// Broadcasting to a single channel
await manager.broadcastTo(
  privateChannel,
  'new-message',
  {
    'message': 'Hello, world!',
    'user': 'John',
  },
);

// Broadcasting to multiple channels
await manager.broadcast(
  [privateChannel, presenceChannel],
  'status-update',
  {
    'status': 'online',
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

### Channel Authentication

```dart
// Register authentication callback for private channels
broadcaster.registerAuthCallback(
  'private-*',
  (channelName, auth) async {
    // Implement your authentication logic here
    return true; // or false to deny access
  },
);

// Register authentication callback for presence channels
broadcaster.registerPresenceAuthCallback(
  'presence-*',
  (channelName, auth) async {
    // Return user data for presence channel
    return {
      'id': 'user-123',
      'name': 'John Doe',
      'email': 'john@example.com',
    };
  },
);
```

### Local Development

For local development with Laravel, you can use the convenient local factory method:

```dart
final broadcaster = await PusherFactory.createLocal(
  key: 'app-key',
  secret: 'app-secret',
  // Optional: customize host and port
  host: 'localhost',
  port: 6001,
);
```

### Error Handling

The package uses the `BroadcastException` class for error handling:

```dart
try {
  await manager.broadcastTo(channel, 'event', data);
} on BroadcastException catch (e) {
  print('Broadcasting failed: ${e.message}');
  if (e.error != null) {
    print('Underlying error: ${e.error}');
  }
}
```

## Laravel Compatibility

This package maintains API compatibility with Laravel's broadcasting system, making it easy to use with existing Laravel backends. The authentication system matches Laravel's implementation, ensuring seamless integration.

### Key Differences from Laravel

While we maintain API compatibility, there are some Dart-specific adaptations:

1. Async/await is used instead of PHP promises
2. Strong typing is enforced where appropriate
3. Dart-idiomatic naming conventions are used in some cases

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This package is open-sourced software licensed under the MIT license.
