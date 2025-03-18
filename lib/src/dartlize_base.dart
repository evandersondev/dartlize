import 'package:dartlize/dartlize.dart';
import 'package:dartlize/src/model.dart';

import 'database_driver.dart';
// Importar os drivers MySQL e Postgres conforme necessário.
// import 'mysql_driver.dart';
// import 'postgres_driver.dart';

class Dartlize {
  Dartlize._internal();
  static final Dartlize _instance = Dartlize._internal();
  late final DatabaseDriver _driver;
  bool _driverAssigned = false;

  factory Dartlize(String uri) {
    if (!_instance._driverAssigned) {
      _instance._setDriver(uri);
      _instance._driverAssigned = true;
    }
    return _instance;
  }

  void _setDriver(String uri) {
    if (uri.startsWith("sqlite:")) {
      // Remove o prefixo "sqlite:" caso necessário, ou passa o URI completo
      _driver = SqliteDriver(uri);
    } else if (uri.startsWith("mysql:")) {
      // Exemplo: _driver = MySqlDriver(uri);
      // Implemente conforme o seu driver MySQL
      throw UnimplementedError("MySqlDriver não foi implementado.");
    } else if (uri.startsWith("postgres:")) {
      // Exemplo: _driver = PostgresDriver(uri);
      // Implemente conforme o seu driver Postgres
      throw UnimplementedError("PostgresDriver não foi implementado.");
    } else {
      throw Exception("URI do driver não suportado.");
    }
  }

  Future<void> connect() => _driver.connect();

  Future<void> disconnect() => _driver.disconnect();

  // Método para sincronizar os modelos com o banco de dados
  Future<void> sync(List<Model> models) async {
    await _driver.connect();
    for (var model in models) {
      await model.sync();
    }
  }

  Model define(
    String name,
    Map<String, DataTypes> schema, [
    Map<String, dynamic>? options,
  ]) {
    var model = Model(_driver, name, schema, options);

    return model;
  }
}
