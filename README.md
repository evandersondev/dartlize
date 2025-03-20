# Dartlize 🚀

Dartlize is a lightweight ORM for Dart designed to simplify database interactions inspired by the Sequelize ORM for Javascript. Easily define models, perform CRUD operations, and manage your database with intuitive methods and a fluent API.

<br>

### Support 💖

If you find Dartlize useful, please consider supporting its development 🌟[Buy Me a Coffee](https://buymeacoffee.com/evandersondev).🌟 Your support helps us improve the framework and make it even better!

<br>

## Features ✨

- **Two ways to define models:** Use `dartlize.define` or extend the `Model` class.
- **Multiple Database Drivers:** SQLite, PostgreSQL, MySQL, and more.
- **Built-In CRUD Operations:** Create, find, update, delete, count and execute raw queries.
- **Automatic Timestamps:** Optionally manage created_at and updated_at fields.

---

<br>

## Installation 📦

Add Dartlize as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  dartlize: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

<br>

## Getting Started ⚡

### 1. Database Initialization

Initialize Dartlize with your chosen database driver. For example:

```dart
import 'package:dartlize/dartlize.dart';

// Sqlite in memory database
final dartlize = Dartlize('sqlite::memory:');

// Uncomment one of these for other databases:
// Sqlite file database:
// final dartlize = Dartlize('sqlite://database/database.db');
// Postgres database:
// final dartlize = Dartlize('postgres://username:password@localhost:5432/database');
// MySql database:
// final dartlize = Dartlize('mysql://username:password@localhost:3306/database');
```

<br>

Before working with your models, initialize and sync your database:

<br>

```dart
void main() async {
  await dartlize.sync();

  if (dartlize.authenticate()) {
    print('✅ Connected to the database.');
  } else {
    print('❌ Authentication failed.');
  }
  // ... continue with model operations
}
```

<br>

### 2. Defining Models

Dartlize offers two methods to configure models:

#### a) Using `dartlize.define`

Define a model directly with a schema:

```dart
import 'package:dartlize/dartlize.dart';

// Define a User model using `dartlize.define`
final User = dartlize.define('users', {
  'name': DataTypes.TEXT,
  'email': DataTypes.TEXT,
  'password': DataTypes.TEXT,
}, {'timestamps': true});
```

<br>

#### b) Extending the `Model` Class

Alternatively, extend Dartlize’s `Model` class to create your own model:

```dart
import 'package:dartlize/dartlize.dart';

class User extends Model {
  User(DatabaseDriver driver)
      : super(
          'user',
          {
            'name': DataTypes.TEXT,
            'email': DataTypes.TEXT,
            'password': DataTypes.TEXT,
          },
          {'timestamps': true},
          driver: driver,
        );
}
```

---

<br>

## CRUD Operations and Methods 📚

Dartlize provides a rich set of methods to interact with the database for any model.

### Create

Insert a new record:

```dart
await user.create({
  'name': 'John Doe',
  'email': 'john@example.com',
  'password': 'password123',
});
```

<br>

### Read/Find

- **findAll:** Retrieve records.

  ```dart
  var users = await user.findAll();
  print(users);
  ```

- **findOne:** Retrieve a single record.

  ```dart
  var userFound = await user.findOne(where: {'id': 1});
  print(userFound);
  ```

- **findByPk:** Find by primary key.

  ```dart
  var userByPk = await user.findByPk(1);
  print(userByPk);
  ```

- **findAndCountAll:** Get records with count.

  ```dart
  var result = await user.findAndCountAll();
  print(result);
  ```

- **findOrCreate:** Find a record or create one if it doesn’t exist.
  ```dart
  var result = await user.findOrCreate(
    where: {'email': 'john@example.com'},
    defaults: {'name': 'John Doe', 'password': 'password123'},
  );
  print(result);
  ```

<br>

### Update

Update existing records:

```dart
final updateResult = await user.update(
  {'name': 'Evanderson Vasconcelos'},
  where: {'id': 1},
);
print('Rows updated: $updateResult');
```

<br>

### Delete

Delete records from the table:

```dart
await user.destroy(where: {'id': 1});
```

<br>

### Count

Get the count of records matching a query:

```dart
final count = await user.count();
print('User count: $count');
```

<br>

### Raw Query

Execute a raw SQL query:

```dart
final result = await user.raw('SELECT * FROM user WHERE id = ?', [1]);
print(result);
```

<br>

### Sync

Synchronize the model with the database (create table if not exists):

```dart
await user.sync();
```

---

<br>

## API Summary 📝

- `Future<int> create(Map<String, dynamic> data)`
- `Future<List<dynamic>> findOrCreate({required Map<String, dynamic> where, Map<String, dynamic>? defaults})`
- `Future<List<Map<String, dynamic>>> findAll({List<String>? attributes, Map<String, dynamic>? where, int? offset, int? limit, List<List<String>>? order})`
- `Future<Map<String, dynamic>> findOne({required Map<String, dynamic> where})`
- `Future<Map<String, dynamic>> findAndCountAll({List<String>? attributes, Map<String, dynamic>? where, int? offset, int? limit, List<List<String>>? order})`
- `Future<Map<String, dynamic>?> findByPk(dynamic pk)`
- `Future<int> update(Map<String, dynamic> data, {required Map<String, dynamic> where})`
- `Future<int> destroy({required Map<String, dynamic> where})`
- `Future<int> count({Map<String, dynamic>? where})`
- `Future<dynamic> raw(String query, [List<dynamic>? parameters])`
- `Future<void> sync()`

---

<br>

## Contributing 🤝

Contributions are welcome! Open issues, submit pull requests, or get in touch with us to help make Dartlize even better. Happy coding! 💡

---

<br>

## License 📄

This project is licensed under the MIT License.

<br>

---

Made with ❤️ for Dart/Flutter developers! 🎯
