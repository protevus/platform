import 'package:belatuk_code_buffer/belatuk_code_buffer.dart';
import 'package:illuminate_view/view.dart' as jael;
import 'package:belatuk_symbol_table/belatuk_symbol_table.dart';
import 'package:test/test.dart';

void main() {
  test('unless directive', () {
    const template = '''
<html>
  <body>
    <h1>Unless Test</h1>
    <div unless=user.isAdmin>
      Regular user content
    </div>
    <div unless=user.isGuest>
      Member content
    </div>
  </body>
</html>
''';

    var buf = CodeBuffer();
    var document = jael.parseDocument(template, sourceUrl: 'test.jael')!;
    var scope = SymbolTable<dynamic>(values: {
      'user': _TestUser(isAdmin: false, isGuest: true),
    });

    const jael.Renderer().render(document, buf, scope);

    expect(
        buf.toString().replaceAll('\n    \n', '\n'),
        '''
<html>
  <body>
    <h1>
      Unless Test
    </h1>
    <div>
      Regular user content
    </div>
  </body>
</html>
    '''
            .trim());
  });

  test('unless with expressions', () {
    const template = '''
<html>
  <body>
    <div unless!=items.length>
      Cart is empty
    </div>
    <div unless!=total>
      Eligible for free shipping
    </div>
  </body>
</html>
''';

    var buf = CodeBuffer();
    var document = jael.parseDocument(template, sourceUrl: 'test.jael')!;
    var scope = SymbolTable<dynamic>(values: {
      'items': [],
      'total': 50 // Changed to 50 to make total < 100 true
    });

    const jael.Renderer().render(document, buf, scope);

    expect(
        buf.toString().replaceAll('\n    \n', '\n'),
        '''
<html>
  <body>
    <div>
      Cart is empty
    </div>
  </body>
</html>
    '''
            .trim());
  });

  test('unless with strict mode', () {
    const template = '''
<div unless=value>
  Should show in non-strict
</div>
''';

    var buf = CodeBuffer();
    var document = jael.parseDocument(template, sourceUrl: 'test.jael')!;

    // Test with strict mode
    var strictScope =
        SymbolTable<dynamic>(values: {'!strict!': true, 'value': null});
    const jael.Renderer().render(document, buf, strictScope);
    expect(buf.toString().replaceAll('\n    \n', '\n').trim(),
        '<div>\n  Should show in non-strict\n</div>');

    // Test without strict mode
    buf.clear();
    var nonStrictScope =
        SymbolTable<dynamic>(values: {'!strict!': false, 'value': null});
    const jael.Renderer().render(document, buf, nonStrictScope);
    expect(buf.toString().trim(), '<div>\n  Should show in non-strict\n</div>');
  });
}

class _TestUser {
  final bool isAdmin;
  final bool isGuest;

  _TestUser({required this.isAdmin, required this.isGuest});
}
