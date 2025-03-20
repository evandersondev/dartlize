import 'package:dartlize/dartlize.dart';

class Model {
  final DatabaseDriver _driver;
  final String name;
  final Map<String, DataTypes> _schema;
  final Map<String, dynamic>? _options;

  bool _isSynced = false;
  Future<void>? _syncFuture;

  Model(
    this.name,
    this._schema,
    this._options, {
    required DatabaseDriver driver,
  }) : _driver = driver;

  Future<void> _ensureSynced() async {
    if (!_isSynced) {
      _syncFuture ??= sync();
      await _syncFuture;
      _isSynced = true;
    }
  }

  Future<Map<String, dynamic>?> create(Map<String, dynamic> data) async {
    final timsestamp = _options?['timestamps'] ?? false;

    await _ensureSynced();
    return await _driver.insert(name, data, timestamps: timsestamp);
  }

  Future<List<dynamic>> findOrCreate({
    required Map<String, dynamic> where,
    Map<String, dynamic>? defaults,
  }) async {
    await _ensureSynced();
    return await _driver.findOrCreate(name, where: where, defaults: defaults);
  }

  Future<List<Map<String, dynamic>>> findAll({
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  }) async {
    await _ensureSynced();

    return await _driver.findAll(
      name,
      attributes: attributes,
      where: where,
      offset: offset,
      limit: limit,
      order: order,
    );
  }

  Future<Map<String, dynamic>> findOne({
    required Map<String, dynamic> where,
  }) async {
    await _ensureSynced();

    return await _driver.findOne(name, where: where);
  }

  Future<Map<String, dynamic>> findAndCountAll({
    List<String>? attributes,
    Map<String, dynamic>? where,
    int? offset,
    int? limit,
    List<List<String>>? order,
  }) async {
    await _ensureSynced();

    return await _driver.findAndCountAll(
      name,
      attributes,
      where,
      offset,
      limit,
      order,
    );
  }

  Future<Map<String, dynamic>?> findByPk(dynamic pk) async {
    await _ensureSynced();
    final primaryKey = _options?['primaryKey'] ?? 'id';

    return await _driver.findByPk(name, primaryKey, pk);
  }

  Future<int> update(
    Map<String, dynamic> data, {
    required Map<String, dynamic> where,
  }) async {
    await _ensureSynced();
    return await _driver.update(name, data, where: where);
  }

  Future<int> destroy({required Map<String, dynamic> where}) async {
    await _ensureSynced();
    return await _driver.destroy(name, where: where);
  }

  Future<int> count({Map<String, dynamic>? where}) async {
    await _ensureSynced();
    return await _driver.count(name, where: where);
  }

  Future<dynamic> raw(String query, [List<dynamic>? parameters]) async {
    await _ensureSynced();
    return _driver.raw(query, parameters);
  }

  Future<void> sync() async {
    var tableName = _options?['tableName'] ?? name;
    final timsestamp = _options?['timestamps'] ?? false;

    var newOptions = _options != null ? Map.of(_options!) : <String, dynamic>{};

    var newSchema = Map.of(_schema);

    if (timsestamp) {
      newSchema['created_at'] = DataTypes.DATE;
      newSchema['updated_at'] = DataTypes.DATE;
    }

    if (newOptions['primaryKey'] == null) {
      if (!newSchema.containsKey('id')) {
        newSchema['id'] = DataTypes.INTEGER;
      }
      newOptions['primaryKey'] = 'id';
    }

    await _driver.createTable(tableName, newSchema, newOptions);
  }
}
