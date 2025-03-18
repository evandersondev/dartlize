import 'package:dartlize/src/data_types.dart';

abstract class DatabaseDriver {
  Future<void> connect();
  Future<void> disconnect();
  Future<dynamic> raw(String query, [List<dynamic>? parameters]);
  Future<void> sync();
  Future<int> insert(String table, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> findAll(String table);
  Future<void> createTable(
    String tableName,
    Map<String, DataTypes> schema, [
    Map<String, dynamic>? options,
  ]);
  void validateSchema(Map<String, DataTypes> schema);
}
