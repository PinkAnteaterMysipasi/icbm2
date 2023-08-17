import 'dart:io';
import 'package:alfred/alfred.dart';
import 'db.dart';

final webapp = Alfred()
  ..get('/buy/:id', (req, res) async {
    final DateTime start = DateTime.now();
    final team = await pb.collection('teams').getOne('b5ywdhnk4j9tnp2');
    final String? id = req.params['id'];
    if (id == null) {
      res.html('specify id pls');
      return;
    }
    final buyRes = await buy(id, team);
    if (buyRes.isFailure) {
      res.html(buyRes.failure.toString());
      return;
    }
    res.html('bought ${buyRes.success} in ${DateTime.now().difference(start).inMilliseconds} ms');
  })
  ..get('/solve/:id', (req, res) async {
    final DateTime start = DateTime.now();
    final team = await pb.collection('teams').getOne('b5ywdhnk4j9tnp2');
    final String? id = req.params['id'];
    if (id == null) {
      res.html('specify id pls');
      return;
    }
    final buyRes = await solve(id, true, team);
    if (buyRes.isFailure) {
      res.html(buyRes.failure.toString());
      return;
    }
    res.html('solved ${buyRes.success} in ${DateTime.now().difference(start).inMilliseconds} ms');
  })
  ..get('/notsolve/:id', (req, res) async {
    final DateTime start = DateTime.now();
    final team = await pb.collection('teams').getOne('b5ywdhnk4j9tnp2');
    final String? id = req.params['id'];
    if (id == null) {
      res.html('specify id pls');
      return;
    }
    final buyRes = await solve(id, false, team);
    if (buyRes.isFailure) {
      res.html(buyRes.failure.toString());
      return;
    }
    res.html('solved ${buyRes.success} in ${DateTime.now().difference(start).inMilliseconds} ms');
  })
  ..get('/view/:id', (req, res) async {
    final team = await pb.collection('teams').getOne('b5ywdhnk4j9tnp2');
    final String? id = req.params['id'];
    if (id == null) {
      res.html('specify id pls');
      return;
    }
    final buyRes = await view(id, team);
    if (buyRes.isFailure) {
      res.html(buyRes.failure.toString());
      return;
    }
    res.html(await buyRes.success.readAsString());
  });


extension on HttpResponse {
  Future html(String html) {
    headers.contentType = ContentType.html;
    write(html);
    return close();
  }
}
