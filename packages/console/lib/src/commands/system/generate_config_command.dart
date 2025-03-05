import '../melos/melos_command.dart';

/// Command to combine Melos configuration files
class GenerateConfigCommand extends MelosCommand {
  @override
  String get name => 'generate:config';

  @override
  String get description => 'Combine Melos configuration files';

  @override
  String get signature => 'generate:config';

  @override
  Future<void> handle() async {
    try {
      output.info('Combining Melos configuration files...');

      // Execute the combine config command from root directory
      await executeMelos(
        'run',
        args: ['combine_config'],
        throwOnNonZero: true,
      );

      output.success('Configuration files combined successfully');
    } catch (e) {
      output.error(
          'Failed to combine configuration files - see output above for details');
      rethrow;
    }
  }
}
