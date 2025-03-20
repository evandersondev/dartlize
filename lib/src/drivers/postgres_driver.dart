import 'package:dartlize/dartlize.dart';

class PostgresDriver extends DatabaseDriver {
  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<int> count(String table, {Map<String, dynamic>? where}) {
    // TODO: implement count
    throw UnimplementedError();
  }

  @override
  Future<void> createTable(
    String tableName,
    Map<String, DataTypes> schema, [
    Map<String, dynamic>? options,
  ]) {
    // TODO: implement createTable
    throw UnimplementedError();
  }

  @override
  Future<int> destroy(String table, {required Map<String, dynamic> where}) {
    // TODO: implement destroy
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> findAll(
    String table, {
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  }) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> findAndCountAll(
    String table,
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  ) {
    // TODO: implement findAndCountAll
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> findByPk(String table, String pkName, pk) {
    // TODO: implement findByPk
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> findOne(
    String table, {
    required Map<String, dynamic> where,
  }) {
    // TODO: implement findOne
    throw UnimplementedError();
  }

  @override
  Future<List> findOrCreate(
    String table, {
    required Map<String, dynamic> where,
    Map<String, dynamic>? defaults,
  }) {
    // TODO: implement findOrCreate
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data, {
    bool timestamps = false,
  }) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future raw(String query, [List? parameters]) {
    // TODO: implement raw
    throw UnimplementedError();
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> where,
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  void validateSchema(Map<String, DataTypes> schema) {
    // TODO: implement validateSchema
  }
}
