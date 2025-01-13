import 'package:source_span/source_span.dart';
import '../ast/ast.dart';
import '../config.dart';
import '../scanner/scanner.dart';
import 'blade_parser.dart';

/// Compiles Blade templates into executable code
class Compiler {
  /// The configuration for the compiler
  final BladeConfig config;

  /// Create a new compiler with the given configuration
  const Compiler(this.config);

  /// Compile a template source into executable code
  Future<String> compile(SourceFile source) async {
    try {
      // 1. Scan the source into tokens
      var scanner = Scanner(source);
      var tokens = scanner.scan();

      if (scanner.errors.isNotEmpty) {
        throw scanner.errors.first;
      }

      // 2. Parse tokens into AST
      var parser = BladeParser(tokens, source);
      var ast = parser.parse();

      if (parser.errors.isNotEmpty) {
        throw parser.errors.first;
      }

      // 3. Transform AST (handle inheritance, components, etc)
      var transformer = Transformer(config);
      ast = await transformer.transform(ast);

      // 4. Generate code from AST
      var generator = CodeGenerator(config);
      return generator.generate(ast);
    } catch (e) {
      if (e is BladeError) rethrow;
      throw BladeError(
        BladeErrorSeverity.error,
        'Compilation failed: $e',
        source.span(0),
        e,
      );
    }
  }
}

/// Transforms the AST to handle inheritance, components, etc.
class Transformer {
  final BladeConfig config;

  const Transformer(this.config);

  Future<TemplateNode> transform(TemplateNode ast) async {
    // Handle template inheritance
    if (ast.hasParent) {
      // Load and compile parent template
      // This would be implemented by the specific view engine integration
      throw UnimplementedError('Template inheritance not implemented');
    }

    // Process components
    var visitor = ComponentVisitor(config);
    visitor.visitNode(ast);

    return ast;
  }
}

/// Visits component nodes to process them
class ComponentVisitor extends RecursiveAstVisitor<void> {
  final BladeConfig config;

  ComponentVisitor(this.config);

  @override
  void visitComponent(ComponentNode node) {
    // Process component
    var factory = config.components[node.name];
    if (factory == null) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Unknown component: ${node.name}',
        node.span,
      );
    }

    // Continue visiting children
    super.visitComponent(node);
  }
}

/// Generates code from the AST
class CodeGenerator {
  final BladeConfig config;
  final StringBuffer _output = StringBuffer();

  CodeGenerator(this.config);

  String generate(TemplateNode ast) {
    var visitor = GeneratorVisitor(_output, config);
    visitor.visitNode(ast);
    return _output.toString();
  }
}

/// Visits nodes to generate code
class GeneratorVisitor extends RecursiveAstVisitor<void> {
  final StringBuffer _output;
  final BladeConfig config;

  GeneratorVisitor(this._output, this.config);

  @override
  void visitText(TextNode node) {
    _output.write(_escapeHtml(node.text));
  }

  @override
  void visitExpression(ExpressionNode node) {
    _output.write('<?= ${node.evaluate({})} ?>');
  }

  @override
  void visitElement(ElementNode node) {
    _output.write('<${node.tagName}');
    node.attributes.forEach((name, value) {
      _output.write(' $name="$value"');
    });
    if (node.selfClosing) {
      _output.write('/>');
    } else {
      _output.write('>');
      for (var child in node.children) {
        visitNode(child);
      }
      _output.write('</${node.tagName}>');
    }
  }

  @override
  void visitComponent(ComponentNode node) {
    var factory = config.components[node.name];
    if (factory == null) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Unknown component: ${node.name}',
        node.span,
      );
    }

    // Create component instance
    var component = factory(node.attributes);

    // Render component
    _output.write('<?php echo $component->render(); ?>');
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
