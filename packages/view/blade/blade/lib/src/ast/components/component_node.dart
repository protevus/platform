import 'package:source_span/source_span.dart';
import '../ast.dart';
import 'component.dart';

/// A node in the AST that represents a component
class ComponentNode extends Component implements AstNode {
  /// The children of this node
  final List<AstNode> children;

  /// Create a new component node
  ComponentNode(
    String name,
    Map<String, dynamic> attributes,
    Map<String, List<AstNode>> slots,
    FileSpan span,
    this.children,
  ) : super(name, attributes, slots, span) {
    for (var child in children) {
      child.parent = this;
    }
  }

  @override
  Future<String> render(Map<String, dynamic> data) async {
    // This would be implemented by the specific component type
    throw UnimplementedError('ComponentNode.render() not implemented');
  }
}
