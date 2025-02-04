import 'package:illuminate_database/dox_query_builder.dart';

import '../utils/logger.dart';
import 'table.column.dart';

abstract class TableSharedMixin {
  final List<TableColumn> columns = <TableColumn>[];
  String tableName = '';
  bool debug = false;
  DBDriver get dbDriver;
  Logger get logger;
}
