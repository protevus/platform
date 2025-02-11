import 'dart:io';

/// Get the basename of a path
String path_basename(String path) => path.split(Platform.pathSeparator).last;

/// Join two path segments
String path_join(String path1, String path2) =>
    path1 + Platform.pathSeparator + path2;
