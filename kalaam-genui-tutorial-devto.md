---
title: "Flutter GenUI SDK: Build AI-Generated UIs from Scratch (Complete Beginner Tutorial 2026)"
published: false
description: "Step-by-step beginner tutorial: build real-time AI-generated Flutter widget trees using the GenUI SDK, Gemini, and custom CatalogItems. No prior AI experience needed."
tags: flutter, dart, beginners, ai
series: Flutter GenUI SDK
cover_image: https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/tutorial_cover.png
---

Picture this. You open a language learning app. A Gemini model reads that you have been struggling with Arabic verb conjugation, and in under two seconds it assembles a bespoke lesson: a cultural scene-setter card, a triliteral root diagram showing every word in the family, a drag-and-drop vowel placement exercise, then a conjugation table. None of those screens were pre-designed. No developer wired them together for this session. The interface was composed at runtime, by the model itself, for you.

That app is [Kalaam · كلام](https://github.com/sayed3li97/kalaam), and the technology making it possible is the **Flutter GenUI SDK**.

![Kalaam home screen — type a learning goal or pick a real-world Arabic scenario](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/gif_home.gif)
_Kalaam's home screen: type any learning goal ("bargaining in a Cairo market"), or pick a pre-built real-world scenario. The rest — every widget, every step — is assembled live by Gemini._

This tutorial is your complete beginner's guide to building exactly this kind of app. By the end you will understand the five core concepts behind GenUI, you will have written your first custom widget the model can compose, and you will have a working open-source reference — Kalaam's full codebase — to study whenever you need to go deeper.

No prior AI experience required. You need to know Flutter basics: widgets, `StatefulWidget`, `pubspec.yaml`. That is enough.

---

## What Is Flutter GenUI? The Real Explanation

Most Flutter tutorials teach you to build a fixed UI. You define your widget tree, you compile it, and the app ships that exact structure to every user. The AI might power a search bar or a recommendation feed, but the interface itself is still pre-designed by a human developer.

GenUI flips that model. Instead of the developer defining the UI, the developer defines a **vocabulary of widgets**, and an AI model decides which widgets to assemble, in which order, with which data, based on what the user needs right now.

The Flutter GenUI SDK (`genui` on pub.dev, version 0.9.2, published by `labs.flutter.dev`) is the official Flutter implementation of the A2UI v0.9 protocol. Announced at Google I/O 2026 alongside Flutter 3.44, it gives you the scaffolding to build apps where Gemini authors the UI at runtime.

Here is the key insight that most explanations miss: **the SDK does not call Gemini for you**. It does not know about Firebase, API keys, or networking. What it does is:

1. Take your catalog of widget definitions and embed their schemas into the Gemini system prompt, so the model knows what widgets it can create and what properties each one accepts.
2. Parse the structured JSON Gemini streams back and turn it into live Flutter widgets, progressively, before the full response arrives.
3. Keep a reactive data model that widgets can bind to, so the AI can push state updates without rebuilding the whole screen.

The AI writes the layout spec. The SDK renders it. You write the widgets.

![Live GenUI Inspector — watch Gemini compose the Flutter widget tree token by token](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/gif_inspector.gif)
_Tap the `{}` button and watch Gemini write your UI in real time. Every field in that JSON panel became a widget on screen above it._

> **Alpha warning:** GenUI is marked "highly experimental" by the Flutter team. Pin to `^0.9.2` (not `any`) in your `pubspec.yaml` and subscribe to the [CHANGELOG on GitHub](https://github.com/flutter/genui/blob/main/CHANGELOG.md). APIs will change between minor versions. Build something real with it today, but expect to update call sites when new versions land.

---

## The A2UI Protocol: What Is Actually Happening Under the Hood

Every existing GenUI tutorial treats the JSON protocol as a black box. Open it once and the entire SDK becomes obvious.

When your app sends a message to Gemini, the model does not respond with plain text. Because of the system prompt GenUI generates, it responds with structured JSON messages following the A2UI v0.9 wire format. These messages tell the SDK what to render. There are four types.

**`createSurface`** — Gemini is creating a new UI area (think: a new step in your lesson).

```json
{
  "type": "createSurface",
  "surfaceId": "turn_1",
  "components": [
    {
      "id": "root_explorer_1",
      "component": "RootExplorer",
      "rootWord": "ك-ت-ب",
      "rootMeaning": "to write",
      "family": [
        {
          "word": "كَتَبَ",
          "transliteration": "kataba",
          "meaning": "he wrote",
          "pattern": "فَعَلَ"
        }
      ]
    }
  ]
}
```

**`surfaceUpdate`** — Gemini is modifying an existing surface in place. No screen rebuild, no transition.

```json
{
  "type": "surfaceUpdate",
  "surfaceId": "turn_1",
  "components": [
    {
      "id": "feedback_text",
      "component": "Text",
      "content": "Correct! كَتَبَ follows the فَعَلَ pattern."
    }
  ]
}
```

**`dataModelUpdate`** — Gemini is pushing new state to the reactive data store. Any widget bound to that path rebuilds automatically.

```json
{
  "type": "dataModelUpdate",
  "updates": {
    "learner/accuracy": 0.82,
    "session/wordsCorrect": 7
  }
}
```

**`deleteSurface`** — Remove a surface when a lesson step is done.

```json
{
  "type": "deleteSurface",
  "surfaceId": "turn_1"
}
```

Those four messages are everything GenUI understands. The SDK's job is to listen to Gemini's stream, parse these messages as tokens arrive (before the full response is complete), and apply them to the widget tree. Now that you know what is happening at the wire level, every class in the SDK makes immediate sense.

![Kalaam's Live GenUI Inspector showing a CREATE turn_2 message with full A2UI JSON](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/inspector.png)
_Kalaam's Live Inspector mid-lesson. The `CREATE turn_2` badge on the left is a `createSurface` message. The fields below it — `"version": "v0.9"`, `"surfaceId": "turn_2"` — are the start of the Root Explorer component JSON. The Root Explorer you see rendered above the panel is what those fields became._

---

## The 8-Step Interaction Cycle

Every interaction in a GenUI app follows the same loop:

1. User types or taps something
2. Your app calls `conversation.sendRequest(content)`
3. `Conversation` triggers `A2uiTransportAdapter`'s `onSend` callback
4. Your callback calls Gemini and pipes each streaming token to `_transport.addChunk(chunk)`
5. `A2uiParserTransformer` parses the streaming JSON in real time
6. Parsed `A2uiMessage` objects feed into `SurfaceController.handleMessage()`
7. `SurfaceController` updates the `DataModel` and its `Surface` widgets rebuild
8. User taps a generated widget, `UserActionEvent` is dispatched, `SurfaceController.onSubmit` emits, `Conversation` wraps it as a new user turn, and the cycle restarts from step 2

Every API call you will make maps to one step in this loop. Keep the cycle in mind as you read the sections below.

```plaintext
User input
    │
    ▼
conversation.sendRequest()
    │
    ▼
A2uiTransportAdapter.onSend  ──────►  Gemini API (your code)
                                              │ streams chunks
    ◄─────────────────────────────────────────┘
    │
    ▼
A2uiTransportAdapter.addChunk()
    │  (parses streaming JSON)
    ▼
SurfaceController.handleMessage()
    │
    ├─► createSurface   ──► Surface widget added to screen
    ├─► surfaceUpdate   ──► Surface widget updated in place
    ├─► dataModelUpdate ──► Bound widgets rebuild automatically
    └─► deleteSurface   ──► Surface widget removed
    │
    ▼ (user taps generated widget)
UserActionEvent ──► conversation.sendRequest() ──► loop restarts
```

---

## Prerequisites and Project Setup

Before writing any GenUI code, confirm you have:

- Flutter 3.44+ (run `flutter --version` to check)
- Dart 3.9+
- A Firebase project with [AI Logic enabled](https://firebase.google.com/docs/ai-logic/get-started) — Gemini Developer API is on the free tier
- The `flutterfire_cli` tool: `dart pub global activate flutterfire_cli`

### Install the dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  genui: ^0.9.2
  firebase_core: ^3.10.0
  firebase_ai: ^2.5.0
  json_schema_builder: ^0.2.0
```

Run `flutter pub get`.

### Configure Firebase

Run `flutterfire configure` and follow the prompts. It generates `lib/firebase_options.dart`. This file contains your app's credentials and must never be committed. Add these lines to `.gitignore` right now:

```plaintext
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

### iOS and macOS network entitlement (a step almost every tutorial skips)

If you target iOS or macOS, your app will silently fail to reach Gemini without this entitlement. Add it once and forget about it.

In `ios/Runner/Runner.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

In `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

### Initialize Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## The Five Core Concepts You Must Understand

### 1. CatalogItem — Defining What the AI Can Build

A `CatalogItem` is the fundamental unit of GenUI. It tells the SDK (and therefore Gemini) that a widget named `X` exists, what JSON properties it accepts, and how to render it as a Flutter widget.

Here is a minimal but complete example — a simple Arabic flashcard:

```dart
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final flashcardItem = CatalogItem(
  name: 'ArabicFlashcard',
  dataSchema: S.object(
    properties: {
      'arabic': S.string(description: 'Arabic word with full diacritics'),
      'transliteration': S.string(description: 'Romanised pronunciation'),
      'meaning': S.string(description: 'English translation'),
    },
    required: ['arabic', 'transliteration', 'meaning'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "card_1",
    "component": "ArabicFlashcard",
    "arabic": "كَتَبَ",
    "transliteration": "kataba",
    "meaning": "he wrote"
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data['arabic'] as String? ?? '',
              style: const TextStyle(fontSize: 32),
            ),
            Text(data['transliteration'] as String? ?? ''),
            Text(data['meaning'] as String? ?? ''),
          ],
        ),
      ),
    );
  },
);
```

Three things are happening here, and all three matter.

**`dataSchema`** defines the JSON the model must provide when it wants to create this widget. The `json_schema_builder` package gives you a type-safe DSL (`S.object`, `S.string`, `S.list`, `S.boolean`) for writing JSON Schema. GenUI embeds this schema into the system prompt so Gemini knows which fields are valid and required.

**`exampleData`** contains one or more example JSON snippets. GenUI uses these as few-shot examples in the system prompt, teaching the model the correct format by demonstration rather than by description alone. This is the single biggest lever for getting consistent, valid output from the model. A good example is worth more than a detailed description.

**`widgetBuilder`** is the Flutter side. It receives a `CatalogItemContext` containing `ctx.data` (the parsed JSON), `ctx.dataContext` (access to the reactive data model), and `ctx.dispatchEvent(...)` (to send user interactions back to Gemini). Return any Flutter widget. Keep `mainAxisSize: MainAxisSize.min` on columns and rows — GenUI embeds your widget inside a dynamically-sized surface, and unbounded height constraints will crash it.

Here is what a real `CatalogItem` looks like rendered — Kalaam's Root System Explorer, generated from a single `RootExplorer` component in a `createSurface` message:

![Root System Explorer — all nodes collapsed, ش-ر-ب root with five derived words radiating outward](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/root_explorer.png)
_Every node, connector line, and label comes from the JSON Gemini provided in the `createSurface` message. The `widgetBuilder` turns that JSON into this radial diagram._

### 2. Catalog — Grouping Your CatalogItems

A `Catalog` is a named collection of `CatalogItem`s. You combine your custom items with the built-in primitives:

```dart
final appCatalog = Catalog(
  items: [
    flashcardItem,
    ...BasicCatalogItems.all(),
  ],
);
```

`BasicCatalogItems.all()` gives you 17 built-in widgets for free: `Button`, `Column`, `Row`, `Card`, `Text`, `TextField`, `AudioPlayer`, `Tabs`, `List`, `Image`, `Icon`, `Divider`, `Slider`, `ChoicePicker`, `CheckBox`, `DateTimeInput`, and `Modal`. Gemini can use both your custom widgets and the primitives in the same layout. A single `createSurface` message might compose a `Column` containing an `ArabicFlashcard` followed by a `Button`.

Kalaam exposes a combined catalog of all 13 custom Arabic teaching widgets plus all built-in primitives, defined in [`lib/features/session/catalog/catalog.dart`](https://github.com/sayed3li97/kalaam/blob/main/lib/features/session/catalog/catalog.dart).

### 3. SurfaceController — The Runtime Engine

`SurfaceController` is the brain of a GenUI session. It processes incoming `A2uiMessage` objects, manages the reactive `DataModel`, and broadcasts events when the user interacts with generated widgets.

```dart
final controller = SurfaceController(catalogs: [appCatalog]);
```

The `Surface` widget renders whatever the model has built for a given surface ID:

```dart
Surface(
  host: controller,
  surfaceId: 'turn_1',
)
```

`Surface` listens to `SurfaceController` and rebuilds whenever Gemini sends a `surfaceUpdate` or `dataModelUpdate` for that surface ID. You do not manage this rebuild yourself.

### 4. A2uiTransportAdapter — The Streaming Bridge

`A2uiTransportAdapter` bridges the gap between raw LLM token chunks and parsed `A2uiMessage` objects. You create it with an `onSend` callback that fires whenever `Conversation` wants to send a message to Gemini:

```dart
final transport = A2uiTransportAdapter(
  onSend: (List<Content> messages) async {
    final stream = _model.generateContentStream(messages);
    await for (final chunk in stream) {
      transport.addChunk(chunk.text ?? '');
    }
    transport.finishSending();
  },
);
```

Every token from Gemini passes through `transport.addChunk()`. The adapter parses the streaming JSON incrementally and emits complete `A2uiMessage` objects as soon as they are parseable. This is why surfaces appear progressively as Gemini generates them, not all at once when the full response arrives.

Note that `transport.incomingMessages` is a stream of `A2uiMessage` objects you can tap independently for logging or inspection. Kalaam uses this to power its Live GenUI Inspector.

### 5. Conversation — The Top-Level Facade

`Conversation` wires `SurfaceController` and `A2uiTransportAdapter` together and manages conversation history. It is the only object your UI layer needs to hold:

```dart
final conversation = Conversation(
  controller: controller,
  transport: transport,
);
```

Send a user message:

```dart
await conversation.sendRequest(Content.user('teach me the root ك-ت-ب'));
```

`Conversation` builds the full `List<Content>` history (all prior turns) and passes it to your `onSend` callback, so Gemini always has the full context.

---

## Building Your First GenUI App Step by Step

Here is what the finished app looks like: a Gemini-composed lesson flowing from a vocab carousel through the Root System Explorer, with the QuickChoice quiz at the end.

![Full Kalaam session flow — home screen to vocab carousel to Root Explorer to quiz, all UI composed by Gemini at runtime](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/gif_session_flow.gif)
_Home screen → Begin lesson → VocabCarousel → Root System Explorer → QuickChoice quiz. None of these transitions were pre-wired — Gemini assembled them from the catalog._

Let's put all five concepts together. This is a minimal, complete, runnable example.

### Step 1: Create the catalog

```dart
// lib/catalog.dart
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final infoCardItem = CatalogItem(
  name: 'InfoCard',
  dataSchema: S.object(
    properties: {
      'title': S.string(description: 'Card heading'),
      'body': S.string(description: 'Card body text'),
    },
    required: ['title', 'body'],
  ),
  exampleData: [
    () => '''
[{"id":"c1","component":"InfoCard","title":"Hello","body":"GenUI is working."}]
''',
  ],
  widgetBuilder: (ctx) {
    final d = ctx.data as Map<String, Object?>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d['title'] as String? ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(d['body'] as String? ?? ''),
          ],
        ),
      ),
    );
  },
);

final appCatalog = Catalog(
  items: [infoCardItem, ...BasicCatalogItems.all()],
);
```

### Step 2: Wire the session screen

```dart
// lib/session_screen.dart
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'catalog.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final GenerativeModel _model;

  final _textController = TextEditingController();
  final List<String> _surfaceIds = [];
  bool _waiting = false;

  @override
  void initState() {
    super.initState();

    _controller = SurfaceController(catalogs: [appCatalog]);

    // Track new surfaces so we can render them
    _controller.surfaces.listen((surfaces) {
      setState(() {
        _surfaceIds
          ..clear()
          ..addAll(surfaces.keys);
      });
    });

    // Build system prompt from catalog
    final systemPrompt =
        PromptBuilder.chat(catalog: appCatalog).systemPromptJoined();

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(systemPrompt),
    );

    _transport = A2uiTransportAdapter(
      onSend: _sendToGemini,
    );

    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );
  }

  Future<void> _sendToGemini(List<Content> messages) async {
    setState(() => _waiting = true);
    try {
      final stream = _model.generateContentStream(messages);
      await for (final chunk in stream) {
        _transport.addChunk(chunk.text ?? '');
      }
    } catch (e) {
      // Show an error banner in your UI here
    } finally {
      _transport.finishSending();
      if (mounted) setState(() => _waiting = false);
    }
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _conversation.sendRequest(Content.user(text));
  }

  @override
  void dispose() {
    _conversation.dispose();
    _transport.dispose();
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GenUI Demo')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _surfaceIds.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Surface(
                  host: _controller,
                  surfaceId: _surfaceIds[i],
                ),
              ),
            ),
          ),
          if (_waiting) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration:
                        const InputDecoration(hintText: 'Ask Gemini...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Type "show me an info card about Flutter" and Gemini creates an `InfoCard` surface. Type "update it to be about Dart" and Gemini sends a `surfaceUpdate` modifying the same surface in place. The AI is composing and mutating your widget tree.

> **PromptBuilder token count:** the system prompt GenUI generates from your catalog is large — typically 3,000 to 5,000 tokens, depending on how many catalog items and how detailed your schemas are. Every message to Gemini includes this full prompt. Plan for it in your cost estimates. Very small or local models will not have sufficient context window or instruction-following capability to handle it. To reduce token count, use `PromptBuilder.custom()` with a hand-written prompt, or pass only essential extra instructions via `systemPromptFragments`.

---

## Custom CatalogItem Deep Dive: The Root System Explorer

The `InfoCard` above is easy to follow. Kalaam's `RootExplorer` — a radial diagram of Arabic root words — is a production example showing how far you can push a single `CatalogItem`.

Look at the schema alone:

```dart
final rootExplorerItem = CatalogItem(
  name: 'RootExplorer',
  dataSchema: S.object(
    properties: {
      'rootWord': S.string(
        description: 'The triliteral root, letters joined by dashes, e.g. ك-ت-ب',
      ),
      'rootMeaning': S.string(
        description: 'Core meaning of the root in English',
      ),
      'family': S.list(
        description: 'Derived words that share this root',
        minItems: 3,
        maxItems: 7,
        items: S.object(
          properties: {
            'word': S.string(description: 'Derived word with full harakat'),
            'transliteration': S.string(description: 'Romanised pronunciation'),
            'meaning': S.string(description: 'English meaning'),
            'pattern': S.string(
              description: 'Morphological pattern (wazn), e.g. فَعَلَ, مَفْعَل, فَاعِل',
            ),
            'isExpanded': S.boolean(
              description: 'DataModel-bound, false initially',
            ),
          },
          required: ['word', 'transliteration', 'meaning'],
        ),
      ),
    },
    required: ['rootWord', 'rootMeaning', 'family'],
  ),
  // ... widgetBuilder renders the radial diagram
);
```

Three patterns here that apply to any production `CatalogItem`:

**Nested schemas for arrays.** `S.list(items: S.object(...))` lets you define complex nested structures. Gemini learns to produce the entire `family` array with all sub-fields from a single example, without any additional instruction. The schema and the example together are the full specification.

**DataModel binding hints in descriptions.** The `isExpanded` field description says "DataModel-bound, false initially." This is a hint to Gemini that it can send a `dataModelUpdate` targeting this field's path to expand or collapse specific nodes without rebuilding the surface. The description field in your schema is part of the model's instruction set.

**Passing `ctx` down the widget tree.** The `widgetBuilder` passes `CatalogItemContext` to child widgets. The individual radial nodes use `ctx.dataContext` for binding and `ctx.dispatchEvent(...)` for the Explore button. Keep `ctx` accessible throughout every level of your widget tree that needs to interact with GenUI.

The full 498-line implementation lives at [`lib/features/session/catalog/items/root_explorer_item.dart`](https://github.com/sayed3li97/kalaam/blob/main/lib/features/session/catalog/items/root_explorer_item.dart).

Here is that same widget with a node tapped — the `isExpanded` DataModel path flipped to `true`, revealing the وزن pattern badge and Explore button without any surface rebuild:

![Root System Explorer node expanded — showing وزن مَفْعُول badge and Explore arrow button](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/gif_node_expand.gif)
_Tapping مَشْرُوب expands it to reveal its morphological pattern (وزن مَفْعُول) and an Explore→ button that asks Gemini to branch deeper into that word. The animation is an `AnimatedContainer` reacting to local state — no GenUI rebuild needed._

---

## DataModel Binding with `A2uiSchemas.stringReference`

The DataModel is where GenUI starts to feel like magic. Gemini writes to it with `dataModelUpdate` messages and your widgets react automatically — no `setState`, no `StreamBuilder` wiring on your part.

Kalaam's `QuickChoice` widget (multiple-choice quiz) uses a more advanced binding pattern than `S.boolean`: `A2uiSchemas.stringReference`. This tells Gemini that a field is not a static value but a live DataModel path it can write to:

```dart
final quickChoiceItem = CatalogItem(
  name: 'QuickChoice',
  dataSchema: S.object(
    properties: {
      'question': A2uiSchemas.stringReference(
        description: 'The multiple choice question',
      ),
      'options': S.list(
        description: 'Array of 4 options',
        minItems: 4,
        maxItems: 4,
        items: S.object(
          properties: {
            'id': S.string(description: 'Option identifier (A, B, C, or D)'),
            'text': S.string(description: 'Option content text'),
          },
          required: ['id', 'text'],
        ),
      ),
      'correctId': S.string(description: 'The correct option ID'),
      'selectedId': A2uiSchemas.stringReference(
        description: 'DataModel-bound chosen option ID',
      ),
      'explanationOnWrong': A2uiSchemas.stringReference(
        description: 'Explanation shown if user chooses wrong answer',
      ),
    },
    required: ['question', 'options', 'correctId', 'explanationOnWrong'],
  ),
```

The `selectedId` field is declared as a `stringReference`. When Gemini creates the surface it provides a DataModel path like `session/quiz_1/selected`. When the user taps an option, the widget writes the option ID to that path. When Gemini wants to reveal the correct/incorrect state, it sends a `dataModelUpdate` with `session/quiz_1/selected = "B"` and the widget rebuilds automatically to show the result.

In the `widgetBuilder`, you consume a `stringReference` like this:

```dart
final selectedIdRef = data['selectedId'];
if (selectedIdRef is Map && selectedIdRef.containsKey('path')) {
  return BoundString(
    dataContext: ctx.dataContext,
    value: selectedIdRef,
    builder: (context, selectedId) {
      // Rebuild whenever Gemini sends dataModelUpdate for this path
      return _QuizWidget(selectedId: selectedId, ...);
    },
  );
}
```

`BoundString`, `BoundBool`, `BoundNumber`, and `BoundList` are all built into GenUI. They listen to the DataModel path and call their `builder` with the updated value whenever Gemini (or your own widget code) writes to that path.

This pattern — Gemini setting a path, a widget binding to it, and the widget reacting without any app-level `setState` — is the cleanest way to handle interactive state in GenUI apps. Kalaam uses it for quiz selection, mastery ring progress, and the expanded/collapsed state of each node in the Root Explorer.

![Root Explorer expanded node — isExpanded DataModel path flipped to true, revealing وزن badge](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/root_expanded.png)
_The expanded state is a DataModel-bound `BoundBool`. Gemini can expand or collapse any node mid-lesson by sending a `dataModelUpdate` — without touching the surface or rebuilding any other widget._

---

## Handling User Interactions with UserActionEvent

When a user taps a generated widget, you need to send that event back to Gemini so it can decide what to do next. `UserActionEvent` is the mechanism.

Kalaam centralises this in a small helper that every catalog item uses:

```dart
// lib/features/session/catalog/kalaam_actions.dart
import 'package:genui/genui.dart';

void sendKalaamAction(
  CatalogItemContext ctx,
  String actionName,
  Map<String, Object?> payload,
) {
  ctx.dispatchEvent(
    UserActionEvent(
      name: actionName,
      sourceComponentId: ctx.componentId,
      context: payload,
    ),
  );
}
```

The Root Explorer's Explore button uses it like this:

```dart
GestureDetector(
  onTap: () => sendKalaamAction(
    ctx,
    'explore_word',
    {'word': word, 'root': rootWord, 'meaning': meaning},
  ),
  child: const Text('Explore →'),
)
```

When the user taps, `SurfaceController.onSubmit` emits a `UserActionEvent`. `Conversation` wraps it as a `UiInteractionMessage` and sends it back to Gemini as the next user turn. Gemini receives the action name and payload as context and might respond by creating a new `VocabCard` surface for that specific word, or a `ConjugationTable` for its verb forms.

The event name (`'explore_word'`) is a contract. You define it in your system prompt fragments (to teach the model what actions exist), and you dispatch it from your widget. Keep names specific and documented.

Here is `UserActionEvent` in practice — the `QuickChoice` quiz widget dispatching a correct or incorrect answer, which causes Gemini to generate the next lesson surface:

![QuickChoice quiz interaction — incorrect answer highlights red, correct answer highlights green, explanation appears below](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/gif_quiz_interaction.gif)
_Tap "Tea" → red highlight (wrong). Correct answer "Coffee" turns green immediately. Gemini receives `{isCorrect: false}` and tailors the next turn._

---

## The Live GenUI Inspector: Watching Gemini Build the UI

One of the most instructive patterns in Kalaam is the Live GenUI Inspector — a slide-up panel that streams the raw A2UI JSON messages Gemini emits, displayed as pretty-printed text. It is not part of the SDK. It is ten lines of code using `_transport.incomingMessages`.

```dart
// In your service / state holder:
final a2uiLog = ValueNotifier<List<A2uiLogEntry>>([]);

late final StreamSubscription<A2uiMessage> _logSub;

// After creating _transport:
_logSub = _transport.incomingMessages.listen((message) {
  final entry = A2uiLogEntry(
    kind: message.type,           // createSurface | surfaceUpdate | etc.
    surfaceId: message.surfaceId,
    json: const JsonEncoder.withIndent('  ').convert(message.toJson()),
  );
  a2uiLog.value = [...a2uiLog.value, entry];
});
```

The inspector panel is a `ValueListenableBuilder` over this notifier:

```dart
ValueListenableBuilder<List<A2uiLogEntry>>(
  valueListenable: a2uiLog,
  builder: (context, logs, _) {
    return ListView.builder(
      reverse: true,
      itemCount: logs.length,
      itemBuilder: (_, i) => _LogTile(entry: logs[logs.length - 1 - i]),
    );
  },
)
```

This pattern has a purpose beyond debugging: it makes the GenUI data flow visible to other developers. The moment someone watches a `CREATE turn_2` badge appear and immediately sees the corresponding Root Explorer render on screen, the whole concept of AI-generated UI clicks. Kalaam ships this in production precisely for that reason.

Full implementation at [`lib/features/session/view/widgets/genui_inspector.dart`](https://github.com/sayed3li97/kalaam/blob/main/lib/features/session/view/widgets/genui_inspector.dart).

![Live GenUI Inspector streaming — CREATE turn_2 badge appearing as Gemini assembles the Root Explorer widget](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/gif_inspector_stream2.gif)
_The Inspector streaming A2UI JSON alongside the live lesson. The `CREATE turn_2` badge marks the Root Explorer surface. Every field you see was streamed token by token from Gemini._

---

## Debugging GenUI Apps

### Enable SDK logging

The `configureLogging()` function is your most powerful debugging tool. Add it before `runApp`:

```dart
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';

void main() async {
  final logger = configureLogging(level: Level.ALL);
  logger.onRecord.listen((record) {
    debugPrint('[genui] ${record.level.name}: ${record.message}');
  });
  // ...
}
```

With `Level.ALL` you see each raw JSON chunk as it arrives, when the parser detects a new message type, when `SurfaceController` creates or updates a surface, DataModel path updates, and any parse errors with the offending fragment. Drop to `Level.INFO` in release builds.

### Inspect the generated system prompt

Run this once to understand what the model sees and why prompt token count matters:

```dart
final prompt = PromptBuilder.chat(catalog: appCatalog).systemPromptJoined();
debugPrint('Prompt length: ${prompt.length} chars');
debugPrint('Token estimate: ${prompt.length ~/ 4}');
debugPrint(prompt);
```

### Common errors and fixes

| Symptom | Most likely cause | Fix |
|---|---|---|
| Surfaces never appear | `onSend` not calling `_transport.addChunk()` on every chunk | Verify your `await for` loop reaches every streamed token |
| iOS/macOS network fails silently | Missing `com.apple.security.network.client` | Add the entitlement to both Debug and Release entitlement files |
| Gemini returns plain text | System prompt not passed to the model | Confirm `systemInstruction: Content.system(systemPrompt)` is in `generativeModel(...)` |
| `setState called after dispose` | Listening to `_controller.surfaces` without canceling | Store the `StreamSubscription` and cancel it in `dispose()` |
| Widget renders blank | `ctx.data` type mismatch | Cast with explicit null fallback: `ctx.data as Map<String, Object?>? ?? {}` |
| Layout overflow | Custom widget using `Expanded` or unbounded height | Use `mainAxisSize: MainAxisSize.min` on all `Column`/`Row` widgets inside catalog items |

---

## Kalaam as a Production Reference

Everything covered in this tutorial appears at production scale in [Kalaam · كلام](https://github.com/sayed3li97/kalaam). Here is the map:

| Concept | Kalaam location |
|---|---|
| 13 custom `CatalogItem`s | `lib/features/session/catalog/items/` |
| Combined catalog (custom + primitives) | `lib/features/session/catalog/catalog.dart` |
| `SurfaceController` + `Conversation` wiring | `lib/shared/services/ai_session_service.dart` |
| `A2uiTransportAdapter` with logging tap | `lib/shared/services/ai_session_service.dart:61` |
| Live GenUI Inspector | `lib/features/session/view/widgets/genui_inspector.dart` |
| `UserActionEvent` helper | `lib/features/session/catalog/kalaam_actions.dart` |
| DataModel binding with `BoundBool` | `lib/features/session/catalog/items/root_explorer_item.dart:295` |
| System prompt with pedagogy fragments | `lib/features/session/prompt/kalaam_prompt.dart` |
| Demo Mode (no credentials) | `lib/features/session/demo/kalaam_demo.dart` |
| Architecture overview | `docs/ARCHITECTURE.md` |

![Kalaam widget catalog — VocabCarousel showing full Arabic diacritics with IPA and English](https://raw.githubusercontent.com/sayed3li97/kalaam/main/assets/screenshots/vocab_carousel.png)
_One of Kalaam's 13 custom `CatalogItem`s: the `VocabCarousel`. Gemini picks which words go in the deck, the widget renders them with full diacritics, transliteration, and example sentences._

Clone it, run it in Demo Mode (`flutter run --dart-define=KALAAM_DEMO=true`), and open the Live GenUI Inspector. Watch the A2UI JSON stream as you interact with the lesson. That transparency is intentional — Kalaam was built to make the GenUI programming model concrete.

---

## What's Next: genui_catalog and the Broader A2UI Ecosystem

Once you have built your first custom `CatalogItem`, you may not need to build everything from scratch. The `genui_catalog` package (version 0.3.0) ships 17 pre-built production components:

```yaml
dependencies:
  genui_catalog: ^0.3.0
```

Highlights: `KpiCard`, `DataTable`, `TimelineCard`, `ActionForm`, `ProfileCard`, `StepperCard`, `SearchBar`, `ChartCard`. For dashboards, data apps, or form-heavy interfaces, this package saves significant time. For domain-specific apps like Kalaam, custom `CatalogItem`s are still irreplaceable — no generic primitive approximates a radial Arabic root diagram.

The A2UI protocol itself has ecosystem participants beyond Flutter. React, Angular, Lit, and several agent frameworks (AG2, Vercel json-renderer) implement the same wire format. A Flutter app using `genui` can talk to a Node.js backend agent using the same A2UI v0.9 protocol via the `genui_a2a` package.

For further reading:

- [Official Flutter GenUI docs](https://docs.flutter.dev/ai/genui) — the authoritative API reference
- [Google Codelabs: Build a GenUI App](https://codelabs.developers.google.com/codelabs/genui-intro) — interactive guided walkthrough
- [Kalaam on GitHub](https://github.com/sayed3li97/kalaam) — the production reference used throughout this tutorial, Apache-2.0

---

## What You Have Built

GenUI inverts the traditional app architecture. Instead of shipping a fixed screen for every state, you ship a vocabulary of widgets and let the model decide how to compose them. The Flutter GenUI SDK gives you the scaffolding to make that work: `CatalogItem` to define your vocabulary, `Catalog` to group it, `SurfaceController` as the runtime engine, `A2uiTransportAdapter` as the streaming bridge, and `Conversation` as the facade that ties it all together.

The A2UI protocol underneath is simple: four message types, a reactive data model, and a streaming JSON parser. Once you see those four messages — `createSurface`, `surfaceUpdate`, `dataModelUpdate`, `deleteSurface` — the entire SDK is predictable.

Kalaam applies this architecture to Arabic language learning with 13 custom teaching widgets, a bidirectional interaction loop, live DataModel binding for learner progress, and a transparent inspector so you can watch the model work. It is open source, fully documented, and built specifically to be the kind of reference this tutorial needed.

The next time someone asks what "AI-native" means in a mobile app, you have a concrete answer — and working code to show them.
