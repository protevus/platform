/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/http.dart';

/// Specifies a matchable route path.
///
/// Contains [RouteSegment]s for each path segment. This class is used internally by [Router].
class RouteSpecification {
  /// Creates a [RouteSpecification] from a [String].
  ///
  /// The [patternString] must be stripped of any optionals.
  RouteSpecification(String patternString) {
    segments = _splitPathSegments(patternString);
    variableNames = segments
        .where((e) => e.isVariable)
        .map((e) => e.variableName!)
        .toList();
  }

  /// Creates a list of [RouteSpecification]s from a given route pattern.
  ///
  /// This method handles optional segments in the route pattern.
  /// @param routePattern The input route pattern string.
  /// @return A list of [RouteSpecification]s.
  static List<RouteSpecification> specificationsForRoutePattern(
    String routePattern,
  ) {
    return _pathsFromRoutePattern(routePattern)
        .map((path) => RouteSpecification(path))
        .toList();
  }

  /// A list of this specification's [RouteSegment]s.
  late List<RouteSegment> segments;

  /// A list of all variables in this route.
  late List<String> variableNames;

  /// A reference back to the [Controller] to be used when this specification is matched.
  Controller? controller;

  /// Returns a string representation of the route specification.
  @override
  String toString() => segments.join("/");
}

/// Generates a list of path strings from a given route pattern.
///
/// This function handles optional segments and regular expressions in the route pattern.
/// @param inputPattern The input route pattern string.
/// @return A list of path strings.
List<String> _pathsFromRoutePattern(String inputPattern) {
  var routePattern = inputPattern;
  var endingOptionalCloseCount = 0;
  while (routePattern.endsWith("]")) {
    routePattern = routePattern.substring(0, routePattern.length - 1);
    endingOptionalCloseCount++;
  }

  final chars = routePattern.codeUnits;
  final patterns = <String>[];
  final buffer = StringBuffer();
  final openOptional = '['.codeUnitAt(0);
  final openExpression = '('.codeUnitAt(0);
  final closeExpression = ')'.codeUnitAt(0);

  bool insideExpression = false;
  for (var i = 0; i < chars.length; i++) {
    final code = chars[i];

    if (code == openExpression) {
      if (insideExpression) {
        throw ArgumentError(
          "Router compilation failed. Route pattern '$routePattern' cannot use expression that contains '(' or ')'",
        );
      } else {
        buffer.writeCharCode(code);
        insideExpression = true;
      }
    } else if (code == closeExpression) {
      if (insideExpression) {
        buffer.writeCharCode(code);
        insideExpression = false;
      } else {
        throw ArgumentError(
          "Router compilation failed. Route pattern '$routePattern' cannot use expression that contains '(' or ')'",
        );
      }
    } else if (code == openOptional) {
      if (insideExpression) {
        buffer.writeCharCode(code);
      } else {
        patterns.add(buffer.toString());
      }
    } else {
      buffer.writeCharCode(code);
    }
  }

  if (insideExpression) {
    throw ArgumentError(
      "Router compilation failed. Route pattern '$routePattern' has unterminated regular expression.",
    );
  }

  if (endingOptionalCloseCount != patterns.length) {
    throw ArgumentError(
      "Router compilation failed. Route pattern '$routePattern' does not close all optionals.",
    );
  }

  // Add the final pattern - if no optionals, this is the only pattern.
  patterns.add(buffer.toString());

  return patterns;
}

/// Splits a path string into a list of [RouteSegment]s.
///
/// This function handles regular expressions within path segments.
/// @param inputPath The input path string.
/// @return A list of [RouteSegment]s.
List<RouteSegment> _splitPathSegments(String inputPath) {
  var path = inputPath;
  // Once we've gotten into this method, the path has been validated for optionals and regex and optionals have been removed.

  // Trim leading and trailing
  while (path.startsWith("/")) {
    path = path.substring(1, path.length);
  }
  while (path.endsWith("/")) {
    path = path.substring(0, path.length - 1);
  }

  final segments = <String>[];
  final chars = path.codeUnits;
  var buffer = StringBuffer();

  final openExpression = '('.codeUnitAt(0);
  final closeExpression = ')'.codeUnitAt(0);
  final pathDelimiter = '/'.codeUnitAt(0);
  bool insideExpression = false;

  for (var i = 0; i < path.length; i++) {
    final code = chars[i];

    if (code == openExpression) {
      buffer.writeCharCode(code);
      insideExpression = true;
    } else if (code == closeExpression) {
      buffer.writeCharCode(code);
      insideExpression = false;
    } else if (code == pathDelimiter) {
      if (insideExpression) {
        buffer.writeCharCode(code);
      } else {
        segments.add(buffer.toString());
        buffer = StringBuffer();
      }
    } else {
      buffer.writeCharCode(code);
    }
  }

  if (segments.any((seg) => seg == "")) {
    throw ArgumentError(
      "Router compilation failed. Route pattern '$path' contains an empty path segment.",
    );
  }

  // Add final
  segments.add(buffer.toString());

  return segments.map((seg) => RouteSegment(seg)).toList();
}
