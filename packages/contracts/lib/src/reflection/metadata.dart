/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Metadata for a property
class PropertyMetadata {
  final String name;
  final Type type;
  final bool isStatic;
  final bool isPrivate;
  final bool isFinal;
  final bool isConst;

  const PropertyMetadata({
    required this.name,
    required this.type,
    this.isStatic = false,
    this.isPrivate = false,
    this.isFinal = false,
    this.isConst = false,
  });
}

/// Metadata for a method
class MethodMetadata {
  final String name;
  final Type returnType;
  final List<Type> parameterTypes;
  final List<String> parameterNames;
  final List<bool> isRequired;
  final List<bool> isNamed;
  final bool isStatic;
  final bool isPrivate;
  final bool isAbstract;

  const MethodMetadata({
    required this.name,
    required this.returnType,
    required this.parameterTypes,
    required this.parameterNames,
    required this.isRequired,
    required this.isNamed,
    this.isStatic = false,
    this.isPrivate = false,
    this.isAbstract = false,
  });
}

/// Metadata for a constructor
class ConstructorMetadata {
  final String name;
  final List<Type> parameterTypes;
  final List<String> parameterNames;
  final List<bool> isRequired;
  final List<bool> isNamed;
  final bool isConst;
  final bool isFactory;

  const ConstructorMetadata({
    required this.name,
    required this.parameterTypes,
    required this.parameterNames,
    required this.isRequired,
    required this.isNamed,
    this.isConst = false,
    this.isFactory = false,
  });
}
