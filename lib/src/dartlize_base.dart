// import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'package:dartlize/src/database_driver.dart';
import 'package:dartlize/src/model.dart';

import 'data_types.dart';

class Dartilize {
  static final Dartilize _instance = Dartilize._internal();
  late DatabaseDriver _driver;
  final Map<String, Model> _models = {};

  factory Dartilize(DatabaseDriver driver) {
    _instance._driver = driver;
    return _instance;
  }

  Dartilize._internal();

  Future<void> connect() => _driver.connect();
  Future<void> disconnect() => _driver.disconnect();

  Future<void> sync(List<Model> models) async {
    await _driver.connect();

    for (var model in models) {
      _models[model.name] = model;
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
