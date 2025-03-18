import 'package:dartlize/src/data_types.dart';
import 'package:dartlize/src/database_driver.dart';
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
    var columns = schema.entries.map((entry) {
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
    }).join(', ');
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
      return 'INTEGER';
    }
    if (type.type == 'DATEONLY') {
      return 'TEXT';
    }
    return type.toString();
  }

  @override
  Future<void> disconnect() async {
    _connection.dispose();
  }

  @override
  Future<List<Map<String, dynamic>>> findAll(String table) {
    final result = _connection.select('SELECT * FROM $table');
    final rows = result.map((row) {
      final nestedMap = row.toTableColumnMap();
      final flattened = <String, dynamic>{};
      nestedMap?.forEach((_, colMap) {
        flattened.addAll(colMap);
      });
      return flattened;
    }).toList();
    return Future.value(rows);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final columns = data.keys.join(', ');
      final placeholders = data.keys.map((_) => '?').join(', ');
      final stmt = _connection.prepare(
        'INSERT INTO $table ($columns) VALUES ($placeholders)',
      );

      final values = data.values.toList();
      stmt.execute(values);
      return 1;
    } catch (e) {
      print(e);
      return 0;
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
}
