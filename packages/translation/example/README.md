# Translation Package Examples

This directory contains examples demonstrating how to use the Translation package in different scenarios.

## Setup

1. For basic and advanced examples:
```bash
cd packages/translation
dart pub get
```

2. For Flutter example:
```bash
cd packages/translation/example
flutter pub get
```

## Running Examples

### Basic Usage (`basic_usage.dart`)

Shows fundamental features:
```bash
cd packages/translation
dart example/basic_usage.dart
```

Features demonstrated:
- Setting default locale
- Loading translation files
- Basic translations
- Translations with replacements
- Pluralization
- Locale switching
- Fallback locales

### Advanced Pluralization (`advanced_pluralization.dart`)

Shows complex pluralization features:
```bash
cd packages/translation
dart example/advanced_pluralization.dart
```

Features demonstrated:
- Basic pluralization
- Explicit number conditions
- Range conditions
- Mixed conditions
- Language-specific pluralization rules (e.g., Russian)
- Replacements with pluralization

### Flutter Integration (`flutter_integration.dart`)

Shows how to integrate with Flutter:
```bash
cd packages/translation/example
flutter run -t lib/flutter_integration.dart
```

Features demonstrated:
- Initializing translations in a Flutter app
- Using translations in widgets
- Dynamic locale switching
- Pluralization with UI state
- Building a language switcher

## Translation Files

The examples use JSON translation files in the `translations` directory:

### English (`en.json`):
```json
{
  "messages": {
    "welcome": "Hello!",
    "greeting": "Hello, :name!",
    "items": "You have {1} item|You have :count items",
    "new_feature": "Check out our new feature!",
    "add_item": "Add Item"
  }
}
```

### Spanish (`es.json`):
```json
{
  "messages": {
    "welcome": "¡Hola!",
    "greeting": "¡Hola, :name!",
    "items": "Tienes {1} artículo|Tienes :count artículos",
    "new_feature": "¡Mira nuestra nueva función!",
    "add_item": "Agregar Artículo"
  }
}
```

## Key Features Demonstrated

1. **Pluralization Rules**
   - Basic two-form pluralization (English-like)
   - Complex pluralization (Russian, Arabic)
   - Range-based pluralization
   - Explicit number conditions

2. **String Replacements**
   - Named placeholders (`:name`)
   - Count placeholders for pluralization

3. **Locale Handling**
   - Setting default locale
   - Switching locales at runtime
   - Fallback locales
   - Locale normalization

4. **File Organization**
   - JSON-based translations
   - Namespaced keys
   - Multiple translation files

5. **Framework Integration**
   - Standalone Dart usage
   - Flutter widget integration
   - State management
   - UI updates on locale changes

## Requirements

- Dart SDK >=3.0.0
- Flutter SDK >=3.0.0 (for Flutter example)
