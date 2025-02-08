import 'package:illuminate_config/config.dart';
import 'package:illuminate_database/query_builder.dart';
import 'package:illuminate_support/support.dart';
import 'package:sample_app/config/postgres.dart';
import 'package:postgres/postgres.dart';

/// Query builder service
/// --------------------------
/// Initializing to setup query builder so that this project can use ORM.
/// If this project do not require database, you can simply delete this file
/// and remove from config/services.dart list.
class ORMService implements Service {
  @override
  Future<void> setup() async {
    /// Initialize Sql QueryBuilder
    SqlQueryBuilder.initialize(
      database: await Connection.open(
        postgresEndpoint,
        settings: postgresPoolSetting,
      ),
      debug: true,
      printer: Env.get('APP_ENV') == 'development'
          ? PrettyQueryPrinter()
          : ConsoleQueryPrinter(),
    );
  }
}
