import 'dart:io';

import '../contracts/base.dart';
import '../contracts/view.dart';

/// Resolves view engines by their type.
class EngineResolver {
  /// The registered engines.
  final Map<String, ViewEngine Function()> _resolvers = {};

  /// Register a new engine resolver.
  void register(String engine, ViewEngine Function() resolver) {
    _resolvers[engine] = resolver;
  }

  /// Resolve an engine instance by name.
  ViewEngine resolve(String engine) {
    final resolver = _resolvers[engine];
    if (resolver == null) {
      throw UnsupportedError('View engine [$engine] not found.');
    }

    return resolver();
  }
}

/// The file engine implementation.
class FileEngine implements ViewEngine {
  @override
  Future<String> get(String path, Map<String, dynamic> data) async {
    try {
      return await _evaluateFile(path, data);
    } catch (e) {
      throw ViewException('Error evaluating file: $path', e);
    }
  }

  Future<String> _evaluateFile(String path, Map<String, dynamic> data) async {
    // For now, just return the raw file contents
    // In a real implementation, this would process templates
    return await File(path).readAsString();
  }
}

/// The template engine implementation.
class TemplateEngine implements ViewEngine {
  @override
  Future<String> get(String path, Map<String, dynamic> data) async {
    try {
      final template = await File(path).readAsString();
      return _processTemplate(template, data);
    } catch (e) {
      throw ViewException('Error processing template: $path', e);
    }
  }

  String _processTemplate(String template, Map<String, dynamic> data) {
    // Simple template processing - replace {{variable}} with actual values
    return template.replaceAllMapped(
      RegExp(r'\{\{([^}]+)\}\}'),
      (match) {
        final key = match.group(1)?.trim();
        return data[key]?.toString() ?? '';
      },
    );
  }
}
