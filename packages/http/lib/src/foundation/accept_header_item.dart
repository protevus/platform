import 'package:protevus_http/foundation.dart';

/// Represents an Accept-* header item.
class AcceptHeaderItem {
  String _value;
  double _quality = 1.0;
  int _index = 0;
  final Map<String, String> _attributes = {};

  /// Constructs an AcceptHeaderItem with a value and optional attributes.
  AcceptHeaderItem(this._value, [Map<String, String>? attributes]) {
    if (attributes != null) {
      attributes.forEach((name, value) {
        setAttribute(name, value);
      });
    }
  }

  /// Builds an AcceptHeaderItem instance from a string.
  static AcceptHeaderItem fromString(String? itemValue) {
    final parts = HeaderUtils.split(itemValue ?? '', ';=');

    if (parts.isEmpty) {
      throw ArgumentError('Invalid header value');
    }

    final value = parts[0][0];
    final attributes = HeaderUtils.combine(parts.sublist(1));

    return AcceptHeaderItem(value, attributes.cast<String, String>());
  }

  /// Returns header value's string representation.
  @override
  String toString() {
    final attributes = Map<String, dynamic>.from(_attributes);
    if (_quality < 1) {
      attributes['q'] = _quality.toString();
    }
    return _value +
        (attributes.isNotEmpty
            ? '; ${HeaderUtils.headerToString(attributes, ';')}'
            : '');
  }

  /// Set the item value.
  AcceptHeaderItem setValue(String value) {
    _value = value;
    return this;
  }

  /// Returns the item value.
  String getValue() => _value;

  /// Set the item quality.
  AcceptHeaderItem setQuality(double quality) {
    _quality = quality;
    return this;
  }

  /// Returns the item quality.
  double getQuality() => _quality;

  /// Set the item index.
  AcceptHeaderItem setIndex(int index) {
    _index = index;
    return this;
  }

  /// Returns the item index.
  int getIndex() => _index;

  /// Tests if an attribute exists.
  bool hasAttribute(String name) => _attributes.containsKey(name);

  /// Returns an attribute by its name.
  dynamic getAttribute(String name, {dynamic defaultValue}) {
    return _attributes[name] ?? defaultValue;
  }

  /// Returns all attributes.
  Map<String, String> getAttributes() => Map.from(_attributes);

  /// Set an attribute.
  AcceptHeaderItem setAttribute(String name, String value) {
    if (name == 'q') {
      _quality = double.parse(value);
    } else {
      _attributes[name] = value;
    }
    return this;
  }
}
