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

/// A class responsible for generating source code for isolate execution.
class SourceGenerator {
  /// Constructs a SourceGenerator instance.
  ///
  /// [executableType]: The Type of the executable class.
  /// [imports]: List of import statements to include in the generated source.
  /// [additionalTypes]: List of additional Types to include in the generated source.
  /// [additionalContents]: Optional additional content to append to the generated source.
  SourceGenerator(
    this.executableType, {
    this.imports = const [],
    this.additionalTypes = const [],
    this.additionalContents,
  });

  /// The Type of the executable class.
  Type executableType;

  /// Returns the name of the executable type.
  String get typeName =>
      MirrorSystem.getName(reflectType(executableType).simpleName);

  /// List of import statements to include in the generated source.
  final List<String> imports;

  /// Optional additional content to append to the generated source.
  final String? additionalContents;

  /// List of additional Types to include in the generated source.
  final List<Type> additionalTypes;

  /// Generates the complete script source for isolate execution.
  ///
  /// Returns a Future<String> containing the generated source code.
  Future<String> get scriptSource async {
    final typeSource = (await _getClass(executableType)).toSource();
    final builder = StringBuffer();

    // Add standard imports
    builder.writeln("import 'dart:async';");
    builder.writeln("import 'dart:isolate';");
    builder.writeln("import 'dart:mirrors';");

    // Add custom imports
    for (final anImport in imports) {
      builder.writeln("import '$anImport';");
    }

    // Add main function for isolate execution
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

    // Add executable class source
    builder.writeln(typeSource);

    // Add Executable base class source
    builder.writeln((await _getClass(Executable)).toSource());

    // Add additional types' sources
    for (final type in additionalTypes) {
      final source = await _getClass(type);
      builder.writeln(source.toSource());
    }

    // Add additional contents if provided
    if (additionalContents != null) {
      builder.writeln(additionalContents);
    }

    return builder.toString();
  }

  /// Retrieves the ClassDeclaration for a given Type.
  ///
  /// [type]: The Type to retrieve the ClassDeclaration for.
  /// Returns a Future<ClassDeclaration>.
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

/// Creates an AnalysisContext for a given file path.
///
/// [path]: The file path to create the context for.
/// [resourceProvider]: Optional ResourceProvider, defaults to PhysicalResourceProvider.INSTANCE.
/// Returns an AnalysisContext.
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
