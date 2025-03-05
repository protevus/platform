import '../melos/melos_command.dart';

/// Command to bootstrap the monorepo
class BootstrapCommand extends MelosCommand {
  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Bootstrap the monorepo by installing all dependencies';

  @override
  String get signature => 'bootstrap';

  @override
  Future<void> handle() async {
    try {
      output.newLine();
      output.info('Bootstrapping monorepo...');
      output.writeln('----------------------------------------');

      await executeMelos('bootstrap', throwOnNonZero: false);

      output.newLine();
      output.success('Bootstrap completed successfully');
    } catch (e) {
      output.error('Bootstrap failed - see output above for details');
      rethrow;
    }
  }
}
