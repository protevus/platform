#!/usr/bin/env dart

import 'dart:io';
import 'package:artisan/artisan.dart';

void main(List<String> arguments) async {
  final app = Artisan();

  try {
    await app.runWithArguments(arguments);
  } catch (e) {
    exit(1);
  }
}
