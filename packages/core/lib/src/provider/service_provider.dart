import 'package:platform_core/core.dart';
import 'package:platform_container/container.dart';

abstract class ServiceProvider {
  late Application app;
  late Container container;
  late final Map<String, dynamic> _config;
  bool _isEnabled = true;
  bool _isDeferred = false;

  ServiceProvider([Map<String, dynamic>? config]) : _config = config ?? {};

  Map<String, dynamic> get config => _config;
  bool get isEnabled => _isEnabled;
  bool get isDeferred => _isDeferred;

  void configure(Map<String, dynamic> options) {
    _config.addAll(options);
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void setDeferred(bool deferred) {
    _isDeferred = deferred;
  }

  void registerWithContainer(Container container) {
    this.container = container;
  }

  Future<void> register();
  Future<void> beforeBoot() async {}
  Future<void> boot();
  Future<void> afterBoot() async {}

  List<Type> get dependencies => [];
}
