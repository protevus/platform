import 'package:source_span/source_span.dart';
import 'ast_node.dart';
import 'directives.dart';

/// Represents a complete Blade template
class TemplateNode extends ContainerNode {
  final FileSpan span;
  final ExtendsDirective? extends_;
  final Map<String, SectionDirective> sections;
  final Map<String, YieldDirective> yields;

  TemplateNode(
    this.span,
    List<AstNode> children, {
    this.extends_,
    this.sections = const {},
    this.yields = const {},
  }) : super(children) {
    if (extends_ != null) {
      extends_!.parent = this;
    }
    sections.values.forEach((section) => section.parent = this);
    yields.values.forEach((yield_) => yield_!.parent = this);
  }

  /// Whether this template extends another template
  bool get hasParent => extends_ != null;

  /// Get a section by name
  SectionDirective? getSection(String name) => sections[name];

  /// Get a yield by name
  YieldDirective? getYield(String name) => yields[name];
}

/// Represents a partial template included via @include
class PartialTemplateNode extends ContainerNode {
  final FileSpan span;
  final String name;
  final Map<String, ExpressionNode> data;

  PartialTemplateNode(
    this.span,
    this.name,
    List<AstNode> children, {
    this.data = const {},
  }) : super(children) {
    data.values.forEach((expr) => expr.parent = this);
  }
}

/// Represents a stack of content sections
class StackNode extends ContainerNode {
  final FileSpan span;
  final String name;
  final bool prepend;

  StackNode(
    this.span,
    this.name,
    List<AstNode> children, {
    this.prepend = false,
  }) : super(children);
}

/// Represents a push to a stack
class PushNode extends ContainerNode {
  final FileSpan span;
  final String stack;
  final bool prepend;

  PushNode(
    this.span,
    this.stack,
    List<AstNode> children, {
    this.prepend = false,
  }) : super(children);
}

/// Represents an HTML comment
class CommentNode extends AstNode with ParentAware {
  final FileSpan span;
  final String content;

  CommentNode(this.span, this.content);
}

/// Represents a Blade comment
class BladeCommentNode extends AstNode with ParentAware {
  final FileSpan span;
  final String content;

  BladeCommentNode(this.span, this.content);
}

/// Represents raw Dart code
class DartNode extends AstNode with ParentAware {
  @override
  final FileSpan span;
  final String code;

  DartNode(this.span, this.code);
}

/// Represents a verbatim block that should not be processed
class VerbatimNode extends ContainerNode {
  final FileSpan span;

  VerbatimNode(this.span, List<AstNode> children) : super(children);
}

/// Represents an HTML DOCTYPE declaration
class DoctypeNode extends AstNode with ParentAware {
  final FileSpan span;
  final String type;

  DoctypeNode(this.span, this.type);
}

/// Represents a once block that should only be rendered once
class OnceNode extends ContainerNode {
  final FileSpan span;
  final String key;

  OnceNode(this.span, this.key, List<AstNode> children) : super(children);
}

/// Represents an environment specific block
class EnvNode extends ContainerNode {
  final FileSpan span;
  final List<String> environments;

  EnvNode(this.span, this.environments, List<AstNode> children)
      : super(children);
}

/// Represents a production-only block
class ProductionNode extends ContainerNode {
  final FileSpan span;

  ProductionNode(this.span, List<AstNode> children) : super(children);
}

/// Represents an error node for invalid syntax
class ErrorNode extends AstNode with ParentAware {
  final FileSpan span;
  final String message;
  final Object? error;

  ErrorNode(this.span, this.message, [this.error]);
}

/// Represents a template fragment that can be cached
class CacheNode extends ContainerNode {
  final FileSpan span;
  final ExpressionNode key;
  final ExpressionNode? duration;

  CacheNode(
    this.span,
    this.key,
    List<AstNode> children, {
    this.duration,
  }) : super(children) {
    key.parent = this;
    if (duration != null) {
      duration!.parent = this;
    }
  }
}
