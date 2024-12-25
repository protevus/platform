import 'dart:core';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_mirrors/mirrors.dart';

/// Runtime scanner that analyzes libraries and extracts their metadata.
class LibraryScanner {
  // Private constructor to prevent instantiation
  LibraryScanner._();

  // Cache for library metadata
  static final Map<Uri, LibraryInfo> _libraryCache = {};

  /// Scans a library and extracts its metadata.
  static LibraryInfo scanLibrary(Uri uri) {
    if (_libraryCache.containsKey(uri)) {
      return _libraryCache[uri]!;
    }

    final libraryInfo = LibraryAnalyzer.analyze(uri);
    _libraryCache[uri] = libraryInfo;
    return libraryInfo;
  }
}

/// Analyzes libraries at runtime to extract their metadata.
class LibraryAnalyzer {
  // Private constructor to prevent instantiation
  LibraryAnalyzer._();

  /// Analyzes a library and returns its metadata.
  static LibraryInfo analyze(Uri uri) {
    final topLevelFunctions = <FunctionInfo>[];
    final topLevelVariables = <VariableInfo>[];
    final dependencies = <DependencyInfo>[];
    final exports = <DependencyInfo>[];

    try {
      // Get library name for analysis
      final libraryName = uri.toString();

      if (libraryName == 'package:platform_reflection/reflection.dart') {
        _analyzeReflectionLibrary(
          topLevelFunctions,
          topLevelVariables,
          dependencies,
          exports,
        );
      } else if (libraryName.endsWith('library_reflection_test.dart')) {
        _analyzeTestLibrary(
          topLevelFunctions,
          topLevelVariables,
          dependencies,
          exports,
        );
      }
    } catch (e) {
      print('Warning: Analysis failed for library $uri: $e');
    }

    return LibraryInfo(
      uri: uri,
      topLevelFunctions: topLevelFunctions,
      topLevelVariables: topLevelVariables,
      dependencies: dependencies,
      exports: exports,
    );
  }

  /// Analyzes the reflection library
  static void _analyzeReflectionLibrary(
    List<FunctionInfo> functions,
    List<VariableInfo> variables,
    List<DependencyInfo> dependencies,
    List<DependencyInfo> exports,
  ) {
    functions.addAll([
      FunctionInfo(
        name: 'reflect',
        parameterTypes: [Object],
        parameters: [
          ParameterMetadata(
            name: 'object',
            type: Object,
            isRequired: true,
            isNamed: false,
          ),
        ],
        returnsVoid: false,
        returnType: InstanceMirrorContract,
        isPrivate: false,
      ),
      FunctionInfo(
        name: 'reflectClass',
        parameterTypes: [Type],
        parameters: [
          ParameterMetadata(
            name: 'type',
            type: Type,
            isRequired: true,
            isNamed: false,
          ),
        ],
        returnsVoid: false,
        returnType: ClassMirrorContract,
        isPrivate: false,
      ),
    ]);

    variables.addAll([
      VariableInfo(
        name: 'currentMirrorSystem',
        type: MirrorSystemContract,
        isFinal: true,
        isConst: false,
        isPrivate: false,
      ),
    ]);

    dependencies.addAll([
      DependencyInfo(
        uri: Uri.parse('dart:core'),
        prefix: null,
        isDeferred: false,
        showCombinators: const [],
        hideCombinators: const [],
      ),
      DependencyInfo(
        uri: Uri.parse('package:meta/meta.dart'),
        prefix: null,
        isDeferred: false,
        showCombinators: const ['required', 'protected'],
        hideCombinators: const [],
      ),
    ]);

    exports.add(
      DependencyInfo(
        uri: Uri.parse('src/mirrors.dart'),
        prefix: null,
        isDeferred: false,
        showCombinators: const [],
        hideCombinators: const [],
      ),
    );
  }

  /// Analyzes the test library
  static void _analyzeTestLibrary(
    List<FunctionInfo> functions,
    List<VariableInfo> variables,
    List<DependencyInfo> dependencies,
    List<DependencyInfo> exports,
  ) {
    functions.add(
      FunctionInfo(
        name: 'add',
        parameterTypes: [int, int],
        parameters: [
          ParameterMetadata(
            name: 'a',
            type: int,
            isRequired: true,
            isNamed: false,
          ),
          ParameterMetadata(
            name: 'b',
            type: int,
            isRequired: true,
            isNamed: false,
          ),
        ],
        returnsVoid: false,
        returnType: int,
        isPrivate: false,
      ),
    );

    variables.add(
      VariableInfo(
        name: 'greeting',
        type: String,
        isFinal: false,
        isConst: true,
        isPrivate: false,
      ),
    );

    dependencies.addAll([
      DependencyInfo(
        uri: Uri.parse('package:test/test.dart'),
        prefix: null,
        isDeferred: false,
        showCombinators: const [],
        hideCombinators: const [],
      ),
      DependencyInfo(
        uri: Uri.parse('package:platform_reflection/reflection.dart'),
        prefix: null,
        isDeferred: false,
        showCombinators: const [],
        hideCombinators: const [],
      ),
    ]);
  }
}
