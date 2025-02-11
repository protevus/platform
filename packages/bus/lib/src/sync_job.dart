import 'package:illuminate_contracts/contracts.dart';

/// A job that is executed synchronously in the current process.
///
/// This class provides a way to execute jobs synchronously while still maintaining
/// compatibility with the queue interfaces.
class SyncJob implements InteractsWithQueue {
  /// The container instance.
  final dynamic _container;

  /// The raw job payload.
  final String _payload;

  /// The connection name.
  final String _connectionName;

  /// The queue name.
  @override
  final String queue;

  /// Whether the job has been deleted.
  bool _deleted = false;

  /// Whether the job has been released.
  bool _released = false;

  /// The number of times the job has been attempted.
  @override
  int attempts = 0;

  /// Creates a new sync job instance.
  ///
  /// [container] The container instance.
  /// [payload] The raw job payload.
  /// [connectionName] The connection name.
  /// [queue] The queue name.
  SyncJob(this._container, this._payload, this._connectionName, this.queue);

  @override
  dynamic get job => this;

  @override
  set job(dynamic job) {
    // No-op for sync jobs
  }

  @override
  bool get isDeleted => _deleted;

  @override
  bool get isReleased => _released;

  @override
  Future<void> delete() async {
    _deleted = true;
  }

  @override
  Future<void> release([Duration? delay]) async {
    _released = true;
  }

  @override
  void setJob(dynamic job) {
    // No-op for sync jobs
  }

  /// Get the container instance.
  dynamic get container => _container;

  /// Get the raw job payload.
  String get payload => _payload;

  /// Get the connection name.
  String get connectionName => _connectionName;
}
