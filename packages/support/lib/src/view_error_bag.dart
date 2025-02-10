// import 'package:illuminate_contracts/contracts.dart'; show MessageBagContract;
// import 'package:illuminate_contracts/contracts.dart' show MessageBagContract;
// import 'package:illuminate_macroable/macroable.dart';
// import 'package:illuminate_conditionable/conditionable.dart';
import 'message_bag.dart';
import 'stringable.dart';
import 'carbon.dart';

/// A class that provides error bag functionality for views.
///
/// This class allows for storing and retrieving error messages
/// organized by named bags, with string conversion capabilities.
class ViewErrorBag extends Stringable {
  /// The array of registered error bags.
  final Map<String, MessageBag> _bags;

  /// Create a new view error bag instance.
  ViewErrorBag()
      : _bags = {},
        super('');

  /// Get a MessageBag instance from the bags.
  MessageBag? getBag(String key) => _bags[key];

  /// Get all the bags.
  Map<String, MessageBag> getBags() => Map.from(_bags);

  /// Add a new MessageBag instance to the bags.
  void put(String key, MessageBag bag) {
    _bags[key] = bag;
  }

  /// Determine if a MessageBag instance exists in the bags.
  bool hasBag(String key) => _bags.containsKey(key);

  /// Get the number of messages in all bags.
  int count() {
    return _bags.values.fold<int>(0, (sum, bag) => sum + bag.length);
  }

  /// Get the raw messages in all bags.
  Map<String, Map<String, List<String>>> messages() {
    return Map.fromEntries(
      _bags.entries
          .map((entry) => MapEntry(entry.key, entry.value.getMessages())),
    );
  }

  /// Get all of the messages from all bags as a flat array.
  List<String> all() {
    return _bags.values
        .expand((bag) => bag.all().values.expand((messages) => messages))
        .toList();
  }

  /// Get the first message from any bag.
  String? first() {
    for (final bag in _bags.values) {
      final message = bag.first();
      if (message != null) return message;
    }
    return null;
  }

  /// Get the first message from a specific bag.
  String? firstFromBag(String bag) {
    return _bags[bag]?.first();
  }

  /// Determine if any bag has messages.
  bool any() => _bags.values.any((bag) => bag.isNotEmpty);

  /// Determine if all bags are empty.
  bool get isEmpty => !any();

  /// Determine if any bag has messages.
  bool get isNotEmpty => any();

  /// Convert the error bag to a string.
  @override
  String toString() {
    final messages = all();
    return messages.isEmpty ? '' : messages.join('\n');
  }

  @override
  dynamic when(dynamic value, dynamic Function(dynamic, dynamic)? callback,
      {dynamic Function(dynamic, dynamic)? orElse}) {
    return callback?.call(this, value) ?? orElse?.call(this, value) ?? this;
  }

  @override
  dynamic unless(dynamic value, dynamic Function(dynamic, dynamic)? callback,
      {dynamic Function(dynamic, dynamic)? orElse}) {
    return callback?.call(this, value) ?? orElse?.call(this, value) ?? this;
  }

  @override
  void whenThen(dynamic value, void Function() callback,
      {void Function()? orElse}) {
    if (value == true) {
      callback();
    } else if (orElse != null) {
      orElse();
    }
  }

  @override
  void unlessThen(dynamic value, void Function() callback,
      {void Function()? orElse}) {
    if (value == false) {
      callback();
    } else if (orElse != null) {
      orElse();
    }
  }

  @override
  dynamic tap([void Function(dynamic)? callback]) {
    callback?.call(this);
    return this;
  }

  @override
  T dump<T extends Object>([List<Object?>? args]) {
    print(toString());
    if (args != null) {
      for (final arg in args) {
        print(arg);
      }
    }
    return this as T;
  }

  @override
  Never dd([List<Object?>? args]) {
    dump(args);
    throw Exception('Dump and die');
  }

  // Forward all Stringable methods to a new Stringable instance
  @override
  int getLength() => Stringable(toString()).getLength();

  @override
  Stringable camel() => Stringable(toString()).camel();

  @override
  Stringable studly() => Stringable(toString()).studly();

  @override
  Stringable snake([String separator = '_']) =>
      Stringable(toString()).snake(separator);

  @override
  Stringable kebab() => Stringable(toString()).kebab();

  @override
  Stringable title() => Stringable(toString()).title();

  @override
  Stringable lower() => Stringable(toString()).lower();

  @override
  Stringable upper() => Stringable(toString()).upper();

  @override
  Stringable slug([String separator = '-']) =>
      Stringable(toString()).slug(separator);

  @override
  Stringable ascii() => Stringable(toString()).ascii();

  @override
  bool startsWith(dynamic needles) =>
      Stringable(toString()).startsWith(needles);

  @override
  bool endsWith(dynamic needles) => Stringable(toString()).endsWith(needles);

  @override
  Stringable finish(String cap) => Stringable(toString()).finish(cap);

  @override
  Stringable start(String prefix) => Stringable(toString()).start(prefix);

  @override
  bool contains(dynamic needles) => Stringable(toString()).contains(needles);

  @override
  Stringable limit(int limit, [String end = '...']) =>
      Stringable(toString()).limit(limit, end);

  @override
  Stringable toBase64() => Stringable(toString()).toBase64();

  @override
  Stringable fromBase64() => Stringable(toString()).fromBase64();

  @override
  List<String>? parseCallback([String separator = '@']) =>
      Stringable(toString()).parseCallback(separator);

  @override
  Stringable mask(int start, [int? length, String mask = '*']) =>
      Stringable(toString()).mask(start, length, mask);

  @override
  Stringable padBoth(int length, [String pad = ' ']) =>
      Stringable(toString()).padBoth(length, pad);

  @override
  Stringable padLeft(int length, [String pad = ' ']) =>
      Stringable(toString()).padLeft(length, pad);

  @override
  Stringable padRight(int length, [String pad = ' ']) =>
      Stringable(toString()).padRight(length, pad);

  @override
  List<String> split(Pattern pattern) => Stringable(toString()).split(pattern);

  @override
  Stringable substr(int start, [int? length]) =>
      Stringable(toString()).substr(start, length);

  @override
  Stringable replace(Pattern from, String replace) =>
      Stringable(toString()).replace(from, replace);

  @override
  Stringable replaceFirst(Pattern from, String replace) =>
      Stringable(toString()).replaceFirst(from, replace);

  @override
  Stringable replaceLast(Pattern from, String replace) =>
      Stringable(toString()).replaceLast(from, replace);

  @override
  bool toBoolean() => Stringable(toString()).toBoolean();

  @override
  Stringable trim() => Stringable(toString()).trim();

  @override
  Stringable trimChars(String chars) => Stringable(toString()).trimChars(chars);

  @override
  Stringable between(String start, String end) =>
      Stringable(toString()).between(start, end);

  @override
  Stringable before(String search) => Stringable(toString()).before(search);

  @override
  Stringable after(String search) => Stringable(toString()).after(search);

  @override
  Stringable beforeLast(String search) =>
      Stringable(toString()).beforeLast(search);

  @override
  Stringable afterLast(String search) =>
      Stringable(toString()).afterLast(search);

  @override
  bool matches(Pattern pattern) => Stringable(toString()).matches(pattern);

  @override
  Carbon toDate() => Stringable(toString()).toDate();

  @override
  bool equals(String other) => toString() == other;

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViewErrorBag && other.toString() == toString();
  }
}
