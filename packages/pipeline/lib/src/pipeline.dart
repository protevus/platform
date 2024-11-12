import 'dart:async';
import 'dart:mirrors';
import 'package:platform_container/container.dart';
import 'package:logging/logging.dart';
import 'pipeline_contract.dart';
import 'conditionable.dart';

/// Defines the signature for a pipe function.
typedef PipeFunction = FutureOr<dynamic> Function(
    dynamic passable, FutureOr<dynamic> Function(dynamic) next);

/// The primary class for building and executing pipelines.
class Pipeline with Conditionable<Pipeline> implements PipelineContract {
  /// The container implementation.
  Container? _container;

  final Map<String, Type> _typeMap = {};

  /// The object being passed through the pipeline.
  dynamic _passable;

  /// The array of class pipes.
  final List<dynamic> _pipes = [];

  /// The method to call on each pipe.
  String _method = 'handle';

  /// Logger for the pipeline.
  final Logger _logger = Logger('Pipeline');

  /// Create a new class instance.
  Pipeline(this._container);

  void registerPipeType(String name, Type type) {
    _typeMap[name] = type;
  }

  /// Set the object being sent through the pipeline.
  @override
  Pipeline send(dynamic passable) {
    _passable = passable;
    return this;
  }

  /// Set the array of pipes.
  @override
  Pipeline through(dynamic pipes) {
    if (_container == null) {
      throw Exception(
          'A container instance has not been passed to the Pipeline.');
    }
    _pipes.addAll(pipes is Iterable ? pipes.toList() : [pipes]);
    return this;
  }

  /// Push additional pipes onto the pipeline.
  @override
  Pipeline pipe(dynamic pipes) {
    if (_container == null) {
      throw Exception(
          'A container instance has not been passed to the Pipeline.');
    }
    _pipes.addAll(pipes is Iterable ? pipes.toList() : [pipes]);
    return this;
  }

  /// Set the method to call on the pipes.
  @override
  Pipeline via(String method) {
    _method = method;
    return this;
  }

  /// Run the pipeline with a final destination callback.
  @override
  Future<dynamic> then(FutureOr<dynamic> Function(dynamic) destination) async {
    if (_container == null) {
      throw Exception(
          'A container instance has not been passed to the Pipeline.');
    }

    var pipeline = (dynamic passable) async => await destination(passable);

    for (var pipe in _pipes.reversed) {
      var next = pipeline;
      pipeline = (dynamic passable) async {
        return await carry(pipe, passable, next);
      };
    }

    return await pipeline(_passable);
  }

  /// Run the pipeline and return the result.
  @override
  Future<dynamic> thenReturn() async {
    return then((passable) => passable);
  }

  /// Get a Closure that represents a slice of the application onion.
  Future<dynamic> carry(dynamic pipe, dynamic passable, Function next) async {
    try {
      if (pipe is Function) {
        return await pipe(passable, next);
      }

      if (pipe is String) {
        if (_container == null) {
          throw Exception('Container is null, cannot resolve pipe: $pipe');
        }

        final parts = parsePipeString(pipe);
        final pipeClass = parts[0];
        final parameters = parts.length > 1 ? parts.sublist(1) : [];

        Type? pipeType;
        if (_typeMap.containsKey(pipeClass)) {
          pipeType = _typeMap[pipeClass];
        } else {
          // Try to resolve from mirrors
          try {
            for (var lib in currentMirrorSystem().libraries.values) {
              for (var decl in lib.declarations.values) {
                if (decl is ClassMirror &&
                    decl.simpleName == Symbol(pipeClass)) {
                  pipeType = decl.reflectedType;
                  break;
                }
              }
              if (pipeType != null) break;
            }
          } catch (_) {}

          if (pipeType == null) {
            throw Exception('Type not registered for pipe: $pipe');
          }
        }

        var instance = _container?.make(pipeType);
        if (instance == null) {
          throw Exception('Unable to resolve pipe: $pipe');
        }

        return await invokeMethod(
            instance, _method, [passable, next, ...parameters]);
      }

      if (pipe is Type) {
        if (_container == null) {
          throw Exception('Container is null, cannot resolve pipe type');
        }

        var instance = _container?.make(pipe);
        if (instance == null) {
          throw Exception('Unable to resolve pipe type: $pipe');
        }

        return await invokeMethod(instance, _method, [passable, next]);
      }

      // Handle instance of a class
      if (pipe is Object) {
        return await invokeMethod(pipe, _method, [passable, next]);
      }

      throw Exception('Unsupported pipe type: ${pipe.runtimeType}');
    } catch (e) {
      return handleException(passable, e);
    }
  }

  /// Parse full pipe string to get name and parameters.
  List<String> parsePipeString(String pipe) {
    var parts = pipe.split(':');
    return [parts[0], if (parts.length > 1) ...parts[1].split(',')];
  }

  /// Get the array of configured pipes.
  List<dynamic> pipes() {
    return List.unmodifiable(_pipes);
  }

  /// Get the container instance.
  Container getContainer() {
    if (_container == null) {
      throw Exception(
          'A container instance has not been passed to the Pipeline.');
    }
    return _container!;
  }

  /// Set the container instance.
  Pipeline setContainer(Container container) {
    _container = container;
    return this;
  }

  /// Handle the value returned from each pipe before passing it to the next.
  dynamic handleCarry(dynamic carry) {
    if (carry is Future) {
      return carry.then((value) => value ?? _passable);
    }
    return carry ?? _passable;
  }

  Future<dynamic> invokeMethod(
      dynamic instance, String methodName, List<dynamic> arguments) async {
    // First try call() for invokable objects
    if (instance is Function) {
      return await instance(arguments[0], arguments[1]);
    }

    var instanceMirror = reflect(instance);

    // Check for call method first (invokable objects)
    var callSymbol = Symbol('call');
    if (instanceMirror.type.declarations.containsKey(callSymbol)) {
      var result = instanceMirror.invoke(callSymbol, arguments);
      return await result.reflectee;
    }

    // Then try the specified method
    var methodSymbol = Symbol(methodName);
    if (!instanceMirror.type.declarations.containsKey(methodSymbol)) {
      throw Exception('Method $methodName not found on instance: $instance');
    }

    var result = instanceMirror.invoke(methodSymbol, arguments);
    return await result.reflectee;
  }

  /// Handle the given exception.
  dynamic handleException(dynamic passable, Object e) {
    if (e is Exception && e.toString().contains('Container is null')) {
      throw Exception(
          'A container instance has not been passed to the Pipeline.');
    }
    _logger.severe('Exception occurred in pipeline', e);
    throw e;
  }
}
