import '../melos/melos_command.dart';

/// Command to generate dummy test files for packages
class GenerateDumbTestCommand extends MelosCommand {
  @override
  String get name => 'generate:dumbtest';

  @override
  String get description =>
      'Generate dummy test files for packages that only have .gitkeep in their test directory';

  @override
  String get signature => '''generate:dumbtest 
{package? : The package to generate dummy tests for}''';

  /// The dummy test file content
  final String _dummyTestContent = r'''import 'package:test/test.dart';

void main() {
  group("Dummy Test", () {
    test("Always passes", () {
      expect(true, isTrue);
    });

    test("Basic arithmetic", () {
      expect(2 + 2, equals(4));
    });

    test("String manipulation", () {
      String testString = "Protevus Platform";
      expect(testString.contains("Platform"), isTrue);
      expect(testString.toLowerCase(), equals("protevus platform"));
    });
  });
}''';

  @override
  Future<void> handle() async {
    try {
      final package = argument<String?>('package');

      if (package != null) {
        // Generate for specific package
        final fullPackage = 'illuminate_$package';
        await _generateForPackage(fullPackage);
      } else {
        // Auto-discover packages that need dummy tests
        output.newLine();
        output.info('Scanning packages for missing tests...');
        output.writeln('----------------------------------------');

        // List all packages
        await melosExec(
          r'if [ -d "test" ] && [ $(ls -A test | grep -v .gitkeep | wc -l) -eq 0 ]; then echo "{MELOS_PACKAGE_NAME}"; fi',
          throwOnNonZero: false,
        );

        // Generate tests for packages that need them
        await melosExec(
          'if [ -d "test" ] && [ \$(ls -A test | grep -v .gitkeep | wc -l) -eq 0 ]; then mkdir -p test && printf "%s" \'' +
              _dummyTestContent +
              '\' > test/dummy_test.dart && echo "Generated dummy test for {MELOS_PACKAGE_NAME}"; fi',
          throwOnNonZero: false,
        );
      }

      output.newLine();
      output.success('Dummy test generation completed successfully');
    } catch (e) {
      output.error(
          'Failed to generate dummy tests - see output above for details');
      rethrow;
    }
  }

  /// Generate dummy test for a specific package
  Future<void> _generateForPackage(String package) async {
    output.newLine();
    output.info('Checking package: $package');
    output.writeln('----------------------------------------');

    await melosExec(
      'if [ -d "test" ] && [ \$(ls -A test | grep -v .gitkeep | wc -l) -eq 0 ]; then mkdir -p test && printf "%s" \'' +
          _dummyTestContent +
          '\' > test/dummy_test.dart && echo "Generated dummy test"; else echo "Package already has tests, skipping."; fi',
      scope: package,
      throwOnNonZero: false,
    );
  }
}
