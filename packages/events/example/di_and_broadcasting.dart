import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_events/events.dart';
import 'package:platform_contracts/contracts.dart';

/// Example event that should be broadcasted
class UserLoggedIn implements ShouldBroadcast {
  final String email;
  final DateTime timestamp;

  UserLoggedIn(this.email) : timestamp = DateTime.now();

  @override
  List<String> broadcastOn() => ['user-events', 'activity-log'];

  @override
  String broadcastAs() => 'user.logged_in';

  @override
  Map<String, dynamic> broadcastWith() => {
        'email': email,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  bool broadcastWhen() {
    final hour = timestamp.hour;
    return hour >= 9 && hour <= 17;
  }
}

/// Example service that depends on event dispatcher
class AuthenticationService {
  final EventDispatcherContract _events;

  AuthenticationService(this._events);

  Future<void> login(String email, String password) async {
    // Simulate authentication
    await Future.delayed(Duration(milliseconds: 100));

    // Dispatch login event
    await _events.dispatch(UserLoggedIn(email));

    print('User logged in: $email');
  }
}

void main() async {
  // Set up container
  final container = Container(MirrorsReflector());

  // Register event dispatcher
  final dispatcher = EventDispatcher(container);
  container.registerSingleton<EventDispatcherContract>(dispatcher);

  // Register auth service factory
  container.registerFactory<AuthenticationService>((container) {
    return AuthenticationService(
      container.make<EventDispatcherContract>()!,
    );
  });

  // Get auth service from container
  final auth = container.make<AuthenticationService>()!;

  // Register event listeners
  dispatcher.listen(UserLoggedIn, (event, data) {
    final login = data[0] as UserLoggedIn;
    print('Broadcast: User ${login.email} logged in at ${login.timestamp}');
  });

  // Perform login which will trigger event
  await auth.login('john@example.com', 'password123');

  // Example of using null dispatcher for testing
  final nullDispatcher = NullDispatcher();
  final testAuth = AuthenticationService(nullDispatcher);

  // This won't trigger any events
  await testAuth.login('test@example.com', 'password123');
}
