import 'package:dartlize/dartlize.dart';
import 'package:example/config/database.dart';

final user = dartlize.define('user', {
  'name': DataTypes.TEXT,
  'email': DataTypes.TEXT,
  'password': DataTypes.TEXT,
});
