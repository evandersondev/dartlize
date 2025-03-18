// class MySqlDriver implements DatabaseDriver {
//   late mysql.MySqlConnection _connection;
//   final String connectionString;

//   MySqlDriver(this.connectionString);

//   @override
//   Future<void> connect() async {
//     _connection = await mysql.MySqlConnection.connect(mysql.ConnectionSettings.parse(connectionString));
//   }

//   @override
//   Future<void> disconnect() async {
//     await _connection.close();
//   }

//   @override
//   Future<List<Map<String, dynamic>>> rawQuery(String query, [List<dynamic>? parameters]) async {
//     var results = await _connection.prepared(query, parameters ?? []);
//     return results.map((row) => row.fields).toList();
//   }

//   @override
//   Future<void> sync() async {
//     // Implementação de sync para MySQL
//   }

//   @override
//   Future<int> insert(String table, Map<String, dynamic> data) async {
//     var keys = data.keys.join(',');
//     var values = data.values.map((v) => '?').join(',');
//     var result = await _connection.prepared('INSERT INTO $table ($keys) VALUES ($values)', data.values.toList());
//     return result.insertId;
//   }

//   @override
//   Future<List<Map<String, dynamic>>> findAll(String table) async {
//     var results = await _connection.query('SELECT * FROM $table');
//     return results.map((row) => row.fields).toList();
//   }
// }
