import 'dart:convert';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_collections/collections.dart';

/// Provides functionality for working with data arrays.
///
/// This trait provides methods for getting and setting data,
/// checking if data exists, merging data, and converting to array/JSON.
mixin InteractsWithData implements Arrayable, Jsonable {
  /// The data for the instance.
  final Map<String, dynamic> _data = {};

  /// Get an item from the data array using "dot" notation.
  T? get<T>(String key, [T? defaultValue]) {
    return Arr.get<T>(_data, key, defaultValue);
  }

  /// Set a value in the data array using "dot" notation.
  void set(String key, dynamic value) {
    Arr.set(_data, key, value);
  }

  /// Check if an item exists in the data array using "dot" notation.
  bool has(String key) {
    return Arr.has(_data, key);
  }

  /// Remove an item from the data array using "dot" notation.
  void remove(String key) {
    Arr.forget(_data, key);
  }

  /// Merge the given data into the instance's data.
  void merge(Map<String, dynamic> data) {
    _deepMerge(_data, data);
  }

  /// Get all of the data for the instance.
  Map<String, dynamic> getData() {
    return Map<String, dynamic>.from(_data);
  }

  @override
  Map<String, dynamic> toArray() {
    return getData();
  }

  @override
  String toJson([Map<String, dynamic>? options]) {
    return jsonEncode(toArray());
  }

  /// Recursively merge two maps.
  void _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        if (!target.containsKey(key)) {
          target[key] = <String, dynamic>{};
        }
        if (target[key] is Map<String, dynamic>) {
          _deepMerge(target[key] as Map<String, dynamic>, value);
        } else {
          target[key] = value;
        }
      } else {
        target[key] = value;
      }
    });
  }
}
