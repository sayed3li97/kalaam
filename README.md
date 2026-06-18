<div align="center">

# Kalaam · كلام

### An Arabic tutor whose UI is composed live by Gemini.

**Kalaam is a Flutter showcase for the [GenUI SDK](https://pub.dev/packages/genui) (A2UI v0.9).**  
There is no fixed lesson UI — a Gemini model *generates the interface at runtime*,  
assembling each step of an Arabic lesson from a catalog of widgets and adapting to  
what the learner does.

[![CI](https://github.com/sayed3li97/kalaam/actions/workflows/ci.yml/badge.svg)](https://github.com/sayed3li97/kalaam/actions/workflows/ci.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart)](https://dart.dev)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-40c4ff.svg)](https://pub.dev/packages/flutter_lints)

</div>

---

<div align="center">
<img src="assets/screenshots/demo.png" alt="A Kalaam lesson composed live by Gemini" width="280"/>
&nbsp;&nbsp;
<img src="assets/screenshots/root_explorer.png" alt="Arabic triliteral root explorer" width="280"/>
&nbsp;&nbsp;
<img src="assets/screenshots/widgets.png" alt="Custom Arabic teaching widgets" width="280"/>

*Left: a live Gemini-composed lesson · Centre: the root explorer · Right: custom Arabic widgets*
</div>

---

## What this is

Most apps ship a fixed screen for every state. Kalaam ships a **vocabulary of widgets** and lets the model decide what to render. Pick a scenario (or type a goal like *"bargaining in a Cairo market"*) and Gemini composes a multi-widget Arabic lesson in real time — scene-setters, flip-card vocab, the **triliteral-root diagram**, vowel-placement trainers, conjugation tables, quizzes, roleplay — reacting to each answer.

A built-in **Live GenUI Inspector** (`</>` button) streams the raw [A2UI](https://github.com/google/A2UI) JSON the model emits, so you can literally watch *"this JSON became that widget."*

## Why it's a GenUI showcase

| Capability | What Kalaam does |
|---|---|
| **Model builds the UI** | Gemini emits `createSurface` / `updateComponents` messages assembling `Column`, `Card`, `Button`… with custom Arabic widgets |
| **Bidirectional loop** | Every interactive widget dispatches a `UserActionEvent`; a wrong quiz triggers a targeted pronunciation drill |
| **Live data model** | Correct answers `updateDataModel`, animating the mastery ring *without rebuilding the screen* |
| **Streaming UI** | Surfaces appear as tokens arrive; the Inspector resolves JSON into typed widgets in real time |
| **13 custom widgets** | Each one a `CatalogItem` with a JSON schema the model learns to use |

## Widget catalog

> Kalaam exposes a **combined catalog** of genui primitives + custom Arabic widgets. Gemini picks and composes from both.

### Custom Arabic teaching widgets

| Widget | Purpose |
|---|---|
| `RootExplorer` | Radial diagram showing a triliteral root (ك-ل-م) with all its word-family branches; tap to expand with pattern (وزن) |
| `HarakatBuilder` | Consonant skeleton + vowel palette; learner places diacritics letter by letter and sees the word re-render live |
| `ConjugationTable` | Pronoun × form grid (past/present, verb forms I–X); tap a cell for TTS + explanation |
| `VocabCard` | Flip card — Arabic front, definition back, with root, example sentence, and audio |
| `VocabCarousel` | Swipeable deck of VocabCards for a vocabulary set |
| `SceneCard` | Illustrated scene-setter that anchors each new lesson context |
| `PhonemeCard` | Isolated phoneme with mouth diagram, IPA, example word, and audio |
| `DialogueBubble` | Roleplay conversation turn with speaker, Arabic text, transliteration, and translation |
| `CulturalNote` | Styled callout for cultural context and nuance |
| `MasteryRing` | Animated circular progress indicator driven by `updateDataModel` |
| `QuickChoice` | Multiple-choice quiz tile with immediate correct/incorrect feedback |
| `SentenceBuilder` | Drag-and-drop Arabic sentence assembly |
| `FillInTheBlank` | Cloze exercise with RTL-aware inline blanks |

### genui built-in primitives also available to the model

`Column` · `Row` · `Card` · `Text` · `Button` · `Icon` · `Divider` · `Image` · `ChoicePicker` · `TextField` · `Slider` · `Tabs` · `List` · `AudioPlayer`

---

## Run it

### Option A — Demo Mode (no Firebase, ~30 seconds)

The fastest way to see the showcase. Replays a curated lesson through the *real* GenUI pipeline — no API key, no backend.

```bash
git clone https://github.com/sayed3li97/kalaam.git
cd kalaam

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=KALAAM_DEMO=true
```

### Option B — Live Mode (Gemini composes in real time)

Bring your own Firebase project — **never** use someone else's credentials.

```bash
git clone https://github.com/sayed3li97/kalaam.git
cd kalaam

flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 1. Create a Firebase project at console.firebase.google.com
# 2. Enable: Build → AI Logic → Get started → Gemini Developer API (free tier)
# 3. Wire the config into this checkout:
dart pub global activate flutterfire_cli
flutterfire configure          # generates git-ignored firebase_options.dart

flutter run                    # live mode is the default
```

> [!IMPORTANT]
> **Secrets are git-ignored.** `lib/firebase_options.dart`, `google-services.json`, and
> `GoogleService-Info.plist` are excluded from version control — only `*.example` templates
> are tracked. Keep **[Firebase App Check](https://firebase.google.com/docs/app-check) on**
> and set a billing budget alert; the Gemini Developer API bills your project, so an
> unprotected key is abusable. See [SECURITY.md](SECURITY.md).

`tool/setup.sh` automates pub-get + codegen + flutterfire for you.

---

## How it works

```
 You ─tap/answer─▶ UserActionEvent ─▶ SurfaceController.onSubmit
                                             │
                             ChatMessage(UiInteractionPart)
                                             ▼
       Gemini (firebase_ai)  ◀── system prompt + catalog schema + history
             │ streams A2UI JSON
             ▼
  A2uiTransportAdapter ─parse─▶ SurfaceController ─▶ Surface widgets (your UI)
             │                                             ▲
             └────────── a2uiLog ──▶ Live GenUI Inspector ─┘
```

- **System prompt** (`lib/features/session/prompt/`) teaches the model the A2UI wire format, how to compose multi-component layouts, and Arabic pedagogy.
- **Catalog** (`lib/features/session/catalog/`) = genui primitives + 13 custom widgets, each a `CatalogItem` with a JSON schema + a Flutter `widgetBuilder`.
- **Service** (`lib/shared/services/ai_session_service.dart`) owns the transport and the conversation loop.
- **Inspector** (`lib/features/session/view/widgets/genui_inspector.dart`) buffers every A2UI message the model emits and renders them as pretty-printed JSON in a slide-up panel.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the complete picture.

---

## Project structure

```
lib/
  core/
    config/            build-time flags (demo mode, model selection)
    constants/         surface IDs, scenario definitions, language constants
  shared/
    models/            Freezed immutable models (Language, Scenario, SessionState…)
    services/          ai_session_service.dart  ← the GenUI loop
    repositories/      progress persistence (shared_preferences)
    widgets/           reusable UI components (DuoButton, MainShell)
  features/
    home/              scenario picker + free-text goal entry
    progress/          progress tracking screen
    session/
      catalog/         ← the heart of the showcase
        items/         13 custom Arabic CatalogItems
        catalog.dart   combined catalog (primitives + custom)
        kalaam_actions.dart
      prompt/          Gemini system prompt (Arabic pedagogy + A2UI format)
      demo/            canned A2UI transcripts for Demo Mode
      view/
        session_screen.dart
        widgets/genui_inspector.dart   ← Live GenUI Inspector
assets/
  fonts/               Amiri (Arabic), IBM Plex Mono, IBM Plex Sans Arabic
  screenshots/
docs/
  ARCHITECTURE.md      layer diagram, data-flow, design decisions
test/
  kalaam_catalog_test.dart    catalog render + A2UI fixture tests
  progress_repository_test.dart
```

---

## Development

### Prerequisites

- Flutter ≥ 3.44.0 / Dart ≥ 3.9.0
- Xcode 16+ (iOS) or Android Studio (Android)
- For live mode: a Firebase project with Gemini Developer API enabled

### Running tests & analysis

```bash
dart format .                             # auto-format
flutter analyze --fatal-infos             # must be 0 issues
flutter test                              # run all tests
flutter test --coverage                   # with coverage report
```

### Code generation

After editing any `@riverpod` or `@freezed` annotated class:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### CI

GitHub Actions (`.github/workflows/ci.yml`) runs automatically on every push and PR:

1. **Format · Analyze · Test** (Ubuntu) — using placeholder Firebase config, no secrets needed
2. **Build Android APK** (Ubuntu, demo mode, keyless)
3. **Build iOS** (macOS, demo mode, no codesign)

---

## Contributing

PRs welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for setup steps, conventions, and the merge checklist. Security issues should follow [SECURITY.md](SECURITY.md). This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

**Adding a new catalog widget?**  
Use `lib/features/session/catalog/items/scene_card_item.dart` as the reference. Every `CatalogItem` needs a `dataSchema`, `exampleData`, and a `widgetBuilder`; interactive widgets dispatch via `sendKalaamAction`. Register it in `catalog.dart` and add a fixture in `test/kalaam_catalog_test.dart`.

---

## Acknowledgements

Built on the Flutter [`genui`](https://pub.dev/packages/genui) package and the [A2UI v0.9](https://github.com/google/A2UI) protocol.  
Arabic typography by [Amiri](https://github.com/alif-type/amiri) and [IBM Plex Arabic](https://github.com/IBM/plex).

---

## License

[Apache-2.0](LICENSE) © 2026 The Kalaam Authors.
