import 'dart:io';
import 'package:test/test.dart';
import '../tools/python_parser.dart';

void main() {
  group('PythonParser', () {
    test('parses interface correctly', () async {
      final file = File('test/fixtures/sample.py');
      final classes = await PythonParser.parseFile(file);

      final interface = classes.firstWhere((c) => c.isInterface);
      expect(interface.name, equals('LLMProtocol'));
      expect(interface.docstring, equals('Protocol for language models.'));

      // Test generate method
      final generateMethod =
          interface.methods.firstWhere((m) => m.name == 'generate');
      expect(generateMethod.isAsync, isTrue);
      expect(generateMethod.isAbstract, isTrue);
      expect(generateMethod.docstring,
          equals('Generate completions for the prompts.'));
      expect(generateMethod.parameters.length, equals(1));
      expect(generateMethod.parameters.first.name, equals('prompts'));
      expect(generateMethod.parameters.first.type, equals('List[str]'));
      expect(generateMethod.returnType, equals('List[str]'));

      // Test model_name property
      final modelNameMethod =
          interface.methods.firstWhere((m) => m.name == 'model_name');
      expect(modelNameMethod.isProperty, isTrue);
      expect(modelNameMethod.isAbstract, isTrue);
      expect(modelNameMethod.docstring, equals('Get the model name.'));
      expect(modelNameMethod.parameters.isEmpty, isTrue);
      expect(modelNameMethod.returnType, equals('str'));
    });

    test('parses abstract class correctly', () async {
      final file = File('test/fixtures/sample.py');
      final classes = await PythonParser.parseFile(file);

      final abstractClass = classes.firstWhere((c) => c.name == 'BaseChain');
      expect(abstractClass.docstring, equals('Base class for chains.'));

      // Test properties
      expect(abstractClass.properties.length, equals(2));
      final memoryProp =
          abstractClass.properties.firstWhere((p) => p.name == 'memory');
      expect(memoryProp.type, equals('Optional[dict]'));
      expect(memoryProp.hasDefault, isTrue);

      // Test run method
      final runMethod =
          abstractClass.methods.firstWhere((m) => m.name == 'run');
      expect(runMethod.isAsync, isTrue);
      expect(runMethod.isAbstract, isTrue);
      expect(runMethod.docstring, equals('Run the chain on the inputs.'));
      expect(runMethod.parameters.length, equals(1));
      expect(runMethod.parameters.first.name, equals('inputs'));
      expect(runMethod.parameters.first.type, equals('dict'));
      expect(runMethod.returnType, equals('dict'));
    });

    test('parses concrete class correctly', () async {
      final file = File('test/fixtures/sample.py');
      final classes = await PythonParser.parseFile(file);

      final concreteClass = classes.firstWhere((c) => c.name == 'SimpleChain');
      expect(concreteClass.docstring,
          equals('A simple implementation of a chain.'));

      // Test constructor
      final constructor =
          concreteClass.methods.firstWhere((m) => m.name == '__init__');
      expect(constructor.docstring, equals('Initialize the chain.'));
      expect(constructor.parameters.length, equals(1));
      expect(constructor.parameters.first.name, equals('llm'));
      expect(constructor.parameters.first.type, equals('LLMProtocol'));

      // Test run method
      final runMethod =
          concreteClass.methods.firstWhere((m) => m.name == 'run');
      expect(runMethod.isAsync, isTrue);
      expect(runMethod.isAbstract, isFalse);
      expect(runMethod.docstring, equals('Execute the chain logic.'));
      expect(runMethod.parameters.length, equals(1));
      expect(runMethod.parameters.first.name, equals('inputs'));
      expect(runMethod.parameters.first.type, equals('dict'));
      expect(runMethod.returnType, equals('dict'));
    });
  });
}
