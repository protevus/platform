import 'package:illuminate_view/src/ast/ast.dart';
import 'package:source_span/source_span.dart';

/// Test version of RegularElement that supports parent references
class TestElement extends RegularElement {
  Element? parent;

  TestElement(
      Token lt,
      Identifier tagName,
      Iterable<Attribute> attributes,
      Token gt,
      List<ElementChild> initialChildren,
      Token lt2,
      Token slash,
      Identifier tagName2,
      Token gt2)
      : super(lt, tagName, attributes, gt, initialChildren, lt2, slash,
            tagName2, gt2);
}
