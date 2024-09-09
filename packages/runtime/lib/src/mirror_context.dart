/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:mirrors';
import 'package:protevus_runtime/runtime.dart';

/// Global instance of the MirrorContext.
RuntimeContext instance = MirrorContext._();

/// A runtime context implementation using Dart's mirror system.
///
/// This class provides runtime type information and compilation capabilities
/// using reflection.
class MirrorContext extends RuntimeContext {
  /// Private constructor to ensure singleton instance.
  ///
  /// Initializes the context by compiling all available runtimes.
  MirrorContext._() {
    final m = <String, Object>{};

    for (final c in compilers) {
      final compiledRuntimes = c.compile(this);
      if (m.keys.any((k) => compiledRuntimes.keys.contains(k))) {
        final matching = m.keys.where((k) => compiledRuntimes.keys.contains(k));
        throw StateError(
          'Could not compile. Type conflict for the following types: ${matching.join(", ")}.',
        );
      }
      m.addAll(compiledRuntimes);
    }

    runtimes = RuntimeCollection(m);
  }

  /// List of all class mirrors in the current mirror system.
  ///
  /// Excludes classes marked with @PreventCompilation.
  final List<ClassMirror> types = currentMirrorSystem()
      .libraries
      .values
      .where((lib) => lib.uri.scheme == "package" || lib.uri.scheme == "file")
      .expand((lib) => lib.declarations.values)
      .whereType<ClassMirror>()
      .where((cm) => firstMetadataOfType<PreventCompilation>(cm) == null)
      .toList();

  /// List of all available compilers.
  ///
  /// Returns instances of non-abstract classes that are subclasses of Compiler.
  List<Compiler> get compilers {
    return types
        .where((b) => b.isSubclassOf(reflectClass(Compiler)) && !b.isAbstract)
        .map((b) => b.newInstance(Symbol.empty, []).reflectee as Compiler)
        .toList();
  }

  /// Retrieves all non-abstract subclasses of a given type.
  ///
  /// [type] The base type to find subclasses of.
  /// Returns a list of ClassMirror objects representing the subclasses.
  List<ClassMirror> getSubclassesOf(Type type) {
    final mirror = reflectClass(type);
    return types.where((decl) {
      if (decl.isAbstract) {
        return false;
      }

      if (!decl.isSubclassOf(mirror)) {
        return false;
      }

      if (decl.hasReflectedType) {
        if (decl.reflectedType == type) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Coerces an input to a specified type T.
  ///
  /// Attempts to cast the input directly, and if that fails,
  /// uses runtime casting.
  ///
  /// [input] The object to be coerced.
  /// Returns the coerced object of type T.
  @override
  T coerce<T>(dynamic input) {
    try {
      return input as T;
    } catch (_) {
      return runtimeCast(input, reflectType(T)) as T;
    }
  }
}

/// Retrieves the first metadata annotation of a specific type from a declaration.
///
/// [dm] The DeclarationMirror to search for metadata.
/// [dynamicType] Optional TypeMirror to use instead of T.
/// Returns the first metadata of type T, or null if not found.
T? firstMetadataOfType<T>(DeclarationMirror dm, {TypeMirror? dynamicType}) {
  final tMirror = dynamicType ?? reflectType(T);
  try {
    return dm.metadata
        .firstWhere((im) => im.type.isSubtypeOf(tMirror))
        .reflectee as T;
  } on StateError {
    return null;
  }
}
