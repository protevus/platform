import 'package:test/test.dart';

// Core tests
import 'core/pdo_column_test.dart' as column_test;
import 'core/pdo_exception_test.dart' as exception_test;
import 'core/pdo_param_test.dart' as param_test;
import 'core/pdo_result_test.dart' as result_test;

// Driver tests
import 'mysql_driver_test.dart' as mysql_test;

void main() {
  group('PDO Tests', () {
    group('Core', () {
      // Run core component tests
      group('PDOColumn', column_test.main);
      group('PDOException', exception_test.main);
      group('PDOParam', param_test.main);
      group('PDOResult', result_test.main);
    });

    group('Drivers', () {
      // Run driver implementation tests
      group('MySQL', mysql_test.main);
    });
  });
}

/* To run tests with coverage:

1. Install coverage tools:
   ```bash
   dart pub global activate coverage
   ```

2. Run tests with coverage:
   ```bash
   # Generate coverage data
   dart run --pause-isolates-on-exit --enable-vm-service test/all_tests.dart
   dart pub global run coverage:collect_coverage --uri=http://... -o coverage.json --resume-isolates --wait-paused
   dart pub global run coverage:format_coverage --packages=.packages -i coverage.json --report-on=lib --lcov > coverage.lcov
   ```

3. Generate HTML report (if you have lcov installed):
   ```bash
   genhtml coverage.lcov -o coverage
   ```

4. View the coverage report:
   ```bash
   open coverage/index.html
   ```
*/
