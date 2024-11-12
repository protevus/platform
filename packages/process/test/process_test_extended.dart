import 'dart:async';
import 'dart:io' show Directory, Platform, ProcessSignal;
import 'package:platform_process/angel3_process.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  late Angel3Process process;

  setUp(() {
    process = Angel3Process('echo', ['Hello, World!']);
  });

  tearDown(() async {
    await process.dispose();
  });

  // ... (existing tests remain the same)

  test('Process with custom environment variables', () async {
    var command = Platform.isWindows ? 'cmd' : 'sh';
    var args = Platform.isWindows
        ? ['/c', 'echo %TEST_VAR%']
        : ['-c', r'echo $TEST_VAR']; // Use a raw string for Unix-like systems

    var envProcess =
        Angel3Process(command, args, environment: {'TEST_VAR': 'custom_value'});

    var result = await envProcess.run();
    expect(result.output.trim(), equals('custom_value'));
  });

  test('Process with custom working directory', () async {
    var tempDir = Directory.systemTemp.createTempSync();
    try {
      var workingDirProcess = Angel3Process(Platform.isWindows ? 'cmd' : 'pwd',
          Platform.isWindows ? ['/c', 'cd'] : [],
          workingDirectory: tempDir.path);
      var result = await workingDirProcess.run();
      expect(path.equals(result.output.trim(), tempDir.path), isTrue);
    } finally {
      tempDir.deleteSync();
    }
  });

  test('Process with input', () async {
    var catProcess = Angel3Process('cat', []);
    await catProcess.start();
    catProcess.write('Hello, stdin!');
    await catProcess.kill(); // End the process
    var output = await catProcess.outputAsString;
    expect(output.trim(), equals('Hello, stdin!'));
  });

  test('Longer-running process', () async {
    var sleepProcess = Angel3Process(Platform.isWindows ? 'timeout' : 'sleep',
        Platform.isWindows ? ['/t', '2'] : ['2']);
    var startTime = DateTime.now();
    await sleepProcess.run();
    var endTime = DateTime.now();
    expect(endTime.difference(startTime).inSeconds, greaterThanOrEqualTo(2));
  });

  test('Multiple concurrent processes', () async {
    var processes =
        List.generate(5, (_) => Angel3Process('echo', ['concurrent']));
    var results = await Future.wait(processes.map((p) => p.run()));
    for (var result in results) {
      expect(result.output.trim(), equals('concurrent'));
    }
  });

  test('Process signaling', () async {
    if (!Platform.isWindows) {
      // SIGSTOP/SIGCONT are not available on Windows
      var longProcess = Angel3Process('sleep', ['10']);
      await longProcess.start();
      await longProcess.sendSignal(ProcessSignal.sigstop);
      // Process should be stopped, so it shouldn't complete immediately
      expect(longProcess.exitCode, doesNotComplete);
      await longProcess.sendSignal(ProcessSignal.sigcont);
      await longProcess.kill();
      expect(await longProcess.exitCode, isNot(0));
    }
  });

  test('Edge case: empty command', () {
    expect(() => Angel3Process('', []), throwsA(isA<ArgumentError>()));
  });

  test('Edge case: empty arguments list', () {
    // This should not throw an error
    expect(() => Angel3Process('echo', []), returnsNormally);
  });

  test('Edge case: invalid argument type', () {
    // This should throw a compile-time error, but we can't test for that directly
    // Instead, we can test for runtime type checking if implemented
    expect(() => Angel3Process('echo', [1, 2, 3] as dynamic),
        throwsA(isA<ArgumentError>()));
  });
}
