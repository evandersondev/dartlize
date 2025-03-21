// import 'package:dartlize/dartlize.dart';
// import 'package:dartlize/src/drivers/mysql_driver.dart';

// class Dartlize {
//   Dartlize._internal();
//   static final Dartlize _instance = Dartlize._internal();
//   late final DatabaseDriver _driver;
//   bool _driverAssigned = false;

//   factory Dartlize(String uri) {
//     if (!_instance._driverAssigned) {
//       _instance._setDriver(uri);
//       _instance._driverAssigned = true;
//     }
//     return _instance;
//   }

//   // Get to access the driver instance
//   DatabaseDriver get driver => _driver;

//   // ignore: unnecessary_null_comparison
//   bool authenticate() => _driver != null;

//   Future<void> close() async {
//     await _driver.close();
//   }

//   void _setDriver(String uri) {
//     if (uri.startsWith("sqlite:")) {
//       _driver = SqliteDriver(uri);
//     } else if (uri.startsWith("mysql:")) {
//       _driver = MySqlDriver(uri);
//     } else if (uri.startsWith("postgres:")) {
//       // Exemplo: _driver = PostgresDriver(uri);
//       // Implemente conforme o seu driver Postgres
//       throw UnimplementedError("PostgresDriver não foi implementado.");
//     } else {
//       throw Exception("URI do driver não suportado.");
//     }
//   }

//   Future<void> sync() async {
//     await _driver.connect();
//   }

//   Model define(
//     String name,
//     Map<String, DataTypes> schema, [
//     Map<String, dynamic>? options,
//   ]) {
//     var model = Model(name, schema, options, driver: _driver);

//     return model;
//   }
// }
