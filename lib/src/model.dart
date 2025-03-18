import 'package:dartlize/dartlize.dart';
import 'package:dartlize/src/data_types.dart';
import 'package:dartlize/src/database_driver.dart';

class Model {
  final DatabaseDriver _driver;
  final String name;
  final Map<String, DataTypes> _schema;
  final Map<String, dynamic>? _options;

  Model(this._driver, this.name, this._schema, this._options);

  Future<int> create(Map<String, dynamic> data) {
    // Validação dos dados conforme o schema pode ser feita aqui.
    return _driver.insert(name, data);
  }

  Future<List<Map<String, dynamic>>> findAll() {
    return _driver.findAll(name);
  }

  Future<void> sync() async {
    var tableName = name;
    print('[Model $name] Iniciando sync para a tabela $tableName');
    // Se nenhuma chave primária foi definida nas options, adiciona automaticamente "id".
    var newOptions = _options != null ? Map.of(_options!) : <String, dynamic>{};
    var newSchema = Map.of(_schema);
    if (newOptions['primaryKey'] == null) {
      if (!newSchema.containsKey('id')) {
        newSchema['id'] = DataTypes.INTEGER;
      }
      newOptions['primaryKey'] = 'id';
    }
    await _driver.createTable(tableName, newSchema, newOptions);
    print('[Model $name] Tabela criada: $tableName');
  }
}
