import 'package:pocketbase/pocketbase.dart';
import 'package:result_type/result_type.dart';
import 'dart:math' show Random;
import 'dart:io';

enum LoginError {noTokenPresent, wrongTokenPresent}
enum LoginPostError {invalidCredentials}
enum BuyExeError {idNotValid, notEnoughMoney, alreadyBought}
enum SolveExeError {idNotValid, tooEarly, notBought}
enum SellExeError {idNotValid, notBought}
enum ViewExeError {idNotValid, notBought}

final collectionIds = (
  exercises: 'j8fw5h801zf0725',
  players: '8o9rndue7701lca',
  problems: 'lthg3gtwyk9q4wv',
  teams: '8qpxfloij3mbahc',
);

String generateRandomString(int len) {
  var r = Random();
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}

final pb = PocketBase('http://localhost:8090');

Future<Result<RecordModel, LoginError>> getTeamFromCookie (Map<String, String> headers) async {
  String? token = RegExp(r'ICBMtoken=(.+)').firstMatch(headers['cookie'] ?? '')?.group(1);
  if (token == null) return Failure(LoginError.noTokenPresent);
  try {
    final user = await pb.collection('users').getFirstListItem('token = "$token" && expires > @now', expand: 'team');
    return Success(user.expand['team']!.first);
  } on ClientException {
    return Failure(LoginError.wrongTokenPresent);
  }
}

Future<Result<String, LoginPostError>> setUserCookie (String username, String password) async {
  final newToken = generateRandomString(69);
  RecordModel reqUser;
  try {
    reqUser  = await pb.collection('players').getFirstListItem('username = "$username" && password = "$password"');
  } on ClientException {
    return Failure(LoginPostError.invalidCredentials);
  }
  await pb.collection('players').update(reqUser.id, body: {
    'token': newToken,
    'expires': DateTime.now().add(const Duration(days: 1)).toString(),
  });
  return Success(newToken);
}

Future<Result<String, BuyExeError>> buy (String id, RecordModel team) async {
  RecordModel reqExe;
  try {
    reqExe = await pb.collection('exercises').getOne(id);
  } on ClientException {
    return Failure(BuyExeError.idNotValid);
  }
  if (team.data['bought'].contains(reqExe.id) || team.data['solved'].contains(reqExe.id)) return Failure(BuyExeError.alreadyBought);
  if (reqExe.data['price'] > team.data['money']) return Failure(BuyExeError.notEnoughMoney);
  await pb.collection('teams').update(team.id, body: {
    'bought+': [reqExe.id],
    'money-': reqExe.data['price'],
  });
  return Success(reqExe.id);
}

Future<Result<String, SolveExeError>> solve (String id, bool correct, RecordModel team) async {
  RecordModel reqExe;
  try {
    reqExe = await pb.collection('exercises').getOne(id);
  } on ClientException {
    return Failure(SolveExeError.idNotValid);
  }
  final lastTime = DateTime.tryParse(reqExe.data['attempts']?[team.id] ?? '');
  print(lastTime?.add(const Duration(minutes: 1)));
  if (
    lastTime != null &&
    DateTime.now().isBefore(lastTime.add(Duration(seconds: reqExe.data['attempt_dur'])))
  ) return Failure(SolveExeError.tooEarly);
  if (!team.data['bought'].contains(id)) return Failure(SolveExeError.notBought);
  await pb.collection('exercises').update(reqExe.id, body: {
    'attempts': reqExe.data['attempts']..[team.id] = DateTime.now().toIso8601String(),
  });
  if (correct) {
    await pb.collection('teams').update(team.id, body: {
      'bought-': [reqExe.id],
      'solved+': [reqExe.id],
      'money+': reqExe.data['reward'],
    });
  }
  return Success(reqExe.id);
}

Future<Result<String, SellExeError>> sell (String id, RecordModel team) async {
  RecordModel reqExe;
  try {
    reqExe = await pb.collection('exercises').getOne(id);
  } on ClientException {
    return Failure(SellExeError.idNotValid);
  }
  if (!team.data['bought'].contains(reqExe.id)) return Failure(SellExeError.notBought);
  await pb.collection('teams').update(team.id, body: {
    'bought-': [reqExe.id],
    'money+': reqExe.data['second_price'],
  });
  return Success(reqExe.id);
}

Future<Result<File, ViewExeError>> view (String id, RecordModel team) async {
  RecordModel reqExe;
  try {
    reqExe = await pb.collection('exercises').getOne(id);
  } on ClientException {
    return Failure(ViewExeError.idNotValid);
  }
  if (!team.data['bought'].contains(reqExe.id)) return Failure(ViewExeError.notBought);
  final resFile = File(
    '${Directory.current.path}\\pb\\pb_data\\storage\\${collectionIds.exercises}\\${reqExe.id}\\${reqExe.data['html']}'
  );
  return Success(resFile);
}