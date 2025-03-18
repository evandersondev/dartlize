import 'package:example/config/database.dart';
import 'package:example/models/user.dart';

void main() async {
  await dartlize.sync([user]);

  await user.create({
    'name': 'John Doe',
    'email': 'john@example.com',
    'password': 'password123',
  });

  final users = await user.findAll();
  print(users);
}
