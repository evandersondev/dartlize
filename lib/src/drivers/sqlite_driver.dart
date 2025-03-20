import 'package:dartlize/src/data_types.dart';
import 'package:dartlize/src/database_driver.dart';
import 'package:dartlize/src/query_builder.dart';
import 'package:dartlize/src/unsupported_data_type_exception.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteDriver extends DatabaseDriver {
  late Database _connection;
  final String uri;

  SqliteDriver(this.uri);

  @override
  Future<void> connect() async {
    if (uri == 'sqlite::memory:') {
      _connection = sqlite3.openInMemory();
    } else {
      final uriParsed = Uri.parse(uri);
      final dbPath = 'database/${uriParsed.host}';
      _connection = sqlite3.open(dbPath);
    }
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
    _connection.execute(query);
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
      case 'INTEGER':
      case 'BIGINT':
      case 'TEXT':
      case 'CITEXT':
      case 'FLOAT':
      case 'DOUBLE':
      case 'DECIMAL':
      case 'BOOLEAN':
      case 'DATE':
      case 'DATEONLY':
        return true;
      default:
        return false;
    }
  }

  String _mapDataType(DataTypes type) {
    if (type.type == 'BOOLEAN') {
      return 'TINYINT(1)';
    }
    if (type.type == 'DATE') {
      return 'TEXT';
    }
    if (type.type == 'DATEONLY') {
      return 'TEXT';
    }
    return type.toString();
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

      final result = _connection.select(query.toSql(), query.getParameters());
      final rows =
          result.map((row) {
            final nestedMap = row.toTableColumnMap();
            final flattened = <String, dynamic>{};
            nestedMap?.forEach((_, colMap) {
              flattened.addAll(colMap);
            });
            return flattened;
          }).toList();
      return Future.value(rows);
    } on SqliteException catch (e) {
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

      data.forEach((key, value) {
        if (value == null) {
          data[key] = null; // Pode ser redundante, mas serve para assegurar
        }
      });

      final query = Kartx().from(table).insert(data);

      await raw(query.toSql(), query.getParameters());
      return data;
    } on SqliteException catch (e) {
      throw Exception('Failed to insert data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to insert data: $e');
    }
  }

  @override
  Future<List<dynamic>> findOrCreate(
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
    } on SqliteException catch (e) {
      throw Exception('Failed to find or create data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find or create data: $e');
    }
  }

  @override
  Future<dynamic> raw(String query, [List? parameters]) async {
    final stmt = _connection.prepare(query);

    if (parameters == null) {
      return stmt.execute();
    } else {
      return stmt.execute(parameters);
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

      final result = _connection.select(query.toSql(), query.getParameters());
      final rows =
          result.map((row) {
            final nestedMap = row.toTableColumnMap();
            final flattened = <String, dynamic>{};
            nestedMap?.forEach((_, colMap) {
              flattened.addAll(colMap);
            });
            return flattened;
          }).toList();

      if (rows.isEmpty) {
        return Future.value({});
      }

      return Future.value(rows.first);
    } on SqliteException catch (e) {
      throw Exception('Failed to find one data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find one data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> findByPk(
    String table,
    String pkName,
    dynamic pk,
  ) async {
    try {
      final query = Kartx().from(table).select(['*']).where(pkName, '=', pk);

      final result = _connection.select(query.toSql(), query.getParameters());
      final rows =
          result.map((row) {
            final nestedMap = row.toTableColumnMap();
            final flattened = <String, dynamic>{};
            nestedMap?.forEach((_, colMap) {
              flattened.addAll(colMap);
            });
            return flattened;
          }).toList();

      if (rows.isEmpty) {
        return null;
      }

      return Future.value(rows.first);
    } on SqliteException catch (e) {
      throw Exception('Failed to find by pk data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to find by pk data: $e');
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
  Future<int> count(String table, {Map<String, dynamic>? where}) async {
    final query = Kartx().from(table).select(['*']);

    if (where != null) {
      where.forEach((column, value) {
        query.where(column, '=', value);
      });
    }

    final result = _connection.select(
      query.count().toSql(),
      query.getParameters(),
    );
    return result.first['total'] as int;
  }

  @override
  Future<void> close() async {
    _connection.dispose();
  }
}
