import 'dart:convert';

import 'package:kalaam/features/session/catalog/catalog.dart';

/// A curated, offline stand-in for Gemini, used in Demo Mode
/// (`--dart-define=KALAAM_DEMO=true`).
///
/// It returns the next turn as fenced ```json A2UI messages — the *same* wire
/// format the live model emits — which are fed verbatim into
/// [A2uiTransportAdapter.addChunk]. So Demo Mode exercises the real GenUI
/// pipeline (parser → SurfaceController → widgets) with no Firebase or API key;
/// it doubles as deterministic fixtures for CI and golden tests.
///
/// Each turn composes a multi-component layout (a `Text` intro + a custom Arabic
/// widget), mirroring how the live model is prompted to build lessons. Two turns
/// react to the learner's last action ([_phoneme] for a wrong answer, [_culture]
/// for a rude reply) to prove the loop is bidirectional. The finale pushes
/// `updateDataModel` to animate the mastery ring — the SDK's signature trick.
abstract final class KalaamDemo {
  /// Number of scripted turns before the lesson is complete.
  static const int turnCount = 11;

  /// Returns the A2UI for [turn], or null when the lesson is over. [action] is
  /// the decoded `action` object from the learner's last interaction (or null).
  static String? responseFor(int turn, Map<String, Object?>? action) {
    final ctx = action?['context'] as Map<String, Object?>?;
    return switch (turn) {
      0 => _scene(turn),
      1 => _vocab(turn),
      2 => _root(turn),
      3 => _quiz(turn),
      4 => _phoneme(turn, ctx),
      5 => _harakat(turn),
      6 => _conjugation(turn),
      7 => _dialogue(turn),
      8 => _culture(turn, ctx),
      9 => _review(turn),
      10 => _mastery(turn),
      _ => null,
    };
  }

  // --- turns ---------------------------------------------------------------

  static String _scene(
    int t,
  ) => _layout(t, "Let's order coffee in a Cairo ahwa.", {
    'component': 'SceneCard',
    'scenarioTitle': 'Ordering Coffee in Cairo',
    'settingDescription':
        'A bustling ahwa at dawn — cardamom in the air, an al-Ahly match on the TV.',
    'targetLanguage': 'Arabic',
    'difficultyLevel': 'Beginner',
    'emoji': '☕',
  });

  static String _vocab(int t) => _layout(t, 'First, the words you need:', {
    'component': 'VocabCarousel',
    'sectionTitle': 'Words for ordering coffee',
    'items': [
      _word(
        'قَهْوَة',
        'qahwa',
        '/ˈqah.wa/',
        'coffee',
        'أُرِيدُ قَهْوَةً',
        'I want coffee',
        'noun',
      ),
      _word(
        'مِنْ فَضْلِكَ',
        'min faḍlik',
        '/min ˈfad.lik/',
        'please',
        'قَهْوَةً مِنْ فَضْلِكَ',
        'A coffee, please',
        'phrase',
      ),
      _word(
        'شُكْرًا',
        'shukran',
        '/ˈʃuk.ran/',
        'thank you',
        'شُكْرًا جَزِيلًا',
        'Thank you very much',
        'phrase',
      ),
      _word(
        'سُكَّر',
        'sukkar',
        '/ˈsuk.kar/',
        'sugar',
        'بِدُونِ سُكَّر',
        'without sugar',
        'noun',
      ),
    ],
  });

  static String _root(int t) =>
      _layout(t, 'Most coffee words grow from one root, ش-ر-ب (to drink):', {
        'component': 'RootExplorer',
        'rootWord': 'ش-ر-ب',
        'rootMeaning': 'to drink',
        'family': [
          _fam('شَرِبَ', 'shariba', 'he drank', 'verb', 'فَعَلَ'),
          _fam('مَشْرُوب', 'mashrūb', 'a drink', 'noun', 'مَفْعُول'),
          _fam('شَارِب', 'shārib', 'a drinker', 'noun', 'فَاعِل'),
          _fam('مَشْرَب', 'mashrab', 'a place to drink', 'noun', 'مَفْعَل'),
        ],
      });

  static String _quiz(int t) => _layout(t, 'Quick check:', {
    'component': 'QuickChoice',
    'question': 'What does قَهْوَة mean?',
    'options': [
      {'id': 'A', 'text': 'Tea'},
      {'id': 'B', 'text': 'Coffee'},
      {'id': 'C', 'text': 'Water'},
      {'id': 'D', 'text': 'Juice'},
    ],
    'correctId': 'B',
    'selectedId': '',
    'explanationOnWrong':
        'قَهْوَة (qahwa) is coffee — the root of the English word.',
  });

  static String _phoneme(int t, Map<String, Object?>? ctx) {
    final wrong = ctx?['isCorrect'] == false;
    return _layout(
      t,
      wrong
          ? "Let's nail the tricky sound first."
          : 'Now polish the trickiest sound:',
      {
        'component': 'PhonemeCard',
        'phoneme': 'ق',
        'ipaNotation': '/q/',
        'mouthPositionDescription':
            'A deep "k" made far back against the uvula — not the soft English k.',
        'nativeExample': 'قَهْوَة',
        'nativeExampleTranslation': 'coffee',
        'challengeCount': 0,
        'masteryThreshold': 3,
      },
    );
  }

  static String _harakat(int t) =>
      _layout(t, 'Build the word by adding its vowels:', {
        'component': 'HarakatBuilder',
        'instruction': 'Vocalise qahwa (coffee)',
        'letters': ['ق', 'ه', 'و', 'ة'],
        'target': ['fatha', 'sukun', 'fatha', 'none'],
        'transliteration': 'qahwa',
        'translation': 'coffee',
      });

  static String _conjugation(int t) =>
      _layout(t, 'How "to drink" conjugates in the past:', {
        'component': 'ConjugationTable',
        'title': 'شَرِبَ — past tense',
        'headers': ['Pronoun', 'Arabic', 'Sound'],
        'rows': [
          {
            'cells': ['I', 'شَرِبْتُ', 'shribtu'],
          },
          {
            'cells': ['you (m)', 'شَرِبْتَ', 'shribta'],
          },
          {
            'cells': ['he', 'شَرِبَ', 'shariba'],
            'highlight': true,
          },
          {
            'cells': ['she', 'شَرِبَتْ', 'sharibat'],
          },
        ],
        'caption': 'Root ش-ر-ب on the فَعَلَ pattern',
      });

  static String _dialogue(int t) =>
      _layout(t, 'Your turn — the barista greets you:', {
        'component': 'DialogueBubble',
        'characterName': 'Barista',
        'characterLine': 'أَهْلًا! مَاذَا تُرِيدُ؟',
        'characterLineTranslation': 'Welcome! What would you like?',
        'userOptions': [
          {
            'id': 'A',
            'text': 'أُرِيدُ قَهْوَةً مِنْ فَضْلِكَ',
            'register': 'polite',
          },
          {'id': 'B', 'text': 'قَهْوَة.', 'register': 'rude'},
          {'id': 'C', 'text': 'لَحْظَة مِنْ فَضْلِكَ', 'register': 'neutral'},
        ],
        'selectedOptionId': '',
        'showTranslation': false,
      });

  static String _culture(int t, Map<String, Object?>? ctx) {
    final rude = ctx?['register'] == 'rude';
    if (rude) {
      return _layout(t, 'A note on tone:', {
        'component': 'CulturalNote',
        'title': 'Softening the Order',
        'body':
            'A bare "قَهْوَة" reads as abrupt in an ahwa, where warmth matters as much as the order.',
        'doThis': 'Add مِنْ فَضْلِكَ (please) and greet the garson.',
        'avoidThis': 'One-word demands — they sound curt.',
        'icon': '🫖',
      });
    }
    return _layout(t, 'A note on the ahwa:', {
      'component': 'CulturalNote',
      'title': 'Ordering in an Ahwa',
      'body':
          'Egyptian coffeehouses are social institutions; the garson remembers regulars and sitting means you will stay.',
      'doThis': 'Greet with أَهْلًا and make eye contact.',
      'avoidThis': 'Snapping fingers to call the waiter.',
      'icon': '🫖',
    });
  }

  static String _review(int t) => _layout(t, 'One more — review:', {
    'component': 'QuickChoice',
    'question': 'How do you say "please" (to a man)?',
    'options': [
      {'id': 'A', 'text': 'شُكْرًا'},
      {'id': 'B', 'text': 'أَهْلًا'},
      {'id': 'C', 'text': 'مِنْ فَضْلِكَ'},
      {'id': 'D', 'text': 'أُرِيدُ'},
    ],
    'correctId': 'C',
    'selectedId': '',
    'explanationOnWrong': 'مِنْ فَضْلِكَ (min faḍlik) is "please".',
  });

  /// Finale: create the mastery ring bound to /progress/mastery at 0, then push
  /// two `updateDataModel` messages so it animates to 80% WITHOUT rebuilding —
  /// the data-model feedback loop, visible in the Live GenUI Inspector.
  static String _mastery(int t) {
    final sid = 'turn_$t';
    final create = _msg({
      'createSurface': {
        'surfaceId': sid,
        'catalogId': kalaamCatalogId,
        'sendDataModel': true,
      },
    });
    final components = _msg({
      'updateComponents': {
        'surfaceId': sid,
        'components': [
          {
            'id': 'root',
            'component': 'MasteryRing',
            'sessionTitle': 'Ordering Coffee in Cairo',
            'wordsEncountered': 8,
            'exercisesCompleted': 5,
            'correctAnswers': 4,
            'masteryPercent': {'path': '/progress/mastery'},
            'streakDays': 3,
            'topWords': ['قَهْوَة', 'مِنْ فَضْلِكَ', 'شُكْرًا'],
          },
        ],
      },
    });
    final tick1 = _msg({
      'updateDataModel': {
        'surfaceId': sid,
        'path': '/progress/mastery',
        'value': 45,
      },
    });
    final tick2 = _msg({
      'updateDataModel': {
        'surfaceId': sid,
        'path': '/progress/mastery',
        'value': 80,
      },
    });
    return [create, components, tick1, tick2].join('\n\n');
  }

  // --- helpers -------------------------------------------------------------

  /// A standard turn: a fresh surface whose root is a Column of [intro] Text +
  /// the [widget] component.
  static String _layout(int t, String intro, Map<String, Object?> widget) {
    final sid = 'turn_$t';
    final create = _msg({
      'createSurface': {
        'surfaceId': sid,
        'catalogId': kalaamCatalogId,
        'sendDataModel': true,
      },
    });
    final components = _msg({
      'updateComponents': {
        'surfaceId': sid,
        'components': [
          {
            'id': 'root',
            'component': 'Column',
            'children': ['intro', 'main'],
          },
          {'id': 'intro', 'component': 'Text', 'text': intro, 'variant': 'h5'},
          {'id': 'main', ...widget},
        ],
      },
    });
    return '$create\n\n$components';
  }

  static String _msg(Map<String, Object?> body) =>
      '```json\n${jsonEncode({'version': 'v0.9', ...body})}\n```';

  static Map<String, Object?> _word(
    String w,
    String tr,
    String ipa,
    String en,
    String ex,
    String exEn,
    String pos,
  ) => {
    'word': w,
    'transliteration': tr,
    'ipa': ipa,
    'translation': en,
    'exampleSentence': ex,
    'exampleTranslation': exEn,
    'partOfSpeech': pos,
    'isFlipped': false,
  };

  static Map<String, Object?> _fam(
    String w,
    String tr,
    String m,
    String pos,
    String pattern,
  ) => {
    'word': w,
    'transliteration': tr,
    'meaning': m,
    'partOfSpeech': pos,
    'pattern': pattern,
    'isExpanded': false,
  };
}
