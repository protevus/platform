/// AST nodes for the Blade template engine
library blade.ast;

import 'package:source_span/source_span.dart';

// Import all node types needed for the visitors
import 'ast_node.dart';
import 'components.dart';
import 'directives.dart';
import 'template.dart';

// Then export everything
export 'ast_node.dart';
export 'components.dart';
export 'directives.dart';
export 'template.dart';

// Re-export source_span for consumers
export 'package:source_span/source_span.dart' show FileSpan, SourceLocation;

/// The type of error in template parsing or compilation
enum BladeErrorSeverity {
  /// A warning that doesn't prevent compilation
  warning,

  /// An error that prevents compilation
  error,
}

/// Represents an error in template parsing or compilation
class BladeError implements Exception {
  /// The severity of the error
  final BladeErrorSeverity severity;

  /// The error message
  final String message;

  /// The source span where the error occurred
  final FileSpan span;

  /// The underlying error, if any
  final Object? cause;

  BladeError(
    this.severity,
    this.message,
    this.span, [
    this.cause,
  ]);

  @override
  String toString() {
    var type = severity == BladeErrorSeverity.warning ? 'Warning' : 'Error';
    var location = span.start;
    var preview = span.highlight();

    return '''
$type: $message
  at line ${location.line + 1}, column ${location.column + 1}
  in ${location.sourceUrl ?? 'unknown source'}

$preview
''';
  }
}

/// A visitor for traversing the AST
abstract class AstVisitor<T> {
  T? visitNode(AstNode node);
  T? visitTemplate(TemplateNode node);
  T? visitElement(ElementNode node);
  T? visitText(TextNode node);
  T? visitComponent(ComponentNode node);
  T? visitDirective(BladeDirective node);
  T? visitExpression(ExpressionNode node);
  T? visitComment(CommentNode node);
  T? visitBladeComment(BladeCommentNode node);
  T? visitPhp(DartNode node);
  T? visitError(ErrorNode node);
}

/// A visitor that recursively traverses the AST
abstract class RecursiveAstVisitor<T> extends AstVisitor<T> {
  @override
  T? visitNode(AstNode node) {
    if (node is TemplateNode) return visitTemplate(node);
    if (node is ElementNode) return visitElement(node);
    if (node is TextNode) return visitText(node);
    if (node is ComponentNode) return visitComponent(node);
    if (node is BladeDirective) return visitDirective(node);
    if (node is ExpressionNode) return visitExpression(node);
    if (node is CommentNode) return visitComment(node);
    if (node is BladeCommentNode) return visitBladeComment(node);
    if (node is DartNode) return visitPhp(node);
    if (node is ErrorNode) return visitError(node);
    return null;
  }

  @override
  T? visitTemplate(TemplateNode node) {
    for (var child in node.children) {
      visitNode(child);
    }
    for (var section in node.sections.values) {
      visitNode(section);
    }
    for (var yield_ in node.yields.values) {
      visitNode(yield_);
    }
    return null;
  }

  @override
  T? visitElement(ElementNode node) {
    for (var child in node.children) {
      visitNode(child);
    }
    return null;
  }

  @override
  T? visitComponent(ComponentNode node) {
    for (var attr in node.attributes.entries) {
      if (attr.value is AstNode) {
        visitNode(attr.value as AstNode);
      }
    }
    for (var slot in node.slots.values) {
      for (var child in slot) {
        visitNode(child);
      }
    }
    for (var child in node.children) {
      visitNode(child);
    }
    return null;
  }

  @override
  T? visitDirective(BladeDirective node) {
    for (var child in node.children) {
      visitNode(child);
    }
    return null;
  }

  @override
  T? visitText(TextNode node) => null;

  @override
  T? visitExpression(ExpressionNode node) => null;

  @override
  T? visitComment(CommentNode node) => null;

  @override
  T? visitBladeComment(BladeCommentNode node) => null;

  @override
  T? visitPhp(DartNode node) => null;

  @override
  T? visitError(ErrorNode node) => null;
}
