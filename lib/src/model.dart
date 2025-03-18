import 'package:dartlize/dartlize.dart';
import 'package:dartlize/src/data_types.dart';
import 'package:dartlize/src/database_driver.dart';

class Model {
  final DatabaseDriver _driver;
  final String name;
  final Map<String, DataTypes> _schema;
  // As options podem definir a primaryKey, dentre outras configurações.
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
    var tableName = _options?['tableName'] ?? name;
    // Se nenhuma chave primária foi definida nas options, adiciona automaticamente o "id".
    var newOptions = _options != null ? Map.of(_options) : <String, dynamic>{};
    var newSchema = Map.of(_schema);
    if (newOptions['primaryKey'] == null) {
      // Adiciona a coluna id só se ela ainda não existir no schema.
      if (!newSchema.containsKey('id')) {
        newSchema['id'] = DataTypes.INTEGER;
      }
      newOptions['primaryKey'] = 'id';
    }
    print('Creating table $tableName...');
    await _driver.createTable(tableName, newSchema, newOptions);
    print('Table $tableName created successfully.');
  }
}
