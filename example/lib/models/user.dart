import 'package:dartlize/dartlize.dart';
import 'package:example/config/database.dart';

final User = dartlize.define(
  'User',
  {'name': DataTypes.TEXT, 'email': DataTypes.TEXT, 'password': DataTypes.TEXT},
  {'timestamps': true, 'tableName': 'users'},
);

// User.hasMany('Task', foreignKey = 'user_id', as = 'tasks');

final Task = dartlize.define(
  'Task',
  {
    'title': DataTypes.TEXT,
    'description': DataTypes.TEXT,
    'completed': DataTypes.BOOLEAN,
  },
  {'timestamps': true, 'tableName': 'tasks'},
);

// Task.belongsTo('User', foreignKey = 'user_id', as = 'user');
