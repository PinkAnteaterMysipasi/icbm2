import 'package:icbm2/web.dart';
import 'package:icbm2/db.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> args) async {
  final env = DotEnv()..load();
  await pb.admins.authWithPassword(env['PB_USER']!, env['PB_PASS']!);
  for (final exercise in await pb.collection('exercises').getFullList()) {
    await pb.collection('exercises').update(exercise.id, body: {
      'attempts': {},
    });
  }
  await webapp.listen(int.tryParse(args.firstOrNull ?? '3000') ?? 3000);
}