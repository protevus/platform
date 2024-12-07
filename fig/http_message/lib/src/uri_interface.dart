/// Value object representing a URI.
///
/// This interface is meant to represent URIs according to RFC 3986 and to
/// provide methods for most common operations.
abstract class UriInterface {
  /// Retrieve the scheme component of the URI.
  ///
  /// Returns the URI scheme or empty string if not present.
  String getScheme();

  /// Retrieve the authority component of the URI.
  ///
  /// Returns the URI authority in lowercase, or empty string if not present.
  String getAuthority();

  /// Retrieve the user information component of the URI.
  ///
  /// Returns the URI user information, or empty string if not present.
  String getUserInfo();

  /// Retrieve the host component of the URI.
  ///
  /// Returns the URI host in lowercase, or empty string if not present.
  String getHost();

  /// Retrieve the port component of the URI.
  ///
  /// Returns the URI port as an integer, or null if not present.
  int? getPort();

  /// Retrieve the path component of the URI.
  ///
  /// Returns the URI path.
  String getPath();

  /// Retrieve the query string of the URI.
  ///
  /// Returns the URI query string, or empty string if not present.
  String getQuery();

  /// Retrieve the fragment component of the URI.
  ///
  /// Returns the URI fragment, or empty string if not present.
  String getFragment();

  /// Return an instance with the specified scheme.
  ///
  /// [scheme] The scheme to use with the new instance.
  ///
  /// Returns a new instance with the specified scheme.
  /// Throws ArgumentError for invalid schemes.
  UriInterface withScheme(String scheme);

  /// Return an instance with the specified user information.
  ///
  /// [user] The user name to use for authority.
  /// [password] The password associated with [user].
  ///
  /// Returns a new instance with the specified user information.
  UriInterface withUserInfo(String user, [String? password]);

  /// Return an instance with the specified host.
  ///
  /// [host] The hostname to use with the new instance.
  ///
  /// Returns a new instance with the specified host.
  /// Throws ArgumentError for invalid hostnames.
  UriInterface withHost(String host);

  /// Return an instance with the specified port.
  ///
  /// [port] The port to use with the new instance.
  ///
  /// Returns a new instance with the specified port.
  /// Throws ArgumentError for invalid ports.
  UriInterface withPort(int? port);

  /// Return an instance with the specified path.
  ///
  /// [path] The path to use with the new instance.
  ///
  /// Returns a new instance with the specified path.
  /// Throws ArgumentError for invalid paths.
  UriInterface withPath(String path);

  /// Return an instance with the specified query string.
  ///
  /// [query] The query string to use with the new instance.
  ///
  /// Returns a new instance with the specified query string.
  /// Throws ArgumentError for invalid query strings.
  UriInterface withQuery(String query);

  /// Return an instance with the specified fragment.
  ///
  /// [fragment] The fragment to use with the new instance.
  ///
  /// Returns a new instance with the specified fragment.
  UriInterface withFragment(String fragment);

  /// Return the string representation of the URI.
  ///
  /// Returns string representation of the URI.
  String toString();
}
