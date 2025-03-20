import 'package:dartlize/dartlize.dart';
import 'package:example/config/database.dart';

final Task = dartlize.define(
  'tasks',
  {
    'id': DataTypes.TEXT,
    'title': DataTypes.TEXT,
    'description': DataTypes.TEXT,
  },
  {'timestamps': true},
);
