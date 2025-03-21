// import 'query_builder.dart';

// class MysqlDriverImpl extends DatabaseDriver {
//   @override
//   Future<void> connect() async {
//     print("Conectado ao MySQL");
//   }

//   @override
//   Future<List<dynamic>> raw(String query, [List<dynamic>? parameters]) async {
//     print("Executando SQL (MySQL): $query");
//     print("Parâmetros: $parameters");
//     return [];
//   }

//   @override
//   Future<void> createTable(String table, Map<String, String> columns) async {
//     final cols = columns.entries.map((e) => "${e.key} ${e.value}").join(", ");
//     final sql = "CREATE TABLE IF NOT EXISTS $table ($cols);";
//     await raw(sql);
//   }
// }
