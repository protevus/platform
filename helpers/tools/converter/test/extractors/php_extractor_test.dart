import 'package:test/test.dart';
import '../../lib/src/extractors/php_extractor.dart';

void main() {
  group('PhpExtractor', () {
    final extractor = PhpExtractor();

    test('extracts class comment', () {
      const phpCode = '''
/**
 * User entity class.
 * Represents a user in the system.
 */
class User {
}
''';
      final comment = extractor.extractClassComment(phpCode);
      expect(comment, contains('User entity class'));
      expect(comment, contains('Represents a user in the system'));
    });

    test('extracts dependencies', () {
      const phpCode = '''
use App\\Models\\User;
use Illuminate\\Support\\Str as StringHelper;
use App\\Interfaces\\UserInterface;
''';
      final deps = extractor.extractDependencies(phpCode);
      expect(deps, hasLength(3));
      expect(deps[0]['name'], equals('User'));
      expect(deps[1]['name'], equals('StringHelper'));
      expect(deps[2]['name'], equals('UserInterface'));
      expect(deps[1]['source'], equals('Illuminate\\Support\\Str'));
    });

    test('extracts properties', () {
      const phpCode = '''
class User {
    /**
     * The user's name.
     */
    private string \$name;

    /**
     * The user's email.
     */
    protected string \$email;

    /**
     * Is the user active?
     */
    public bool \$isActive = false;
}
''';
      final props = extractor.extractProperties(phpCode);
      expect(props, hasLength(3));

      expect(props[0]['name'], equals('name'));
      expect(props[0]['visibility'], equals('private'));
      expect(props[0]['comment'], contains("The user's name"));

      expect(props[1]['name'], equals('email'));
      expect(props[1]['visibility'], equals('protected'));

      expect(props[2]['name'], equals('isActive'));
      expect(props[2]['visibility'], equals('public'));
    });

    test('extracts methods', () {
      const phpCode = '''
class User {
    /**
     * Get the user's full name.
     * @param string \$title Optional title
     * @return string
     */
    public function getFullName(string \$title = '') {
        return \$title . ' ' . \$this->name;
    }

    /**
     * Set the user's email address.
     */
    protected function setEmail(string \$email) {
        \$this->email = \$email;
    }
}
''';
      final methods = extractor.extractMethods(phpCode);
      expect(methods, hasLength(2));

      expect(methods[0]['name'], equals('getFullName'));
      expect(methods[0]['visibility'], equals('public'));
      expect(methods[0]['parameters'], hasLength(1));
      expect(methods[0]['parameters'][0]['name'], equals('title'));
      expect(methods[0]['parameters'][0]['default'], equals("''"));
      expect(methods[0]['comment'], contains("Get the user's full name"));

      expect(methods[1]['name'], equals('setEmail'));
      expect(methods[1]['visibility'], equals('protected'));
      expect(methods[1]['parameters'], hasLength(1));
      expect(methods[1]['parameters'][0]['name'], equals('email'));
    });

    test('extracts interfaces', () {
      const phpCode = '''
class User implements UserInterface, Authenticatable {
}
''';
      final interfaces = extractor.extractInterfaces(phpCode);
      expect(interfaces, hasLength(2));
      expect(interfaces[0], equals('UserInterface'));
      expect(interfaces[1], equals('Authenticatable'));
    });

    test('extracts traits', () {
      const phpCode = '''
class User {
    use HasFactory, Notifiable;
}
''';
      final traits = extractor.extractTraits(phpCode);
      expect(traits, hasLength(2));
      expect(traits[0], equals('HasFactory'));
      expect(traits[1], equals('Notifiable'));
    });

    test('generates valid YAML output', () {
      const phpCode = '''
/**
 * User entity class.
 */
class User implements UserInterface {
    use HasFactory;

    /**
     * The user's name.
     */
    private string \$name;

    /**
     * Get the user's name.
     */
    public function getName(): string {
        return \$this->name;
    }
}
''';
      final contract = {
        'name': 'User',
        'class_comment': extractor.extractClassComment(phpCode),
        'dependencies': extractor.extractDependencies(phpCode),
        'properties': extractor.extractProperties(phpCode),
        'methods': extractor.extractMethods(phpCode),
        'traits': extractor.extractTraits(phpCode),
        'interfaces': extractor.extractInterfaces(phpCode),
      };

      final yaml = extractor.convertToYaml(contract);

      // Check required sections
      expect(yaml, contains('documentation:'));
      expect(yaml, contains('properties:'));
      expect(yaml, contains('methods:'));
      expect(yaml, contains('interfaces:'));

      // Check content
      expect(yaml, contains('User entity class'));
      expect(yaml, contains('name: name'));
      expect(yaml, contains('visibility: private'));
      expect(yaml, contains('name: getName'));
      expect(yaml, contains('visibility: public'));
      expect(yaml, contains('UserInterface'));

      // Verify formatting
      expect(yaml, isNot(contains('class User')));
      expect(yaml, isNot(contains('function')));
      expect(yaml, isNot(contains('private string')));
    });
  });
}
