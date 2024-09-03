/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:protevus_openapi/v3.dart';
import 'package:protevus_openapi/object.dart';

/// Defines methods for documenting OpenAPI components.
///
/// The documentation process calls methods from objects of this type. You implement methods from
/// this interface to add reusable components to your OpenAPI document. You may use these components
/// when documenting other components or when implementing [APIOperationDocumenter].
///
/// You must implement [documentComponents].
///
/// ApplicationChannel, Controller, ManagedEntity, and AuthServer all implement this interface.
///
abstract class APIComponentDocumenter {
  /// Instructs this object to add its components to the provided [context].
  ///
  /// You may register components with [context] in this method. The order in which components
  /// are registered does not matter.
  ///
  /// Example:
  ///
  ///         class Car implements APIComponentDocumenter {
  ///           @override
  ///           void documentComponents(APIDocumentContext context) {
  ///             context.schema.register("Car", APISchemaObject.object({
  ///               "make": APISchemaObject.string(),
  ///               "model": APISchemaObject.string(),
  ///               "year": APISchemaObject.integer(),
  ///             }));
  ///           }
  ///         }
  ///
  /// See [APIDocumentContext] for more details.
  void documentComponents(APIDocumentContext context);
}

/// Defines methods for documenting OpenAPI operations in a Controller.
///
/// The documentation process calls these methods for every Controller in your ApplicationChannel.
/// You implement [documentOperations] to create or modify [APIOperation] objects that describe the
/// HTTP operations that a controller handler.
abstract class APIOperationDocumenter {
  /// Returns a map of API paths handled by this object.
  ///
  /// This method is implemented by Router to provide the paths of an OpenAPI document
  /// and typically shouldn't be overridden by another controller.
  Map<String, APIPath> documentPaths(APIDocumentContext context);

  /// Documents the API operations handled by this object.
  ///
  /// You implement this method to create or modify [APIOperation] objects that describe the
  /// HTTP operations that a controller handles. Each controller in the channel, starting with
  /// the entry point, have this method.
  ///
  /// By default, a controller returns the operations created by its linked controllers.
  ///
  /// Endpoint controllers should override this method to create a [Map] of [APIOperation] objects, where the
  /// key is a [String] representation of the status code the response is for. Example:
  ///
  ///       @override
  ///       Map<String, APIOperation> documentOperations(APIDocumentContext context, APIPath path) {
  ///         if (path.containsPathParameters(['id'])) {
  ///           return {
  ///             "get": APIOperation("Get one thing", {
  ///               "200": APIResponse(...)
  ///             })
  ///           };
  ///         }
  ///
  ///         return {
  ///           "get": APIOperation("Get some things", {
  ///             "200": APIResponse(...)
  ///           })
  ///         };
  ///       }
  ///
  /// Middleware controllers should override this method to call the superclass' implementation (which gathers
  /// the operation objects from an endpoint controller) and then modify those operations before returning them.
  ///
  ///       @override
  ///       Map<String, APIOperation> documentOperations(APIDocumentContext context, APIPath path) {
  ///         final ops = super.documentOperation(context, path);
  ///
  ///         // add x-api-key header parameter to each operation
  ///         ops.values.forEach((op) {
  ///           op.addParameter(new APIParameter.header("x-api-key, schema: new APISchemaObject.string()));
  ///         });
  ///
  ///         return ops;
  ///       }
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  );
}

/// An object that contains information about [APIDocument] being generated.
///
/// This class serves as a context for the API documentation process, providing access to various
/// component collections and utility methods for managing the documentation generation.
///
/// Component registries for each type of component - e.g. [schema], [responses] - are used to
/// register and reference those types.
class APIDocumentContext {
  /// Creates a new [APIDocumentContext] instance.
  ///
  /// This constructor initializes the context with the provided [document] and sets up
  /// various [APIComponentCollection] instances for different types of API components.
  /// These collections are used to manage and reference reusable components throughout
  /// the API documentation process.
  ///
  /// The following component collections are initialized:
  /// - [schema]: For reusable [APISchemaObject] components.
  /// - [responses]: For reusable [APIResponse] components.
  /// - [parameters]: For reusable [APIParameter] components.
  /// - [requestBodies]: For reusable [APIRequestBody] components.
  /// - [headers]: For reusable [APIHeader] components.
  /// - [securitySchemes]: For reusable [APISecurityScheme] components.
  /// - [callbacks]: For reusable [APICallback] components.
  ///
  /// Each collection is associated with its corresponding component map in the [document].
  APIDocumentContext(this.document)
      : schema = APIComponentCollection<APISchemaObject>._(
          "schemas",
          document.components!.schemas,
        ),
        responses = APIComponentCollection<APIResponse>._(
          "responses",
          document.components!.responses,
        ),
        parameters = APIComponentCollection<APIParameter>._(
          "parameters",
          document.components!.parameters,
        ),
        requestBodies = APIComponentCollection<APIRequestBody>._(
          "requestBodies",
          document.components!.requestBodies,
        ),
        headers = APIComponentCollection<APIHeader>._(
          "headers",
          document.components!.headers,
        ),
        securitySchemes = APIComponentCollection<APISecurityScheme>._(
          "securitySchemes",
          document.components!.securitySchemes,
        ),
        callbacks = APIComponentCollection<APICallback>._(
          "callbacks",
          document.components!.callbacks,
        );

  /// The OpenAPI document being created and populated during the documentation process.
  ///
  /// This [APIDocument] instance represents the root of the OpenAPI specification
  /// structure. It contains all the components, paths, and other information
  /// that will be included in the final OpenAPI document.
  final APIDocument document;

  /// Reusable [APISchemaObject] components.
  ///
  /// This collection manages and provides access to reusable schema components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Schema components are used to define the structure of request and response
  /// bodies, as well as other data structures used in the API.
  final APIComponentCollection<APISchemaObject> schema;

  /// Reusable [APIResponse] components.
  ///
  /// This collection manages and provides access to reusable response components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Response components are used to define standard responses that can be
  /// reused across multiple operations in the API, promoting consistency
  /// and reducing duplication in the API specification.
  final APIComponentCollection<APIResponse> responses;

  /// Reusable [APIParameter] components.
  ///
  /// This collection manages and provides access to reusable parameter components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Parameter components are used to define common parameters that can be
  /// reused across multiple operations in the API, such as query parameters,
  /// path parameters, or header parameters. This promotes consistency and
  /// reduces duplication in the API specification.
  final APIComponentCollection<APIParameter> parameters;

  /// Reusable [APIRequestBody] components.
  ///
  /// This collection manages and provides access to reusable request body components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Request body components are used to define standard request bodies that can be
  /// reused across multiple operations in the API, promoting consistency
  /// and reducing duplication in the API specification.
  final APIComponentCollection<APIRequestBody> requestBodies;

  /// Reusable [APIHeader] components.
  ///
  /// This collection manages and provides access to reusable header components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Header components are used to define common headers that can be
  /// reused across multiple operations in the API. This promotes consistency
  /// and reduces duplication in the API specification. Headers can be used
  /// for various purposes, such as authentication tokens, API versioning,
  /// or custom metadata.
  final APIComponentCollection<APIHeader> headers;

  /// Reusable [APISecurityScheme] components.
  ///
  /// This collection manages and provides access to reusable security scheme components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Security scheme components are used to define the security mechanisms that can be
  /// used across the API. This includes authentication methods such as API keys,
  /// HTTP authentication, OAuth2 flows, and OpenID Connect. By defining these
  /// security schemes as reusable components, they can be easily applied to
  /// different operations or the entire API, ensuring consistent security
  /// documentation and implementation.
  final APIComponentCollection<APISecurityScheme> securitySchemes;

  /// Reusable [APICallback] components.
  ///
  /// This collection manages and provides access to reusable callback components
  /// in the OpenAPI document. These components can be registered, referenced,
  /// and retrieved throughout the API documentation process.
  ///
  /// Callback components are used to define asynchronous, out-of-band requests
  /// that may be initiated by the API provider after the initial request has been
  /// processed. They are typically used for webhooks or other event-driven
  /// interactions. By defining callbacks as reusable components, they can be
  /// easily referenced and applied to different operations in the API specification,
  /// promoting consistency and reducing duplication.
  final APIComponentCollection<APICallback> callbacks;

  /// A list of deferred operations to be executed during the finalization process.
  ///
  /// This list stores functions that represent asynchronous operations that need to be
  /// performed before the API documentation is finalized. These operations are typically
  /// added using the [defer] method and are executed in order during the [finalize] process.
  List<Function> _deferredOperations = [];

  /// Schedules an asynchronous operation to be executed during the documentation process.
  ///
  /// Documentation methods are synchronous. Asynchronous methods may be called and awaited on
  /// in [document]. All [document] closures will be executes and awaited on before finishing [document].
  /// These closures are called in the order they were added.
  void defer(FutureOr Function() document) {
    _deferredOperations.add(document);
  }

  /// Finalizes the API document and returns it as a serializable [Map].
  ///
  /// This method is invoked by the command line tool for creating OpenAPI documents.
  Future<Map<String, dynamic>> finalize() async {
    final dops = _deferredOperations;
    _deferredOperations = [];

    await Future.forEach(dops, (Function dop) => dop());

    document.paths!.values
        .expand((p) => p!.operations.values)
        .where((op) => op!.security != null)
        .expand((op) => op!.security!)
        .forEach((req) {
      req.requirements!.forEach((schemeName, scopes) {
        final scheme = document.components!.securitySchemes[schemeName];
        if (scheme!.type == APISecuritySchemeType.oauth2) {
          for (final flow in scheme.flows!.values) {
            for (final scope in scopes) {
              if (!flow!.scopes!.containsKey(scope)) {
                flow.scopes![scope] = "";
              }
            }
          }
        }
      });
    });

    return document.asMap();
  }
}

/// A collection of reusable OpenAPI objects.
///
/// This class manages a collection of reusable OpenAPI components of type [T],
/// which must extend [APIObject]. It provides methods for registering, retrieving,
/// and referencing components within an OpenAPI document.
///
/// The collection supports two ways of referencing components:
/// 1. By name: Components can be registered with a string name and retrieved using that name.
/// 2. By type: Components can be associated with a Dart Type and retrieved using that Type.
///
/// This class is typically used within an [APIDocumentContext] to manage different
/// types of OpenAPI components such as schemas, responses, parameters, etc.
///
/// Key features:
/// - Register components with [register]
/// - Retrieve components by name with [getObject] or the [] operator
/// - Retrieve components by Type with [getObjectWithType]
/// - Check if a Type has been registered with [hasRegisteredType]
///
/// The class also handles deferred resolution of Type-based references, allowing
/// components to be referenced before they are fully defined.
class APIComponentCollection<T extends APIObject> {
  /// Creates a new [APIComponentCollection] instance.
  ///
  /// This constructor is private and is used internally to initialize
  /// the component collection with a specific type name and component map.
  ///
  /// [_typeName] is a string that represents the type of components in this collection.
  /// It is used to construct the reference URIs for the components.
  ///
  /// [_componentMap] is a map that stores the actual components, with their names as keys.
  /// This map is used to register and retrieve components by name.
  APIComponentCollection._(this._typeName, this._componentMap);

  /// The name of the component type managed by this collection.
  ///
  /// This string is used to construct reference URIs for components in the OpenAPI document.
  /// It typically corresponds to the plural form of the component type, such as "schemas",
  /// "responses", "parameters", etc.
  final String _typeName;

  /// A map that stores the components of type [T] with their names as keys.
  ///
  /// This map is used to store and retrieve components that have been registered
  /// with the [APIComponentCollection]. The keys are the names given to the
  /// components when they are registered, and the values are the actual component
  /// objects of type [T].
  ///
  /// This map is populated by the [register] method and accessed by various
  /// other methods in the class to retrieve registered components.
  final Map<String, T> _componentMap;

  /// A map that associates Dart types with their corresponding API components.
  ///
  /// This map is used to store references between Dart types and their registered
  /// API components. When a component is registered with a specific type using
  /// the [register] method, an entry is added to this map.
  ///
  /// The keys are Dart [Type] objects representing the types associated with
  /// the components, and the values are the corresponding API components of type [T].
  ///
  /// This map is used internally to resolve type-based references and to check
  /// if a specific type has been registered using [hasRegisteredType].
  final Map<Type, T> _typeReferenceMap = {};

  /// A map that stores [Completer] objects for deferred type resolution.
  ///
  /// This map is used to handle cases where a component is referenced by its Type
  /// before it has been registered. The keys are Dart [Type] objects, and the values
  /// are [Completer] objects that will be completed when the corresponding component
  /// is registered.
  ///
  /// When a component is requested by type using [getObjectWithType] and it hasn't
  /// been registered yet, a new [Completer] is added to this map. Later, when the
  /// component is registered using [register], the corresponding [Completer] is
  /// completed, allowing any pending references to be resolved.
  ///
  /// This mechanism enables forward references in the API documentation process,
  /// allowing components to be used before they are fully defined.
  final Map<Type, Completer<T>> _resolutionMap = {};

  /// Registers a component with a given name and optionally associates it with a Type.
  ///
  /// [component] will be stored in the OpenAPI document. The component will be usable
  /// by other objects by its [name].
  ///
  /// If this component is represented by a class, provide it as [representation].
  /// Objects may reference either [name] or [representation] when using a component.
  void register(String name, T component, {Type? representation}) {
    if (_componentMap.containsKey(name)) {
      return;
    }

    if (representation != null &&
        _typeReferenceMap.containsKey(representation)) {
      return;
    }

    _componentMap[name] = component;

    if (representation != null) {
      final refObject = getObject(name);
      _typeReferenceMap[representation] = refObject;

      if (_resolutionMap.containsKey(representation)) {
        _resolutionMap[representation]!.complete(refObject);
        _resolutionMap.remove(representation);
      }
    }
  }

  /// Returns a reference object in this collection with the given [name].
  ///
  /// See [getObject].
  T operator [](String name) => getObject(name);

  /// Returns an object that references a component named [name].
  ///
  /// This method creates and returns a reference object of type [T] that points to
  /// a component in the OpenAPI document with the given [name]. The returned object
  /// is always a reference; it does not contain the actual values of the component.
  ///
  /// An object is always returned, even if no component named [name] exists.
  /// If after [APIDocumentContext.finalize] is called and no object
  /// has been registered for [name], an error is thrown.
  T getObject(String name) {
    final obj = _getInstanceOf();
    obj.referenceURI = Uri(path: "/components/$_typeName/$name");
    return obj;
  }

  /// Returns an object that references a component registered for [type].
  ///
  /// This method creates and returns a reference object of type [T] that points to
  /// a component in the OpenAPI document associated with the given [type].
  ///
  /// An object is always returned, even if no component named has been registered
  /// for [type]. If after [APIDocumentContext.finalize] is called and no object
  /// has been registered for [type], an error is thrown.
  T getObjectWithType(Type type) {
    final obj = _getInstanceOf();
    obj.referenceURI =
        Uri(path: "/components/$_typeName/conduit-typeref:$type");

    if (_typeReferenceMap.containsKey(type)) {
      obj.referenceURI = _typeReferenceMap[type]!.referenceURI;
    } else {
      final completer =
          _resolutionMap.putIfAbsent(type, () => Completer<T>.sync());

      completer.future.then((refObject) {
        obj.referenceURI = refObject.referenceURI;
      });
    }

    return obj;
  }

  /// Creates and returns an empty instance of type [T].
  ///
  /// This method is used internally to create empty instances of various API components
  /// based on the generic type [T]. It supports the following types:
  /// - [APISchemaObject]
  /// - [APIResponse]
  /// - [APIParameter]
  /// - [APIRequestBody]
  /// - [APIHeader]
  /// - [APISecurityScheme]
  /// - [APICallback]
  ///
  /// For each supported type, it calls the corresponding `empty()` constructor
  /// and casts the result to type [T].
  ///
  /// If [T] is not one of the supported types, this method throws a [StateError]
  /// with a message indicating that it cannot reference an API object of that type.
  ///
  /// Returns: An empty instance of type [T].
  ///
  /// Throws: [StateError] if [T] is not a supported API object type.
  T _getInstanceOf() {
    switch (T) {
      case const (APISchemaObject):
        return APISchemaObject.empty() as T;
      case const (APIResponse):
        return APIResponse.empty() as T;
      case const (APIParameter):
        return APIParameter.empty() as T;
      case const (APIRequestBody):
        return APIRequestBody.empty() as T;
      case const (APIHeader):
        return APIHeader.empty() as T;
      case const (APISecurityScheme):
        return APISecurityScheme.empty() as T;
      case const (APICallback):
        return APICallback.empty() as T;
    }

    throw StateError("cannot reference API object of type $T");
  }

  /// Checks if a specific Type has been registered with this component collection.
  ///
  /// This method returns true if a component has been registered for the given [type]
  /// using the [register] method with a non-null [representation] parameter.
  ///
  /// Parameters:
  ///   [type] - The Type to check for registration.
  ///
  /// Returns:
  ///   A boolean value indicating whether the [type] has been registered (true) or not (false).
  ///
  /// Example:
  ///   ```dart
  ///   final collection = APIComponentCollection<APISchemaObject>(...);
  ///   collection.register('User', userSchema, representation: User);
  ///
  ///   assert(collection.hasRegisteredType(User) == true);
  ///   assert(collection.hasRegisteredType(String) == false);
  ///   ```
  bool hasRegisteredType(Type type) {
    return _typeReferenceMap.containsKey(type);
  }
}
