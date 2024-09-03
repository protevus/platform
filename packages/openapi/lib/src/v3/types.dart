/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Represents the different data types that can be used in an API.
///
/// This enumeration defines the following types:
/// - [string]: Represents a sequence of characters.
/// - [number]: Represents a numeric value, which can include decimals.
/// - [integer]: Represents a whole number without decimals.
/// - [boolean]: Represents a true or false value.
/// - [array]: Represents a collection of values.
/// - [object]: Represents a complex data structure with key-value pairs.
enum APIType { string, number, integer, boolean, array, object }

/// A utility class for encoding and decoding [APIType] values.
///
/// This class provides static methods to convert between [APIType] enum values
/// and their corresponding string representations.
class APITypeCodec {
  /// Decodes a string representation of an [APIType] to its corresponding enum value.
  ///
  /// This method takes a [String] parameter [type] and returns the corresponding
  /// [APIType] enum value. If the input string doesn't match any known type,
  /// the method returns null.
  ///
  /// Parameters:
  ///   - type: A [String] representing the API type to be decoded.
  ///
  /// Returns:
  ///   The corresponding [APIType] enum value, or null if no match is found.
  static APIType? decode(String? type) {
    switch (type) {
      case "string":
        return APIType.string;
      case "number":
        return APIType.number;
      case "integer":
        return APIType.integer;
      case "boolean":
        return APIType.boolean;
      case "array":
        return APIType.array;
      case "object":
        return APIType.object;
      default:
        return null;
    }
  }

  /// Encodes an [APIType] enum value to its corresponding string representation.
  ///
  /// This method takes an [APIType] parameter [type] and returns the corresponding
  /// string representation. If the input type is null or doesn't match any known type,
  /// the method returns null.
  ///
  /// Parameters:
  ///   - type: An [APIType] enum value to be encoded.
  ///
  /// Returns:
  ///   The corresponding [String] representation of the [APIType], or null if the input is null or no match is found.
  static String? encode(APIType? type) {
    switch (type) {
      case APIType.string:
        return "string";
      case APIType.number:
        return "number";
      case APIType.integer:
        return "integer";
      case APIType.boolean:
        return "boolean";
      case APIType.array:
        return "array";
      case APIType.object:
        return "object";
      default:
        return null;
    }
  }
}
