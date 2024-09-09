/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/http.dart';

/// Represents a segment of a route path.
class RouteSegment {
  /// Creates a new RouteSegment from a string segment.
  ///
  /// [segment] The string representation of the route segment.
  RouteSegment(String segment) {
    if (segment == "*") {
      isRemainingMatcher = true;
      return;
    }

    final regexIndex = segment.indexOf("(");
    if (regexIndex != -1) {
      final regexText = segment.substring(regexIndex + 1, segment.length - 1);
      matcher = RegExp(regexText);

      segment = segment.substring(0, regexIndex);
    }

    if (segment.startsWith(":")) {
      variableName = segment.substring(1, segment.length);
    } else if (regexIndex == -1) {
      literal = segment;
    }
  }

  /// Creates a new RouteSegment directly with specified properties.
  ///
  /// [literal] The literal string of the segment.
  /// [variableName] The name of the variable if this is a variable segment.
  /// [expression] The regular expression string for matching.
  /// [matchesAnything] Whether this segment matches anything (like "*").
  RouteSegment.direct({
    this.literal,
    this.variableName,
    String? expression,
    bool matchesAnything = false,
  }) {
    isRemainingMatcher = matchesAnything;
    if (expression != null) {
      matcher = RegExp(expression);
    }
  }

  /// The literal string of the segment.
  String? literal;

  /// The name of the variable if this is a variable segment.
  String? variableName;

  /// The regular expression for matching this segment.
  RegExp? matcher;

  /// Whether this segment is a literal matcher.
  bool get isLiteralMatcher =>
      !isRemainingMatcher && !isVariable && !hasRegularExpression;

  /// Whether this segment has a regular expression for matching.
  bool get hasRegularExpression => matcher != null;

  /// Whether this segment is a variable.
  bool get isVariable => variableName != null;

  /// Whether this segment matches all remaining segments.
  bool isRemainingMatcher = false;

  /// Checks if this RouteSegment is equal to another object.
  ///
  /// Returns true if the [other] object is a RouteSegment and has the same
  /// [literal], [variableName], [isRemainingMatcher], and [matcher] pattern.
  ///
  /// [other] The object to compare with this RouteSegment.
  @override
  bool operator ==(Object other) =>
      other is RouteSegment &&
      literal == other.literal &&
      variableName == other.variableName &&
      isRemainingMatcher == other.isRemainingMatcher &&
      matcher?.pattern == other.matcher?.pattern;

  /// Generates a hash code for this RouteSegment.
  ///
  /// The hash code is based on either the [literal] value or the [variableName],
  /// whichever is not null. This ensures that RouteSegments with the same
  /// literal or variable name will have the same hash code.
  ///
  /// Returns an integer hash code value.
  @override
  int get hashCode => (literal ?? variableName).hashCode;

  /// Returns a string representation of the RouteSegment.
  ///
  /// The string representation depends on the type of the segment:
  /// - For a literal matcher, it returns the literal value.
  /// - For a variable segment, it returns the variable name.
  /// - For a segment with a regular expression, it returns the pattern enclosed in parentheses.
  /// - For a remaining matcher (wildcard), it returns "*".
  ///
  /// Returns a string representing the RouteSegment.
  @override
  String toString() {
    if (isLiteralMatcher) {
      return literal ?? "";
    }

    if (isVariable) {
      return variableName ?? "";
    }

    if (hasRegularExpression) {
      return "(${matcher!.pattern})";
    }

    return "*";
  }
}

/// Represents a node in the route tree.
class RouteNode {
  /// Creates a new RouteNode from a list of route specifications.
  ///
  /// [specs] The list of route specifications.
  /// [depth] The depth of this node in the route tree.
  /// [matcher] The regular expression matcher for this node.
  RouteNode(List<RouteSpecification?> specs, {int depth = 0, RegExp? matcher}) {
    patternMatcher = matcher;

    final terminatedAtThisDepth =
        specs.where((spec) => spec?.segments.length == depth).toList();
    if (terminatedAtThisDepth.length > 1) {
      throw ArgumentError(
        "Router compilation failed. Cannot disambiguate from the following routes: $terminatedAtThisDepth.",
      );
    } else if (terminatedAtThisDepth.length == 1) {
      specification = terminatedAtThisDepth.first;
    }

    final remainingSpecifications = List<RouteSpecification?>.from(
      specs.where((spec) => depth != spec?.segments.length),
    );

    final Set<String> childEqualitySegments = Set.from(
      remainingSpecifications
          .where((spec) => spec?.segments[depth].isLiteralMatcher ?? false)
          .map((spec) => spec!.segments[depth].literal),
    );

    for (final childSegment in childEqualitySegments) {
      final childrenBeginningWithThisSegment = remainingSpecifications
          .where((spec) => spec?.segments[depth].literal == childSegment)
          .toList();
      equalityChildren[childSegment] =
          RouteNode(childrenBeginningWithThisSegment, depth: depth + 1);
      remainingSpecifications
          .removeWhere(childrenBeginningWithThisSegment.contains);
    }

    final takeAllSegment = remainingSpecifications.firstWhere(
      (spec) => spec?.segments[depth].isRemainingMatcher ?? false,
      orElse: () => null,
    );
    if (takeAllSegment != null) {
      takeAllChild = RouteNode.withSpecification(takeAllSegment);
      remainingSpecifications.removeWhere(
        (spec) => spec?.segments[depth].isRemainingMatcher ?? false,
      );
    }

    final Set<String?> childPatternedSegments = Set.from(
      remainingSpecifications
          .map((spec) => spec?.segments[depth].matcher?.pattern),
    );

    patternedChildren = childPatternedSegments.map((pattern) {
      final childrenWithThisPattern = remainingSpecifications
          .where((spec) => spec?.segments[depth].matcher?.pattern == pattern)
          .toList();

      if (childrenWithThisPattern
              .any((spec) => spec?.segments[depth].matcher == null) &&
          childrenWithThisPattern
              .any((spec) => spec?.segments[depth].matcher != null)) {
        throw ArgumentError(
          "Router compilation failed. Cannot disambiguate from the following routes, as one of them will match anything: $childrenWithThisPattern.",
        );
      }

      return RouteNode(
        childrenWithThisPattern,
        depth: depth + 1,
        matcher: childrenWithThisPattern.first?.segments[depth].matcher,
      );
    }).toList();
  }

  /// Creates a new RouteNode with a specific route specification.
  ///
  /// [specification] The route specification for this node.
  RouteNode.withSpecification(this.specification);

  /// Regular expression matcher for this node. May be null.
  RegExp? patternMatcher;

  /// The controller associated with this route node.
  Controller? get controller => specification?.controller;

  /// The route specification for this node.
  RouteSpecification? specification;

  /// Children nodes that are matched using regular expressions.
  List<RouteNode> patternedChildren = [];

  /// Children nodes that are matched using string equality.
  Map<String, RouteNode> equalityChildren = {};

  /// Child node that matches all remaining segments.
  RouteNode? takeAllChild;

  /// Finds the appropriate node for the given path segments.
  ///
  /// [requestSegments] An iterator of the path segments.
  /// [path] The full request path.
  ///
  /// Returns the matching RouteNode or null if no match is found.
  RouteNode? nodeForPathSegments(
    Iterator<String> requestSegments,
    RequestPath path,
  ) {
    if (!requestSegments.moveNext()) {
      return this;
    }

    final nextSegment = requestSegments.current;

    if (equalityChildren.containsKey(nextSegment)) {
      return equalityChildren[nextSegment]!
          .nodeForPathSegments(requestSegments, path);
    }

    for (final node in patternedChildren) {
      if (node.patternMatcher == null) {
        // This is a variable with no regular expression
        return node.nodeForPathSegments(requestSegments, path);
      }

      if (node.patternMatcher!.firstMatch(nextSegment) != null) {
        // This segment has a regular expression
        return node.nodeForPathSegments(requestSegments, path);
      }
    }

    // If this is null, then we return null from this method
    // and the router knows we didn't find a match.
    return takeAllChild;
  }

  /// Generates a string representation of the RouteNode and its children.
  ///
  /// This method creates a hierarchical string representation of the RouteNode,
  /// including information about the pattern matcher, associated controller,
  /// and child nodes. The representation is indented based on the depth of the
  /// node in the route tree.
  ///
  /// [depth] The depth of this node in the route tree, used for indentation.
  ///
  /// Returns a string representation of the RouteNode and its children.
  @override
  String toString({int depth = 0}) {
    final buf = StringBuffer();
    for (var i = 0; i < depth; i++) {
      buf.write("\t");
    }

    if (patternMatcher != null) {
      buf.write("(match: ${patternMatcher!.pattern})");
    }

    buf.writeln(
      "Controller: ${specification?.controller?.nextController?.runtimeType}",
    );
    equalityChildren.forEach((seg, spec) {
      for (var i = 0; i < depth; i++) {
        buf.write("\t");
      }

      buf.writeln("/$seg");
      buf.writeln(spec.toString(depth: depth + 1));
    });

    return buf.toString();
  }
}
