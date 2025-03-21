import 'dart:convert';

import 'package:darto/darto.dart';
import 'package:example/models/user.dart';
import 'package:uuid/uuid.dart';
import 'package:zard/zard.dart';

Router appRouter() {
  final router = Router();

  router.post('/tasks', (Request req, Response res) async {
    final taskSchema = z.map({
      'title': z.string().min(3).max(100),
      'description': z.string().min(3).optional(),
    });

    final task = taskSchema.parse(jsonDecode(await req.body));
    task['id'] = Uuid().v4(); // Generate a random UUID

    final userCreated = await Task.create(task);

    res.status(CREATED).json(userCreated);
  });

  router.get('/tasks', (Request req, Response res) async {
    final tasks = await Task.findAll();

    res.json(tasks);
  });

  router.put('/tasks/:id', (Request req, Response res) async {
    final id = req.params['id'];

    final taskExists = await Task.findByPk(id);
    if (taskExists == null) {
      res.status(NOT_FOUND).end();
      return;
    }

    final taskSchema = z.map({
      'title': z.string().min(3).max(100).optional(),
      'description': z.string().min(3).optional(),
    });

    final task = taskSchema.parse(jsonDecode(await req.body));

    await Task.update(task, where: {'id': id});

    res.status(OK).end();
  });

  return router;
}
