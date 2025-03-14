import '../../command.dart';

/// Command group for managing development services
class ServicesCommand extends Command {
  @override
  String get name => 'services';

  @override
  String get description =>
      'Manage development services (databases, caching, etc)';

  @override
  String get signature => 'services';

  @override
  Future<void> handle() async {
    // Show command help
    output.info('Available services commands:');
    output.info('  services:up        Start development services');
    output.info('  services:down      Stop development services');
    output.info('  services:status    Show service status');
    output.info('  services:logs      View service logs');
    output.info('  services:cleanup   Clean up service resources');
    output.info('  services:add       Add a new service module');
    output.info('  services:remove    Remove a service module');
    output.info('  services:configure Configure a service');
    output.info('  services:generate  Generate docker-compose file');
    output.newLine();
    output.info('Run a command with --help to see command-specific options.');
  }
}
