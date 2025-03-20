import 'package:dartlize/dartlize.dart';
import 'package:dartlize/src/query_builder.dart';
import 'package:dartlize/src/unsupported_data_type_exception.dart';
import 'package:mysql1/mysql1.dart';

class MySqlDriver implements DatabaseDriver {
  late MySqlConnection _connection;
  final String uri;

  MySqlDriver(this.uri);

  @override
  Future<void> close() async {
    await _connection.close();
  }

  @override
  Future<void> connect() async {
    final uriParsed = Uri.parse(uri);

    final settings = ConnectionSettings(
      host: uriParsed.host,
      port: uriParsed.port,
      user: uriParsed.userInfo.split(':').first,
      password: uriParsed.userInfo.split(':').last,
      db: uriParsed.path.substring(1),
    );
    _connection = await MySqlConnection.connect(settings);
  }

  @override
  Future<int> count(String table, {Map<String, dynamic>? where}) async {
    final query = Kartx().from(table).select(['*']);

    if (where != null) {
      where.forEach((column, value) {
        query.where(column, '=', value);
      });
    }

    final result = await _connection.query(
      query.count().toSql(),
      query.getParameters(),
    );
    return result.length;
  }

  @override
  Future<void> createTable(
    String tableName,
    Map<String, DataTypes> schema, [
    Map<String, dynamic>? options,
  ]) async {
    validateSchema(schema);

    var primaryKeyField = options?['primaryKey'];
    var columns = schema.entries
        .map((entry) {
          var columnType = _mapDataType(entry.value);
          var definition = '${entry.key} $columnType';
          if (primaryKeyField != null && entry.key == primaryKeyField) {
            if (columnType == 'INTEGER') {
              definition += ' PRIMARY KEY AUTOINCREMENT';
            } else {
              definition += ' PRIMARY KEY';
            }
          }
          return definition;
        })
        .join(', ');
    var query = 'CREATE TABLE IF NOT EXISTS $tableName ($columns)';
    _connection.query(query);
  }

  String _mapDataType(DataTypes type) {
    return type.toString();
  }

  @override
  Future<int> destroy(
    String table, {
    required Map<String, dynamic> where,
  }) async {
    try {
      final query = Kartx().from(table).delete();

      where.forEach((column, value) {
        query.where(column, '=', value);
      });
      await raw(query.toSql(), query.getParameters());
      return 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> findAll(
    String table, {
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  }) async {
    try {
      final query = Kartx().from(table).select(attributes ?? ['*']);

      if (where != null) {
        where.forEach((column, value) {
          if (value is List && value.length == 2) {
            query.where(column, value[0].toString(), value[1]);
          } else {
            query.where(column, '=', value);
          }
        });
      }

      if (order != null) {
        for (var column in order) {
          if (column.length == 2) {
            query.orderBy(column[0], column[1]);
          } else {
            throw ArgumentError(
              'Invalid order format, must be [column, direction]',
            );
          }
        }
      }

      if (offset != null) query.offset(offset);
      if (limit != null) query.limit(limit);

      final result = await _connection.query(
        query.toSql(),
        query.getParameters(),
      );

      final rows = result.map((row) => row.fields).toList();
      return Future.value(rows);
    } on MySqlException catch (e) {
      throw Exception('Failed to find all data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find all data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> findAndCountAll(
    String table,
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  ) async {
    final rows = await findAll(
      table,
      attributes: attributes,
      where: where,
      offset: offset,
      limit: limit,
      order: order,
    );

    return {'count': rows.length, 'rows': rows};
  }

  @override
  Future<Map<String, dynamic>?> findByPk(
    String table,
    String pkName,
    pk,
  ) async {
    try {
      final query = Kartx().from(table).select(['*']).where(pkName, '=', pk);

      final result = await _connection.query(
        query.toSql(),
        query.getParameters(),
      );
      final rows = result.map((row) => row.fields).toList();

      if (rows.isEmpty) {
        return null;
      }

      return Future.value(rows.first);
    } on MySqlException catch (e) {
      throw Exception('Failed to find by pk data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find by pk data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> findOne(
    String table, {
    required Map<String, dynamic> where,
  }) async {
    try {
      final query = Kartx().from(table).select(['*']);

      where.forEach((column, value) {
        query.where(column, '=', value);
      });

      final result = await _connection.query(
        query.toSql(),
        query.getParameters(),
      );
      final rows = result.map((row) => row.fields).toList();

      if (rows.isEmpty) {
        return Future.value({});
      }

      return Future.value(rows.first);
    } on MySqlException catch (e) {
      throw Exception('Failed to find one data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find one data: $e');
    }
  }

  @override
  Future<List> findOrCreate(
    String table, {
    required Map<String, dynamic> where,
    Map<String, dynamic>? defaults,
  }) async {
    try {
      var results = await findAll(table, where: where);
      if (results.isNotEmpty) {
        return [results.first, false];
      }

      final data = {...where, ...?defaults};
      await insert(table, data);

      results = await findAll(table, where: where);
      return [results.first, true];
    } on MySqlException catch (e) {
      throw Exception('Failed to find or create data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find or create data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data, {
    bool timestamps = false,
  }) async {
    try {
      if (timestamps) {
        data['created_at'] = DateTime.now().toIso8601String();
        data['updated_at'] = DateTime.now().toIso8601String();
      }

      final query = Kartx().from(table).insert(data);

      await raw(query.toSql(), query.getParameters());
      return data;
    } on MySqlException catch (e) {
      throw Exception('Failed to insert data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to insert data: $e');
    }
  }

  @override
  Future<dynamic> raw(String query, [List? parameters]) async {
    if (parameters == null) {
      return await _connection.query(query);
    } else {
      return await _connection.query(query, parameters);
    }
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> where,
  }) async {
    try {
      final query = Kartx().from(table).update(data);

      where.forEach((column, value) {
        query.where(column, '=', value);
      });

      await raw(query.toSql(), query.getParameters());
      return 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  void validateSchema(Map<String, DataTypes> schema) {
    for (var entry in schema.entries) {
      if (!_isSupportedType(entry.value)) {
        throw UnsupportedDataTypeException(entry.key, entry.value);
      }
    }
  }

  bool _isSupportedType(DataTypes type) {
    switch (type.type) {
      case 'VARCHAR':
      case 'TEXT':
      case 'BINARY':
      case 'CITEXT':
      case 'TSVECTOR':
      case 'BOOLEAN':
      case 'INTEGER':
      case 'BIGINT':
      case 'FLOAT':
      case 'REAL':
      case 'DOUBLE':
      case 'DECIMAL':
      case 'DATE':
      case 'DATEONLY':
      case 'UUID':
      case 'UUIDV1':
      case 'UUIDV4':
      case 'BLOB':
        return true;
      default:
        return false;
    }
  }
}
