import 'package:source_span/source_span.dart';
import '../ast.dart';

/// Base class for Blade components
abstract class Component with ParentAware {
  /// The name of the component
  final String name;

  /// The attributes passed to the component
  final Map<String, dynamic> attributes;

  /// The slots passed to the component
  final Map<String, List<AstNode>> slots;

  /// The source span for this node
  @override
  final FileSpan span;

  /// Create a new component
  Component(
    this.name,
    this.attributes,
    this.slots,
    this.span,
  );

  /// Render the component with the given context
  Future<String> render(Map<String, dynamic> data);
}

/// A simple component that renders a template
class TemplateComponent extends Component {
  /// The template to render
  final String template;

  /// Create a new template component
  TemplateComponent(
    String name,
    Map<String, dynamic> attributes,
    Map<String, List<AstNode>> slots,
    this.template,
    FileSpan span,
  ) : super(name, attributes, slots, span);

  @override
  Future<String> render(Map<String, dynamic> data) async {
    // This would be implemented by the specific view engine integration
    return template;
  }
}

/// A component that renders a Dart class
class ClassComponent extends Component {
  /// The class instance to render
  final Object instance;

  /// Create a new class component
  ClassComponent(
    String name,
    Map<String, dynamic> attributes,
    Map<String, List<AstNode>> slots,
    this.instance,
    FileSpan span,
  ) : super(name, attributes, slots, span);

  @override
  Future<String> render(Map<String, dynamic> data) async {
    // This would call the appropriate render method on the class instance
    if (instance is ComponentRenderer) {
      return await (instance as ComponentRenderer).render(data);
    }
    throw UnsupportedError(
        'Component class must implement ComponentRenderer: ${instance.runtimeType}');
  }
}

/// Interface for classes that can render as components
abstract class ComponentRenderer {
  /// Render the component with the given data
  Future<String> render(Map<String, dynamic> data);
}

/// A slot in a component template
class Slot with ParentAware {
  /// The name of the slot
  final String name;

  /// The default content if no slot is provided
  final List<AstNode> defaultContent;

  /// The source span for this node
  @override
  final FileSpan span;

  /// Create a new slot
  Slot(
    this.name,
    this.defaultContent,
    this.span,
  );
}

/// A component attribute
class ComponentAttribute with ParentAware {
  /// The name of the attribute
  final String name;

  /// The value of the attribute
  final ExpressionNode? value;

  /// Whether this is a raw attribute (unescaped)
  final bool isRaw;

  /// Whether this is a spread attribute (...attributes)
  final bool isSpread;

  /// The source span for this node
  @override
  final FileSpan span;

  /// Create a new component attribute
  ComponentAttribute(
    this.name,
    this.span, {
    this.value,
    this.isRaw = false,
    this.isSpread = false,
  });
}
