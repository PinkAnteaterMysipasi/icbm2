import 'package:icbm2/db.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:pocketbase/pocketbase.dart';

late final INyxxWebsocket bot;

late final INyxxWebsocket seriousBot; 

late final IInteractions interactions;

Future<void> initBot (String botToken, String seriousBotToken) async {
  bot = NyxxFactory.createNyxxWebsocket(
      botToken,
      GatewayIntents.allUnprivileged | GatewayIntents.messageContent
    )
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();

  seriousBot = NyxxFactory.createNyxxWebsocket(
      seriousBotToken,
      GatewayIntents.allUnprivileged | GatewayIntents.messageContent
    )
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();

  interactions = IInteractions.create(WebsocketInteractionBackend(seriousBot))..syncOnReady();
}

Future<IMessage> botMessage (dynamic channelId, MessageBuilder builder) => bot.httpEndpoints.sendMessage(Snowflake(channelId), builder);
Future<IMessage> seriousBotMessage (dynamic channelId, MessageBuilder builder) => seriousBot.httpEndpoints.sendMessage(Snowflake(channelId), builder);

void rateMessage (RecordModel exercise, String teamId, String solution) async {
  final availableCorrectors = await pb.collection('correctors').getFullList(sort: '-busy');
  final chosenCorrector = availableCorrectors.first;
  interactions.registerButtonHandler('+${exercise.id};$teamId', (event) async {
    await event.acknowledge();
    await pb.collection('correctors').update(chosenCorrector.id, body: {'busy': false});
    await solveRes(exercise.id, teamId);
    await event.editOriginalResponse(ComponentMessageBuilder()
      ..addAttachment(AttachmentBuilder.bytes(solution.codeUnits, 'solution.txt'))
      ..content = 'exercise ${exercise.data['name']} rated good'
    );
  });
  interactions.registerButtonHandler('-${exercise.id};$teamId', (event) async {
    await event.acknowledge();
    await pb.collection('correctors').update(chosenCorrector.id, body: {'busy': false});
    await event.editOriginalResponse(ComponentMessageBuilder()
      ..addAttachment(AttachmentBuilder.bytes(solution.codeUnits, 'solution.txt'))
      ..content = 'exercise `${exercise.data['name']}` rated bad'
    );
  });
  await interactions.sync();
  await seriousBotMessage(chosenCorrector.data['dm_channel'], ComponentMessageBuilder()
    ..addComponentRow(
      ComponentRowBuilder()
        ..addComponent(ButtonBuilder('Good', '+${exercise.id};$teamId', ButtonStyle.success))
        ..addComponent(ButtonBuilder('Bad', '-${exercise.id};$teamId', ButtonStyle.danger))
    )
    ..addAttachment(AttachmentBuilder.bytes(solution.codeUnits, 'solution.txt'))
    ..content = 'rate `${exercise.data['name']}` pls: '
  );
  await pb.collection('correctors').update(chosenCorrector.id, body: {'busy': true});
}