import 'package:icbm2/web.dart';
import 'package:icbm2/db.dart';

void main(List<String> args) async {
  await pb.admins.authWithPassword('bot@bot.bot', 'Krakatice69');
  await webapp.listen(int.tryParse(args.firstOrNull ?? '3000') ?? 3000);
}