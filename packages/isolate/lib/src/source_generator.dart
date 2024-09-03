/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';
import 'dart:isolate';
import 'dart:mirrors';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart';
import 'package:protevus_isolate/isolate.dart';

class SourceGenerator {
  SourceGenerator(
    this.executableType, {
    this.imports = const [],
    this.additionalTypes = const [],
    this.additionalContents,
  });

  Type executableType;

  String get typeName =>
      MirrorSystem.getName(reflectType(executableType).simpleName);
  final List<String> imports;
  final String? additionalContents;
  final List<Type> additionalTypes;

  Future<String> get scriptSource async {
    final typeSource = (await _getClass(executableType)).toSource();
    final builder = StringBuffer();

    builder.writeln("import 'dart:async';");
    builder.writeln("import 'dart:isolate';");
    builder.writeln("import 'dart:mirrors';");
    for (final anImport in imports) {
      builder.writeln("import '$anImport';");
    }
    builder.writeln(
      """
Future main (List<String> args, Map<String, dynamic> message) async {
  final sendPort = message['_sendPort'];
  final executable = $typeName(message);
  final result = await executable.execute();
  sendPort.send({"_result": result});
}
    """,
    );
    builder.writeln(typeSource);

    builder.writeln((await _getClass(Executable)).toSource());
    for (final type in additionalTypes) {
      final source = await _getClass(type);
      builder.writeln(source.toSource());
    }

    if (additionalContents != null) {
      builder.writeln(additionalContents);
    }

    return builder.toString();
  }

  static Future<ClassDeclaration> _getClass(Type type) async {
    final uri =
        await Isolate.resolvePackageUri(reflectClass(type).location!.sourceUri);
    final path =
        absolute(normalize(uri!.toFilePath(windows: Platform.isWindows)));

    final context = _createContext(path);
    final session = context.currentSession;
    final unit = session.getParsedUnit(path) as ParsedUnitResult;
    final typeName = MirrorSystem.getName(reflectClass(type).simpleName);

    return unit.unit.declarations
        .whereType<ClassDeclaration>()
        .firstWhere((classDecl) => classDecl.name.value() == typeName);
  }
}

AnalysisContext _createContext(
  String path, {
  ResourceProvider? resourceProvider,
}) {
  resourceProvider ??= PhysicalResourceProvider.INSTANCE;
  final builder = ContextBuilder(resourceProvider: resourceProvider);
  final contextLocator = ContextLocator(
    resourceProvider: resourceProvider,
  );
  final root = contextLocator.locateRoots(
    includedPaths: [path],
  );
  return builder.createContext(contextRoot: root.first);
}
