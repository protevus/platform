/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:collection';
import 'package:protevus_typeforge/cast.dart' as cast;
import 'package:protevus_typeforge/codable.dart';

/// A container for a dynamic data object that can be decoded into [Coding] objects.
///
/// A [KeyedArchive] is a [Map], but it provides additional behavior for decoding [Coding] objects
/// and managing JSON Schema references ($ref) through methods like [decode], [decodeObject], etc.
///
/// You create a [KeyedArchive] by invoking [KeyedArchive.unarchive] and passing data decoded from a
/// serialization format like JSON and YAML. A [KeyedArchive] is then provided as an argument to
/// a [Coding] subclass' [Coding.decode] method.
///
///         final json = json.decode(...);
///         final archive = KeyedArchive.unarchive(json);
///         final person = Person()..decode(archive);
///
/// You may also create [KeyedArchive]s from [Coding] objects so that they can be serialized.
///
///         final person = Person()..name = "Bob";
///         final archive = KeyedArchive.archive(person);
///         final json = json.encode(archive);
///
/// This class extends [Object] and mixes in [MapBase<String, dynamic>], allowing it to be used as a Map.
/// It also implements [Referenceable], providing functionality for handling references within the archive.
///
/// The constructor is not typically used directly; instead, use the [KeyedArchive.unarchive]
/// or [KeyedArchive.archive] methods to create instances of [KeyedArchive].
class KeyedArchive extends Object
    with MapBase<String, dynamic>
    implements Referenceable {
  /// Use [unarchive] instead.
  KeyedArchive(this._map) {
    _recode();
  }

  /// Unarchives [data] into a [KeyedArchive] that can be used by [Coding.decode] to deserialize objects.
  ///
  /// Each [Map] in [data] (including [data] itself) is converted to a [KeyedArchive].
  /// Each [List] in [data] is converted to a [ListArchive]. These conversions occur for deeply nested maps
  /// and lists.
  ///
  /// If [allowReferences] is true, JSON Schema references will be traversed and decoded objects
  /// will contain values from the referenced object. This flag defaults to false.
  KeyedArchive.unarchive(this._map, {bool allowReferences = false}) {
    _recode();
    if (allowReferences) {
      resolveOrThrow(ReferenceResolver(this));
    }
  }

  /// Archives a [Coding] object into a [Map] that can be serialized into formats like JSON or YAML.
  ///
  /// Note that the return value of this method, as well as all other [Map] and [List] objects
  /// embedded in the return value, are instances of [KeyedArchive] and [ListArchive]. These types
  /// implement [Map] and [List], respectively.
  ///
  /// If [allowReferences] is true, JSON Schema references in the emitted document will be validated.
  /// Defaults to false.
  static Map<String, dynamic> archive(
    Coding root, {
    bool allowReferences = false,
  }) {
    final archive = KeyedArchive({});
    root.encode(archive);
    if (allowReferences) {
      archive.resolveOrThrow(ReferenceResolver(archive));
    }
    return archive.toPrimitive();
  }

  /// Private constructor that creates an empty [KeyedArchive].
  ///
  /// This constructor initializes the internal [_map] with an empty Map<String, dynamic>.
  /// It's intended for internal use within the [KeyedArchive] class.
  KeyedArchive._empty() : _map = <String, dynamic>{};

  /// A reference to another object in the same document.
  ///
  /// This property represents a URI reference to another object within the same document.
  /// It is used to establish relationships between objects in a hierarchical structure.
  ///
  /// Assign values to this property using the default [Uri] constructor and its path argument.
  /// This property is serialized as a [Uri] fragment, e.g. `#/components/all`.
  ///
  /// Example:
  ///
  ///         final object = new MyObject()
  ///           ..referenceURI = Uri(path: "/other/object");
  ///         archive.encodeObject("object", object);
  ///
  Uri? referenceURI;

  /// The internal map that stores the key-value pairs of this [KeyedArchive].
  ///
  /// This map is used to store the actual data of the archive. It is of type
  /// `Map<String, dynamic>` to allow for flexibility in the types of values
  /// that can be stored. The keys are always strings, representing the names
  /// of the properties, while the values can be of any type.
  ///
  /// This map is manipulated by various methods of the [KeyedArchive] class,
  /// such as the [] operator, decode methods, and encode methods. It's also
  /// used when converting the archive to primitive types or when resolving
  /// references.
  Map<String, dynamic> _map;

  /// Stores the inflated (decoded) object associated with this archive.
  ///
  /// This property is used to cache the decoded object after it has been
  /// inflated from the archive data. It allows for efficient retrieval
  /// of the decoded object in subsequent accesses, avoiding repeated
  /// decoding operations.
  ///
  /// The type is [Coding?] to accommodate both null values (when no object
  /// has been inflated yet) and any object that implements the [Coding] interface.
  Coding? _inflated;

  /// A reference to another [KeyedArchive] object.
  ///
  /// This property is used to handle JSON Schema references ($ref).
  /// When a reference is resolved, this property holds the referenced [KeyedArchive] object.
  /// It allows the current archive to access values from the referenced object
  /// when a key is not found in the current archive's map.
  KeyedArchive? _objectReference;

  /// Typecast the values in this archive.
  ///
  /// Prefer to override [Coding.castMap] instead of using this method directly.
  ///
  /// This method will recursively type values in this archive to the desired type
  /// for a given key. Use this method (or [Coding.castMap]) for decoding `List` and `Map`
  /// types, where the values are not `Coding` objects.
  ///
  /// You must `import 'package:codable/cast.dart' as cast;`.
  ///
  /// Usage:
  ///
  ///         final dynamicObject = {
  ///           "key": <dynamic>["foo", "bar"]
  ///         };
  ///         final archive = KeyedArchive.unarchive(dynamicObject);
  ///         archive.castValues({
  ///           "key": cast.List(cast.String)
  ///         });
  ///
  ///         // This now becomes a valid assignment
  ///         List<String> key = archive.decode("key");
  ///
  /// This method takes a [schema] parameter of type `Map<String, cast.Cast>?`, which defines
  /// the types to cast for each key in the archive. If [schema] is null, the method returns
  /// without performing any casting. The method uses a flag [_casted] to ensure it only
  /// performs the casting once. It creates a [cast.Keyed] object with the provided schema
  /// and uses it to cast the values in both the main [_map] and the [_objectReference] map
  /// (if it exists). This ensures type safety and consistency across the entire archive structure.
  void castValues(Map<String, cast.Cast>? schema) {
    if (schema == null) {
      return;
    }
    if (_casted) return;
    _casted = true;
    final caster = cast.Keyed(schema);
    _map = caster.cast(_map);

    if (_objectReference != null) {
      _objectReference!._map = caster.cast(_objectReference!._map);
    }
  }

  /// A flag indicating whether the values in this archive have been cast.
  ///
  /// This boolean is used to ensure that the [castValues] method is only
  /// called once on this archive. It is set to true after the first call
  /// to [castValues], preventing redundant type casting operations.
  bool _casted = false;

  /// Sets the value associated with the given [key] in this [KeyedArchive].
  ///
  /// This operator allows you to assign values to keys in the archive as if it were a regular map.
  /// The [key] must be a [String], and [value] can be of any type.
  ///
  /// Example:
  ///   archive['name'] = 'John Doe';
  ///   archive['age'] = 30;
  ///
  /// Note that this method directly modifies the internal [_map] of the archive.
  /// It does not perform any type checking or conversion on the [value].
  @override
  void operator []=(covariant String key, dynamic value) {
    _map[key] = value;
  }

  /// Retrieves the value associated with the given [key] from this [KeyedArchive].
  ///
  /// This operator allows you to access values in the archive as if it were a regular map.
  /// The [key] must be a [String].
  ///
  /// If the key is found in the current archive's map, its value is returned.
  /// If not found and this archive has an [_objectReference], it attempts to retrieve
  /// the value from the referenced object.
  ///
  /// Example:
  ///   var name = archive['name'];
  ///   var age = archive['age'];
  ///
  /// Returns the value associated with [key], or null if the key is not found.
  @override
  dynamic operator [](covariant Object key) => _getValue(key as String);

  /// Returns an [Iterable] of all the keys in the archive.
  ///
  /// This getter provides access to all the keys stored in the internal [_map]
  /// of the [KeyedArchive]. It allows iteration over all keys without exposing
  /// the underlying map structure.
  ///
  /// Returns: An [Iterable<String>] containing all the keys in the archive.
  @override
  Iterable<String> get keys => _map.keys;

  /// Removes all entries from this [KeyedArchive].
  ///
  /// After this call, the archive will be empty.
  /// This method directly calls the [clear] method on the internal [_map].
  @override
  void clear() => _map.clear();

  /// Removes the entry for the given [key] from this [KeyedArchive] and returns its value.
  ///
  /// This method removes the key-value pair associated with [key] from the internal map
  /// of this [KeyedArchive]. If [key] was in the archive, its associated value is returned.
  /// If [key] was not in the archive, null is returned.
  ///
  /// The [key] should be a [String], as this is a [KeyedArchive]. However, the method
  /// accepts [Object?] to comply with the [MapBase] interface it implements.
  ///
  /// Returns the value associated with [key] before it was removed, or null if [key]
  /// was not in the archive.
  @override
  dynamic remove(Object? key) => _map.remove(key);

  /// Converts this [KeyedArchive] to a primitive [Map<String, dynamic>].
  ///
  /// This method recursively converts the contents of the archive to primitive types:
  /// - [KeyedArchive] instances are converted to [Map<String, dynamic>]
  /// - [ListArchive] instances are converted to [List<dynamic>]
  /// - Other values are left as-is
  ///
  /// This is useful when you need to serialize the archive to a format like JSON
  /// that doesn't support custom object types.
  ///
  /// Returns a new [Map<String, dynamic>] containing the primitive representation
  /// of this archive.
  Map<String, dynamic> toPrimitive() {
    final out = <String, dynamic>{};
    _map.forEach((key, val) {
      if (val is KeyedArchive) {
        out[key] = val.toPrimitive();
      } else if (val is ListArchive) {
        out[key] = val.toPrimitive();
      } else {
        out[key] = val;
      }
    });
    return out;
  }

  /// Retrieves the value associated with the given [key] from this [KeyedArchive].
  ///
  /// This method first checks if the key exists in the current archive's internal map.
  /// If found, it returns the associated value.
  /// If the key is not found in the current archive, and this archive has an [_objectReference],
  /// it attempts to retrieve the value from the referenced object recursively.
  ///
  /// Parameters:
  ///   [key] - The string key to look up in the archive.
  ///
  /// Returns:
  ///   The value associated with the [key] if found, or null if the key is not present
  ///   in either the current archive or any referenced archives.
  dynamic _getValue(String key) {
    if (_map.containsKey(key)) {
      return _map[key];
    }

    return _objectReference?._getValue(key);
  }

  /// Recodes the internal map of this [KeyedArchive].
  ///
  /// This method performs the following operations:
  /// 1. Creates a [cast.Map] caster for string keys and any values.
  /// 2. Iterates through all keys in the internal map.
  /// 3. For each key-value pair:
  ///    - If the value is a [Map], it's converted to a [KeyedArchive].
  ///    - If the value is a [List], it's converted to a [ListArchive].
  ///    - If the key is "$ref", it sets the [referenceURI] by parsing the value.
  ///
  /// This method is called during initialization to ensure proper structure
  /// and typing of the archive's contents.
  void _recode() {
    const caster = cast.Map(cast.string, cast.any);
    final keys = _map.keys.toList();
    for (final key in keys) {
      final val = _map[key];
      if (val is Map) {
        _map[key] = KeyedArchive(caster.cast(val));
      } else if (val is List) {
        _map[key] = ListArchive.from(val);
      } else if (key == r"$ref") {
        referenceURI = Uri.parse(Uri.parse(val.toString()).fragment);
      }
    }
  }

  /// Validates and resolves references within this [KeyedArchive] and its nested objects.
  ///
  /// This method is automatically invoked by both [KeyedArchive.unarchive] and [KeyedArchive.archive].
  @override
  void resolveOrThrow(ReferenceResolver coder) {
    if (referenceURI != null) {
      _objectReference = coder.resolve(referenceURI!);
      if (_objectReference == null) {
        throw ArgumentError(
          "Invalid document. Reference '#${referenceURI!.path}' does not exist in document.",
        );
      }
    }

    _map.forEach((key, val) {
      if (val is KeyedArchive) {
        val.resolveOrThrow(coder);
      } else if (val is ListArchive) {
        val.resolveOrThrow(coder);
      }
    });
  }

  /// Decodes a [KeyedArchive] into an object of type [T] that extends [Coding].
  ///
  /// This method is responsible for inflating (decoding) an object from its archived form.
  /// If the [raw] archive is null, the method returns null.
  ///
  /// If the archive has not been inflated before (i.e., [_inflated] is null),
  /// it creates a new instance using the [inflate] function, decodes the archive
  /// into this new instance, and caches it in [_inflated] for future use.
  ///
  /// Parameters:
  ///   [raw]: The [KeyedArchive] containing the encoded object data.
  ///   [inflate]: A function that returns a new instance of [T].
  ///
  /// Returns:
  ///   The decoded object of type [T], or null if [raw] is null.
  T? _decodedObject<T extends Coding?>(
    KeyedArchive? raw,
    T Function() inflate,
  ) {
    if (raw == null) {
      return null;
    }

    if (raw._inflated == null) {
      raw._inflated = inflate();
      raw._inflated!.decode(raw);
    }

    return raw._inflated as T?;
  }

  /// Returns the object associated with [key] in this [KeyedArchive].
  ///
  /// If [T] is inferred to be a [Uri] or [DateTime],
  /// the associated object is assumed to be a [String] and an appropriate value is parsed
  /// from that string.
  ///
  /// If this object is a reference to another object (via [referenceURI]), this object's key-value
  /// pairs will be searched first. If [key] is not found, the referenced object's key-values pairs are searched.
  /// If no match is found, null is returned.
  T? decode<T>(String key) {
    final v = _getValue(key);
    if (v == null) {
      return null;
    }

    if (T == Uri) {
      return Uri.parse(v.toString()) as T;
    } else if (T == DateTime) {
      return DateTime.parse(v.toString()) as T;
    }

    return v as T?;
  }

  /// Decodes and returns an instance of [T] associated with the given [key] in this [KeyedArchive].
  ///
  /// [inflate] must create an empty instance of [T]. The value associated with [key]
  /// must be a [KeyedArchive] (a [Map]). The values of the associated object are read into
  /// the empty instance of [T].
  T? decodeObject<T extends Coding>(String key, T Function() inflate) {
    final val = _getValue(key);
    if (val == null) {
      return null;
    }

    if (val is! KeyedArchive) {
      throw ArgumentError(
        "Cannot decode key '$key' into '$T', because the value is not a Map. Actual value: '$val'.",
      );
    }

    return _decodedObject(val, inflate);
  }

  /// Decodes and returns a list of objects of type [T] associated with the given [key] in this [KeyedArchive].
  ///
  /// [inflate] must create an empty instance of [T]. The value associated with [key]
  /// must be a [ListArchive] (a [List] of [Map]). For each element of the archived list,
  /// [inflate] is invoked and each object in the archived list is decoded into
  /// the instance of [T].
  List<T?>? decodeObjects<T extends Coding>(String key, T? Function() inflate) {
    final val = _getValue(key);
    if (val == null) {
      return null;
    }
    if (val is! List) {
      throw ArgumentError(
        "Cannot decode key '$key' as 'List<$T>', because value is not a List. Actual value: '$val'.",
      );
    }

    return val
        .map((v) => _decodedObject(v as KeyedArchive?, inflate))
        .toList()
        .cast<T?>();
  }

  /// Decodes and returns a map of objects of type [T] associated with the given [key] in this [KeyedArchive].
  ///
  /// [inflate] must create an empty instance of [T]. The value associated with [key]
  /// must be a [KeyedArchive] (a [Map]), where each value is a [T].
  /// For each key-value pair of the archived map, [inflate] is invoked and
  /// each value is decoded into the instance of [T].
  Map<String, T?>? decodeObjectMap<T extends Coding>(
    String key,
    T Function() inflate,
  ) {
    final v = _getValue(key);
    if (v == null) {
      return null;
    }

    if (v is! Map<String, dynamic>) {
      throw ArgumentError(
        "Cannot decode key '$key' as 'Map<String, $T>', because value is not a Map. Actual value: '$v'.",
      );
    }

    return {
      for (var k in v.keys) k: _decodedObject(v[k] as KeyedArchive?, inflate)
    };
  }

  /// Encodes a [Coding] object into a [Map<String, dynamic>] representation.
  ///
  /// This method creates a [KeyedArchive] from the given [object] and returns its
  /// internal map representation. If the [object] has a [referenceURI], it is
  /// encoded as a '$ref' key in the resulting map.
  ///
  /// If [object] is null, this method returns null.
  ///
  /// Note: There is a known limitation where overridden values from a reference
  /// object are not currently being emitted. This is due to the complexity of
  /// handling cyclic references between objects.
  ///
  /// Parameters:
  ///   [object]: The [Coding] object to be encoded.
  ///
  /// Returns:
  ///   A [Map<String, dynamic>] representation of the [object], or null if [object] is null.
  Map<String, dynamic>? _encodedObject(Coding? object) {
    if (object == null) {
      return null;
    }

    final json = KeyedArchive._empty()
      .._map = {}
      ..referenceURI = object.referenceURI;
    if (json.referenceURI != null) {
      json._map[r"$ref"] = Uri(fragment: json.referenceURI!.path).toString();
    } else {
      object.encode(json);
    }
    return json;
  }

  /// Encodes [value] into this object for [key].
  ///
  /// This method adds a key-value pair to the internal map of the [KeyedArchive].
  /// The [key] is always a [String], while [value] can be of any type.
  ///
  /// If [value] is null, no value is encoded and the [key] will not be present
  /// in the resulting archive.
  void encode(String key, dynamic value) {
    if (value == null) {
      return;
    }

    if (value is DateTime) {
      _map[key] = value.toIso8601String();
    } else if (value is Uri) {
      _map[key] = value.toString();
    } else {
      _map[key] = value;
    }
  }

  /// Encodes a [Coding] object into this object for [key].
  ///
  /// This method takes a [Coding] object [value] and encodes it into the archive
  /// under the specified [key]. If [value] is null, no action is taken and the method returns early.
  ///
  /// The encoding process involves:
  /// 1. Checking if the [value] is null.
  /// 2. If not null, it uses the private [_encodedObject] method to convert the [Coding] object
  ///    into a format suitable for storage in the archive.
  /// 3. The encoded object is then stored in the archive's internal map ([_map]) using the provided [key].
  ///
  /// This method is useful for adding complex objects that implement the [Coding] interface
  /// to the archive, allowing for structured data storage and later retrieval.
  ///
  /// Parameters:
  ///   [key]: A [String] that serves as the identifier for the encoded object in the archive.
  ///   [value]: A [Coding] object to be encoded and stored. Can be null.
  ///
  /// Example:
  ///   ```dart
  ///   final person = Person(name: "John", age: 30);
  ///   archive.encodeObject("person", person);
  ///   ```
  void encodeObject(String key, Coding? value) {
    if (value == null) {
      return;
    }

    _map[key] = _encodedObject(value);
  }

  /// Encodes a list of [Coding] objects into this archive for the given [key].
  ///
  /// This invokes [Coding.encode] on each object in [value] and adds the list of objects
  /// to this archive for the key [key].
  void encodeObjects(String key, List<Coding?>? value) {
    if (value == null) {
      return;
    }

    _map[key] = ListArchive.from(value.map((v) => _encodedObject(v)).toList());
  }

  /// Encodes a map of [Coding] objects into this archive for the given [key].
  ///
  /// This invokes [Coding.encode] on each value in [value] and adds the map of objects
  /// to this archive for the key [key].
  void encodeObjectMap<T extends Coding>(String key, Map<String, T?>? value) {
    if (value == null) return;
    final object = KeyedArchive({});
    value.forEach((k, v) {
      object[k] = _encodedObject(v);
    });

    _map[key] = object;
  }
}
