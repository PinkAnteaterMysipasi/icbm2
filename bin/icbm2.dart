import 'dart:io';
import 'dart:isolate';
import 'package:dotenv/dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hive/hive.dart';
import 'package:icbm2/web.dart';
import 'package:icbm2/db.dart';
// import 'package:icbm2/discord.dart';

void main(List<String> args) async {
  final env = DotEnv()..load();
  pb = PocketBase('http://localhost:${args.length < 2 ? 8090 : int.tryParse(args[1]) ?? 8090}');
  await pb.admins.authWithPassword(env['PB_USER']!, env['PB_PASS']!);
  for (final exercise in await pb.collection('exercises').getFullList()) {
    await pb.collection('exercises').update(exercise.id, body: {
      'attempts': {},
    });
  }
  // await initBot(env['DISCORD_BOT']!, env['DISCORD_SERIOUS_BOT']!);
  Hive.init(Directory.current.path);
  await Isolate.run(() => webapp.listen(int.tryParse(args.firstOrNull ?? '3000') ?? 3000));
}