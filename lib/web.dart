import 'dart:io';
import 'package:alfred/alfred.dart';
import 'package:icbm2/template.dart';
// import 'package:icbm2/discord.dart';
import 'db.dart';

final webapp = Alfred()
  ..get('/login', (req, res) async {
    final loginTemp = await Template.fromCurrentPathAsync('/html/login.html');
    await res.html(loginTemp.blank());
  })
  ..post('/login', (req, res) async {
    final body = await req.body as Map;
    if (!body.containsKey('username') || !body.containsKey('password')) {
      await res.found('/login');
      return;
    }
    final {'username': String username, 'password': String password} = body;
    final loginRes = await setUserCookie(username, password);
    if (loginRes.isFailure) {
      await res.found('/login');
      return;
    }
    res.headers.set('set-cookie', 'ICBMtoken=${loginRes.success}; Domain=localhost; Max-Age=86400;');
    await res.found('/home');
  })
  ..get('/home', (req, res) async {
    final teamRes = await getTeamFromCookie(req.headers.value('cookie') ?? '');
    if (teamRes.isFailure) {
      await res.found('/login');
      return;
    }
    final homeTemp = await Template.fromCurrentPathAsync('/html/home.html');
    await res.html(homeTemp.fill({
      'Team': teamRes.success.data['name'],
      'Money': teamRes.success.data['money'],
      'Bought': [for (var bought in teamRes.success.expand['bought']!) homeTemp.grab('Exe').fill({
        'Id': bought.id,
        'Name': bought.data['name'],
      })],
    }));
  })
  ..get('/buy/:id', (req, res) async {
    final teamRes = await getTeamFromCookie(req.headers.value('cookie') ?? '');
    if (teamRes.isFailure) {
      await res.found('/login');
      return;
    }
    final buyRes = await buy(req.params['id'], teamRes.success.id);
    if (buyRes.isFailure) {
      await res.html(buyRes.failure.toString());
      return;
    }
    await res.found('/view/${buyRes.success}');
  })
  ..get('/solve/:id', (req, res) async {
    final teamRes = await getTeamFromCookie(req.headers.value('cookie') ?? '');
    if (teamRes.isFailure) {
      await res.found('/login');
      return;
    }
    final solveReqRes = await solveReq(req.params['id'], teamRes.success.id);
    if (solveReqRes.isFailure) {
      await res.html(solveReqRes.failure.toString());
      return;
    }
    await res.html('solved ${solveReqRes.success}');
  })
  ..get('/sell/:id', (req, res) async {
    final teamRes = await getTeamFromCookie(req.headers.value('cookie') ?? '');
    if (teamRes.isFailure) {
      await res.found('/login');
      return;
    }
    final solveReqRes = await sell(req.params['id'], teamRes.success.id);
    if (solveReqRes.isFailure) {
      await res.html(solveReqRes.failure.toString());
      return;
    }
    await res.html('sold ${solveReqRes.success}');
  })
  ..get('/view/:id', (req, res) async {
    final teamRes = await getTeamFromCookie(req.headers.value('cookie') ?? '');
    if (teamRes.isFailure) {
      await res.found('/login');
      return;
    }
    final viewRes = await view(req.params['id'], teamRes.success.id);
    if (viewRes.isFailure) {
      await res.html(viewRes.failure.toString());
      return;
    }
    await res.html(await viewRes.success.readAsString());
  });


extension on HttpResponse {
  Future html(String html) {
    headers.contentType = ContentType.html;
    write(html);
    return close();
  }
  Future found(String location) {
    headers.set('location', location);
    statusCode = 302;
    return close();
  }
}
