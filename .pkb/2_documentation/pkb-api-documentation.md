# Protevus Platform API Documentation

This document provides an overview of the APIs and interfaces available in the Protevus Platform. It serves as a reference for developers working with the platform, allowing them to understand and utilize the various components and modules effectively.

## Foundation

The Foundation module provides the core functionality and services required by the Protevus Platform.

### Application

The `Application` class is the entry point for the Protevus Platform. It manages the application lifecycle, configuration, and dependency injection.

```dart
class Application {
  // ...

  /// Initializes the application.
  Future<void> initialize();

  /// Runs the application.
  Future<void> run();

  /// Terminates the application.
  Future<void> terminate();

  // ...
}
```
### Configuration

The Configuration class provides access to the application's configuration settings.

```dart
class Configuration {
  // ...

  /// Gets the value of a configuration setting.
  dynamic get(String key);

  /// Sets the value of a configuration setting.
  void set(String key, dynamic value);

  // ...
}
```
### HTTP

The HTTP module handles HTTP requests and responses, routing, middleware, and controller dispatching.

#### Router

The Router class defines the application's routes and maps them to controllers or middleware.

```dart
class Router {
  // ...

  /// Registers a GET route.
  void get(String path, dynamic handler);

  /// Registers a POST route.
  void post(String path, dynamic handler);

  // ...
}
```
#### Request

The Request class represents an incoming HTTP request.

```dart
class Request {
  // ...

  /// Gets the request method (GET, POST, etc.).
  String get method;

  /// Gets the request URL.
  Uri get url;

  /// Gets the request headers.
  Map<String, String> get headers;

  // ...
}
```
#### Response

The Response class represents an outgoing HTTP response.

```dart
class Response {
  // ...

  /// Sets the response status code.
  void setStatusCode(int statusCode);

  /// Sets a response header.
  void setHeader(String name, String value);

  /// Writes the response body.
  void write(String body);

  // ...
}
```

### View

The View module handles server-side rendering of views and templating.

#### ViewFactory

The ViewFactory class is responsible for creating and rendering views.

```dart
class ViewFactory {
  // ...

  /// Creates a new view instance.
  View make(String view, Map<String, dynamic> data);

  /// Renders a view and returns the rendered output.
  String render(String view, Map<String, dynamic> data);

  // ...
}
```

#### View

The View class represents a server-side view.

```dart
class View {
  // ...

  /// Renders the view and returns the rendered output.
  String render();

  // ...
}
```

### Database

The Database module provides an abstraction layer for interacting with databases, including query builders, object-relational mapping (ORM), and schema migrations.

##### QueryBuilder

The QueryBuilder class allows you to construct and execute database queries.

```dart
class QueryBuilder {
  // ...

  /// Adds a WHERE clause to the query.
  QueryBuilder where(String column, dynamic value);

  /// Executes the query and returns the results.
  Future<List<Map<String, dynamic>>> get();

  // ...
}
```
#### Model

The Model class represents a database table and provides an ORM-like interface for interacting with the data.

```dart
class Model {
  // ...

  /// Creates a new instance of the model.
  Model({Map<String, dynamic> attributes});

  /// Saves the model instance to the database.
  Future<void> save();

  // ...
}
```

### Authentication and Authorization

The Authentication and Authorization module handles user authentication, authorization, and access control mechanisms.

#### AuthManager

The AuthManager class manages user authentication and provides methods for logging in, logging out, and checking authentication status.

```dart
class AuthManager {
  // ...

  /// Attempts to log in a user with the provided credentials.
  Future<bool> login(String email, String password);

  /// Logs out the currently authenticated user.
  Future<void> logout();

  /// Checks if a user is authenticated.
  bool isAuthenticated();

  // ...
}
```

#### Gate

The Gate class provides an interface for defining and checking user permissions and authorizations.

```dart
class Gate {
  // ...

  /// Defines a new permission or authorization.
  void define(String ability, dynamic callback);

  /// Checks if the current user has the specified permission or authorization.
  Future<bool> allows(String ability);

  // ...
}
```

### Events and Queues

The Events and Queues module handles real-time event broadcasting and background job processing.

#### EventDispatcher

The EventDispatcher class is responsible for dispatching and listening to application events.

```dart
class EventDispatcher {
  // ...

  /// Dispatches an event.
  void dispatch(Event event);

  /// Registers an event listener.
  void listen(String eventName, EventListener listener);

  // ...
}
```

#### Queue

The Queue class manages background job processing and task scheduling.

```dart
class Queue {
  // ...

  /// Pushes a new job onto the queue.
  void push(Job job);

  /// Processes the next job in the queue.
  Future<void> processNext();

  // ...
}
```




