# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Keyless **Demo Mode** (`--dart-define=KALAAM_DEMO=true`) that replays curated A2UI
  transcripts through the real GenUI pipeline — clone-and-run with no Firebase.
- Live **data-model loop**: the mastery ring binds to `/progress/mastery` and animates
  on `updateDataModel` without rebuilding the screen.
- **Live GenUI Inspector** improvements: tap an A2UI message to flash the matching surface.
- Open-source scaffolding: LICENSE (Apache-2.0), README, CONTRIBUTING, SECURITY,
  CODE_OF_CONDUCT, CI, issue/PR templates, config templates.

### Changed
- Right-to-left + Arabic localization wired into `MaterialApp`.
- Catalog schemas relaxed (no over-strict enums) so the model's natural output never
  breaks a turn.

### Security
- Removed committed Firebase config from version control; only `*.example` templates are
  tracked. Added App Check.

## [0.1.0] — initial showcase
- Arabic GenUI tutor: Gemini composes lessons at runtime from a catalog of genui
  primitives + custom Arabic widgets (RootExplorer, HarakatBuilder, ConjugationTable, …).
