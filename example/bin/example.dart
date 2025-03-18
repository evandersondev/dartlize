import 'package:example/query_builder.dart';

// void main() async {
//   await dartlize.sync([user]);

//   await user.create({
//     'name': 'John Doe',
//     'email': 'john@example.com',
//     'password': 'password123',
//   });

//   final users = await user.findAll();
//   print(users);
// }
void main() {
  var query = QueryBuilder()
      .from('users')
      .select(['*'])
      .where('users.status', '=', 'active')
      .where('users.email', '=', 'john@example.com');

  var params = query.getParameters();

  // 3️⃣ Enviando para o MySQL
  print('${query.toSql()} - $params');

  var sql =
      QueryBuilder().createTable('users', {
        'id': 'INT PRIMARY KEY AUTO_INCREMENT',
        'name': 'VARCHAR(255)',
        'email': 'VARCHAR(255) UNIQUE',
        'created_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
      }).toSql();

  print(sql);
}
