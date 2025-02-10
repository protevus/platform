import 'package:flutter/material.dart';
import 'package:illuminate_translation/translation.dart';

final enTranslations = {
  'messages': {
    'welcome': 'Hello!',
    'greeting': 'Hello, :name!',
    'items': 'You have {1} item|You have :count items',
    'new_feature': 'Check out our new feature!',
    'add_item': 'Add Item'
  }
};

final esTranslations = {
  'messages': {
    'welcome': '¡Hola!',
    'greeting': '¡Hola, :name!',
    'items': 'Tienes {1} artículo|Tienes :count artículos',
    'new_feature': '¡Mira nuestra nueva función!',
    'add_item': 'Agregar Artículo'
  }
};

void main() {
  // Initialize translations with WebLoader
  final loader = WebLoader()
    ..addTranslations('en', enTranslations)
    ..addTranslations('es', esTranslations);

  // Set the global translator instance
  setTranslator(Translator(loader, 'en'));

  runApp(const TranslationDemo());
}

class TranslationDemo extends StatefulWidget {
  const TranslationDemo({super.key});

  @override
  State<TranslationDemo> createState() => _TranslationDemoState();
}

class _TranslationDemoState extends State<TranslationDemo> {
  String _currentLocale = 'en';
  int _itemCount = 1;

  void _toggleLanguage() {
    setState(() {
      _currentLocale = _currentLocale == 'en' ? 'es' : 'en';
      setLocale(_currentLocale);
    });
  }

  void _incrementItems() {
    setState(() {
      _itemCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(trans('messages.welcome')),
          actions: [
            TextButton(
              onPressed: _toggleLanguage,
              child: Text(_currentLocale.toUpperCase()),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                trans('messages.greeting', replace: {'name': 'Flutter'}),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                choice('messages.items', _itemCount,
                    replace: {'count': _itemCount.toString()}),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _incrementItems,
                child: Text(trans('messages.add_item')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
