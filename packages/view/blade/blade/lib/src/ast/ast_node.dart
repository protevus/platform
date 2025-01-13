import 'package:source_span/source_span.dart';

/// Base class for all AST nodes in the Blade template system.
abstract class AstNode {
  /// The source span for this node, used for error reporting.
  FileSpan get span;

  /// Optional parent node, useful for traversing the AST.
  AstNode? get parent;
  set parent(AstNode? value);
}

/// Mixin to provide parent node tracking.
mixin ParentAware implements AstNode {
  AstNode? _parent;

  @override
  AstNode? get parent => _parent;

  @override
  set parent(AstNode? value) {
    _parent = value;
  }
}

/// Base class for nodes that can contain child nodes.
abstract class ContainerNode extends AstNode with ParentAware {
  final List<AstNode> children;

  ContainerNode(this.children) {
    for (var child in children) {
      child.parent = this;
    }
  }
}

/// Base class for nodes that represent raw text content.
class TextNode extends AstNode with ParentAware {
  final FileSpan span;
  final String text;

  TextNode(this.span, this.text);
}

/// Base class for nodes that represent HTML elements.
class ElementNode extends ContainerNode {
  final FileSpan span;
  final String tagName;
  final Map<String, String> attributes;
  final bool selfClosing;

  ElementNode(
    this.span,
    this.tagName,
    this.attributes,
    List<AstNode> children, {
    this.selfClosing = false,
  }) : super(children);
}

/// Base class for nodes that represent Blade directives.
abstract class DirectiveNode extends ContainerNode {
  final FileSpan span;
  final String name;

  DirectiveNode(this.span, this.name, List<AstNode> children) : super(children);
}

/// Base class for nodes that represent expressions.
abstract class ExpressionNode extends AstNode with ParentAware {
  final FileSpan span;

  ExpressionNode(this.span);

  /// Evaluate the expression with the given context.
  dynamic evaluate(Map<String, dynamic> context);
}

/// Node representing a variable reference.
class VariableNode extends ExpressionNode {
  final String name;

  VariableNode(FileSpan span, this.name) : super(span);

  @override
  dynamic evaluate(Map<String, dynamic> context) => context[name];
}

/// Node representing a literal value.
class LiteralNode extends ExpressionNode {
  final dynamic value;

  LiteralNode(FileSpan span, this.value) : super(span);

  @override
  dynamic evaluate(Map<String, dynamic> context) => value;
}

/// Node representing string interpolation.
class InterpolationNode extends ExpressionNode {
  final ExpressionNode expression;
  final bool raw;

  InterpolationNode(FileSpan span, this.expression, {this.raw = false})
      : super(span) {
    expression.parent = this;
  }

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    var value = expression.evaluate(context);
    return value?.toString() ?? '';
  }
}

/// Node representing a binary operation.
class BinaryOperationNode extends ExpressionNode {
  final ExpressionNode left;
  final String operator;
  final ExpressionNode right;

  BinaryOperationNode(FileSpan span, this.left, this.operator, this.right)
      : super(span) {
    left.parent = this;
    right.parent = this;
  }

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    var l = left.evaluate(context);
    var r = right.evaluate(context);

    switch (operator) {
      case '+':
        return l + r;
      case '-':
        return l - r;
      case '*':
        return l * r;
      case '/':
        return l / r;
      case '%':
        return l % r;
      case '==':
        return l == r;
      case '!=':
        return l != r;
      case '>':
        return l > r;
      case '>=':
        return l >= r;
      case '<':
        return l < r;
      case '<=':
        return l <= r;
      case '&&':
        return l && r;
      case '||':
        return l || r;
      default:
        throw UnsupportedError('Unsupported operator: $operator');
    }
  }
}

/// Node representing a function or method call.
class CallNode extends ExpressionNode {
  final String name;
  final List<ExpressionNode> arguments;

  CallNode(FileSpan span, this.name, this.arguments) : super(span) {
    for (var arg in arguments) {
      arg.parent = this;
    }
  }

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    var fn = context[name];
    if (fn == null) {
      throw StateError('Function not found: $name');
    }
    if (fn is! Function) {
      throw StateError('$name is not a function');
    }

    var args = arguments.map((arg) => arg.evaluate(context)).toList();
    return Function.apply(fn, args);
  }
}
