import 'package:dartlize/src/data_types.dart';

abstract class DatabaseDriver {
  Future<void> connect();
  Future<void> close();
  Future<dynamic> raw(String query, [List<dynamic>? parameters]);
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data, {
    bool timestamps = false,
  });
  // Finders Methods
  Future<List<Map<String, dynamic>>> findAll(
    String table, {
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  });
  Future<Map<String, dynamic>> findAndCountAll(
    String table,
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  );
  Future<Map<String, dynamic>> findOne(
    String table, {
    required Map<String, dynamic> where,
  });
  Future<List<dynamic>> findOrCreate(
    String table, {
    required Map<String, dynamic> where,
    Map<String, dynamic>? defaults,
  });
  Future<Map<String, dynamic>?> findByPk(
    String table,
    String pkName,
    dynamic pk,
  );
  // Update Methods
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> where,
  });
  // Delete Methods
  Future<int> destroy(String table, {required Map<String, dynamic> where});
  Future<void> createTable(
    String tableName,
    Map<String, DataTypes> schema, [
    Map<String, dynamic>? options,
  ]);
  // Count Method
  Future<int> count(String table, {Map<String, dynamic>? where});
  void validateSchema(Map<String, DataTypes> schema);
}
