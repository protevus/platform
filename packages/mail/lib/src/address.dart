/// Represents an email address with an optional display name.
class Address {
  /// The email address.
  final String email;

  /// The optional display name associated with the email address.
  final String? name;

  /// Creates a new email address.
  ///
  /// The [email] parameter must be a valid email address.
  /// The [name] parameter is optional and represents the display name.
  const Address(this.email, [this.name]);

  /// Parses an email address string.
  ///
  /// Supports formats:
  /// - Plain email: "test@example.com"
  /// - With name: "Test User <test@example.com>"
  /// - With quoted name: "\"Test, User\" <test@example.com>"
  factory Address.parse(String input) {
    // Try to match "name <email>" format
    final namedMatch =
        RegExp(r'^(?:"([^"]+)"|([^<]+))\s*<([^>]+)>$').firstMatch(input);
    if (namedMatch != null) {
      final quotedName = namedMatch.group(1);
      final unquotedName = namedMatch.group(2);
      final email = namedMatch.group(3)!;
      final name = (quotedName ?? unquotedName)?.trim();
      return Address(email, name);
    }

    // Assume plain email address
    return Address(input);
  }

  /// Creates an address from a map.
  ///
  /// The map must contain an 'email' key and may contain a 'name' key.
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      map['email'] as String,
      map['name'] as String?,
    );
  }

  /// Converts the address to a map.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }

  /// Returns a string representation of the address.
  ///
  /// If a name is present, returns the format "Name <email@example.com>".
  /// Otherwise, returns just the email address.
  @override
  String toString() {
    if (name != null && name!.isNotEmpty) {
      return '$name <$email>';
    }
    return email;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.email == email && other.name == name;
  }

  @override
  int get hashCode => Object.hash(email, name);
}
