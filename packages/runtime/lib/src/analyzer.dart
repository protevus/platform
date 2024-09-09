/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart';

/// A class for analyzing Dart code.
class CodeAnalyzer {
  /// Constructs a CodeAnalyzer with the given URI.
  ///
  /// Throws an [ArgumentError] if the URI is not absolute or if no analysis context is found.
  CodeAnalyzer(this.uri) {
    if (!uri.isAbsolute) {
      throw ArgumentError("'uri' must be absolute for CodeAnalyzer");
    }

    contexts = AnalysisContextCollection(includedPaths: [path]);

    if (contexts.contexts.isEmpty) {
      throw ArgumentError("no analysis context found for path '$path'");
    }
  }

  /// Gets the path from the URI.
  String get path {
    return getPath(uri);
  }

  /// The URI of the code to analyze.
  late final Uri uri;

  /// The collection of analysis contexts.
  late AnalysisContextCollection contexts;

  /// A cache of resolved ASTs.
  final _resolvedAsts = <String, AnalysisResult>{};

  /// Resolves the unit or library at the given URI.
  ///
  /// Returns a [Future] that completes with an [AnalysisResult].
  Future<AnalysisResult> resolveUnitOrLibraryAt(Uri uri) async {
    if (FileSystemEntity.isFileSync(
      uri.toFilePath(windows: Platform.isWindows),
    )) {
      return resolveUnitAt(uri);
    } else {
      return resolveLibraryAt(uri);
    }
  }

  /// Resolves the library at the given URI.
  ///
  /// Returns a [Future] that completes with a [ResolvedLibraryResult].
  /// Throws an [ArgumentError] if the URI could not be resolved.
  Future<ResolvedLibraryResult> resolveLibraryAt(Uri uri) async {
    assert(
      FileSystemEntity.isDirectorySync(
        uri.toFilePath(windows: Platform.isWindows),
      ),
    );
    for (final ctx in contexts.contexts) {
      final path = getPath(uri);
      if (_resolvedAsts.containsKey(path)) {
        return _resolvedAsts[path]! as ResolvedLibraryResult;
      }

      final output = await ctx.currentSession.getResolvedLibrary(path)
          as ResolvedLibraryResult;
      return _resolvedAsts[path] = output;
    }

    throw ArgumentError("'uri' could not be resolved (contexts: "
        "${contexts.contexts.map((c) => c.contextRoot.root.toUri()).join(", ")})");
  }

  /// Resolves the unit at the given URI.
  ///
  /// Returns a [Future] that completes with a [ResolvedUnitResult].
  /// Throws an [ArgumentError] if the URI could not be resolved.
  Future<ResolvedUnitResult> resolveUnitAt(Uri uri) async {
    assert(
      FileSystemEntity.isFileSync(
        uri.toFilePath(windows: Platform.isWindows),
      ),
    );
    for (final ctx in contexts.contexts) {
      final path = getPath(uri);
      if (_resolvedAsts.containsKey(path)) {
        return _resolvedAsts[path]! as ResolvedUnitResult;
      }

      final output =
          await ctx.currentSession.getResolvedUnit(path) as ResolvedUnitResult;
      return _resolvedAsts[path] = output;
    }

    throw ArgumentError("'uri' could not be resolved (contexts: "
        "${contexts.contexts.map((c) => c.contextRoot.root.toUri()).join(", ")})");
  }

  /// Gets the class declaration from the file at the given URI.
  ///
  /// Returns null if the class is not found or if there's an error.
  ClassDeclaration? getClassFromFile(String className, Uri fileUri) {
    try {
      return _getFileAstRoot(fileUri)
          .declarations
          .whereType<ClassDeclaration>()
          .firstWhere((c) => c.name.value() == className);
    } catch (e) {
      if (e is StateError || e is TypeError || e is ArgumentError) {
        return null;
      }
      rethrow;
    }
  }

  /// Gets all subclasses of the given superclass from the file at the given URI.
  ///
  /// Returns a list of [ClassDeclaration]s.
  List<ClassDeclaration> getSubclassesFromFile(
    String superclassName,
    Uri fileUri,
  ) {
    return _getFileAstRoot(fileUri)
        .declarations
        .whereType<ClassDeclaration>()
        .where((c) =>
            c.extendsClause?.superclass.name2.toString() == superclassName)
        .toList();
  }

  /// Gets the AST root of the file at the given URI.
  ///
  /// Returns a [CompilationUnit].
  CompilationUnit _getFileAstRoot(Uri fileUri) {
    assert(
      FileSystemEntity.isFileSync(
        fileUri.toFilePath(windows: Platform.isWindows),
      ),
    );
    try {
      final path = getPath(fileUri);
      if (_resolvedAsts.containsKey(path)) {
        return (_resolvedAsts[path]! as ResolvedUnitResult).unit;
      }
    } finally {}
    final unit = contexts.contextFor(path).currentSession.getParsedUnit(
          normalize(
            absolute(fileUri.toFilePath(windows: Platform.isWindows)),
          ),
        ) as ParsedUnitResult;
    return unit.unit;
  }

  /// Converts the input URI to a normalized path string.
  ///
  /// This is a static utility method.
  static String getPath(dynamic inputUri) {
    return PhysicalResourceProvider.INSTANCE.pathContext.normalize(
      PhysicalResourceProvider.INSTANCE.pathContext.fromUri(inputUri),
    );
  }
}
