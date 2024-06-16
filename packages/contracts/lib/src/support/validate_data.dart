//import 'dart:collection';
import 'arrayable.dart';

abstract class ValidatedData implements Arrayable, Map<String, dynamic> {
  @override
  Iterator<MapEntry<String, dynamic>> get iterator => entries.iterator;
}
