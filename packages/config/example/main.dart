import 'dart:async';

import 'package:platform_config/angel3_configuration.dart';
import 'package:platform_foundation/core.dart';
import 'package:file/local.dart';

Future<void> main() async {
  var app = Application();
  var fs = const LocalFileSystem();
  await app.configure(configuration(fs));
}
