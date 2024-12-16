import 'dart:io';
import 'package:test/test.dart';
import 'package:platform_support/src/process/executable_finder.dart';
import 'package:path/path.dart' as path;

void main() {
  group('ExecutableFinder', () {
    late String tempDir;
    late Map<String, String> mockEnv;

    setUp(() {
      tempDir =
          Directory.systemTemp.createTempSync('executable_finder_test_').path;
      mockEnv = {
        'PATH': Platform.isWindows
            ? [tempDir, r'C:\Windows\system32'].join(';')
            : [tempDir, '/usr/local/bin'].join(':'),
        if (Platform.isWindows) 'PATHEXT': '.EXE;.BAT;.CMD',
      };
    });

    tearDown(() {
      Directory(tempDir).deleteSync(recursive: true);
    });

    String createExecutable(String name, [bool executable = true]) {
      final filePath = path.join(tempDir, name);
      final file = File(filePath);
      file.writeAsStringSync('#!/bin/sh\necho "test version 1.0.0"');
      if (!Platform.isWindows && executable) {
        // Make file executable on Unix-like systems
        Process.runSync('chmod', ['+x', filePath]);
      }
      return filePath;
    }

    test('finds executable in PATH', () {
      final executablePath = createExecutable(
        Platform.isWindows ? 'test.exe' : 'test',
      );
      final finder = ExecutableFinder(mockEnv);

      expect(finder.find('test'), equals(executablePath));
    });

    test('finds all executables in PATH', () {
      final path1 = createExecutable(
        Platform.isWindows ? 'test1.exe' : 'test1',
      );
      final path2 = createExecutable(
        Platform.isWindows ? 'test2.exe' : 'test2',
      );
      final finder = ExecutableFinder(mockEnv);

      final results = finder.findAll('test*');
      expect(results, containsAll([path1, path2]));
    });

    test('returns null for non-existent executable', () {
      final finder = ExecutableFinder(mockEnv);
      expect(finder.find('nonexistent'), isNull);
    });

    test('finds executable with absolute path', () {
      final executablePath = createExecutable(
        Platform.isWindows ? 'test.exe' : 'test',
      );
      final finder = ExecutableFinder(mockEnv);

      expect(finder.find(executablePath), equals(executablePath));
    });

    test('returns null for non-executable file on Unix', () {
      if (!Platform.isWindows) {
        final filePath = createExecutable('test', false);
        final finder = ExecutableFinder(mockEnv);

        expect(finder.find(filePath), isNull);
      }
    });

    test('finds executable in current directory', () {
      final currentDir = Directory.current;
      try {
        // Change to temp directory
        Directory.current = tempDir;

        final executableName = Platform.isWindows ? 'test.exe' : 'test';
        createExecutable(executableName);
        final finder = ExecutableFinder(mockEnv);

        expect(
          finder.find(executableName),
          equals(path.join(tempDir, executableName)),
        );
      } finally {
        // Restore current directory
        Directory.current = currentDir;
      }
    });

    test('returns default search paths', () {
      final finder = ExecutableFinder();
      final defaultPaths = finder.getDefaultPath();

      if (Platform.isWindows) {
        expect(defaultPaths, contains(r'C:\Windows\system32'));
      } else {
        expect(defaultPaths, contains('/usr/bin'));
      }
    });

    test('finds executable with version requirement', () {
      final executablePath = createExecutable(
        Platform.isWindows ? 'test.exe' : 'test',
      );
      final finder = ExecutableFinder(mockEnv);

      expect(finder.findWithVersion('test', '1.0.0'), equals(executablePath));
      expect(finder.findWithVersion('test', '2.0.0'), isNull);
    });

    test('checks if executable exists', () {
      createExecutable(
        Platform.isWindows ? 'test.exe' : 'test',
      );
      final finder = ExecutableFinder(mockEnv);

      expect(finder.exists('test'), isTrue);
      expect(finder.exists('nonexistent'), isFalse);
    });

    test('handles empty PATH', () {
      final finder = ExecutableFinder({'PATH': ''});
      expect(finder.find('test'), isNull);
    });

    test('handles missing PATH', () {
      final finder = ExecutableFinder({});
      expect(finder.find('test'), isNull);
    });

    if (Platform.isWindows) {
      test('tries multiple extensions on Windows', () {
        final exePath = createExecutable('test.exe');
        final batPath = createExecutable('test.bat');
        final finder = ExecutableFinder(mockEnv);

        final results = finder.findAll('test*');
        expect(results, containsAll([exePath, batPath]));
      });

      test('respects PATHEXT order on Windows', () {
        createExecutable('test.exe');
        createExecutable('test.bat');
        final finder = ExecutableFinder({
          ...mockEnv,
          'PATHEXT': '.BAT;.EXE',
        });

        expect(
          path.extension(finder.find('test')!).toLowerCase(),
          equals('.bat'),
        );
      });
    }
  });
}
