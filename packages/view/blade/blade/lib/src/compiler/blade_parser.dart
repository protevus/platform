import 'package:source_span/source_span.dart';
import '../ast/ast.dart';
import '../scanner/scanner.dart';
import 'parser.dart';

/// A parser for Blade templates
class BladeParser extends Parser {
  /// Create a new Blade parser
  BladeParser(super.tokens, super.source);

  @override
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

  @override
  DirectiveNode parseUnlessDirective(FileSpan span) {
    var condition = parseExpression();
    var children = parseBlock();
    return UnlessDirective(span, condition, children);
  }

  @override
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

  @override
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

  @override
  DirectiveNode parseWhileDirective(FileSpan span) {
    var condition = parseExpression();
    var children = parseBlock();
    return WhileDirective(span, condition, children);
  }

  @override
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

  @override
  DirectiveNode parseSectionDirective(FileSpan span) {
    var name = parseStringLiteral();
    var children = parseBlock();
    return SectionDirective(span, name, children);
  }

  @override
  DirectiveNode parseYieldDirective(FileSpan span) {
    var name = parseStringLiteral();
    return YieldDirective(span, name);
  }

  @override
  DirectiveNode parseExtendsDirective(FileSpan span) {
    var layout = parseStringLiteral();
    return ExtendsDirective(span, layout);
  }

  @override
  DirectiveNode parseIncludeDirective(FileSpan span) {
    var view = parseStringLiteral();
    Map<String, ExpressionNode>? data;

    if (peek().type == TokenType.comma) {
      advance(); // ,
      data = parseDataArray();
    }

    return IncludeDirective(span, view, data);
  }
}
