import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:kalaam/features/session/catalog/catalog.dart';

/// Feeds a hand-written A2UI message sequence through the REAL genui pipeline
/// (transport → parser → SurfaceController with the combined catalog) and
/// returns the resulting surface plus any validation errors the controller
/// reported. This is exactly the path a live Gemini response travels.
Future<({SurfaceDefinition? def, List<String> errors})> _render(
  String surfaceId,
  String componentsJson,
) async {
  final controller = SurfaceController(catalogs: [kalaamCatalog]);
  final transport = A2uiTransportAdapter(onSend: (_) async {});
  final conversation = Conversation(
    controller: controller,
    transport: transport,
  );

  final errors = <String>[];
  final sub = controller.onSubmit.listen((m) {
    // reportError funnels A2UI validation failures onto onSubmit as a
    // UiInteractionPart whose JSON contains an "error" object.
    for (final p in m.parts.uiInteractionParts) {
      if (p.interaction.contains('"error"')) errors.add(p.interaction);
    }
  });

  // Feed the two A2UI messages as separate fenced chunks, mirroring streaming.
  transport.addChunk(
    '```json\n{"version":"v0.9","createSurface":{"surfaceId":"$surfaceId",'
    '"catalogId":"kalaam-widgets-catalog","sendDataModel":true}}\n```',
  );
  await Future<void>.delayed(const Duration(milliseconds: 20));
  transport.addChunk(
    '```json\n{"version":"v0.9","updateComponents":{"surfaceId":"$surfaceId",'
    '"components":$componentsJson}}\n```',
  );
  await Future<void>.delayed(const Duration(milliseconds: 60));

  final def = controller.contextFor(surfaceId).definition.value;
  await sub.cancel();
  conversation.dispose();
  controller.dispose();
  transport.dispose();
  return (def: def, errors: errors);
}

/// Like [_render] but feeds an arbitrary sequence of A2UI message bodies (each
/// gets fenced), and snapshots the data-model value at [readPath] before
/// teardown — for exercising `updateDataModel` loops.
Future<({SurfaceDefinition? def, List<String> errors, num? value})>
_renderSequence(
  String surfaceId,
  List<String> messageBodies, {
  required String readPath,
}) async {
  final controller = SurfaceController(catalogs: [kalaamCatalog]);
  final transport = A2uiTransportAdapter(onSend: (_) async {});
  final conversation = Conversation(
    controller: controller,
    transport: transport,
  );

  final errors = <String>[];
  final sub = controller.onSubmit.listen((m) {
    for (final p in m.parts.uiInteractionParts) {
      if (p.interaction.contains('"error"')) errors.add(p.interaction);
    }
  });

  for (final body in messageBodies) {
    transport.addChunk('```json\n$body\n```');
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }
  await Future<void>.delayed(const Duration(milliseconds: 60));

  final ctx = controller.contextFor(surfaceId);
  final def = ctx.definition.value;
  final value = ctx.dataModel.getValue<num>(DataPath(readPath));

  await sub.cancel();
  conversation.dispose();
  controller.dispose();
  transport.dispose();
  return (def: def, errors: errors, value: value);
}

void main() {
  group('Combined catalog', () {
    test('exposes genui primitives + Kalaam custom widgets', () {
      final names = kalaamCatalog.items.map((i) => i.name).toSet();
      // primitives
      for (final p in [
        'Column',
        'Row',
        'Card',
        'Text',
        'Button',
        'Image',
        'Tabs',
        'ChoicePicker',
        'TextField',
      ]) {
        expect(names, contains(p), reason: 'missing primitive $p');
      }
      // featured custom widgets
      for (final c in [
        'RootExplorer',
        'HarakatBuilder',
        'ConjugationTable',
        'SceneCard',
        'VocabCarousel',
        'MasteryRing',
      ]) {
        expect(names, contains(c), reason: 'missing custom $c');
      }
      expect(kalaamCatalog.catalogId, 'kalaam-widgets-catalog');
    });
  });

  group('Multi-component layouts render without validation errors', () {
    test(
      'Column → [Text, RootExplorer] (composition + the root diagram)',
      () async {
        final r = await _render('s1', '''
[
  {"id":"root","component":"Column","children":["h","wheel"]},
  {"id":"h","component":"Text","text":"Words sharing the root ك-ت-ب:"},
  {"id":"wheel","component":"RootExplorer","rootWord":"ك-ت-ب","rootMeaning":"to write","family":[
    {"word":"كَتَبَ","transliteration":"kataba","meaning":"he wrote","partOfSpeech":"verb","pattern":"فَعَلَ","isExpanded":false},
    {"word":"كِتَاب","transliteration":"kitāb","meaning":"book","partOfSpeech":"noun","pattern":"فِعَال","isExpanded":false},
    {"word":"مَكْتَب","transliteration":"maktab","meaning":"office","partOfSpeech":"noun","pattern":"مَفْعَل","isExpanded":false}
  ]}
]''');
        expect(r.def?.components['root']?.type, 'Column');
        expect(r.def?.components['wheel']?.type, 'RootExplorer');
        expect(r.errors, isEmpty, reason: r.errors.join('\n'));
      },
    );

    test('HarakatBuilder', () async {
      final r = await _render('s2', '''
[
  {"id":"root","component":"HarakatBuilder","instruction":"Vocalise qahwa","letters":["ق","ه","و","ة"],"target":["fatha","sukun","fatha","none"],"transliteration":"qahwa","translation":"coffee"}
]''');
      expect(r.def?.components['root']?.type, 'HarakatBuilder');
      expect(r.errors, isEmpty, reason: r.errors.join('\n'));
    });

    test('ConjugationTable', () async {
      final r = await _render('s3', '''
[
  {"id":"root","component":"ConjugationTable","title":"كَتَبَ — past","headers":["Pronoun","Arabic","Sound"],"rows":[
    {"cells":["I","كَتَبْتُ","katabtu"]},
    {"cells":["he","كَتَبَ","kataba"],"highlight":true}
  ],"caption":"Pattern فَعَلَ"}
]''');
      expect(r.def?.components['root']?.type, 'ConjugationTable');
      expect(r.errors, isEmpty, reason: r.errors.join('\n'));
    });

    test(
      'mixed primitives + custom: Column[Text, QuickChoice, Row[Button]]',
      () async {
        final r = await _render('s4', '''
[
  {"id":"root","component":"Column","children":["q","quiz","actions"]},
  {"id":"q","component":"Text","text":"Quick check:"},
  {"id":"quiz","component":"QuickChoice","question":"What does قَهْوَة mean?","options":[
    {"id":"A","text":"Tea"},{"id":"B","text":"Coffee"},{"id":"C","text":"Water"},{"id":"D","text":"Juice"}
  ],"correctId":"B","selectedId":"","explanationOnWrong":"qahwa is coffee."},
  {"id":"actions","component":"Row","children":["next"]},
  {"id":"next","component":"Button","child":"nextLabel","action":{"event":{"name":"continue"}}},
  {"id":"nextLabel","component":"Text","text":"Next"}
]''');
        expect(r.def?.components['root']?.type, 'Column');
        expect(r.def?.components['quiz']?.type, 'QuickChoice');
        expect(r.def?.components['next']?.type, 'Button');
        expect(r.errors, isEmpty, reason: r.errors.join('\n'));
      },
    );
  });

  group('MasteryRing data-model binding (the showcase finale)', () {
    test('accepts a literal masteryPercent', () async {
      final r = await _render('m1', '''
[
  {"id":"root","component":"MasteryRing","sessionTitle":"Ordering Coffee in Cairo","wordsEncountered":8,"exercisesCompleted":5,"correctAnswers":4,"masteryPercent":80,"streakDays":3,"topWords":["قَهْوَة","شُكْرًا"]}
]''');
      expect(r.def?.components['root']?.type, 'MasteryRing');
      expect(r.errors, isEmpty, reason: r.errors.join('\n'));
    });

    test('accepts a bound masteryPercent and animates via updateDataModel', () async {
      // create → updateComponents (ring bound to /progress/mastery) → two ticks.
      final r = await _renderSequence('m2', [
        '{"version":"v0.9","createSurface":{"surfaceId":"m2","catalogId":"kalaam-widgets-catalog","sendDataModel":true}}',
        '{"version":"v0.9","updateComponents":{"surfaceId":"m2","components":['
            '{"id":"root","component":"MasteryRing","sessionTitle":"Ordering Coffee in Cairo","wordsEncountered":8,"exercisesCompleted":5,"correctAnswers":4,"masteryPercent":{"path":"/progress/mastery"},"streakDays":3,"topWords":["قَهْوَة"]}'
            ']}}',
        '{"version":"v0.9","updateDataModel":{"surfaceId":"m2","path":"/progress/mastery","value":45}}',
        '{"version":"v0.9","updateDataModel":{"surfaceId":"m2","path":"/progress/mastery","value":80}}',
      ], readPath: '/progress/mastery');
      expect(r.def?.components['root']?.type, 'MasteryRing');
      expect(r.errors, isEmpty, reason: r.errors.join('\n'));
      // The model-pushed data loop actually landed in the data model.
      expect(r.value, 80);
    });
  });
}
