import 'package:source_span/source_span.dart';
import 'ast_node.dart';

/// Base class for all Blade directives
abstract class BladeDirective extends DirectiveNode {
  BladeDirective(FileSpan span, String name, List<AstNode> children)
      : super(span, name, children);
}

/// Represents an @if directive
/// @if ($condition)
class IfDirective extends BladeDirective {
  final ExpressionNode condition;
  final List<AstNode> elseBranch;

  IfDirective(
    FileSpan span,
    this.condition,
    List<AstNode> thenBranch, [
    this.elseBranch = const [],
  ]) : super(span, 'if', thenBranch) {
    condition.parent = this;
    for (var node in elseBranch) {
      node.parent = this;
    }
  }
}

/// Represents an @unless directive
/// @unless ($condition)
class UnlessDirective extends BladeDirective {
  final ExpressionNode condition;

  UnlessDirective(FileSpan span, this.condition, List<AstNode> children)
      : super(span, 'unless', children) {
    condition.parent = this;
  }
}

/// Represents a @foreach directive
/// @foreach ($items as $item)
class ForeachDirective extends BladeDirective {
  final ExpressionNode items;
  final String itemName;
  final String? keyName;

  ForeachDirective(
    FileSpan span,
    this.items,
    this.itemName,
    List<AstNode> children, {
    this.keyName,
  }) : super(span, 'foreach', children) {
    items.parent = this;
  }
}

/// Represents a @forelse directive
/// @forelse ($items as $item)
class ForelseDirective extends BladeDirective {
  final ExpressionNode items;
  final String itemName;
  final String? keyName;
  final List<AstNode> emptyBranch;

  ForelseDirective(
    FileSpan span,
    this.items,
    this.itemName,
    List<AstNode> children,
    this.emptyBranch, {
    this.keyName,
  }) : super(span, 'forelse', children) {
    items.parent = this;
    for (var node in emptyBranch) {
      node.parent = this;
    }
  }
}

/// Represents a @while directive
/// @while ($condition)
class WhileDirective extends BladeDirective {
  final ExpressionNode condition;

  WhileDirective(FileSpan span, this.condition, List<AstNode> children)
      : super(span, 'while', children) {
    condition.parent = this;
  }
}

/// Represents a @for directive
/// @for ($i = 0; $i < 10; $i++)
class ForDirective extends BladeDirective {
  final ExpressionNode initialization;
  final ExpressionNode condition;
  final ExpressionNode increment;

  ForDirective(
    FileSpan span,
    this.initialization,
    this.condition,
    this.increment,
    List<AstNode> children,
  ) : super(span, 'for', children) {
    initialization.parent = this;
    condition.parent = this;
    increment.parent = this;
  }
}

/// Represents a @switch directive
/// @switch($value)
class SwitchDirective extends BladeDirective {
  final ExpressionNode value;
  final List<CaseDirective> cases;
  final DefaultDirective? defaultCase;

  SwitchDirective(
    FileSpan span,
    this.value,
    this.cases, [
    this.defaultCase,
  ]) : super(span, 'switch', []) {
    value.parent = this;
    for (var case_ in cases) {
      case_.parent = this;
    }
    if (defaultCase != null) {
      defaultCase!.parent = this;
    }
  }
}

/// Represents a @case directive within a switch
/// @case($value)
class CaseDirective extends BladeDirective {
  final ExpressionNode value;

  CaseDirective(FileSpan span, this.value, List<AstNode> children)
      : super(span, 'case', children) {
    value.parent = this;
  }
}

/// Represents a @default directive within a switch
/// @default
class DefaultDirective extends BladeDirective {
  DefaultDirective(FileSpan span, List<AstNode> children)
      : super(span, 'default', children);
}

/// Represents a @section directive
/// @section('name')
class SectionDirective extends BladeDirective {
  final String sectionName;
  final bool append;

  SectionDirective(
    FileSpan span,
    this.sectionName,
    List<AstNode> children, {
    this.append = false,
  }) : super(span, 'section', children);
}

/// Represents a @yield directive
/// @yield('name')
class YieldDirective extends BladeDirective {
  final String sectionName;

  YieldDirective(FileSpan span, this.sectionName)
      : super(span, 'yield', const []);
}

/// Represents an @extends directive
/// @extends('layout')
class ExtendsDirective extends BladeDirective {
  final String layout;

  ExtendsDirective(FileSpan span, this.layout)
      : super(span, 'extends', const []);
}

/// Represents an @include directive
/// @include('view', ['key' => 'value'])
class IncludeDirective extends BladeDirective {
  final String view;
  final Map<String, ExpressionNode>? data;

  IncludeDirective(FileSpan span, this.view, [this.data])
      : super(span, 'include', const []) {
    data?.values.forEach((expr) => expr.parent = this);
  }
}

/// Represents an @each directive
/// @each($array as $key => $value)
class EachDirective extends BladeDirective {
  final ExpressionNode items;
  final String valueName;
  final String? keyName;

  EachDirective(
    FileSpan span,
    this.items,
    this.valueName,
    List<AstNode> children, {
    this.keyName,
  }) : super(span, 'each', children) {
    items.parent = this;
  }
}

/// Represents a @php directive
/// @php
class DartDirective extends BladeDirective {
  final String code;

  DartDirective(FileSpan span, this.code) : super(span, 'dart', const []);
}

/// Represents an @auth directive
/// @auth
class AuthDirective extends BladeDirective {
  AuthDirective(FileSpan span, List<AstNode> children)
      : super(span, 'auth', children);
}

/// Represents a @guest directive
/// @guest
class GuestDirective extends BladeDirective {
  GuestDirective(FileSpan span, List<AstNode> children)
      : super(span, 'guest', children);
}
