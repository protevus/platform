import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:platform_process/angel3_process.dart';
import 'package:test/test.dart';

void main() {
  late Angel3Process process;

  setUp(() {
    process = Angel3Process('echo', ['Hello, World!']);
  });

  tearDown(() async {
    await process.dispose();
  });

  test('Angel3Process initialization', () {
    expect(process.command, equals('echo'));
    expect(process.startTime, isNull);
    expect(process.endTime, isNull);
  });

  test('Start and run a simple process', () async {
    var result = await process.run();
    expect(process.startTime, isNotNull);
    expect(result.exitCode, equals(0));
    expect(result.output.trim(), equals('Hello, World!'));
    expect(process.endTime, isNotNull);
  });

  test('Stream output', () async {
    await process.start();
    var outputStream = process.output.transform(utf8.decoder);
    var streamOutput = await outputStream.join();
    await process.exitCode; // Wait for the process to complete
    expect(streamOutput.trim(), equals('Hello, World!'));
  });

  test('Error output for non-existent command', () {
    var errorProcess = Angel3Process('non_existent_command', []);
    expect(errorProcess.start(), throwsA(isA<ProcessException>()));
  });

  test('Process with error output', () async {
    Angel3Process errorProcess;
    if (Platform.isWindows) {
      errorProcess = Angel3Process('cmd', ['/c', 'dir', '/invalid_argument']);
    } else {
      errorProcess = Angel3Process('ls', ['/non_existent_directory']);
    }

    print('Starting error process...');
    var result = await errorProcess.run();
    print('Error process completed.');
    print('Exit code: ${result.exitCode}');
    print('Standard output: "${result.output}"');
    print('Error output: "${result.errorOutput}"');

    expect(result.exitCode, isNot(0), reason: 'Expected non-zero exit code');
    expect(result.errorOutput.trim(), isNotEmpty,
        reason: 'Expected non-empty error output');

    await errorProcess.dispose();
  });

  test('Kill running process', () async {
    var longRunningProcess = Angel3Process('sleep', ['5']);
    await longRunningProcess.start();
    await longRunningProcess.kill();
    var exitCode = await longRunningProcess.exitCode;
    expect(exitCode, isNot(0));
  });

  test('Process timeout', () async {
    var timeoutProcess =
        Angel3Process('sleep', ['10'], timeout: Duration(seconds: 1));
    expect(() => timeoutProcess.run(), throwsA(isA<TimeoutException>()));
  }, timeout: Timeout(Duration(seconds: 5)));
}
