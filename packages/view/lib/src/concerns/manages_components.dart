import '../contracts/base.dart';
import '../contracts/view.dart';

/// A component slot implementation.
class ComponentSlot {
  /// The content of the slot.
  final String content;

  /// The attributes of the slot.
  final Map<String, dynamic> attributes;

  /// Create a new component slot instance.
  ComponentSlot(this.content, [this.attributes = const {}]);

  @override
  String toString() => content;
}

/// A mixin that provides component management functionality.
mixin ManagesComponents {
  /// The components being rendered.
  final List<dynamic> _componentStack = [];

  /// The original data passed to the component.
  final List<Map<String, dynamic>> _componentData = [];

  /// The component data for the component that is currently being rendered.
  Map<String, dynamic> _currentComponentData = {};

  /// The slot contents for the component.
  final List<Map<String, dynamic>> _slots = [];

  /// The names of the slots being rendered.
  final List<List<List<dynamic>>> _slotStack = [];

  /// Start a component rendering process.
  void startComponent(dynamic view, [Map<String, dynamic> data = const {}]) {
    _componentStack.add(view);
    _componentData.add(data);
    _slots.add({});
    _slotStack.add([]);
  }

  /// Start the first component that exists from the given list.
  void startComponentFirst(List<String> names,
      [Map<String, dynamic> data = const {}]) {
    for (final name in names) {
      if (exists(name)) {
        startComponent(name, data);
        return;
      }
    }
    throw ViewException('None of the components in the given list exist.');
  }

  /// Render the current component.
  Future<String> renderComponent() async {
    final view = _componentStack.removeLast();
    final previousComponentData = _currentComponentData;

    try {
      final data = _getComponentData();
      _currentComponentData = {...previousComponentData, ...data};

      if (view is Future<View>) {
        final resolvedView = await view;
        return await resolvedView.withManyData(data).render();
      } else if (view is View) {
        return await view.withManyData(data).render();
      } else if (view is String) {
        final newView = await make(view, data);
        return await newView.render();
      } else {
        throw ViewException('Invalid component view type.');
      }
    } finally {
      _currentComponentData = previousComponentData;
    }
  }

  /// Get the data for the given component.
  Map<String, dynamic> _getComponentData() {
    final defaultSlot =
        ComponentSlot(''); // In Dart we'll manage content differently
    final currentIndex = _componentStack.length;

    final slots = {
      '__default': defaultSlot,
      ..._slots[currentIndex],
    };

    return {
      ..._componentData[currentIndex],
      'slot': defaultSlot,
      ..._slots[currentIndex],
      '__laravel_slots': slots,
    };
  }

  /// Get an item from the component data that exists above the current component.
  T? getConsumableComponentData<T>(String key, [T? defaultValue]) {
    if (_currentComponentData.containsKey(key)) {
      return _currentComponentData[key] as T;
    }

    final currentComponent = _componentStack.length;
    if (currentComponent == 0) {
      return defaultValue;
    }

    for (var i = currentComponent - 1; i >= 0; i--) {
      final data = _componentData[i];
      if (data.containsKey(key)) {
        return data[key] as T;
      }
    }

    return defaultValue;
  }

  /// Start the slot rendering process.
  void slot(String name,
      [String? content, Map<String, dynamic> attributes = const {}]) {
    final currentIndex = _currentComponent();

    if (content != null) {
      _slots[currentIndex][name] = ComponentSlot(content, attributes);
    } else {
      _slots[currentIndex][name] = ComponentSlot('', attributes);
      _slotStack[currentIndex].add([name, attributes]);
    }
  }

  /// Save the slot content for rendering.
  void endSlot() {
    final currentIndex = _currentComponent();
    final currentSlot = _slotStack[currentIndex].removeLast();
    final [name, attributes] = currentSlot;

    _slots[currentIndex][name] =
        ComponentSlot('', attributes); // Content managed differently
  }

  /// Get the index for the current component.
  int _currentComponent() => _componentStack.length - 1;

  /// Flush all of the component state.
  void flushComponents() {
    _componentStack.clear();
    _componentData.clear();
    _currentComponentData = {};
    _slots.clear();
    _slotStack.clear();
  }

  /// Check if a component exists.
  bool exists(String name);

  /// Make a new view instance.
  Future<View> make(String view, [Map<String, dynamic>? data]);
}
