import 'package:darto/darto.dart';
import 'package:example/app_router.dart';
import 'package:example/config/database.dart';

void main() async {
  await dartlize.sync();

  final app = Darto();
  app.use('/api/v1', appRouter());

  app.listen(3000, () => print('Server is running on port 3000'));
}
