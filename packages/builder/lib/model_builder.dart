library dox_builder;

import 'package:build/build.dart';
import 'package:illuminate_builder/src/model_builder.dart';
import 'package:source_gen/source_gen.dart';

Builder buildDoxModel(BuilderOptions options) => SharedPartBuilder(
      [ModelBuilder()],
      'dox_model_generator',
    );
