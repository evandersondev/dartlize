import 'package:dartlize/dartlize.dart';

void main() async {
  final usersTable = sqliteTable("users", {
    'id': integer().primaryKey(autoIncrement: true),
    'name': text().notNull(),
    'age': integer(),
    'email': text().notNull().unique(),
  });

  final dartlize = Dartlize("sqlite::memory:", [usersTable]);
  final db = await dartlize.sync();

  await db.insert('users').values({
    'name': 'John Doe',
    'age': 30,
    'email': 'john@mail.com',
  });

  var selectQuery = await db.select().from('users');

  await db
      .update('users')
      .set({'age': 31})
      .where(eq('users.email', 'john@mail.com'));

  selectQuery = await db.select().from('users');
  print(selectQuery);

  await db.insert('users').values({
    'name': 'Evanderson',
    'age': 32,
    'email': 'evan@mail.com',
  });

  // // Exemplo: Exclusão.
  // final deleteQuery = db
  //     .delete('users')
  //     // Note: O método set() em delete não gera uma cláusula SET no SQL padrão;
  //     // ele pode ser utilizado para lógica customizada (ex: soft delete).
  //     .set({'age': 31})
  //     .where(eq('users.email', 'john@mail.com'));
  // print("SQL gerado (DELETE): ${deleteQuery.toSql()}");
  // await deleteQuery.execute();

  // app.listen(3000, () => print('Server is running on port 3000'));
}
