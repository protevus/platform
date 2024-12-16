import 'package:platform_contracts/contracts.dart';
import 'package:platform_collections/collections.dart';

class Repository implements ConfigContract, Map<String, dynamic> {
  static final Map<String, Function> _macros = {};

  final Map<String, dynamic> _items;

  Repository([Map<String, dynamic> items = const {}])
      : _items = Map.from(items);

  static void macro(String name, Function macro) {
    _macros[name] = macro;
  }

  @override
  bool has(String key) {
    return Arr.has(_items, key);
  }

  @override
  T? get<T>(String key, [T? defaultValue]) {
    final value = Arr.get(_items, key);
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  Map<String, dynamic> getMany(List<String> keys) {
    return Map.fromEntries(keys.map((key) => MapEntry(key, get(key))));
  }

  String string(String key, [String? defaultValue]) {
    final value = get<dynamic>(key);
    if (value is String) {
      return value;
    }
    if (value == null && defaultValue != null) {
      return defaultValue;
    }
    throw ArgumentError(
        'Configuration value for key [$key] must be a string, ${value.runtimeType} given.');
  }

  int integer(String key, [int? defaultValue]) {
    final value = get<dynamic>(key);
    if (value is int) {
      return value;
    }
    if (value == null && defaultValue != null) {
      return defaultValue;
    }
    throw ArgumentError(
        'Configuration value for key [$key] must be an integer, ${value.runtimeType} given.');
  }

  double float(String key, [double? defaultValue]) {
    final value = get<dynamic>(key);
    if (value is double) {
      return value;
    }
    if (value == null && defaultValue != null) {
      return defaultValue;
    }
    throw ArgumentError(
        'Configuration value for key [$key] must be a double, ${value.runtimeType} given.');
  }

  bool boolean(String key, [bool? defaultValue]) {
    final value = get<dynamic>(key);
    if (value is bool) {
      return value;
    }
    if (value == null && defaultValue != null) {
      return defaultValue;
    }
    throw ArgumentError(
        'Configuration value for key [$key] must be a boolean, ${value.runtimeType} given.');
  }

  List<dynamic> array(String key, [List<dynamic>? defaultValue]) {
    final value = get<dynamic>(key);
    if (value is List) {
      return value;
    }
    if (value == null && defaultValue != null) {
      return defaultValue;
    }
    throw ArgumentError(
        'Configuration value for key [$key] must be a List, ${value.runtimeType} given.');
  }

  @override
  void set(dynamic key, dynamic value) {
    Arr.set(_items, key, value);
  }

  @override
  void prepend(String key, dynamic value) {
    final list = array(key, []);
    list.insert(0, value);
    set(key, list);
  }

  @override
  void push(String key, dynamic value) {
    final list = array(key, []);
    list.add(value);
    set(key, list);
  }

  @override
  Map<String, dynamic> all() => Map.from(_items);

  // Implement Map interface
  @override
  dynamic operator [](Object? key) => get(key as String);

  @override
  void operator []=(String key, dynamic value) => set(key, value);

  @override
  void clear() => _items.clear();

  @override
  Iterable<String> get keys => _items.keys;

  @override
  dynamic remove(Object? key) => _items.remove(key);

  // Other Map interface methods...
  @override
  void addAll(Map<String, dynamic> other) => other.forEach(set);

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) {
    for (final entry in newEntries) {
      set(entry.key, entry.value);
    }
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _items.cast<RK, RV>();

  @override
  bool containsKey(Object? key) => has(key as String);

  @override
  bool containsValue(Object? value) => _items.containsValue(value);

  @override
  Iterable<MapEntry<String, dynamic>> get entries => _items.entries;

  @override
  void forEach(void Function(String key, dynamic value) action) {
    _items.forEach(action);
  }

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  int get length => _items.length;

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(String key, dynamic value) convert) {
    return _items.map(convert);
  }

  @override
  dynamic putIfAbsent(String key, dynamic Function() ifAbsent) {
    return _items.putIfAbsent(key, ifAbsent);
  }

  @override
  void removeWhere(bool Function(String key, dynamic value) test) {
    _items.removeWhere(test);
  }

  @override
  dynamic update(String key, dynamic Function(dynamic value) update,
      {dynamic Function()? ifAbsent}) {
    return _items.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(dynamic Function(String key, dynamic value) update) {
    _items.updateAll(update);
  }

  @override
  Iterable<dynamic> get values => _items.values;

  dynamic callMacro(String name, List<dynamic> arguments) {
    if (_macros.containsKey(name)) {
      return Function.apply(_macros[name]!, [this, ...arguments]);
    }
    throw NoSuchMethodError.withInvocation(
        this, Invocation.method(Symbol(name), arguments));
  }
}
