# Contributing to Kalaam

Thanks for your interest! Kalaam is a showcase for the Flutter GenUI SDK, and
contributions that make the demo clearer, more correct, or more accessible are
very welcome.

## Development setup

```bash
flutter --version           # 3.44+ / Dart 3.9+
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=KALAAM_DEMO=true     # no Firebase needed
```

For live mode (real Gemini) see the README → "Run it" → Option B. Never commit a
`firebase_options.dart`, `google-services.json`, or `GoogleService-Info.plist` —
they are git-ignored for a reason.

## Before you open a PR

Run the same gate CI runs:

```bash
dart format .
flutter analyze --fatal-infos        # must be clean
flutter test
```

- After editing any annotated (`@riverpod` / `@freezed`) file, re-run
  `dart run build_runner build --delete-conflicting-outputs`.
- Keep `flutter analyze` at **0 issues** — it is a merge gate.

## Conventions

- **Architecture:** feature-first folders; views render + watch providers only;
  business logic lives in view-models/services; see `docs/ARCHITECTURE.md`.
- **Adding a catalog widget?** Use `lib/features/session/catalog/items/scene_card_item.dart`
  as the reference; every `CatalogItem` needs a `dataSchema`, `exampleData`, and a
  `widgetBuilder`; interactive widgets must dispatch via `sendKalaamAction`. Keep schemas
  **permissive** (no `enumValues` on free-text/display fields) — over-strict schemas break
  whole turns. Register it in `catalog.dart` and add a render fixture in
  `test/kalaam_catalog_test.dart`.
- **Style:** `flutter_lints`; colors from `KalaamTheme` only; spacing via `Gap`; padding
  via `EdgeInsetsDirectional` (the app is RTL); logging via `dart:developer log()`.
- **Commits:** imperative mood, scoped (e.g. `catalog: relax RootExplorer schema`).
  A short PR description + the checklist in the PR template.

## Reporting bugs / proposing features

Open an issue with the appropriate template. For security, see [SECURITY.md](SECURITY.md).

By contributing you agree your contributions are licensed under [Apache-2.0](LICENSE).
