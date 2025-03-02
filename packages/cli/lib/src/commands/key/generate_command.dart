import 'dart:io';
import 'dart:math';
import 'package:illuminate_console/console.dart';

/// Command to generate application key.
class KeyGenerateCommand extends Command {
  @override
  String get name => 'key:generate';

  @override
  String get description => 'Generate application encryption key';

  @override
  String get signature => 'key:generate';

  void _overrideKey(String secret) {
    final List<String> content = [];
    final file = File('.env');

    if (!file.existsSync()) {
      file.writeAsStringSync('APP_KEY=$secret');
      return;
    }

    final contents = file.readAsStringSync();
    final list = contents.split('\n');
    final List<String> keys = [];

    for (var line in list) {
      if (line.toString().trim().isEmpty) {
        content.add('');
      } else {
        final keyValue = line.toString().split('=');
        if (keyValue.length == 2) {
          final key = keyValue[0];
          var value = keyValue[1];
          if (key == 'APP_KEY') {
            value = secret;
          }
          keys.add(key);
          content.add("$key=$value");
        }
      }
    }

    if (!keys.contains('APP_KEY')) {
      content.insert(0, "APP_KEY=$secret");
    }

    file.writeAsStringSync(content.join("\n"));
  }

  @override
  Future<void> handle() async {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final secret = String.fromCharCodes(
      Iterable.generate(
        32,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    _overrideKey(secret);
    output.success('$secret : Key has been updated successfully in .env!');
  }
}
