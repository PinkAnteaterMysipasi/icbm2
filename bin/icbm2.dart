import 'package:icbm2/web.dart';
import 'package:icbm2/db.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> args) async {
  final env = DotEnv()..load();
  await pb.admins.authWithPassword(env['PB_USER']!, env['PB_PASS']!);
  await webapp.listen(int.tryParse(args.firstOrNull ?? '3000') ?? 3000);
}