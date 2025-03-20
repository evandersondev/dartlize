import 'package:dartlize/dartlize.dart';

// final user = dartlize.define('user', {
//   'name': DataTypes.TEXT,
//   'email': DataTypes.TEXT,
//   'password': DataTypes.TEXT,
// });

class User extends Model {
  User(DatabaseDriver dartlize)
    : super(
        'user',
        {
          'name': DataTypes.TEXT,
          'email': DataTypes.TEXT,
          'password': DataTypes.TEXT,
        },
        {'timestamps': true},
        driver: dartlize,
      );
}
