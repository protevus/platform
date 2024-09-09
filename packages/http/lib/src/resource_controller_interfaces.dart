/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_auth/auth.dart';
import 'package:protevus_http/http.dart';
import 'package:protevus_openapi/v3.dart';

/// Abstract class representing the runtime of a ResourceController.
abstract class ResourceControllerRuntime {
  /// List of instance variable parameters.
  List<ResourceControllerParameter>? ivarParameters;

  /// List of operations supported by the ResourceController.
  late List<ResourceControllerOperation> operations;

  /// Documenter for the ResourceController.
  ResourceControllerDocumenter? documenter;

  /// Retrieves the operation runtime for a given method and path variables.
  ///
  /// [method] The HTTP method.
  /// [pathVariables] The list of path variables.
  ///
  /// Returns the matching [ResourceControllerOperation] or null if not found.
  ResourceControllerOperation? getOperationRuntime(
    String method,
    List<String?> pathVariables,
  ) {
    return operations.firstWhereOrNull(
      (op) => op.isSuitableForRequest(method, pathVariables),
    );
  }

  /// Applies request properties to the controller.
  ///
  /// [untypedController] The ResourceController instance.
  /// [args] The invocation arguments.
  void applyRequestProperties(
    ResourceController untypedController,
    ResourceControllerOperationInvocationArgs args,
  );
}

/// Abstract class for documenting a ResourceController.
abstract class ResourceControllerDocumenter {
  /// Documents the components of a ResourceController.
  ///
  /// [rc] The ResourceController instance.
  /// [context] The API documentation context.
  void documentComponents(ResourceController rc, APIDocumentContext context);

  /// Documents the operation parameters of a ResourceController.
  ///
  /// [rc] The ResourceController instance.
  /// [context] The API documentation context.
  /// [operation] The operation to document.
  ///
  /// Returns a list of [APIParameter] objects.
  List<APIParameter> documentOperationParameters(
    ResourceController rc,
    APIDocumentContext context,
    Operation? operation,
  );

  /// Documents the operation request body of a ResourceController.
  ///
  /// [rc] The ResourceController instance.
  /// [context] The API documentation context.
  /// [operation] The operation to document.
  ///
  /// Returns an [APIRequestBody] object or null.
  APIRequestBody? documentOperationRequestBody(
    ResourceController rc,
    APIDocumentContext context,
    Operation? operation,
  );

  /// Documents the operations of a ResourceController.
  ///
  /// [rc] The ResourceController instance.
  /// [context] The API documentation context.
  /// [route] The route string.
  /// [path] The API path.
  ///
  /// Returns a map of operation names to [APIOperation] objects.
  Map<String, APIOperation> documentOperations(
    ResourceController rc,
    APIDocumentContext context,
    String route,
    APIPath path,
  );
}

/// Represents an operation in a ResourceController.
class ResourceControllerOperation {
  /// Creates a new ResourceControllerOperation.
  ResourceControllerOperation({
    required this.scopes,
    required this.pathVariables,
    required this.httpMethod,
    required this.dartMethodName,
    required this.positionalParameters,
    required this.namedParameters,
    required this.invoker,
  });

  /// The required authentication scopes for this operation.
  final List<AuthScope>? scopes;

  /// The path variables for this operation.
  final List<String> pathVariables;

  /// The HTTP method for this operation.
  final String httpMethod;

  /// The name of the Dart method implementing this operation.
  final String dartMethodName;

  /// The positional parameters for this operation.
  final List<ResourceControllerParameter> positionalParameters;

  /// The named parameters for this operation.
  final List<ResourceControllerParameter> namedParameters;

  /// The function to invoke this operation.
  final Future<Response> Function(
    ResourceController resourceController,
    ResourceControllerOperationInvocationArgs args,
  ) invoker;

  /// Checks if a request's method and path variables will select this operation.
  ///
  /// [requestMethod] The HTTP method of the request.
  /// [requestPathVariables] The path variables of the request.
  ///
  /// Returns true if the operation is suitable for the request, false otherwise.
  bool isSuitableForRequest(
    String? requestMethod,
    List<String?> requestPathVariables,
  ) {
    if (requestMethod != null && requestMethod.toUpperCase() != httpMethod) {
      return false;
    }

    if (pathVariables.length != requestPathVariables.length) {
      return false;
    }

    return requestPathVariables.every(pathVariables.contains);
  }
}

/// Represents a parameter in a ResourceController operation.
class ResourceControllerParameter {
  /// Creates a new ResourceControllerParameter.
  ResourceControllerParameter({
    required this.symbolName,
    required this.name,
    required this.location,
    required this.isRequired,
    required dynamic Function(dynamic input)? decoder,
    required this.type,
    required this.defaultValue,
    required this.acceptFilter,
    required this.ignoreFilter,
    required this.requireFilter,
    required this.rejectFilter,
  }) : _decoder = decoder;

  /// Creates a typed ResourceControllerParameter.
  static ResourceControllerParameter make<T>({
    required String symbolName,
    required String? name,
    required BindingType location,
    required bool isRequired,
    required dynamic Function(dynamic input) decoder,
    required dynamic defaultValue,
    required List<String>? acceptFilter,
    required List<String>? ignoreFilter,
    required List<String>? requireFilter,
    required List<String>? rejectFilter,
  }) {
    return ResourceControllerParameter(
      symbolName: symbolName,
      name: name,
      location: location,
      isRequired: isRequired,
      decoder: decoder,
      type: T,
      defaultValue: defaultValue,
      acceptFilter: acceptFilter,
      ignoreFilter: ignoreFilter,
      requireFilter: requireFilter,
      rejectFilter: rejectFilter,
    );
  }

  /// The name of the symbol in the Dart code.
  final String symbolName;

  /// The name of the parameter in the API.
  final String? name;

  /// The type of the parameter.
  final Type type;

  /// The default value of the parameter.
  final dynamic defaultValue;

  /// The filter for accepted values.
  final List<String>? acceptFilter;

  /// The filter for ignored values.
  final List<String>? ignoreFilter;

  /// The filter for required values.
  final List<String>? requireFilter;

  /// The filter for rejected values.
  final List<String>? rejectFilter;

  /// The location of the parameter in the request.
  final BindingType location;

  /// Indicates if the parameter is required.
  final bool isRequired;

  /// The decoder function for the parameter.
  final dynamic Function(dynamic input)? _decoder;

  /// Gets the API parameter location for this parameter.
  APIParameterLocation get apiLocation {
    switch (location) {
      case BindingType.body:
        throw StateError('body parameters do not have a location');
      case BindingType.header:
        return APIParameterLocation.header;
      case BindingType.query:
        return APIParameterLocation.query;
      case BindingType.path:
        return APIParameterLocation.path;
    }
  }

  /// Gets the location name as a string.
  String get locationName {
    switch (location) {
      case BindingType.query:
        return "query";
      case BindingType.body:
        return "body";
      case BindingType.header:
        return "header";
      case BindingType.path:
        return "path";
    }
  }

  /// Decodes the parameter value from the request.
  ///
  /// [request] The HTTP request.
  ///
  /// Returns the decoded value.
  dynamic decode(Request? request) {
    switch (location) {
      case BindingType.query:
        {
          final queryParameters = request!.raw.uri.queryParametersAll;
          final value = request.body.isFormData
              ? request.body.as<Map<String, List<String>>>()[name!]
              : queryParameters[name!];
          if (value == null) {
            return null;
          }
          return _decoder!(value);
        }

      case BindingType.body:
        {
          if (request!.body.isEmpty) {
            return null;
          }
          return _decoder!(request.body);
        }
      case BindingType.header:
        {
          final header = request!.raw.headers[name!];
          if (header == null) {
            return null;
          }
          return _decoder!(header);
        }

      case BindingType.path:
        {
          final path = request!.path.variables[name];
          if (path == null) {
            return null;
          }
          return _decoder!(path);
        }
    }
  }
}

/// Holds the arguments for invoking a ResourceController operation.
class ResourceControllerOperationInvocationArgs {
  /// The instance variables for the invocation.
  late Map<String, dynamic> instanceVariables;

  /// The named arguments for the invocation.
  late Map<String, dynamic> namedArguments;

  /// The positional arguments for the invocation.
  late List<dynamic> positionalArguments;
}
