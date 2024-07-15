class LogicException implements Exception {
  final String message;
  final int code;
  final Exception? previous;
  final StackTrace? stackTrace;

  LogicException(
      [this.message = "", this.code = 0, this.previous, this.stackTrace]);

  @override
  String toString() {
    return "LogicException: $message";
  }

  String getMessage() {
    return message;
  }

  Exception? getPrevious() {
    return previous;
  }

  int getCode() {
    return code;
  }

  String getFile() {
    final frames = stackTrace?.toString().split('\n');
    if (frames != null && frames.isNotEmpty) {
      final frame = frames.first;
      final fileInfo = frame.split(' ').last;
      return fileInfo.split(':').first;
    }
    return "";
  }

  int getLine() {
    final frames = stackTrace?.toString().split('\n');
    if (frames != null && frames.isNotEmpty) {
      final frame = frames.first;
      final fileInfo = frame.split(' ').last;
      final lineInfo = fileInfo.split(':');
      if (lineInfo.length > 1) {
        return int.tryParse(lineInfo[1]) ?? 0;
      }
    }
    return 0;
  }

  List<String> getTrace() {
    return stackTrace?.toString().split('\n') ?? [];
  }

  String getTraceAsString() {
    return stackTrace?.toString() ?? "";
  }
}
