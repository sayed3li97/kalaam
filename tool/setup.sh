#!/usr/bin/env bash
# One-shot dev setup for Kalaam. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶ flutter pub get"
flutter pub get

echo "▶ code generation (riverpod / freezed)"
dart run build_runner build --delete-conflicting-outputs

if [ ! -f lib/firebase_options.dart ]; then
  echo
  echo "⚠  No lib/firebase_options.dart yet. Choose one:"
  echo "   • Keyless Demo Mode (no Firebase):"
  echo "       cp lib/firebase_options.dart.example lib/firebase_options.dart"
  echo "       flutter run --dart-define=KALAAM_DEMO=true"
  echo "   • Live (your own Firebase + Gemini Developer API):"
  echo "       dart pub global activate flutterfire_cli && flutterfire configure"
  echo
else
  echo "✓ lib/firebase_options.dart present."
fi

echo "✓ Setup complete."
echo "  Demo:  flutter run --dart-define=KALAAM_DEMO=true"
echo "  Live:  flutter run"
