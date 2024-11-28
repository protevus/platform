// Test classes ported from Laravel's ContainerTest.php

// Basic concrete class
class ContainerConcreteStub {}

// Interface and implementations
abstract class IContainerContractStub {
  String getValue();
}

class ContainerImplementationStub implements IContainerContractStub {
  final String value;
  ContainerImplementationStub([this.value = 'implementation']);
  @override
  String getValue() => value;
}

class ContainerImplementationStubTwo implements IContainerContractStub {
  @override
  String getValue() => 'implementation2';
}

// Classes with dependencies
class ContainerDependentStub {
  final IContainerContractStub impl;
  ContainerDependentStub(this.impl);
}

class ContainerNestedDependentStub {
  final ContainerDependentStub inner;
  ContainerNestedDependentStub(this.inner);
}

// Classes with default values
class ContainerDefaultValueStub {
  final ContainerConcreteStub stub;
  final String default_;
  ContainerDefaultValueStub(this.stub, [this.default_ = 'taylor']);
}

// Classes with mixed parameters
class ContainerMixedPrimitiveStub {
  final int first;
  final ContainerConcreteStub stub;
  final int last;
  ContainerMixedPrimitiveStub(this.first, this.stub, this.last);
}

// Classes for variable injection
class ContainerInjectVariableStub {
  final String something;
  ContainerInjectVariableStub(ContainerConcreteStub concrete, this.something);
}

class ContainerInjectVariableStubWithInterface
    implements IContainerContractStub {
  final String something;
  ContainerInjectVariableStubWithInterface(
      ContainerConcreteStub concrete, this.something);
  @override
  String getValue() => something;
}

// Class for contextual binding
class ContainerContextualBindingCallTarget {
  IContainerContractStub work(IContainerContractStub stub) => stub;
}

// Classes for circular dependency testing
class CircularAStub {
  CircularAStub(CircularBStub b);
}

class CircularBStub {
  CircularBStub(CircularCStub c);
}

class CircularCStub {
  CircularCStub(CircularAStub a);
}

// Additional test types
class StubAlias implements IContainerContractStub {
  @override
  String getValue() => 'alias';
}
