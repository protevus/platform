import 'package:source_span/source_span.dart';
import '../ast/ast.dart';
import '../scanner/scanner.dart';
import 'parser.dart';

/// Extension methods for parsing directives
extension DirectiveParser on Parser {
  /// Parse an @if directive
  DirectiveNode parseIfDirective(FileSpan span) {
    var condition = parseExpression();
    var thenBranch = parseBlock();
    List<AstNode> elseBranch = [];

    if (peek().type == TokenType.directive && peek().lexeme == '@else') {
      advance(); // @else
      elseBranch = parseBlock();
    }

    return IfDirective(span, condition, thenBranch, elseBranch);
  }

  /// Parse an @unless directive
  DirectiveNode parseUnlessDirective(FileSpan span) {
    var condition = parseExpression();
    var children = parseBlock();
    return UnlessDirective(span, condition, children);
  }

  /// Parse a @foreach directive
  DirectiveNode parseForeachDirective(FileSpan span) {
    var items = parseExpression();
    if (peek().lexeme != 'as') {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected "as" in foreach',
        peek().span,
      );
    }
    advance(); // as

    var itemName = parseIdentifier();
    String? keyName;

    if (peek().type == TokenType.arrow) {
      advance(); // =>
      keyName = itemName;
      itemName = parseIdentifier();
    }

    var children = parseBlock();
    return ForeachDirective(span, items, itemName, children, keyName: keyName);
  }

  /// Parse a @forelse directive
  DirectiveNode parseForelseDirective(FileSpan span) {
    var items = parseExpression();
    if (peek().lexeme != 'as') {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected "as" in forelse',
        peek().span,
      );
    }
    advance(); // as

    var itemName = parseIdentifier();
    String? keyName;

    if (peek().type == TokenType.arrow) {
      advance(); // =>
      keyName = itemName;
      itemName = parseIdentifier();
    }

    var children = parseBlock();
    List<AstNode> emptyBranch = [];

    if (peek().type == TokenType.directive && peek().lexeme == '@empty') {
      advance(); // @empty
      emptyBranch = parseBlock();
    }

    return ForelseDirective(span, items, itemName, children, emptyBranch,
        keyName: keyName);
  }

  /// Parse a @for directive
  DirectiveNode parseForDirective(FileSpan span) {
    var init = parseExpression();
    if (peek().type != TokenType.semicolon) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected ; in for loop',
        peek().span,
      );
    }
    advance(); // ;

    var condition = parseExpression();
    if (peek().type != TokenType.semicolon) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected ; in for loop',
        peek().span,
      );
    }
    advance(); // ;

    var increment = parseExpression();
    var children = parseBlock();

    return ForDirective(span, init, condition, increment, children);
  }

  /// Parse a @while directive
  DirectiveNode parseWhileDirective(FileSpan span) {
    var condition = parseExpression();
    var children = parseBlock();
    return WhileDirective(span, condition, children);
  }

  /// Parse a @switch directive
  DirectiveNode parseSwitchDirective(FileSpan span) {
    var value = parseExpression();
    var cases = <CaseDirective>[];
    DefaultDirective? defaultCase;

    while (peek().type == TokenType.directive) {
      if (peek().lexeme == '@case') {
        advance(); // @case
        var caseValue = parseExpression();
        var caseChildren = parseBlock();
        cases.add(CaseDirective(peek().span, caseValue, caseChildren));
      } else if (peek().lexeme == '@default') {
        advance(); // @default
        var defaultChildren = parseBlock();
        defaultCase = DefaultDirective(peek().span, defaultChildren);
        break;
      } else {
        break;
      }
    }

    return SwitchDirective(span, value, cases, defaultCase);
  }

  /// Parse a @section directive
  DirectiveNode parseSectionDirective(FileSpan span) {
    var name = parseStringLiteral();
    var children = parseBlock();
    return SectionDirective(span, name, children);
  }

  /// Parse a @yield directive
  DirectiveNode parseYieldDirective(FileSpan span) {
    var name = parseStringLiteral();
    return YieldDirective(span, name);
  }

  /// Parse an @extends directive
  DirectiveNode parseExtendsDirective(FileSpan span) {
    var layout = parseStringLiteral();
    return ExtendsDirective(span, layout);
  }

  /// Parse an @include directive
  DirectiveNode parseIncludeDirective(FileSpan span) {
    var view = parseStringLiteral();
    Map<String, ExpressionNode>? data;

    if (peek().type == TokenType.comma) {
      advance(); // ,
      data = parseDataArray();
    }

    return IncludeDirective(span, view, data);
  }

  /// Parse a block of template content
  List<AstNode> parseBlock() {
    var children = <AstNode>[];
    while (!isAtEnd()) {
      if (peek().type == TokenType.directive &&
          (peek().lexeme == '@end' ||
              peek().lexeme == '@else' ||
              peek().lexeme == '@empty' ||
              peek().lexeme == '@case' ||
              peek().lexeme == '@default')) {
        break;
      }
      var node = parseNode();
      if (node != null) {
        children.add(node);
      }
    }
    if (peek().type == TokenType.directive && peek().lexeme == '@end') {
      advance(); // @end
    }
    return children;
  }

  /// Parse an expression
  ExpressionNode parseExpression() {
    // For now, just parse variables
    // This would be expanded to handle full expressions
    var name = parseIdentifier();
    return VariableNode(peek().span, name);
  }

  /// Parse a string literal
  String parseStringLiteral() {
    if (peek().type != TokenType.string) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected string',
        peek().span,
      );
    }
    var value = advance().lexeme;
    // Remove quotes
    return value.substring(1, value.length - 1);
  }

  /// Parse a data array
  Map<String, ExpressionNode> parseDataArray() {
    var data = <String, ExpressionNode>{};
    if (peek().type == TokenType.openBrace) {
      advance(); // {
      while (peek().type != TokenType.closeBrace) {
        var key = parseStringLiteral();
        if (peek().type != TokenType.arrow) {
          throw BladeError(
            BladeErrorSeverity.error,
            'Expected =>',
            peek().span,
          );
        }
        advance(); // =>
        var value = parseExpression();
        data[key] = value;

        if (peek().type == TokenType.comma) {
          advance(); // ,
        }
      }
      advance(); // }
    }
    return data;
  }
}
