import 'dart:async';

import 'sqlite_driver_impl.dart';
import 'table.dart';

/// Classe que representa uma condição para a cláusula WHERE.
class Condition {
  final String clause;
  final dynamic value;
  Condition(this.clause, this.value);
}

/// Função utilitária para construir condições de igualdade.
Condition eq(String column, dynamic value) {
  return Condition("$column = ?", value);
}

/// QueryBuilder inspirado no Drizzle.
/// Permite construir queries com a sintaxe:
///
///   final users = await db.select().from('users');
///   await db.insert('users').values({'name': 'John Doe', 'age': 30, 'email': 'john@mail.com'});
///   await db.update('users').set({'age': 31}).where(eq('users.email', 'john@mail.com'));
///   await db.delete('users').set({'age': 31}).where(eq('users.email', 'john@mail.com'));
///
/// Ao chamar `.toSql()` o builder retorna a string SQL sem executar a query.
/// Se a query for aguardada (por exemplo, com `await`), ela será executada automaticamente.
final class QueryBuilder implements Future<dynamic> {
  final DatabaseDriver _driver;
  String _table = '';
  List<String> _columns = ['*'];
  final List<String> _whereClauses = [];
  final List<String> _orderByClauses = [];
  final List<String> _joinClauses = [];
  final List<String> _unionQueries = [];
  int? _limit;
  int? _offset;
  Map<String, dynamic> _insertData = {};
  Map<String, dynamic> _updateData = {};
  String? _queryType;
  final List<dynamic> _parameters = [];
  String? _createTableSQL;
  final List<String> _alterTableCommands = [];

  QueryBuilder(this._driver);

  // Métodos para SELECT
  QueryBuilder select([List<String>? columns]) {
    _queryType = 'SELECT';
    _columns = columns ?? ['*'];
    return this;
  }

  QueryBuilder from(String table) {
    _table = table;
    return this;
  }

  // Método where que aceita Condition ou (coluna, operador, valor)
  QueryBuilder where(dynamic columnOrCondition,
      [String? operator, dynamic value]) {
    if (columnOrCondition is Condition) {
      _whereClauses.add(columnOrCondition.clause);
      _parameters.add(columnOrCondition.value);
    } else {
      _whereClauses.add("$columnOrCondition $operator ?");
      _parameters.add(value);
    }
    return this;
  }

  QueryBuilder orderBy(String column, [String direction = 'ASC']) {
    _orderByClauses.add("$column $direction");
    return this;
  }

  QueryBuilder limit(int value) {
    _limit = value;
    return this;
  }

  QueryBuilder offset(int value) {
    _offset = value;
    return this;
  }

  QueryBuilder join(String table, String column1, String column2,
      {String type = 'INNER'}) {
    _joinClauses.add("$type JOIN $table ON $column1 = $column2");
    return this;
  }

  QueryBuilder union(QueryBuilder otherQuery) {
    _unionQueries.add(otherQuery.toSql());
    return this;
  }

  QueryBuilder function(String function, String column, String alias) {
    _columns = ["$function($column) AS $alias"];
    return this;
  }

  QueryBuilder count() {
    _columns = ["COUNT(*) AS total"];
    return this;
  }

  // Métodos para INSERT
  QueryBuilder insert(String table) {
    _table = table;
    _queryType = 'INSERT';
    return this;
  }

  QueryBuilder values(Map<String, dynamic> data) {
    _insertData = Map<String, dynamic>.from(data);
    _parameters.addAll(_insertData.values);
    return this;
  }

  // Métodos para UPDATE
  QueryBuilder update(String table) {
    _table = table;
    _queryType = 'UPDATE';
    return this;
  }

  QueryBuilder set(Map<String, dynamic> data) {
    _updateData = Map<String, dynamic>.from(data);
    _parameters.addAll(_updateData.values);
    return this;
  }

  // Métodos para DELETE
  QueryBuilder delete(String table) {
    _table = table;
    _queryType = 'DELETE';
    return this;
  }

  // Métodos para criação e alteração de tabelas
  QueryBuilder createTable(String table, Map<String, String> columns) {
    _queryType = 'CREATE_TABLE';
    _createTableSQL =
        "CREATE TABLE IF NOT EXISTS $table (${columns.entries.map((e) => "${e.key} ${e.value}").join(', ')})";
    return this;
  }

  QueryBuilder dropTable(String table) {
    _queryType = 'DROP_TABLE';
    _table = table;
    return this;
  }

  QueryBuilder addColumn(String columnName, String columnType) {
    _alterTableCommands.add("ADD COLUMN $columnName $columnType");
    return this;
  }

  QueryBuilder dropColumn(String columnName) {
    _alterTableCommands.add("DROP COLUMN $columnName");
    return this;
  }

  /// Retorna a string SQL gerada sem executar a query.
  String toSql() {
    if (_queryType == 'SELECT') return _buildSelect();
    if (_queryType == 'INSERT') return _buildInsert();
    if (_queryType == 'UPDATE') return _buildUpdate();
    if (_queryType == 'DELETE') return _buildDelete();
    if (_queryType == 'CREATE_TABLE') return "${_createTableSQL!};";
    if (_queryType == 'DROP_TABLE') return "DROP TABLE IF EXISTS $_table;";
    if (_alterTableCommands.isNotEmpty)
      return "ALTER TABLE $_table ${_alterTableCommands.join(", ")};";
    throw Exception('Nenhuma operação definida!');
  }

  List<dynamic> getParameters() => _parameters;

  String _buildSelect() {
    String sql = "SELECT ${_columns.join(', ')} FROM $_table";
    if (_joinClauses.isNotEmpty) sql += " ${_joinClauses.join(" ")}";
    if (_whereClauses.isNotEmpty)
      sql += " WHERE ${_whereClauses.join(" AND ")}";
    if (_orderByClauses.isNotEmpty)
      sql += " ORDER BY ${_orderByClauses.join(", ")}";
    if (_limit != null) sql += " LIMIT $_limit";
    if (_offset != null) sql += " OFFSET $_offset";
    if (_unionQueries.isNotEmpty)
      sql += " UNION ${_unionQueries.join(" UNION ")}";
    return "$sql;";
  }

  String _buildInsert() {
    String columns = _insertData.keys.join(', ');
    String placeholders = List.filled(_insertData.length, '?').join(', ');
    return "INSERT INTO $_table ($columns) VALUES ($placeholders);";
  }

  String _buildUpdate() {
    String setClause = _updateData.keys.map((key) => "$key = ?").join(", ");
    String sql = "UPDATE $_table SET $setClause";
    if (_whereClauses.isNotEmpty)
      sql += " WHERE ${_whereClauses.join(" AND ")}";
    return "$sql;";
  }

  String _buildDelete() {
    String sql = "DELETE FROM $_table";
    if (_whereClauses.isNotEmpty)
      sql += " WHERE ${_whereClauses.join(" AND ")}";
    return "$sql;";
  }

  /// Executa a query construída utilizando o driver.
  /// Para SELECTs, utiliza [DatabaseDriver.execute];
  /// Para INSERT, UPDATE e DELETE, utiliza [DatabaseDriver.raw].
  Future<dynamic> _internalExecute() async {
    final sql = toSql();
    final params = getParameters();
    if (_queryType == 'SELECT') {
      return await _driver.execute(sql, params);
    } else {
      await _driver.raw(sql, params);
      return null;
    }
  }

  /// Executa a query caso o QueryBuilder seja aguardado.
  @override
  Future<T> then<T>(FutureOr<T> Function(dynamic value) onValue,
      {Function? onError}) {
    return _internalExecute().then<T>(onValue, onError: onError);
  }

  @override
  Future<dynamic> catchError(Function onError,
      {bool Function(Object error)? test}) {
    return _internalExecute().catchError(onError, test: test);
  }

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) {
    return _internalExecute().whenComplete(action);
  }

  @override
  Stream<dynamic> asStream() => Stream.fromFuture(_internalExecute());

  @override
  Future<dynamic> timeout(Duration timeLimit,
      {FutureOr<dynamic> Function()? onTimeout}) {
    return _internalExecute().timeout(timeLimit, onTimeout: onTimeout);
  }
}

/// Abstração do driver de banco de dados.
abstract class DatabaseDriver {
  Future<void> connect();
  Future<void> raw(String query, [List<dynamic>? parameters]);
  Future<List<Map<String, dynamic>>> execute(String query,
      [List<dynamic>? parameters]);
  Future<void> createTable(String table, Map<String, String> columns);
}

/// Implementação para MySQL.
class MysqlDriverImpl extends DatabaseDriver {
  @override
  Future<void> connect() async {
    print("Conectado ao MySQL");
  }

  @override
  Future<void> raw(String query, [List<dynamic>? parameters]) async {
    print("Executando SQL (MySQL): $query");
    print("Parâmetros: $parameters");
  }

  @override
  Future<List<Map<String, dynamic>>> execute(String query,
      [List<dynamic>? parameters]) async {
    print("Executando SQL (MySQL) para SELECT: $query");
    print("Parâmetros: $parameters");
    return [];
  }

  @override
  Future<void> createTable(String table, Map<String, String> columns) async {
    final cols = columns.entries.map((e) => "${e.key} ${e.value}").join(", ");
    final sql = "CREATE TABLE IF NOT EXISTS $table ($cols);";
    await raw(sql);
  }
}

/// Implementação para Postgres.
class PostgresDriverImpl extends DatabaseDriver {
  @override
  Future<void> connect() async {
    print("Conectado ao Postgres");
  }

  @override
  Future<void> raw(String query, [List<dynamic>? parameters]) async {
    print("Executando SQL (Postgres): $query");
    print("Parâmetros: $parameters");
  }

  @override
  Future<List<Map<String, dynamic>>> execute(String query,
      [List<dynamic>? parameters]) async {
    print("Executando SQL (Postgres) para SELECT: $query");
    print("Parâmetros: $parameters");
    return [];
  }

  @override
  Future<void> createTable(String table, Map<String, String> columns) async {
    final cols = columns.entries.map((e) => "${e.key} ${e.value}").join(", ");
    final sql = "CREATE TABLE IF NOT EXISTS $table ($cols);";
    await raw(sql);
  }
}

/// Fábrica para obter o driver adequado com base na URI.
class SqlDriverFactory {
  static Future<DatabaseDriver> getDriver(String uri) async {
    if (uri.startsWith('sqlite')) {
      final driver = SqliteDriverImpl(uri);
      await driver.connect();
      return driver;
    } else if (uri.startsWith('mysql')) {
      final driver = MysqlDriverImpl();
      await driver.connect();
      return driver;
    } else if (uri.startsWith('postgres')) {
      final driver = PostgresDriverImpl();
      await driver.connect();
      return driver;
    }
    throw Exception('Driver não suportado!');
  }
}

/// Classe principal que configura e sincroniza as tabelas,
/// retornando um objeto que permite invocar os métodos: select, insert, update e delete.
class Dartlize {
  final String uri;
  final List<Table> _tables;
  late final DatabaseDriver _driver;

  Dartlize(this.uri, this._tables);

  /// Sincroniza as tabelas e retorna um DatabaseFacade para construir queries.
  Future<DatabaseFacade> sync() async {
    _driver = await SqlDriverFactory.getDriver(uri);
    for (final table in _tables) {
      await _driver.createTable(table.name, table.columns);
    }
    return DatabaseFacade(_driver);
  }
}

/// Classe que expõe os métodos de consulta no estilo Drizzle.
class DatabaseFacade {
  final DatabaseDriver _driver;
  DatabaseFacade(this._driver);

  QueryBuilder select() {
    return QueryBuilder(_driver)..select();
  }

  QueryBuilder insert(String table) {
    return QueryBuilder(_driver)..insert(table);
  }

  QueryBuilder update(String table) {
    return QueryBuilder(_driver)..update(table);
  }

  QueryBuilder delete(String table) {
    return QueryBuilder(_driver)..delete(table);
  }
}
