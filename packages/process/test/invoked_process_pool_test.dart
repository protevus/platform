import 'dart:io';
import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('InvokedProcessPool', () {
    late Factory factory;
    late List<InvokedProcess> processes;
    late InvokedProcessPool pool;

    setUp(() async {
      factory = Factory();
      processes = [];
      for (var i = 1; i <= 3; i++) {
        final proc = await Process.start('echo', ['Process $i']);
        final process = InvokedProcess(proc, 'echo Process $i');
        processes.add(process);
      }
      pool = InvokedProcessPool(processes);
    });

    tearDown(() {
      pool.kill();
    });

    test('provides access to processes', () {
      expect(pool.processes, equals(processes));
      expect(pool.length, equals(3));
      expect(pool.isEmpty, isFalse);
      expect(pool.isNotEmpty, isTrue);
    });

    test('waits for all processes', () async {
      final results = await pool.wait();
      expect(results.results.length, equals(3));
      for (var i = 0; i < 3; i++) {
        expect(results.results[i].output().trim(), equals('Process ${i + 1}'));
      }
    });

    test('kills all processes', () async {
      // Start long-running processes
      processes = [];
      for (var i = 1; i <= 3; i++) {
        final proc = await Process.start('sleep', ['10']);
        final process = InvokedProcess(proc, 'sleep 10');
        processes.add(process);
      }
      pool = InvokedProcessPool(processes);

      // Kill all processes
      pool.kill();

      // Wait for all processes and verify they were killed
      final results = await pool.wait();
      for (final result in results.results) {
        expect(result.failed(), isTrue);
      }
    });

    test('provides process access by index', () {
      expect(pool[0], equals(processes[0]));
      expect(pool[1], equals(processes[1]));
      expect(pool[2], equals(processes[2]));
    });

    test('provides first and last process access', () {
      expect(pool.first, equals(processes.first));
      expect(pool.last, equals(processes.last));
    });

    test('supports process list operations', () {
      expect(pool.processes, equals(processes));
      expect(pool.processes.length, equals(processes.length));
    });

    test('adds process to pool', () async {
      final proc = await Process.start('echo', ['New Process']);
      final newProcess = InvokedProcess(proc, 'echo New Process');
      pool.add(newProcess);

      expect(pool.length, equals(4));
      expect(pool.last, equals(newProcess));
    });

    test('removes process from pool', () async {
      final processToRemove = processes[1];
      expect(pool.remove(processToRemove), isTrue);
      expect(pool.length, equals(2));
      expect(pool.processes, isNot(contains(processToRemove)));
    });

    test('clears all processes', () {
      pool.clear();
      expect(pool.isEmpty, isTrue);
      expect(pool.length, equals(0));
    });

    test('handles mixed process results', () async {
      processes = [];
      // Success process
      final successProc1 = await Process.start('echo', ['success']);
      processes.add(InvokedProcess(successProc1, 'echo success'));

      // Failure process
      final failureProc = await Process.start('false', []);
      processes.add(InvokedProcess(failureProc, 'false'));

      // Another success process
      final successProc2 = await Process.start('echo', ['another success']);
      processes.add(InvokedProcess(successProc2, 'echo another success'));

      pool = InvokedProcessPool(processes);
      final results = await pool.wait();

      expect(results.results[0].successful(), isTrue);
      expect(results.results[1].failed(), isTrue);
      expect(results.results[2].successful(), isTrue);
    });

    test('handles concurrent output', () async {
      processes = [];

      // Create processes with different delays
      final proc1 =
          await Process.start('sh', ['-c', 'sleep 0.2 && echo First']);
      processes.add(InvokedProcess(proc1, 'sleep 0.2 && echo First'));

      final proc2 =
          await Process.start('sh', ['-c', 'sleep 0.1 && echo Second']);
      processes.add(InvokedProcess(proc2, 'sleep 0.1 && echo Second'));

      final proc3 = await Process.start('echo', ['Third']);
      processes.add(InvokedProcess(proc3, 'echo Third'));

      pool = InvokedProcessPool(processes);
      final results = await pool.wait();

      final outputs = results.results.map((r) => r.output().trim()).toList();
      expect(outputs, containsAll(['First', 'Second', 'Third']));
    });

    test('provides process IDs', () {
      final pids = pool.pids;
      expect(pids.length, equals(3));
      for (var i = 0; i < 3; i++) {
        expect(pids[i], equals(processes[i].pid));
      }
    });
  });
}
