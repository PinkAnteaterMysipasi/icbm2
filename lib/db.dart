import 'dart:math' show Random;
import 'dart:io';
import 'package:result_type/result_type.dart';
import 'package:pocketbase/pocketbase.dart';

enum LoginError {noTokenPresent, wrongTokenPresent}
enum LoginPostError {invalidCredentials}
enum BuyExeError {idNotValid, notEnoughMoney, alreadyBought}
enum SolveExeReqError {idNotValid, tooEarly, notBought}
enum SolveExeResError {idNotValid, notPending}
enum GetExeError {idNotValid, notBought}
enum SellExeError {idNotValid, notBought}
enum ViewExeError {idNotValid, notBought}
// enum ViewMarketError {}

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

late final PocketBase pb;

Future<Result<RecordModel, LoginError>> getTeamFromCookie (String cookie) async {
  String? token = RegExp(r'ICBMtoken=(.+)').firstMatch(cookie)?.group(1);
  if (token == null) return Failure(LoginError.noTokenPresent);
  try {
    final user = await pb.collection('players').getFirstListItem('token = "$token" && expires > @now', expand: 'team,team.solved,team.bought,team.pending');
    return Success(user.data['team']);
  } on ClientException {
    return Failure(LoginError.wrongTokenPresent);
  }
}

Future<Result<RecordModel, LoginError>> getUserFromCookie (String cookie) async {
  String? token = RegExp(r'ICBMtoken=(.+)').firstMatch(cookie)?.group(1);
  if (token == null) return Failure(LoginError.noTokenPresent);
  try {
    final user = await pb.collection('players').getFirstListItem('token = "$token" && expires > @now', expand: 'team,team.solved,team.bought,team.pending');
    return Success(user);
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

Future<Result<String, BuyExeError>> buy (String id, String teamId) async {
  RecordModel exe;
  RecordModel team;
  try {
    exe = await pb.collection('exercises').getOne(id);
    team = await pb.collection('teams').getOne(teamId);
  } on ClientException {
    return Failure(BuyExeError.idNotValid);
  }
  if (team.data['bought'].contains(exe.id) || team.data['solved'].contains(exe.id)) return Failure(BuyExeError.alreadyBought);
  if (exe.data['price'] > team.data['money']) return Failure(BuyExeError.notEnoughMoney);
  await pb.collection('teams').update(team.id, body: {
    'bought+': [exe.id],
    'money-': exe.data['price'],
  });
  return Success(exe.id);
}

Future<Result<RecordModel, SolveExeReqError>> solveReq (String id, String teamId) async {
  RecordModel exe;
  RecordModel team;
  try {
    exe = await pb.collection('exercises').getOne(id);
    team = await pb.collection('teams').getOne(teamId);
  } on ClientException {
    return Failure(SolveExeReqError.idNotValid);
  }
  final lastTime = DateTime.tryParse(exe.data['attempts']?[team.id] ?? '');
  if (
    lastTime != null &&
    DateTime.now().isBefore(lastTime.add(Duration(seconds: exe.data['attempt_dur'])))
  ) return Failure(SolveExeReqError.tooEarly);
  if (!team.data['bought'].contains(id)) return Failure(SolveExeReqError.notBought);
  await pb.collection('exercises').update(exe.id, body: {
    'attempts': exe.data['attempts']..[team.id] = DateTime.now().toIso8601String(),
  });
  await pb.collection('teams').update(team.id, body: {
    'bought-': [exe.id],
    'pending+': [exe.id],
  });
  return Success(exe);
}

Future<Result<String, SolveExeResError>> solveRes (String id, String teamId) async {
  RecordModel reqExe;
  RecordModel team;
  try {
    reqExe = await pb.collection('exercises').getOne(id);
    team = await pb.collection('teams').getOne(teamId);
  } on ClientException {
    return Failure(SolveExeResError.idNotValid);
  }
  if (!team.data['pending'].contains(reqExe.id)) return Failure(SolveExeResError.notPending);
  await pb.collection('teams').update(team.id, body: {
    'pending-': [reqExe.id],
    'solved+': [reqExe.id],
    'money+': reqExe.data['reward'],
  });
  return Success(reqExe.id);
}

// Future<Result<RecordModel, GetExeError>> getExercise (String id, RecordModel team) async {
//   RecordModel reqExe;
//   try {
//     reqExe = await pb.collection('exercises').getOne(id);
//   } on ClientException {
//     return Failure(GetExeError.idNotValid);
//   }
//   if (!team.data['bought'].contains(id)) return Failure(GetExeError.notBought);
//   return Success(reqExe);
// }

Future<Result<String, SellExeError>> sell (String id, String teamId) async {
  RecordModel exe;
  RecordModel team;
  try {
    exe = await pb.collection('exercises').getOne(id);
    team = await pb.collection('teams').getOne(teamId);
  } on ClientException {
    return Failure(SellExeError.idNotValid);
  }
  if (!team.data['bought'].contains(exe.id)) return Failure(SellExeError.notBought);
  await pb.collection('teams').update(team.id, body: {
    'bought-': [exe.id],
    'money+': exe.data['second_price'],
  });
  return Success(exe.id);
}

Future<Result<File, ViewExeError>> view (String id, String teamId) async {
  RecordModel exe;
  RecordModel team;
  try {
    exe = await pb.collection('exercises').getOne(id);
    team = await pb.collection('teams').getOne(teamId);
  } on ClientException {
    return Failure(ViewExeError.idNotValid);
  }
  if (!team.data['bought'].contains(exe.id)) return Failure(ViewExeError.notBought);
  final resFile = File(
    '${Directory.current.path}\\pb\\pb_data\\storage\\${collectionIds.exercises}\\${exe.id}\\${exe.data['html']}'
  );
  return Success(resFile);
}

// Future<Result<List<RecordModel>, void>> viewMarket () async {
//   return pb.collection('problems').getFullList();
// }