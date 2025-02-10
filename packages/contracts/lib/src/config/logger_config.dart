class LoggerConfig {
  final String name;
  final bool enabled;
  final bool prettyPrint;
  final String level;

  const LoggerConfig({
    this.name = '',
    this.enabled = false,
    this.prettyPrint = false,
    this.level = 'info',
  });
}
