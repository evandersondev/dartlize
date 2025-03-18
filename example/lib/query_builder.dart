class QueryBuilder {
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

  QueryBuilder from(String table) {
    _table = table;
    return this;
  }

  QueryBuilder select(List<String> columns) {
    _queryType = 'SELECT';
    _columns = columns;
    return this;
  }

  QueryBuilder where(String column, String operator, dynamic value) {
    _whereClauses.add("$column $operator ?");
    _parameters.add(value);
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

  QueryBuilder insert(Map<String, dynamic> data) {
    _queryType = 'INSERT';
    _insertData = data;
    _parameters.addAll(data.values);
    return this;
  }

  QueryBuilder update(Map<String, dynamic> data) {
    _queryType = 'UPDATE';
    _updateData = data;
    _parameters.addAll(data.values);
    return this;
  }

  QueryBuilder delete() {
    _queryType = 'DELETE';
    return this;
  }

  QueryBuilder join(
    String table,
    String column1,
    String column2, {
    String type = 'INNER',
  }) {
    _joinClauses.add("$type JOIN $table ON $column1 = $column2");
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

  QueryBuilder union(QueryBuilder otherQuery) {
    _unionQueries.add(otherQuery.toSql());
    return this;
  }

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
}
