/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Represents the different data types used in API responses and requests.
///
/// This enum defines the following types:
/// - [string]: Represents textual data.
/// - [number]: Represents numeric data, including floating-point numbers.
/// - [integer]: Represents whole number values.
/// - [boolean]: Represents true/false values.
/// - [array]: Represents a collection of values.
/// - [file]: Represents file data.
/// - [object]: Represents complex structured data.
enum APIType { string, number, integer, boolean, array, file, object }

/// A utility class for encoding and decoding [APIType] values.
///
/// This class provides static methods to convert between [APIType] enum values
/// and their corresponding string representations.
class APITypeCodec {
  /// Decodes a string representation of an API type into its corresponding [APIType] enum value.
  ///
  /// This method takes a [String] parameter [type] and returns the matching [APIType] enum value.
  /// If the input string doesn't match any known API type, the method returns null.
  ///
  /// Parameters:
  ///   [type]: A string representation of the API type.
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
      case "file":
        return APIType.file;
      case "object":
        return APIType.object;
    }
    return null;
  }

  /// Encodes an [APIType] enum value into its corresponding string representation.
  ///
  /// This method takes an [APIType] parameter [type] and returns the matching string representation.
  /// If the input [APIType] is null or doesn't match any known API type, the method returns null.
  ///
  /// Parameters:
  ///   [type]: An [APIType] enum value.
  ///
  /// Returns:
  ///   The corresponding string representation of the [APIType], or null if no match is found or input is null.
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
      case APIType.file:
        return "file";
      case APIType.object:
        return "object";
      default:
        return null;
    }
  }
}
