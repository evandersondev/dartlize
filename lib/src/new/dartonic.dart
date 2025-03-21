import 'query_builder.dart';
import 'table.dart';

class Dartlize {
  final String uri;
  final List<Table> _tables;
  late final DatabaseDriver _driver;

  Dartlize(this.uri, this._tables);

  /// Sincroniza as tabelas e retorna um QueryBuilder conectado ao driver.
  Future<QueryBuilder> sync() async {
    _driver = await SqlDriverFactory.getDriver(uri);
    for (final table in _tables) {
      await _driver.createTable(table.name, table.columns);
    }
    return QueryBuilder(_driver);
  }
}
