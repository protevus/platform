import 'package:source_span/source_span.dart';
import '../ast/ast.dart';
import '../scanner/scanner.dart';

/// Base class for parsing tokens into an AST
abstract class Parser {
  /// The tokens to parse
  final List<Token> tokens;

  /// The source file being parsed
  final SourceFile source;

  /// The current position in the token list
  int _current = 0;

  /// Any errors encountered during parsing
  final List<BladeError> _errors = [];

  /// Create a new parser
  Parser(this.tokens, this.source);

  /// Get any errors encountered during parsing
  List<BladeError> get errors => List.unmodifiable(_errors);

  /// Whether we've reached the end of the token stream
  bool isAtEnd() => _current >= tokens.length;

  /// Get the current token without advancing
  Token peek() => tokens[_current];

  /// Get the next token without advancing
  Token peekNext() {
    if (_current + 1 >= tokens.length) return tokens[_current];
    return tokens[_current + 1];
  }

  /// Advance to the next token and return the current one
  Token advance() {
    if (!isAtEnd()) _current++;
    return tokens[_current - 1];
  }

  /// Parse an identifier
  String parseIdentifier() {
    if (peek().type != TokenType.identifier) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected identifier',
        peek().span,
      );
    }
    return advance().lexeme;
  }

  /// Parse the tokens into an AST
  TemplateNode parse() {
    var children = <AstNode>[];
    var sections = <String, SectionDirective>{};
    var yields = <String, YieldDirective>{};
    ExtendsDirective? extends_;

    while (!isAtEnd()) {
      try {
        var node = parseNode();
        if (node != null) {
          if (node is ExtendsDirective) {
            extends_ = node;
          } else if (node is SectionDirective) {
            sections[node.sectionName] = node;
          } else if (node is YieldDirective) {
            yields[node.sectionName] = node;
          } else {
            children.add(node);
          }
        }
      } catch (e) {
        if (e is BladeError) {
          _errors.add(e);
        } else {
          _errors.add(BladeError(
            BladeErrorSeverity.error,
            'Parse error: $e',
            _current < tokens.length ? tokens[_current].span : source.span(0),
            e,
          ));
        }
        _synchronize();
      }
    }

    return TemplateNode(
      source.span(0),
      children,
      extends_: extends_,
      sections: sections,
      yields: yields,
    );
  }

  /// Parse a single node from the token stream
  AstNode? parseNode() {
    var token = peek();
    switch (token.type) {
      case TokenType.text:
        return TextNode(advance().span, token.lexeme);
      case TokenType.directive:
        return parseDirective();
      case TokenType.openTag:
        return parseElement();
      case TokenType.expression:
        return parseExpression();
      case TokenType.rawExpression:
        return parseRawExpression();
      case TokenType.comment:
        return parseComment();
      default:
        advance();
        return null;
    }
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

  /// Parse element attributes
  Map<String, String> parseAttributes() {
    var attributes = <String, String>{};
    while (peek().type == TokenType.identifier) {
      var name = parseIdentifier();
      var value = '';

      if (peek().type == TokenType.equals) {
        advance(); // =
        if (peek().type != TokenType.string) {
          throw BladeError(
            BladeErrorSeverity.error,
            'Expected string',
            peek().span,
          );
        }
        value = advance().lexeme;
        // Remove quotes
        value = value.substring(1, value.length - 1);
      }

      attributes[name] = value;
    }
    return attributes;
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

  /// Synchronize the parser state after an error
  void _synchronize() {
    advance();

    while (!isAtEnd()) {
      var previous = tokens[_current - 1];
      if (previous.type == TokenType.semicolon) return;

      var current = peek();
      switch (current.type) {
        case TokenType.directive:
        case TokenType.openTag:
          return;
        default:
          advance();
      }
    }
  }

  /// Parse a directive node
  DirectiveNode parseDirective() {
    var token = advance();
    var name = token.lexeme.substring(1); // Remove @ prefix

    switch (name) {
      case 'if':
        return parseIfDirective(token.span);
      case 'unless':
        return parseUnlessDirective(token.span);
      case 'foreach':
        return parseForeachDirective(token.span);
      case 'for':
        return parseForDirective(token.span);
      case 'while':
        return parseWhileDirective(token.span);
      case 'switch':
        return parseSwitchDirective(token.span);
      case 'section':
        return parseSectionDirective(token.span);
      case 'yield':
        return parseYieldDirective(token.span);
      case 'extends':
        return parseExtendsDirective(token.span);
      case 'include':
        return parseIncludeDirective(token.span);
      default:
        throw BladeError(
          BladeErrorSeverity.error,
          'Unknown directive: @$name',
          token.span,
        );
    }
  }

  /// Parse an HTML element
  ElementNode parseElement() {
    var openTag = advance(); // <
    var tagName = parseIdentifier();
    var attributes = parseAttributes();
    var selfClosing = false;

    if (peek().type == TokenType.slash) {
      advance(); // /
      selfClosing = true;
    }

    if (peek().type != TokenType.closeTag) {
      throw BladeError(
        BladeErrorSeverity.error,
        'Expected >',
        peek().span,
      );
    }
    advance(); // >

    var children = <AstNode>[];
    if (!selfClosing) {
      while (!isAtEnd() &&
          !(peek().type == TokenType.openTag &&
              peekNext().lexeme == '/' + tagName)) {
        var child = parseNode();
        if (child != null) {
          children.add(child);
        }
      }

      if (isAtEnd()) {
        throw BladeError(
          BladeErrorSeverity.error,
          'Unterminated element: $tagName',
          openTag.span,
        );
      }

      advance(); // <
      advance(); // /
      if (parseIdentifier() != tagName) {
        throw BladeError(
          BladeErrorSeverity.error,
          'Mismatched closing tag',
          peek().span,
        );
      }
      if (peek().type != TokenType.closeTag) {
        throw BladeError(
          BladeErrorSeverity.error,
          'Expected >',
          peek().span,
        );
      }
      advance(); // >
    }

    return ElementNode(
      openTag.span,
      tagName,
      attributes,
      children,
      selfClosing: selfClosing,
    );
  }

  /// Parse a raw expression
  ExpressionNode parseRawExpression() {
    var token = advance();
    var expr = token.lexeme;
    // Remove {!! and !!}
    expr = expr.substring(3, expr.length - 3).trim();
    return VariableNode(token.span, expr);
  }

  /// Parse a comment
  AstNode parseComment() {
    var token = advance();
    var content = token.lexeme;
    // Remove {{-- and --}}
    content = content.substring(4, content.length - 4).trim();
    return BladeCommentNode(token.span, content);
  }

  // Directive parsing methods are implemented in directive_parser.dart
  DirectiveNode parseIfDirective(FileSpan span);
  DirectiveNode parseUnlessDirective(FileSpan span);
  DirectiveNode parseForeachDirective(FileSpan span);
  DirectiveNode parseForDirective(FileSpan span);
  DirectiveNode parseWhileDirective(FileSpan span);
  DirectiveNode parseSwitchDirective(FileSpan span);
  DirectiveNode parseSectionDirective(FileSpan span);
  DirectiveNode parseYieldDirective(FileSpan span);
  DirectiveNode parseExtendsDirective(FileSpan span);
  DirectiveNode parseIncludeDirective(FileSpan span);
}
